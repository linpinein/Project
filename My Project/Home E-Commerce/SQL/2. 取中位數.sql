/**************************************************************************************
2. 取RFM數據的「中位數」，將客戶做 VIP 與 non-VIP 的分群
	- RFM_analyze 列出編號
	- 根據編號求出R、F、M的中位數
**************************************************************************************/

/**************************************************************************************
-- Date_diff（R）的中位數（最近一次消費日期）
**************************************************************************************/
CREATE VIEW 
	RFM_Median as 
WITH Rank_R as (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY "Date_diff(R)") as Row_num,		-- 給每行編號
        "Date_diff(R)"												-- 抓這一欄的 中位數
    FROM 
        RFM_analyze
),
Total_count_1 as (													-- 計算總行數
    SELECT
		MAX(Row_num) as Row_count									-- Row_num 最大值 = 總行數
	FROM
		Rank_R
),
Median_R as (
	SELECT
		avg("Date_diff(R)") as Mid_R									-- 配合下列 WHERE，如果總行數為「偶數」，中位數 = 篩選出的兩個數「平均數」
	FROM 
		Rank_R,
		Total_Count_1
	WHERE	
		Row_num IN ((Row_count + 1) / 2, (Row_count + 2) / 2)		-- 找 ROW_num 的中位數在哪一行（假設行數為7、8）：
),																		-- ROW_num 為奇數 7 → Row_num IN ( 4 , 4.5(4) ) → 中位數在第4行 → 取avg
																		-- ROW_num 為偶數 8 → Row_num IN ( 4.5(4) , 5 ) → 中位數在第4、5行 → 取avg

/**************************************************************************************
-- purchase_count（F）的中位數（每個客戶累計消費次數）
**************************************************************************************/

Rank_F as (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY "Purchase_count(F)") as Row_num,
		"Purchase_count(F)"
    FROM 
        RFM_analyze
),
Total_count_2 as (
    SELECT
		MAX(Row_num) as Row_count
	FROM
		Rank_F
),
Median_F as (
	SELECT
		avg("Purchase_count(F)") as Mid_F
	FROM 
		Rank_F,
		Total_Count_2
	WHERE	
		Row_num IN ((Row_count + 1) / 2, (Row_count + 2) / 2)
),
	
/**************************************************************************************
-- purchase_sum（M）的中位數（累計消費金額）
**************************************************************************************/

Rank_M as (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY "Purchase_sum(M)") as Row_num,
        "Purchase_sum(M)"
    FROM 
        RFM_analyze
),
Total_count_3 as (
    SELECT
		MAX(Row_num) as Row_count
	FROM
		Rank_M
),
Median_M as (
	SELECT
		avg("Purchase_sum(M)") as Mid_M
	FROM 
		Rank_M,
		Total_Count_3
	WHERE	
		Row_num IN ((Row_count + 1) / 2, (Row_count + 2) / 2)
)
		
/**************************************************************************************
-- 合併列出R、F、M 中位數
**************************************************************************************/

SELECT
	Mid_R,
	Mid_F,
	Mid_M
FROM
	Median_R,
	Median_F,
	Median_M