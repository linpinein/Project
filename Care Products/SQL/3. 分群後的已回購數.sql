/**************************************************************************************
3-1. 計算首購行為分群後的已回購數
	- 先抓出有回購的客戶有哪些，屬於哪一年
**************************************************************************************/

WITH RC as (
	SELECT DISTINCT
		C.CustomerId,
		O.TransactionYear
	FROM
		Customers C
	JOIN
		Orders O
	USING
		(CustomerId)
	WHERE
		C.FirstTransactionYear = O.TransactionYear
	GROUP BY
		1
	HAVING
		COUNT(C.CustomerId) >= 2
)

/**************************************************************************************
3-2. 回購的商品，類型有哪些
**************************************************************************************/

, RP as (
	SELECT
		RC.CustomerId,
		RC.TransactionYear,
		P.ProductType
	FROM
		RC
	JOIN
		Orders O
	USING
		(CustomerId)
	JOIN
		OrderDetails OD
	USING
		(OrderId)
	JOIN
		Products P
	USING
		(ProductId)
)

/**************************************************************************************
3-3. 判斷每個客戶是否回購該商品
	- 如果客戶有回購該商品，記為1，反之為0
**************************************************************************************/

, RP2 as (
	SELECT
		CustomerId,
		TransactionYear,
		max(CASE
				WHEN ProductType = '核心商品' THEN 1 ELSE 0 END) as '購買核心商品',
		max(CASE
				WHEN ProductType = '帶路商品' THEN 1 ELSE 0 END) as '購買帶路商品',
		max(CASE
				WHEN ProductType = '其他商品' THEN 1 ELSE 0 END) as '購買其他商品'
	FROM
		RP
	GROUP by
		1,2
)

/**************************************************************************************
3-4. 統計各種回購行為的總數
**************************************************************************************/

SELECT
	TransactionYear,
	count(*) as '總計',
	sum(CASE
			WHEN 購買核心商品 = 1 AND 購買帶路商品 = 0 THEN 1 ELSE 0 END) as '買核心，沒買帶路',
	sum(CASE
			WHEN 購買帶路商品 = 1 AND 購買核心商品 = 0 THEN 1 ELSE 0 END) as '買帶路，沒買核心',
	sum(CASE
			WHEN 購買帶路商品 = 1 AND 購買核心商品 = 1 THEN 1 ELSE 0 END) as '買核心，買帶路',
	sum(CASE
			WHEN 購買帶路商品 = 0 AND 購買核心商品 = 0 AND 購買其他商品 = 1 THEN 1 ELSE 0 END) as '只買其他商品'
FROM
	RP2
GROUP by
	1