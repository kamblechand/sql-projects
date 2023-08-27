/*1. what is the total amount each customer spent on zomato?*/

select sales.userid,sum(product.price) from sales inner join product 
on sales.product_id=product.product_id
group by sales.userid;

/* how many days each customer visited zomato?*/
select * from users
select * from sales
select * from product

select userid ,count(created_date)from sales
group by userid
order by userid;

/*what is the first product purchased by each customer?*/
select * from(
select *,rank() over( partition by userid order by created_date) rnk from sales) a
where rnk=1;

/* what is the most purchased item on menu how many times it was purchased by each customers?*/
select userid,count(userid) from sales 
where product_id=
(select product_id  from sales
group by product_id
order by count(product_id) desc
limit 1)
group by userid;


/*which item was the most popular for each customer?*/
select * from (
select * ,rank() over(partition by userid order by cnt desc) rnk from
(select userid ,product_id,count(product_id) cnt from sales
group by userid,product_id)a)b
where rnk=1;

/*which item was first purchased by the  customer after they became member?*/

select * from
(select c.*,rank() over(partition by userid order by created_date) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date)c)b
where rnk=1;

--what is the total order and amount spent by each customers before they become member?
select userid,count(product_id),sum(price) as sums from
(select sales.userid ,sales.product_id,product.price from product inner join sales
on product.product_id=sales.product_id inner join goldusers_signup on sales.userid=goldusers_signup.userid 
where created_date<=gold_signup_date)e
group by userid
order by userid;

--Q8).if buying each product generates points for eg 5rs=2 zomato points and each produuct has different purchasing point
-- for eg for p1 5rs=1 zomato point 
--for p2 10rs=5 zomato point  and p3 5rs=1 zomato point 
--calculate points collected by each customers and for which product most points have been given till now.

select p.*,sum/points  as total_points from
(select n.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as points from 
(select m.*,sum(price) from
(select a.userid,a.product_id,b.price from sales a inner join product b on a.product_id=b.product_id )m
group by m.userid,m.product_id,m.price)n)p
order by userid;


--in the first one year after a customer joins the gold program (inluding their job date)
--irrespective of what the customer has purchased they earn 5 zomato points for every 10rs spent who earned more
--1 or3  and what was their points earnings in their first year?

select m.*,price/2 as points  from
(select a.userid, a.gold_signup_date ,c.price,b.product_id,b.created_date from goldusers_signup a 
 inner join sales b on a.userid=b.userid 
 inner join product c on b.product_id=c.product_id
where b.created_date>=a.gold_signup_date and b.created_date<=a.gold_signup_date+interval'1 year')m;

--rank all the transactions of the customers.
select * ,rank() over (partition by userid order by created_date)rnk from sales


--rank all the transactions for each members whenever they are zomato gold member for every non gold member transaction mark as na
select n.*,case when rnk=0 then 'na' else rnk end as rnkk from
(select m.*,cast((case when gold_signup_date is null then 0 else rank() over (partition by userid order by created_date desc )
				end) as varchar ) as rnk from 
(select a.userid ,a.created_date,a.product_id, b.gold_signup_date from sales a left join goldusers_signup b on a.userid=b.userid  and created_date>=gold_signup_date)m)n;



select o.*,replace(rnk,'0','na') as rnkkk from
(select n.*,cast (0 as varchar) end as rnkk from
((select m.*,case  when  gold_signup_date is null then 0 else rank() over (partition by userid order by created_date desc )
				end  rnk from 
(select a.userid ,a.created_date,a.product_id, b.gold_signup_date from sales a left join goldusers_signup b on a.userid=b.userid 
 and created_date>=gold_signup_date)m)n)o);








