/**************************************************************************************
1. RFM分析：每個客戶累計消費次數（F頻率）、累計消費金額（M金額）
	- 每個客戶在Orders表，有出現幾筆數據
	- 每位客戶在Orders表，所有訂單的消費總金額
**************************************************************************************/
CREATE VIEW 
	RFM_Analyze as 
WITH F_M as (
	SELECT DISTINCT
		O.Customer_id,
		count(O.Order_id) as "Purchase_Count(F)"
		sum(P.Price) as "Purchase_Sum(M)"
	FROM
		Orders O
	JOIN
		Products P
	USING
		(Product_id)
	GROUP by
		1
),

/**************************************************************************************
1-2 RFM分析：最近一次消費日期（R日期）
	- 設定分析日期為 2023-08-30，先找出 每個客戶最新一次交易日期
	- 再算出 每位客戶 最近一次 Orders.order_purchase_timestamp 與 2023-08-30 天數差距
**************************************************************************************/

R as (														-- 每個客戶最近一次消費日期（R）
	SELECT DISTINCT
		O.Customer_id,		
		last_value(O.Order_purchase_timestamp) OVER (		-- window function：last_value 找分區的最後一行
			PARTITION by O.Customer_id
			ORDER by O.Order_purchase_timestamp
			ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
		) as Last_time_purchase
	FROM
		Orders O
)
SELECT														-- 天數差距 + 合併顯示F、M，存成 RFM_analyze.csv
	R.Customer_id,
	round(julianday('2023-08-30 00:00') - julianday(R.Last_time_purchase),2) as "Date_Diff(R)",		-- 沒有Datediff的替代品...
	F_M."Purchase_Count(F)",
	F_M."Purchase_Sum(M)"
FROM
	R
JOIN
	F_M
USING
	(Customer_id)
ORDER by
	2 DESC