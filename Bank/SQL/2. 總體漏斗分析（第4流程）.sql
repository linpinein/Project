/*******************************************************************************
2. 總體漏斗分析：找出各流程的總人數
	- 持續消費：找出「不活躍用戶」，以 CreditCard_Count - 不活躍人數 = 持續消費
	
	- 不活躍人數 定義：
		1.沒有消費，申請信用卡後就沒使用的人數
		2.有消費，但超過3個月沒有消費的人數（以2025/1/1開始分析做回推）
*******************************************************************************/
/*******************************************************************************
2-1 不活躍人數：
	1.沒有消費，申請信用卡後就沒使用的人數：
		- 找出持有信用卡的CustomerID（Applications的人數）
		- 對比信用卡交易出現的CustomerID（CreditCard的人數）
*******************************************************************************/

WITH No_Use_Cus AS (
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
2-2 不活躍人數：
	2. 有消費，但超過3個月沒有消費的人數：
		- 找出每個CustomerID最後的交易日期
*******************************************************************************/
	
Three_Months_No_purchase_Cus AS (
    SELECT DISTINCT
        CustomerID,
        LAST_VALUE (TransactionTime)										-- 以 LAST_VALUE 獲取 CustomerID 的最後一次 TransactionTime
    OVER (
			PARTITION BY CustomerID											-- 按客戶 分區
            ORDER BY TransactionTime 										-- 按交易時間 排序
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING		-- 包含所有時間範圍的交易
				) AS Last_Trans_Time
    FROM
        CreditCardTransaction
)

/*******************************************************************************
2-3 合併顯示
*******************************************************************************/

SELECT
    '3 Months No Purchase' AS Type,                                         -- 新增類別標籤
    COUNT(CustomerID) AS 'Count'
FROM
    Three_Months_No_purchase_Cus
WHERE
    julianday('2025-01-01') - julianday(Last_Trans_Time) > 90				-- 最後交易日期與2025/1/1相差90天
	
UNION ALL

SELECT
    'No Use' AS Type,                                                       -- 新增類別標籤
    COUNT(A_Cus) AS Count
FROM
    No_Use_Cus
WHERE
    CC_Cus IS NULL
	
/*******************************************************************************
2-4 使用excel算出 持續消費 人數（CreditCard_Count - 不活躍人數 = 持續消費）
*******************************************************************************/