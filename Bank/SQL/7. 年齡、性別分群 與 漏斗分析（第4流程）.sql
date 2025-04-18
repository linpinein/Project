/*******************************************************************************
7. 年齡、性別分群 與 漏斗分析：加入年齡、性別分群，找出各流程的總人數
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
			WHEN Age >= 18 and Age < 30 THEN '18~29歲' 			-- min = 18，且18~20歲人數較少，合併至20~29歲分群
			WHEN Age >= 30 and Age < 40 THEN '30~39歲'
			WHEN Age >= 40 and Age < 50 THEN '40~49歲'
			WHEN Age >= 50 and Age < 60 THEN '50~59歲'
			WHEN Age >= 60 and Age < 70 THEN '60~69歲'
		ELSE
			'70歲以上'											-- 70歲以上人數較少，以 >70歲 做分群
		END as Age_Group
	FROM
		Customers
),

/*******************************************************************************
7-1 不活躍人數：
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
7-2 不活躍人數：
	2. 有消費，但超過3個月沒有消費的人數：
		- 找出每個CustomerID最後的交易日期
*******************************************************************************/

Three_Months_No_purchase_Cus AS (
    SELECT DISTINCT
        CustomerID,
        LAST_VALUE (TransactionTime)
    OVER (
			PARTITION BY CustomerID
			ORDER BY TransactionTime 
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
			) AS Last_Trans_Time
    FROM
        CreditCardTransaction
)

/*******************************************************************************
7-3 合併顯示，增加 性別 篩選
*******************************************************************************/

SELECT
	AG.Age_Group,
	C.Gender,
    '3 Months No Purchase' AS Type,
    COUNT(AG.CustomerID) AS 'Count'
FROM
    Three_Months_No_purchase_Cus TMNPC
JOIN
	AG
on
	TMNPC.CustomerID = AG.CustomerID
JOIN
	Customers C
on
	AG.CustomerID = C.CustomerID
WHERE
    julianday('2025-01-01') - julianday(Last_Trans_Time) > 90		-- 最後交易日期與2025/1/1相差90天
GROUP by
	1,2
	
UNION ALL

SELECT
	AG.Age_Group,
	C.Gender,
    'No Use' AS Type,
    COUNT(A_Cus) AS 'Count'
FROM
    No_Use_Cus
JOIN
	AG
on
	No_Use_Cus.A_Cus = AG.CustomerID
JOIN
	Customers C
on
	AG.CustomerID = C.CustomerID
WHERE
    CC_Cus IS NULL
GROUP by
	1,2

/*******************************************************************************
7-4 使用excel算出 持續消費 人數（CreditCard_Count - 不活躍人數 = 持續消費）
*******************************************************************************/