/*******************************************************************************
3. 年齡分群（男女）：
	- 將各年齡每10歲分一群
	- 加入男女性別做篩選
*******************************************************************************/

/*******************************************************************************
3-1 將每個客戶（CustomerID）的年齡進行分群
*******************************************************************************/
WITH AG AS (
    SELECT
		CustomerID,
    CASE
        WHEN Age >= 0 and Age < 30 THEN '18~29歲'		            -- min = 18，且18~20歲人數較少，合併至20~29歲分群
        WHEN Age >= 30 and Age < 40 THEN '30~39歲'
        WHEN Age >= 40 and Age < 50 THEN '40~49歲'
        WHEN Age >= 50 and Age < 60 THEN '50~59歲'
        WHEN Age >= 60 and Age < 70 THEN '60~69歲'
    ELSE
        '70歲以上'                                   	            -- 70歲以上人數較少，以 >70歲 做分群
    END as
		Age_Group
    FROM
        Customers
)
SELECT
    Age_Group,
    SUM(CASE                                                        --  當性別為 男 or 女，記為1，否則為0，再進行總和
			WHEN C.Gender = 'Male' THEN 1 ELSE 0 END) as Male,
    SUM(CASE
			WHEN C.Gender = 'Female' THEN 1 ELSE 0 END) as Female,
    COUNT(*) as Total
FROM
    AG
JOIN
    Customers C
USING
    (CustomerID)
GROUP BY
    1
ORDER BY
    1;