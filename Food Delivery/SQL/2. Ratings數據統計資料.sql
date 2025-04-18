/**************************************************************************************
1. 觀察 Comments 的分布狀況
**************************************************************************************/
CREATE VIEW Comments_Stats
	as
WITH Comments_Dist as (
	SELECT
		Comments,
		count(Comments) as Comments_Count,
		round(count(Comments) * 100.0 / sum(count(Comments)) OVER () , 2) ||'%' as Comments_Percentage
	FROM
		TX_Restaurant
	GROUP by
		1
),

/**************************************************************************************
2. 找出 Comments 的統計資料
	- 先算出每行的百分比排名
	- 算出平均數、最大小值、四分位數
**************************************************************************************/

Comments_Rank as (
	SELECT
		Comments,
		percent_rank() over (ORDER by Comments) as R_Rank
	FROM
		TX_Restaurant
),
Comments_IQR as (												-- Comments欄位的四分位數呈現
	SELECT
		round(avg(Comments) , 2) as 'Avg',
		min(Comments) as 'Min',
		min(CASE WHEN R_Rank >= 0.25 THEN Comments END) AS Q1,
		min(CASE WHEN R_Rank >= 0.50 THEN Comments END) AS Q2,
		min(CASE WHEN R_Rank >= 0.75 THEN Comments END) AS Q3,
		max(Comments) as 'Max'
	FROM 
		Comments_Rank
)

/**************************************************************************************
3. 列出 Comments 的統計資料
	- 至「統計表csv.」繪製圖表
**************************************************************************************/

SELECT
	*
FROM
	Comments_IQR;
