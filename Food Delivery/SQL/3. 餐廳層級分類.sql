/**************************************************************************************************************************************
1. Score 的四分位數的3段分群
**************************************************************************************************************************************/

ALTER TABLE																		-- 預先建立 Restaurant_Level 欄位，以便後續 UPDATE 語句能正確寫入 餐廳層級分類
	TX_Restaurant
ADD COLUMN
	Restaurant_Level VARCHAR(30);

WITH Res_Score_Cat as (															-- 餐廳評分分類
    SELECT
		TXR.Restaurant_Id,
        CASE
            WHEN Score >= SS.Min AND Score < SS.Q1 THEN 'Low'					-- Min → Q1（1.3~4.4）：低評分餐廳
            WHEN Score >= SS.Q1 AND Score < SS.Q3 THEN 'Normal'					-- Q1 → Q3（4.5~4.7）：中評分
            ELSE 'High'															-- Q3 → Max（4.8~5.0）：高評分
        END as Score_Category
    FROM
        TX_Restaurant TXR,
        Score_Stats SS
),

/**************************************************************************************************************************************
2. Score 的四分位數分群
	- Min → Q1：低評論數餐廳 / Q1 → 199：中評論數 / 200 → Max：高評論數
	- 從圖表中發現，200評論數有大量的餐廳，因此以200以上則評論數為中、高評論數的 分群間隔
**************************************************************************************************************************************/

Res_Comments_Cat as (
    SELECT
		TXR.Restaurant_Id,
        CASE
            WHEN Comments >= RS.Min AND Comments < RS.Q1 THEN 'Low'				-- Min → Q1（10~28）
            WHEN Comments >= RS.Q1 AND Comments < '200' THEN 'Normal'			-- Q1 → 199（29~199）
            ELSE 'High'															-- 200 → Max（200~500）
        END as Comments_Category
    FROM
        TX_Restaurant TXR,
        Comments_Stats RS
),

/**************************************************************************************************************************************
3. 餐廳層級分類
	- 在評級系統中，必須要先有評分才可以進行評論 → 評論數的多寡影響評分的高低
		-- 待觀察：All評分  + Low評論（評論數量不足，因此列入待觀察名單）
		-- 待改進：Low評分 + Normal、High評論
		-- 一般餐廳：Normal評分 + Normal、High評論
		-- 熱門餐廳：High評分 + Normal、High評論
**************************************************************************************************************************************/

Res_level as (
	SELECT
		TXR.Restaurant_Id,
		Res_Score_Cat.Score_Category,
		Res_Comments_Cat.Comments_Category,
		CASE
			WHEN Score_Category in ('Low' , 'Normal' , 'High') AND Comments_Category = 'Low' THEN 'To_Observe'
			WHEN Score_Category = 'Low' AND Comments_Category in ('Normal' , 'High') THEN 'To_Improve'
			WHEN Score_Category = 'Normal' AND Comments_Category in ('Normal' , 'High') THEN 'Normal'
			WHEN Score_Category = 'High' AND Comments_Category in ('Normal' , 'High')  THEN 'Popular'
		END as
			Restaurant_Level
	FROM
		TX_Restaurant TXR
	LEFT JOIN
		Res_Score_Cat
	USING
		(Restaurant_Id)
	LEFT JOIN
		Res_Comments_Cat
	USING
		(Restaurant_Id)
)

/**************************************************************************************************************************************
4. 更新原資料表
**************************************************************************************************************************************/

UPDATE
	TX_Restaurant as TXR
SET
	Restaurant_Level = (
		SELECT
			Restaurant_Level
		FROM
			Res_level as RL
		WHERE
			TXR.Restaurant_Id = RL.Restaurant_Id
	);