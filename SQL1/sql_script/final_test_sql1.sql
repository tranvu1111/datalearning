--cau 1
with cte1 as (
    SELECT p.category_id, o.customer_id, SUM(unit_price*quantity) total_spent            
    FROM orders o
    JOIN order_items oi
    ON o.order_id = oi.order_id
    JOIN products p
    ON oi.product_id = p.product_id
    GROUP BY p.category_id, o.customer_id 
    order BY p.category_id, total_spent DESC
    
), cte2 as (
    select category_id, customer_id , total_spent,
            rank() over(partition by category_id order by total_spent DESC) rank_
    from cte1

)
select pc.category_name, cust.name , total_spent, ct.phone
from cte2,
    product_categories pc,
    customers cust,
    contacts ct
where  1 = 1
    and cte2.rank_ = 1
    and pc.category_id = cte2.category_id 
    and cust.customer_id = cte2.customer_id
    and ct.customer_id = cust.customer_id;

--cau 2
with cte1 as (
    select o.customer_id
        ,p.product_id 
        ,sum(unit_price*quantity) total_spent
    from products p
        ,order_items oi
        ,orders o
    where 1 =1 
        and p.product_id = oi.product_id
        and o.order_id = oi.order_id
    group by o.customer_id, p.product_id
    order by o.customer_id
), cte2 as (
    select customer_id
        ,product_id 
        ,total_spent
        , row_number() over (partition by customer_id order by total_spent DESC) take_rank
    from cte1
)
select cust.name, cust.website, p.product_name , cte2.total_spent
from cte2 , products p , customers cust
where cte2.take_rank in (1,2,3)
    and cte2.customer_id = cust.customer_id
    and cte2.product_id = p.product_id;
    
    
    
--cau 3


with cte1 as (
    select p.category_id
    ,p.product_id
    ,sum(unit_price*quantity) total_revenue_per_product

    from order_items ot
    inner join products p on p.product_id = ot.product_id
    group by  p.category_id , p.product_id
    order by p.category_id , total_revenue_per_product desc
), cte2 as (
    select category_id
    ,product_id
    ,total_revenue_per_product
    ,sum(total_revenue_per_product) over(partition by category_id) total_revenue_per_category
    from cte1
), final_cte as (
    select pc.category_name
        ,p.product_name
        ,cte2.total_revenue_per_product
        ,cte2.total_revenue_per_category
        ,round((cte2.total_revenue_per_product/cte2.total_revenue_per_category)*100,2) || '%' as percentage_of_category
    from cte2
    inner join product_categories pc on cte2.category_id = pc.category_id
    inner join products p on cte2.product_id = p.product_id
),
total_row as (
    select
        'Total' as category_name,
        '' as product_name,
        null as total_revenue_per_product,
        sum(total_revenue_per_product) as total_revenue_per_category,
        '' as percentage_of_category
    from final_cte
)
select category_name
       ,product_name
       ,total_revenue_per_product
       ,total_revenue_per_category
       ,percentage_of_category
from final_cte
union all
select category_name
       ,product_name
       ,total_revenue_per_product
       ,total_revenue_per_category
       ,percentage_of_category
from total_row;
    
    
--cau4
with cte as (
    select extract( year from o1.order_date)  || '-'|| extract(month from o1.order_date) month_
            ,cust_info.full_name
            ,cust_info.phone
            ,o3.order_price
    from orders o1
        ,(select customer_id
                ,min(order_date) first_order_date
        from orders
        where status = 'Shipped'
        group by customer_id
        order by customer_id,first_order_date) o2
        ,(select o1.order_id
                ,sum(unit_price*quantity) order_price
         from order_items ot
         join orders o1
         on o1.order_id = ot.order_id
         group by o1.order_id ) o3
         ,(select c.customer_id
                ,ct.first_name ||' ' || ct.last_name full_name
                ,ct.phone
            from customers c
            join contacts ct
            on c.customer_id = ct.customer_id) cust_info
    where o1.customer_id = o2.customer_id
        and o1.order_date = o2.first_order_date
        and o1.order_id = o3.order_id
        and o1.customer_id = cust_info.customer_id
    order by o1.order_date

)select month_
        ,sum(order_price) 
from cte
group by month_
order by month_;


create or replace procedure take_first_order_infor
is
    cursor c1 is 
        select extract( year from o1.order_date)  || '-'|| extract(month from o1.order_date) month_
                ,cust_info.full_name
                ,cust_info.phone
                ,o3.order_price
        from orders o1
            ,(select customer_id
                    ,min(order_date) first_order_date
            from orders
            where status = 'Shipped'
            group by customer_id
            order by customer_id,first_order_date) o2
            ,(select o1.order_id
                    ,sum(unit_price*quantity) order_price
             from order_items ot
             join orders o1
             on o1.order_id = ot.order_id
             group by o1.order_id ) o3
             ,(select c.customer_id
                    ,ct.first_name ||' ' || ct.last_name full_name
                    ,ct.phone
                from customers c
                join contacts ct
                on c.customer_id = ct.customer_id) cust_info
        where o1.customer_id = o2.customer_id
            and o1.order_date = o2.first_order_date
            and o1.order_id = o3.order_id
            and o1.customer_id = cust_info.customer_id
        order by o1.order_date ;
    
    

    v_prior_month varchar2(10) := 0;
    v_month varchar2(10) ;
    total number:=0;
    index_tab number;

begin    
    for line_ in c1
        loop 
            v_month := line_.month_;
            if v_month <> v_prior_month then
                
                dbms_output.put_line(v_prior_month||  ' ' || total );
                v_prior_month := v_month;
                total:= 0 ;
                
             end if;   

                dbms_output.put_line(line_.month_ ||' ' || line_.full_name || ' ' ||line_.phone || ' ' || line_.order_price );
                total := total+ line_.order_price;
        end loop;
        dbms_output.put_line(v_prior_month||  ' ' || total );
end;
/      
set serveroutput on;
exec take_first_order_infor;

--cau5

create or replace procedure cust_dont_by_for_2months (input_date DATE)
is
begin
    for cust in (
        with cte as (
            select DISTINCT customer_id 
            from orders
            where status = 'Shipped'
                and order_date <= input_date
                and customer_id not in (select DISTINCT customer_id
                                        from orders
                                        where status = 'Shipped'
                                            and order_date >= add_months(input_date,-2)
                                            and order_date <= input_date
                                            )
        ) select first_name || ' '  || last_name full_name
                ,phone
        from contacts
        join cte
        on contacts.customer_id = cte.customer_id
    )
    loop 
        dbms_output.put_line(cust.full_name || ' '|| cust.phone);
        
    end loop;
end;
/
set serveroutput on;
exec cust_dont_by_for_2months(to_date('17-JUN-17'));