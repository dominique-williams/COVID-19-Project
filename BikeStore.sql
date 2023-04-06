/*
Creating a master dataset for an executive revenue dashboard.

Skills Used: Joins, Aggregate Functions, Concatenating
*/
Select o.order_id,
Concat(c.first_name, ' ', c.last_name) as [customers],
c.city,
c.state, 
o.order_date,
Sum(i.quantity) as [total units],
Sum(i.quantity * i.list_price) as [revenue],
p.product_name,
ca.category_name,
b.brand_name,
s.store_name,
Concat(st.first_name, ' ', st.last_name) as [sales rep]
From sales.orders o
Join sales.customers c
On o.customer_id = c.customer_id
Join sales.order_items i
On o.order_id = i.order_id
Join production.products p
On i.product_id = p.product_id
join production.categories ca
On p.category_id = ca.category_id
Join production.brands b
On p.brand_id = b.brand_id
Join sales.stores s
On o.store_id = s.store_id
Join sales.staffs st
On o.staff_id = st.staff_id
Group by o.order_id,
Concat(c.first_name, ' ', c.last_name), 
c.city, 
c.state, 
o.order_date,
p.product_name,
ca.category_name,
b.brand_name,
s.store_name,
Concat(st.first_name, ' ', st.last_name)

