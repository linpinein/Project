/*****************************************************************************
4. 年齡分群 與 漏斗分析：加入年齡分群，找出各流程的總人數
	- 年齡分群：將各年齡每10歲分一群
	- 成為會員：訪問行為中，造訪 註冊頁面 且有 提交申請行為 的CustomerID人數
	- 申請信用卡：有造訪 信用卡頁面 提交申請 的CustomerID人數
*****************************************************************************/

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
		END as
			Age_Group
	FROM
		Customers
),

-- 成為會員

RegistrationCount as (
	SELECT DISTINCT
		B.CustomerID
	FROM
		Behavior B
	WHERE
		B.VisitPage = 'Registration'
	AND
		B.ClickEvent = 'SubmitForm'
),

-- 申請信用卡

CreditCardCount as (
	SELECT DISTINCT
		B.CustomerID
	FROM	
		Behavior B
	WHERE
		B.VisitPage = 'CreditCard'
	AND
		B.ClickEvent = 'SubmitForm'
)

-- 合併顯示

SELECT
	AG.Age_Group,
	count(RC.CustomerID) as Registration_Count,
	count(CCC.CustomerID) as CreditCard_Count
FROM
	AG
JOIN
	Customers C
on
	AG.CustomerID = C.CustomerID
LEFT JOIN
	RegistrationCount RC
on
	AG.CustomerID = RC.CustomerID
LEFT JOIN
	CreditCardCount CCC
on
	AG.CustomerID = CCC.CustomerID
GROUP by
	1