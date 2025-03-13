/*****************************************************************************
1. 總體漏斗分析：找出各流程的總人數
	- 瀏覽網站：訪問行為中，僅瀏覽網站的CustomerID人數
	- 成為會員：訪問行為中，造訪 註冊頁面 且有 提交申請行為 的CustomerID人數
	- 申請信用卡：有造訪 信用卡頁面 提交申請 的CustomerID人數
*****************************************************************************/

-- 瀏覽網站

WITH ViewCount as (
	SELECT 
		count(DISTINCT B.CustomerID) as View_Count
	FROM
		Behavior B
),

-- 成為會員

RegistrationCount as (
	SELECT
		count(DISTINCT B.CustomerID) as Registration_Count
	FROM
		Behavior B
	WHERE
		B.VisitPage = 'Registration'
	AND
		B.ClickEvent = 'SubmitForm'
),

-- 申請信用卡

CreditCardCount as (
	SELECT
		count(DISTINCT B.CustomerID) as CreditCard_Count
	FROM	
		Behavior B
	WHERE
		B.VisitPage = 'CreditCard'
	AND
		B.ClickEvent = 'SubmitForm'
)

-- 合併顯示

SELECT 
	View_Count,
	Registration_Count,
	CreditCard_Count
FROM
	ViewCount,
	RegistrationCount,
	CreditCardCount



