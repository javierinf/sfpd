
SELECT 
count(DISTINCT incident_id) AS Burglaries_in_South_of_Market FROM crimes WHERE (analysis_neighborhood = 'South of Market') AND (incident_category = 'Burglary') AND (incident_date BETWEEN '2018-05-01' AND '2018-05-31');

--burglaries_in_south_of_market 
-------------------------------
--                            48

SELECT DISTINCT
analysis_neighborhood, count (DISTINCT incident_number) AS reported_incidents FROM crimes WHERE (analysis_neighborhood IS NOT null)  GROUP BY analysis_neighborhood ORDER BY count(DISTINCT incident_number) ASC LIMIT 5;

-- analysis_neighborhood | reported_incidents 
-----------------------+--------------------
-- McLaren Park          |                 57
-- Lincoln Park          |                 79
-- Seacliff              |                 97
-- Presidio              |                158
-- Treasure Island       |                268

WITH CTE_gp AS (SELECT DISTINCT police_district, count (DISTINCT incident_number) AS active_incidents FROM crimes WHERE (resolution= 'Open or Active')  GROUP BY police_district ORDER BY count(DISTINCT incident_number) ASC)

(SELECT 'Max' AS max_min, police_district, active_incidents FROM CTE_gp ORDER BY active_incidents DESC LIMIT 1)
UNION
(SELECT 'Min' AS max_min, police_district, active_incidents FROM CTE_gp ORDER BY active_incidents ASC LIMIT 1);

--max_min | police_district | active_incidents 
---------+-----------------+------------------
-- Max     | Central         |            11679
-- Min     | Out of SF       |             2020