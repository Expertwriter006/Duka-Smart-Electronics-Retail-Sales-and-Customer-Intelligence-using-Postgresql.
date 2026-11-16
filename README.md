# Duka-Smart-Electronics-Retail-Sales-and-Customer-Intelligence-using-Postgresql.
This article entails a SQL analysis of Duka Smart Electronics, a Kenyan electronics retailer trading since January 2025. The project sets up a Postgresql database, loads 150 customers and 800 orders, answers 46 business questions in SQL, and turns the results into insights and a Power BI dashboard.
## Objectives of the Project

- Creates the `retail_analytics database` with two related tables, customers and orders
- Answers 46 business questions in SQL, from basic filters to window functions, views, and a function
- Explains what the results mean for management in insights.md

## Data in Tables

The tables were created and had data as follows:

**`customers (150 rows)`**
**Column**	**Type**	**Meaning**
`customer_id`	integer, primary key	Unique customer number
`customer_name`	varchar(100), not null	Full name
`gender	`varchar(10)	Male or Female
`city`	varchar(50)	One of ten Kenyan towns
`registration_date`	date	When the customer joined
`customer_segment`	varchar(20)	Retail, Corporate or VIP



![Customers](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/v5k5cy10dte3er8ztg0u.png)



**`orders (800 rows)`**
**Column**	**Type**	**Meaning**
`order_id`	integer, primary key	Unique order number
`customer_id`	integer, foreign key to customers	Who placed the order
`order_date`	date, not null	When it was placed
`product_name`	varchar(100)	What was bought
`product_category`	varchar(50)	Electronics, Accessories, Home Appliances, Computing or Mobile Phones
`quantity`	integer (greater than 0)	Units in the order
`unit_price`	numeric(12,2)	Selling price per unit in KSh, before discount
`cost_price`	numeric(12,2)	Cost of one unit in KSh
`discount`	numeric(5,2), 0 to 100	Discount percentage, so 10 means 10% off
`payment_method`	varchar(30)	M-Pesa, Cash, Card or Bank Transfer
`order_status`	varchar(20)	Completed, Pending or Cancelled


![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/t2b65zr2hyhtyk70rnn0.png)

## Rules Applied in the Queries

For every query that I ran, I applied specific rules that were uniform across;

- **Revenue** = `quantity * unit_price * (1 - discount / 100)`, counting completed orders only.
- **Cost** = quantity * cost_price, completed orders only.
- **Profit** = revenue minus cost.
- **Profit margin** = profit divided by revenue, times 100, with NULLIF(..., 0) to avoid division by zero.
- Order counts include all statuses unless a question says otherwise.
- A month means year and month together, so January 2025 and January 2026 are different months.
- I used "Today" as the latest order_date in the dataset, not the current date.
- Money values are rounded to 2 decimals in the final SELECT only.
- The status value is written 'Completed' with a capital C, because PostgreSQL string comparison is case-sensitive.

## Dashboard

The dashboard connects Power BI Desktop to the database and uses the views:

`Monthly_sales_summary:` month, orders, revenue, cost, profit
`Category_performance:` revenue, cost, profit, and margin by category
`Customer_spending_ranking:` customers ranked by completed-order spending


![Image description](https://dev-to-uploads.s3.us-east-2.amazonaws.com/uploads/articles/m6xe2w5fv0m977l465b8.png)

## Business Insights

After thorough examination and analysis of the dataset, I had the following business insights to make;

### 1. Accessories earn the best margin, but they are only 4.5% of revenue

#### Finding (Q16, Q33, Q42)

- Mobile Phones lead on profit: KSh 728,761 at a 10.5% margin.
- Accessories earn a 42.4% margin, against 9.9% to 11.4% for the four other categories.
- Accessories bring in only KSh 1,077,496, which is 4.5% of revenue, yet they produce KSh 456,746 of profit, which is 15.8% of all profit.

#### Importance of this;

- The business depends on four electronics categories that earn about ten shillings of profit per hundred sold.
- A small shift of sales toward accessories raises profit faster than the same shift in phones or laptops.

#### Recommendation

- Sell an accessory with every phone, laptop and TV (cases, chargers, bags, HDMI cables) and show it at checkout.
- Track "accessory orders per phone or laptop order" monthly as a simple target.

### 2. Discounts take over half of the profit

#### Finding (Q33, discount analysis)

- 328 of 634 completed orders (52%) carry a discount, averaging 10.8%.
- Discounts given total about KSh 1.52 million, which equals 53% of the KSh 2.89 million profit.
- Completed orders with a discount earn a 7.0% margin, against 17.5% for orders without one.
- Mobile Phones (KSh 472,238) and Computing (KSh 461,694) receive the largest discounts.

#### Why it matters

- The electronics lines already have thin margins (about 10%), so a 10% discount removes almost all the profit on an order.
- Part of the gap comes from product mix, since discounts may fall on lower-margin items, so the effect is a warning, not a precise measure.

#### Recommendation

- Cap discounts on phones and computing, and require approval above a set level such as 5%.
- Test whether discounted orders are really bigger or more frequent. If not, the discount is only giving margin away.

### 3. A third of customers have gone quiet

#### Finding (Q34, cohort retention)

- 47 of 132 purchasing customers (36%) made their last completed order more than 90 days before the dataset ends (2026-09-30).
- By segment: Retail 34 of 88 (39%), Corporate 7 of 25 (28%), VIP 6 of 19 (32%).
- Repeat buying is otherwise healthy: 89 of 132 customers (67%) ordered in more than one month, and every customer in the February to May 2025 cohorts ordered again.

#### Why it matters

- Lapsed customers have already bought once, so winning them back is cheaper than finding new ones.
- Six VIP customers lapsing is the costliest part, since VIPs spend the most per head.

#### Recommendation

- Call or message the 6 lapsed VIPs and 7 lapsed Corporate accounts personally this month.
- Send a simple M-Pesa-friendly offer to lapsed Retail customers, starting with those who ranked in the high or medium value bands.
- Re-run Q34 every month and track the lapsed count as a health measure.

### 4. Sales are growing, with a strong December and a weak January

#### Finding (Q31, Q38, Q39, Q40)

- Average monthly revenue rose from KSh 943,607 in 2025 to KSh 1,425,787 in the first nine months of 2026, an increase of 51%.
- December 2025 was the strongest month in 2025 at KSh 2,027,121, and the following January fell 84% to KSh 322,433.
- January 2026 is the lowest-revenue month in the dataset, below the 2025 low of KSh 369,566 in February.
- August and September 2026 are among the best months overall (KSh 2.24 million and KSh 2.09 million).

#### Importance;

- The business is growing, but demand is uneven, with a festive-season peak followed by a sharp dip.
- The January drop affects cash flow and stock planning.

#### Recommendation

- Order extra stock and plan marketing for November and December.
- Run a January promotion that does not rely on deep discounts, for example bundles with accessories.
- Compare 2025 and 2026 using the same months only, since 2026 has no October to December yet.

## Conclusion

This project built a PostgreSQL database for Duka Smart Electronics, loaded 150 customers and 800 orders, and answered 46 business questions in SQL, supported by views, a pgSQL function, a cohort-retention table, an index test, and a Power BI dashboard. Using completed orders only, the business earned KSh 24.16 million in revenue and KSh 2.89 million in profit (a 12.0% margin) from 132 purchasing customers. The analysis shows that growth is real but fragile, average monthly revenue rose 51% in 2026, yet demand dips sharply after December, revenue depends heavily on the top quarter of customers (69.2%) and on Nairobi (39.7%), and 36% of purchasing customers have gone quiet. Profit is held back by thin electronics margins of about 10% and by discounts that equal roughly 53% of profit, while Accessories earn a 42.4% margin on only 4.5% of revenue. About 21.6% of order value is still cancelled or pending. These findings point to clear actions that bundle accessories with high-value products, cap discounts, win back lapsed VIP and high-value customers, reduce cancellations, and prepare stock and promotions for the December peak and January slump.
