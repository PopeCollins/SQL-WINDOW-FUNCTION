show tables;
select * from payments;
select * from clients;
select * from payment_methods;
select * from invoices;

-- QUEST 1
-- Fetch the top 2 highest invoice paid by each cleint 
select y.* 
from (select i.*, 
		row_number() over(partition by client_id order by invoice_total desc) as TT
		from invoices i) y
where TT < 3;


-- QUEST 2 
-- Fetch the maximum and minimum invoice paid by each client
-- QUERY 1
with ty as
			( with t as 
					(select i.*,
						rank() over(partition by client_id order by invoice_total desc) as RN,
						max(invoice_total) over (partition by client_id ) As Highest_Invoice,
						min(invoice_total) over (partition by client_id ) As lowest_Invoice
						from invoices i)
		select t.* 
		from  t
		where RN = 1)
Select c.name,
ty.client_id,
ty.Highest_Invoice,
ty.lowest_Invoice
from ty
join clients c on c.client_id = ty.client_id ;

-- Other window functions
-- Using dense rank
select i.*, 
dense_rank() over(partition by client_id order by invoice_total desc) as TT
from invoices i;

-- Using lag
select i.*, 
lag(invoice_total) over(partition by client_id order by invoice_total desc) as TT
from invoices i;
-- 
select i.*, 
lag(invoice_total, 2, 0) over(partition by client_id order by invoice_total desc) as TT
from invoices i;

-- Using lead
select i.*, 
lead(invoice_total) over(partition by client_id order by invoice_total desc) as yy
from invoices i;

-- Identify if the invoice amount of each client is higher or lower than the previous transactions
select t.*,
lag(invoice_total) over(partition by client_id ) as T_lag,
case when invoice_total > (lag(invoice_total) over(partition by client_id )) then 'Higher Invoice'
	when invoice_total < (lag(invoice_total) over(partition by client_id )) then 'Lowerr Invoice'
	when invoice_total = (lag(invoice_total) over(partition by client_id )) then 'The same Invoice'
    end as Invoice_decision
from invoices t;



