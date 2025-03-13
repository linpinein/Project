/**************************************************************************************
1. 觀察 Score 的分布狀況
**************************************************************************************/
CREATE VIEW Score_Stats
	as
WITH Score_Dist as (
	SELECT
		Score,
		count(Score) as Score_Count,
		round(count(Score) * 100.0 / sum(count(Score)) OVER () , 2) ||'%' as Score_Percentage
	FROM
		TX_Restaurant
	GROUP by
		1
),

/**************************************************************************************
2. 找出 Score 的統計資料
	- 先算出每行的百分比排名
	- 算出平均數、最大小值、四分位數
**************************************************************************************/

Score_Rank as (
	SELECT
		Score,
		percent_rank() over (ORDER by Score) as S_Rank
	FROM
		TX_Restaurant
),
Score_IQR as (
	SELECT
		round(avg(Score) , 2) as 'Avg',
		min(Score) as 'Min',
		min(CASE WHEN S_Rank >= 0.25 THEN Score END) AS Q1,
		min(CASE WHEN S_Rank >= 0.50 THEN Score END) AS Q2,
		min(CASE WHEN S_Rank >= 0.75 THEN Score END) AS Q3,
		max(Score) as 'Max'
	FROM 
		Score_Rank
)

/**************************************************************************************
3. 列出 Score 的統計資料
**************************************************************************************/

SELECT
	*
FROM
	Score_IQR;
