--create database retail_data
use retail_data

--DATA PREPRATION AND UNDERSTANDING
select * from dbo.Customer;
select * from dbo.Transactions;
select * from dbo.prod_cat_info;

--1) Total Number of Rows in each of 3 tables in the database

select count(*) as Count from dbo.Customer
union
select count(*) as Count from dbo.prod_cat_info
union
select count(*) as Count from dbo.Transactions;

--2) Total Number of Transaction that have return

select count(distinct (transaction_id))as Total_transaction from dbo.Transactions
where qty <0;

--3)

select CONVERT(date,tran_date,105) as Trans_date from dbo.Transactions;

--4) 

select DATEDIFF(year,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(date,tran_date,105))) as Year_diff ,
DATEDIFF(MONTH,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(date,tran_date,105))) as Month_diff ,
DATEDIFF(DAY,MIN(CONVERT(date,tran_date,105)),MAX(CONVERT(date,tran_date,105))) as Day_diff 
from dbo.Transactions;

--5)
select prod_cat,prod_subcat from dbo.prod_cat_info
where prod_subcat='DIY';


--DATA ANALYSIS
select * from dbo.Customer;
select * from dbo.prod_cat_info;
select * from dbo.Transactions;


--1)
select top 1 store_type ,
count(*) as cnt 
from dbo.Transactions
group by store_type
order by cnt desc;

--2)
select gender,count(*) as cnt from dbo.Customer
where gender is not null
group by gender;

--3)
select top 1 city_code,count(*) as cnt from dbo.Customer
group by city_code
order by cnt desc

--4)
select prod_cat,prod_subcat from dbo.prod_cat_info
where prod_cat='Books';

--5)
select prod_cat_code,MAX(Qty) from dbo.Transactions
group by prod_cat_code;

--6)
select sum(cast(total_amt as float)) as net_revenue from dbo.prod_cat_info as t1
join Transactions as t2
on t1.prod_cat_code=t2.prod_cat_code 
and t1.prod_sub_cat_code=t2.prod_subcat_code 
where prod_cat ='books' or prod_cat ='electronics';

--7)
select count(*) as tot_cnt  from(		-- this is a inline query

select cust_id,count(distinct(transaction_id))as cnt from dbo.Transactions
where Qty >0
group by cust_id
having count(distinct(transaction_id)) >10
) as t5;

--8) 
select sum(cast(total_amt as float)) as Combined_revenue from dbo.prod_cat_info as t1
join Transactions  as t2
on t1.prod_cat_code=t2.prod_cat_code 
and t1.prod_sub_cat_code=t2.prod_subcat_code 
where prod_cat in ('clothing','electronics') and store_type='flagship store' and qty>0;

--9)
select prod_subcat,sum(cast(total_amt as float)) as total_revenue
from Customer as t1
join Transactions as t2 
on t1.customer_Id=t2.cust_id
join prod_cat_info as t3
on t2.prod_cat_code=t3.prod_cat_code and t2.prod_subcat_code=t3.prod_sub_cat_code
where gender='m' and  prod_cat='electronics'
group by prod_subcat

--10)
-- percentage of sales
select t5.prod_subcat,t5.percentage_sales,percentage_return from(
select top 5 prod_subcat,
(sum(cast(total_amt as float))/(select sum(cast(total_amt as float)) as total_sales from Transactions where qty >0)) as percentage_sales
from prod_cat_info as t1
join Transactions as t2 
on t1.prod_cat_code=t2.prod_cat_code and t1.prod_sub_cat_code=t2.prod_subcat_code
where qty >0
group by prod_subcat
order by percentage_sales desc
) as t5
join

--percentage of return
(
select prod_subcat,
(sum(cast(total_amt as float))/(select sum(cast(total_amt as float)) as total_sales from Transactions where qty <0)) as percentage_return
from prod_cat_info as t1
join Transactions as t2 
on t1.prod_cat_code=t2.prod_cat_code and t1.prod_sub_cat_code=t2.prod_subcat_code
where qty <0
group by prod_subcat) as t6

on t5.prod_subcat=t6.prod_subcat


--11)
--age of customer
select * from(
select * from (
select cust_id,datediff(year,dob,max_date) as age ,total_revenue from(
select cust_id,DOB,max(convert (date,tran_date,105) )as max_date,
sum(cast(total_amt as float)) as total_revenue from customer as t1
join Transactions as t2
on t1.customer_Id=t2.cust_id
group by cust_id,DOB) as inline_query
) as inline_query1
where age between 25 and 35) as inline_query3
join(
--last 30 days of transaction
select cust_id,CONVERT(date,tran_date,105) as trans_date  
from Transactions
group by cust_id,CONVERT(date,tran_date,105) 
having CONVERT(date,tran_date,105) >=(select dateadd(day,-30,max(convert(date,tran_date,105))) as cutoff_date from Transactions)) as inline_query4
on inline_query3.cust_id=inline_query4.cust_id

--12)
select top 1 prod_cat_code ,sum(rtn) as total_rtn from(
select prod_cat_code,CONVERT(date,tran_date,105) as trans_date  ,sum(qty) as rtn
from Transactions
where qty <0
group by prod_cat_code,CONVERT(date,tran_date,105) 
having CONVERT(date,tran_date,105) >=(select dateadd(month,-3,max(convert(date,tran_date,105))) as cutoff_Month from Transactions)
) as t1
group by prod_cat_code
order by total_rtn


--13)

select store_type, sum(cast(total_amt as float)) as revenue, sum(Qty) as quantity
from Transactions
where qty >0
group by Store_type
order by revenue desc, quantity desc

--14)

select prod_cat_code,avg(cast(total_amt as float)) as avg_revenue  
from Transactions
where qty >0
group by prod_cat_code
having avg(cast(total_amt as float)) >= (select avg(cast(total_amt as float)) from Transactions where qty >0 )


--15)
select prod_subcat_code,sum(cast(total_amt as float)) as revenue, AVG(cast(total_amt as float)) as average_rev
from Transactions
where qty >0 and prod_cat_code in (select top 5 prod_cat_code  from Transactions
									where qty >0
									group by prod_cat_code
									order by sum(qty) desc	)
group by prod_subcat_code

