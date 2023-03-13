-- Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region
SELECT * FROM dim_customer 
WHERE region = 'APAC'
 and customer= 'Atliq Exclusive' ;





-- Provide a report with all the unique product counts for each segment
select segment, count(distinct product) as product_count FROM dim_product 
group by segment
order by product_count desc;



-- Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?

select * from (SELECT division, sum( sold_quantity ), sm.product_code,dp.product,
dense_rank() over (partition by division  order by sold_quantity desc) as rnk 
FROM fact_sales_monthly as sm join dim_product as dp
on  sm.product_code = dp.product_code 
where fiscal_year= 2021 
group by division, sm.product_code) x where x.rnk<4;




-- channel helped to bring more gross sales in the fiscal year 2021
  
         
         
        With temp as (select sm.customer_code, dp.product, sm.product_code, cus.channel, 
		gp.gross_price, mc.manufacturing_cost, dc.pre_invoice_discount_pct, sm.sold_quantity, sm.fiscal_year,
        (gross_price * sold_quantity) AS GROSS_SALES
		 from  dim_product  as dp
		 join fact_sales_monthly as sm on dp.product_code = sm.product_code
		 join fact_pre_invoice_deductions as dc on sm.customer_code= dc.customer_code
		 join fact_manufacturing_cost as mc on dp.product_code=mc.product_code
		 join fact_gross_price as gp on dp.product_code= gp.product_code 
         join dim_customer as cus on cus.customer_code= sm.customer_code
         where sm.fiscal_year= gp.fiscal_year 
         and sm.fiscal_year= dc.fiscal_year and 
         sm.fiscal_year=mc.cost_year)
         
         SELECT 
  channel, 
  SUM(GROSS_SALES) AS total_gross_sales, 
  SUM(GROSS_SALES) / (SELECT SUM(GROSS_SALES) FROM temp WHERE fiscal_year = 2021) * 100 AS percentage_contribution 
FROM 
  temp 
WHERE 
  fiscal_year = 2021 
GROUP BY 
  channel 
;



--  products that have the highest and lowest manufacturing costs      
SELECT 
  mc.product_code, product,
  manufacturing_cost 
FROM 
  fact_manufacturing_cost mc
  join dim_product d on mc.product_code= d.product_code
WHERE 
  manufacturing_cost = (
    SELECT 
      MAX(manufacturing_cost) 
    FROM 
      fact_manufacturing_cost
  )
  OR manufacturing_cost = (
    SELECT 
      MIN(manufacturing_cost) 
    FROM 
      fact_manufacturing_cost
  );




-- finding unique product increase in the  year 2020 and 2021
 SELECT 
  COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END) AS unique_products_2020, 
  COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) AS unique_products_2021, 
  ((COUNT(DISTINCT CASE WHEN fiscal_year = 2021 THEN product_code END) 
    - COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END))
    / COUNT(DISTINCT CASE WHEN fiscal_year = 2020 THEN product_code END)) * 100 AS percentage_change 
FROM 
  fact_sales_monthly
WHERE 
  fiscal_year IN (2020, 2021);
  
  
  
  
  -- In which quarter of 2020, got the maximum total_sold_quantity

 SELECT
    QUARTER(date) AS Quarter,
    SUM(sold_quantity) AS total_sold_quantity
FROM
    fact_sales_monthly
WHERE
    fiscal_year = 2020
    AND date >= '2020-01-01'
    AND date < '2021-01-01'
GROUP BY
    Quarter

;

-- Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month

 with tempmonthly as (select (gross_price * sold_quantity) AS GROSS_SALES,
 cus.customer, monthname(sm.date) as months  , sm.fiscal_year
        
		 from  dim_product  as dp
		 join fact_sales_monthly as sm on dp.product_code = sm.product_code
		 join fact_pre_invoice_deductions as dc on sm.customer_code= dc.customer_code
		 join fact_manufacturing_cost as mc on dp.product_code=mc.product_code
		 join fact_gross_price as gp on dp.product_code= gp.product_code 
         join dim_customer as cus on cus.customer_code= sm.customer_code
         
         where sm.fiscal_year= gp.fiscal_year 
         and sm.fiscal_year= dc.fiscal_year and 
         sm.fiscal_year=mc.cost_year
         
         group by cus.customer , months , sm.fiscal_year)
        
 select * from tempmonthly where customer= 'Atliq Exclusive';
 
 

-- Generate a report which contains the top 5 customers who received anaverage high pre_invoice_discount_pct for the fiscal year 2021 and in theIndian market

SELECT id.customer_code, dc.market, fiscal_year, pre_invoice_discount_pct 
FROM fact_pre_invoice_deductions  id
join dim_customer dc on id.customer_code= dc.customer_code
WHERE market = 'India' AND fiscal_year = 2021 
HAVING pre_invoice_discount_pct > (SELECT AVG(pre_invoice_discount_pct) 
FROM fact_pre_invoice_deductions
 WHERE market = 'India' AND fiscal_year = 2021)
ORDER BY pre_invoice_discount_pct DESC
LIMIT 5;


  
