use mavenfuzzyfactory;


/*
1. First, I’d like to show our volume growth. Can you pull overall session and order volume, 
trended by quarter for the life of the business? Since the most recent quarter is incomplete, 
you can decide how to handle it.
*/ 

select year(website_sessions.created_at) as yr,
       quarter(website_Sessions.created_at) as Qtr,
       count(website_sessions.website_session_id) as sessions,
       count(order_id) as order_volume
from website_sessions
left join orders on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at <= '2015-03-20'
group by 1,2;

/*
2. Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures 
since we launched, for session-to-order conversion rate, revenue per order, and revenue per session. 

*/

select year(website_sessions.created_at) as yr,
       quarter(website_Sessions.created_at) as Qtr,
       count(order_id)/count(website_sessions.website_session_id) as session_to_order_conv_rate,
       sum(price_usd)/count(order_id) as revenue_per_order,
       sum(price_usd)/count(website_sessions.website_session_id) as revenue_per_session
from website_sessions
left join orders on website_sessions.website_session_id = orders.website_session_id
-- where website_sessions.created_at <= '2015-03-20'
group by 1,2;

/*
3. I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders 
from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?
*/

select year(website_sessions.created_at) as yr,
       quarter(website_Sessions.created_at) as Qtr,
       count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then order_id else null end) as Gser_nonbrand_orders,
       count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then order_id else null end) as bser_nonbrand_orders,
       count(case when utm_campaign = 'brand' then order_id else null end) as brand_orders,
       count(case when http_referer = 'https://www.gsearch.com' and utm_source is null then order_id else null end) as 
       organic_search_orders,
       count(case when http_referer is null then order_id else null end) as direct_type_in_orders
from website_sessions
left join orders on website_sessions.website_session_id = orders.website_session_id
group by 1,2;

/*
4. Next, let’s show the overall session-to-order conversion rate trends for those same channels, 
by quarter. Please also make a note of any periods where we made major improvements or optimizations.
*/

select year(website_sessions.created_at) as yr,
       quarter(website_Sessions.created_at) as Qtr,
       count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then order_id else null end)/
       count(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end)
       as gsearch_session_to_order_convrate,
       count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then order_id else null end)/
       count(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end)
       as bsearch_session_to_order_convrate,
       count(case when utm_campaign = 'brand' then order_id else null end)/
       count(case when utm_campaign = 'brand' then website_sessions.website_session_id else null end)
       as brand_session_to_order_convrate,
       count(case when http_referer = 'https://www.gsearch.com' and utm_source is null then order_id else null end)/
       count(case when http_referer = 'https://www.gsearch.com' and utm_source is null then website_sessions.website_session_id else null end)
       as organic_search_session_to_orders_convrate,
       count(case when http_referer is null then order_id else null end)/count(case when http_referer is null then website_sessions.website_session_id else null end)
       as direct_type_session_to_orders_convrate
from website_sessions
left join orders on website_sessions.website_session_id = orders.website_session_id
group by 1,2;

/*
5. We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue 
and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
*/

select year(created_at) as yr,
       month(created_at) as mon,
       sum(case when product_id = 1 then price_usd else null end) as revenue_product_1,
       sum(case when product_id = 2 then price_usd else null end) as revenue_product_2,
       sum(case when product_id = 3 then price_usd else null end) as revenue_product_3,
       sum(case when product_id = 4 then price_usd else null end) as revenue_product_4,
       sum(case when product_id = 1 then price_usd else null end) - 
       sum(case when product_id = 1 then cogs_usd else null end) as margin_product_1,
       sum(case when product_id = 2 then price_usd else null end) -
       sum(case when product_id = 2 then cogs_usd else null end) as margin_product_2,
       sum(case when product_id = 3 then price_usd else null end) -
       sum(case when product_id = 3 then cogs_usd else null end) as margin_product_3,
       sum(case when product_id = 4 then price_usd else null end) -
       sum(case when product_id = 4 then cogs_usd else null end) as margin_product_4,
       sum(price_usd) as total_revenue,
       sum(price_usd - cogs_usd) as total_margin 
from order_items
group by 1,2;


/*
6. Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to 
the /products page, and show how the % of those sessions clicking through another page has changed 
over time, along with a view of how conversion from /products to placing an order has improved.
*/

select year(created_at) as yr,
       month(created_at) as mon,
       count(distinct case when pageview_url = '/products' then website_session_id else null end) as product_page_sessions,
       count(distinct case when pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear', '/the-birthday-sugar-panda','/the-hudson-river-mini-bear')
       then website_session_id else null end) as next_page_sessions,
       count(distinct case when pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear', '/the-birthday-sugar-panda','/the-hudson-river-mini-bear')
       then website_session_id else null end)/count(case when pageview_url = '/products' then website_session_id else null end) as clickthrough_rate,
       count(distinct case when pageview_url = '/thank-you-for-your-order' then website_session_id else null end) as orders,
       count(distinct case when pageview_url = '/thank-you-for-your-order' then website_session_id else null end)/
       count(distinct case when pageview_url = '/products' then website_session_id else null end) as products_to_orders_conv_rate
from website_pageviews
group by 1,2;

/*
7. We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). 
Could you please pull sales data since then, and show how well each product cross-sells from one another?
*/

create temporary table A1 
select order_id, 
      primary_product_id
from orders
where created_at > '2014-12-05';

select A1.order_id,
       primary_product_id,
       product_id as cross_sold_products
from A1
left join order_items on A1.order_id = order_items.order_id
And order_items.is_primary_item = 0; -- only bringing in cross sells.

select primary_product_id,
       count(order_id) as total_orders,
       count(case when cross_sold_products = 1 then order_id else null end) as _xsold_p1,
	   count(case when cross_sold_products = 2 then order_id else null end) as _xsold_p2,
	   count(case when cross_sold_products = 3 then order_id else null end) as _xsold_p3,
	   count(case when cross_sold_products = 4 then order_id else null end) as _xsold_p4,
        count(case when cross_sold_products = 1 then order_id else null end)/count(order_id) as p1_xsell_rate,
        count(case when cross_sold_products = 2 then order_id else null end)/count(order_id) as p2_xsell_rate,
        count(case when cross_sold_products = 3 then order_id else null end)/count(order_id) as p3_xsell_rate,
        count(case when cross_sold_products = 4 then order_id else null end)/count(order_id) as p4_xsell_rate
from (select A1.order_id,
       primary_product_id,
       product_id as cross_sold_products
from A1
left join order_items on A1.order_id = order_items.order_id
And order_items.is_primary_item = 0) as cross_sell
group by 1;
       










