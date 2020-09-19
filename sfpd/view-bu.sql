DROP VIEW crimes_aggregrate;



CREATE VIEW crimes_aggregrate as (
SELECT 
(date_trunc('hour', incident_datetime) + date_part('minute', incident_datetime)::int / 15 * interval '15 min') as incident_ts,
incident_id,
--array_to_string(array_agg(incident_category::text),'||') as incident_categories,
--min(incident_datetime) as first_incident_datetime,
--min(report_datetime) as first_report_datetime
count(incident_id) OVER(PARTITION BY analysis_neighborhood , (date_trunc('hour', incident_datetime) + date_part('minute', incident_datetime)::int / 15 * interval '15 min')  ) as neigborhood_incidents,
CASE WHEN (SELECT min(dist) FROM 
            (SELECT (c.point::point <@> cc.point::point) AS dist 
               FROM crimes cc where (cc.point is not null) AND (tsrange(cc.incident_datetime - interval '15 min',cc.incident_datetime + interval '15 min','[]') @> c.incident_datetime)
                 AND (c.point != cc.point)) as a)*1.60934 > 1 THEN true
            ELSE false
            END as nearby_suspicious_activity


FROM crimes c
where  (c.point is not null)
GROUP BY incident_id,incident_datetime,analysis_neighborhood,point
ORDER BY incident_datetime,analysis_neighborhood
  
);

SELECT * FROM crimes_aggregrate;