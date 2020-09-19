DROP VIEW crimes_aggregrate;
CREATE VIEW crimes_aggregrate AS 
(
  SELECT
(date_trunc('hour', incident_datetime) + date_part('minute', incident_datetime)::INT / 15 * INTERVAL '15 min') AS incident_ts,
    incident_id,
    array_to_string(array_agg(incident_category::text),'||') as incident_categories,
    min(incident_datetime) OVER(PARTITION BY incident_id) as first_incident_datetime,
    min(report_datetime) OVER(PARTITION BY incident_id) as first_report_datetime,
    COUNT(incident_id) OVER(PARTITION BY analysis_neighborhood , 
    (
      date_trunc('hour', incident_datetime) + date_part('minute', incident_datetime)::INT / 15 * INTERVAL '15 min'
    )
) AS neigborhood_incidents,
    CASE
      WHEN
        (SELECT
            MIN(dist) 
          FROM
            (SELECT
                (concat('(',c.longitude,',',c.latitude,')')::point <@> concat('(',cc.longitude,',',cc.latitude,')')::point) AS dist 
              FROM
                crimes cc 
              WHERE
                (cc.point IS NOT NULL)
                AND 
                (tsrange(cc.incident_datetime - INTERVAL '15 min', cc.incident_datetime + INTERVAL '15 min', '[]') @> c.incident_datetime)
                AND 
                (c.incident_id != cc.incident_id)
            ) AS a
        ) *1.60934 < 1 
      THEN
        TRUE 
      ELSE
        FALSE 
    END  AS nearby_suspicious_activity 
  FROM
    crimes c 
  WHERE
    (c.point IS NOT NULL)
  GROUP BY
    incident_id, incident_datetime, analysis_neighborhood,latitude,longitude,report_datetime
 ORDER BY
    incident_datetime, analysis_neighborhood );