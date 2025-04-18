/**************************************************************************************
2-1. 將新客的首購行為，進行分群
	- 4種分群：「買核心商品，沒買帶路商品」、「買帶路商品，沒買核心商品」、「買核心商品，買帶路商品」、「只買其他商品」
	- 找每個客戶的首購商品
**************************************************************************************/

WITH CP as (
	SELECT
		C.CustomerId,
		C.FirstTransactionYear,
		P.ProductType
	FROM
		Customers C
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
	WHERE
		C.FirstTransactionDate = O.TransactionDate
)

/**************************************************************************************
2-2. 判斷每個客戶是否首購該商品
	- 如果客戶有購買該商品，記為1，反之為0
**************************************************************************************/
/**************************************************************************************
max使用原因：
	- 在ncp子查詢中，可以發現每筆訂單有多個商品，意即顧客可以在同一個訂單中購買多個商品，
	因此在做數據蒐集時，當發現同個訂單出現過一次特定商品（核心、帶路、其他）
	便將其視為購買過該商品，因此需要在case when前加上max，並配合group by以CustomerId分類，
	確保每個商品最終只被記錄一次。
**************************************************************************************/

, CP2 as (	
	SELECT
		CustomerId,
		FirstTransactionYear,
		max(CASE
				WHEN ProductType = '核心商品' THEN 1 ELSE 0 END) as '購買核心商品',	
		max(CASE
				WHEN ProductType = '帶路商品' THEN 1 ELSE 0 END) as '購買帶路商品',
		max(CASE
				WHEN ProductType = '其他商品' THEN 1 ELSE 0 END) as '購買其他商品'
	FROM
		CP
	GROUP by
		1,2
)

/**************************************************************************************
2-3. 統計各種首購行為的總數
**************************************************************************************/

SELECT						
	FirstTransactionYear,
	count(*) as '總計',
	sum(CASE
			WHEN 購買核心商品 = 1 AND 購買帶路商品 = 0 THEN 1 ELSE 0 END) as '買核心，沒買帶路',	-- sum：針對符合條件的總計
	sum(CASE
			WHEN 購買帶路商品 = 1 AND 購買核心商品 = 0 THEN 1 ELSE 0 END) as '買帶路，沒買核心',
	sum(CASE
			WHEN 購買帶路商品 = 1 AND 購買核心商品 = 1 THEN 1 ELSE 0 END) as '買核心，買帶路',
	sum(CASE
			WHEN 購買帶路商品 = 0 AND 購買核心商品 = 0 AND 購買其他商品 = 1 THEN 1 ELSE 0 END) as '只買其他商品'
FROM
	CP2
GROUP by
	1