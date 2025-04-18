/**************************************************************************************
1-1. 計算2021、2022年的 新客數
	- 找出Customers表中FirstTransactionYear欄 各年份出現的顧客總數
**************************************************************************************/

WITH New_Cus_Count as (
    SELECT
        FirstTransactionYear as 'Year',
        count(CustomerId) as 'New_Cus'
    FROM
        Customers C
    WHERE
        FirstTransactionYear in (2021, 2022)
    GROUP BY
        FirstTransactionYear
)

/**************************************************************************************
1-2. 計算2021、2022年的 回購數（回購：於同一年份，再次購買）
	- 找出Customers表中 每個客戶 的 FirstTransactionYear
	- 找出Orders表中 每個客戶 的 TransactionYear
	- 同一年份中，再次出現該 客戶，視為該客戶 回購
**************************************************************************************/

, Rebuy_Count as (
	SELECT DISTINCT
		C.CustomerId,
		O.TransactionYear as 'Year'
	FROM
		Customers C
	JOIN
		Orders O
	USING
		(CustomerId)
	WHERE
		C.FirstTransactionYear = O.TransactionYear			-- 首購年份 = 購物年份
	GROUP BY
		1
	HAVING
		count(C.CustomerId) >= 2							-- 該CustomerId出現2次以上，且於同一年份，才篩選為「回購」
)

/**************************************************************************************
1-3. 統整合併顯示 新客數、回購數、回購率
**************************************************************************************/

SELECT
    NCC.Year,
    NCC.New_Cus as '新客數',
    count(RC.CustomerId) as '回購數',
    round(count(RC.CustomerId) * 100.0 / NCC.New_Cus, 1)  || '%' as '回購率'
FROM
    New_Cus_Count NCC
JOIN
	Rebuy_Count RC
on
	NCC.Year = RC.Year
GROUP by
	1
ORDER BY
	1;