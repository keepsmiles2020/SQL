SELECT * FROM mairui

SELECT *,
ROW_NUMBER() over(PARTITION by  `分公司描述` ,`设备号` ORDER BY `填单完成日期` DESC, `填单完成时间` DESC) AS rk 
FROM mairui
WHERE `设备号` = '106-BB-02000033'

SELECT `分公司描述`,COUNT(DISTINCT `设备号`) c FROM mairui GROUP BY `分公司描述`

SELECT *,
TO_DAYS(`填单完成日期`)-LAG(TO_DAYS(`填单完成日期`)) over(PARTITION by  `分公司描述` ,`设备号` ORDER BY `填单完成日期`) AS diff_date,
ROW_NUMBER() over(PARTITION by  `分公司描述` ,`设备号` ORDER BY `填单完成日期` DESC,`填单完成时间` DESC) AS rk 
FROM mairui
WHERE `设备号` = '106-BB-02000033'



SELECT 
*
-- temp.`分公司描述`, 
-- COUNT(DISTINCT temp.`设备号`) AS count_1 -- 一次维修
FROM
(
	-- 筛选出一次性维修的设备
	SELECT *,
	TO_DAYS(`填单完成日期`)-LAG(TO_DAYS(`填单完成日期`)) over(PARTITION by  `分公司描述` ,`设备号` ORDER BY `填单完成日期`) AS diff_date,
	ROW_NUMBER() over(PARTITION by  `分公司描述` ,`设备号` ORDER BY `填单完成日期` DESC,`填单完成时间` DESC) AS rk 
	FROM mairui
) temp 
-- LEFT JOIN mairui mr 
-- ON temp.`单据号码` = mr.`单据号码`
WHERE 
-- 
(temp.diff_date > 60 AND temp.rk = 1) 
OR
(temp.diff_date IS NULL AND temp.rk = 1)
GROUP BY `分公司描述`

--------- 
SELECT 
t.`分公司描述`,
ROUND(t.count_1/t2.count_2,4)AS p 
FROM 
(
-- 筛选出一次性维修的设备
	SELECT 
	temp.`分公司描述`, 
	COUNT(DISTINCT temp.`设备号`) AS count_1 -- 一次维修
	FROM
	(
		-- 时间间隔差
		SELECT *,
		TO_DAYS(`填单完成日期`)-LAG(TO_DAYS(`填单完成日期`)) over(PARTITION by  `分公司描述` ,`设备号` ORDER BY `填单完成日期`) AS diff_date,
		ROW_NUMBER() over(PARTITION by  `分公司描述` ,`设备号` ORDER BY `填单完成日期` DESC,`填单完成时间` DESC) AS rk  -- 按日期排名
		FROM mairui
	) temp 
	WHERE 
	(temp.diff_date > 60 AND 	temp.rk = 1) OR
	(temp.diff_date IS NULL  AND temp.rk = 1)
	GROUP BY `分公司描述`
) t 
JOIN 
(
	-- 每个公司有多少台设备
	SELECT `分公司描述`,COUNT(DISTINCT `设备号`) count_2 FROM mairui GROUP BY `分公司描述`
) t2
ON t.`分公司描述` = t2.`分公司描述`
ORDER BY p DESC
