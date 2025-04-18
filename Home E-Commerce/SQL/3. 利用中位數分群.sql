/**************************************************************************************
4. RFM分群：以中位數分群，符合以下條件的客戶 分群 "non-VIP"、"VIP"
	- 客戶RFM符合 VIP條件：
		1. 最近一次消費日期 離 中位數 近：Date_diff（R）<= Mid_R
		2. 累計消費次數 >= 中位數：Purchase_count（F）>= Mid_F
		3. 累計消費金額 >= 中位數：Purchase_sum（M）>= Mid_M
**************************************************************************************/
CREATE VIEW 
	RFM_VIP_Grouping as
SELECT 
	RA.*,
    CASE
		WHEN "Date_diff(R)" <= Mid_R
		AND "Purchase_count(F)" >= Mid_F
		AND "Purchase_sum(M)" >= Mid_M
	THEN
		"VIP"
	ELSE
		"non-VIP"
	END as 
		Grouping
FROM
	RFM_analyze RA,
	RFM_median