/*******************************************************************************
5. 年齡分群 與 漏斗分析：加入年齡分群，找出各流程的總人數
	- 年齡分群
	- 持續消費：找出「不活躍用戶」，以 CreditCard_Count - 不活躍人數 = 持續消費
	
	- 不活躍人數 定義：
		1.沒有消費，申請信用卡後就沒使用的人數
		2.有消費，但超過3個月沒有消費的人數（以2025/1/1開始分析做回推）
*******************************************************************************/

-- 年齡分群

WITH AG as (
	SELECT
		CustomerID,
		CASE
			WHEN Age >= 18 and Age < 30 THEN '18~29歲' 		-- min = 18，且18~20歲人數較少，合併至20~29歲分群
			WHEN Age >= 30 and Age < 40 THEN '30~39歲'
			WHEN Age >= 40 and Age < 50 THEN '40~49歲'
			WHEN Age >= 50 and Age < 60 THEN '50~59歲'
			WHEN Age >= 60 and Age < 70 THEN '60~69歲'
		ELSE
			'70歲以上'										-- 70歲以上人數較少，以 >70歲 做分群
		END as Age_Group
	FROM
		Customers
)
	SELECT					-- 各年齡群人數
		Age_Group,
		count(CustomerID)
	FROM
		AG
	GROUP by
		1     

/*******************************************************************************
5-1 不活躍人數：
	1.沒有消費，申請信用卡後就沒使用的人數：
		- 找出持有信用卡的CustomerID（Applications的人數）
		- 對比信用卡交易出現的CustomerID（CreditCard的人數）
*******************************************************************************/
	
No_Use_Cus AS (
    SELECT DISTINCT
        A.CustomerID AS A_Cus,
        CCT.CustomerID AS CC_Cus
    FROM
        Applications A
    LEFT JOIN
        CreditCardTransaction CCT
    USING
        (CustomerID)
),

/*******************************************************************************
5-2 不活躍人數：
	2. 有消費，但超過3個月沒有消費的人數：
		- 找出每個CustomerID最後的交易日期
*******************************************************************************/

Three_Months_No_purchase_Cus AS (
    SELECT DISTINCT
        CustomerID,
        LAST_VALUE (TransactionTime)									-- 以 LAST_VALUE 獲取 CustomerID 的最後一次 TransactionTime
    OVER (
			PARTITION BY CustomerID										-- 按客戶 分區
			ORDER BY TransactionTime 									-- 按交易時間 排序
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING	-- 包含所有時間範圍的交易
				) AS Last_Trans_Time
    FROM
        CreditCardTransaction
)

/*******************************************************************************
5-3 合併顯示
*******************************************************************************/

SELECT
	AG.Age_Group,
    '3 Months No Purchase' AS Type,
    COUNT(CustomerID) AS 'Count'
FROM
    Three_Months_No_purchase_Cus
JOIN
	AG
USING
	(CustomerID)
WHERE
    julianday('2025-01-01') - julianday(Last_Trans_Time) > 90			-- 最後交易日期與2025/1/1相差90天
GROUP by
	1
	
UNION ALL

SELECT
	AG.Age_Group,
    'No Use' AS Type,
    COUNT(A_Cus) AS 'Count'
FROM
    No_Use_Cus
JOIN
	AG
on
	No_Use_Cus.A_Cus = AG.CustomerID
WHERE
    CC_Cus IS NULL
GROUP by
	1;

/*******************************************************************************
5-4 使用excel算出 持續消費 人數（CreditCard_Count - 不活躍人數 = 持續消費）
*******************************************************************************/