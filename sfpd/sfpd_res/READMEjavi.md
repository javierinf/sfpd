# SF Crime Report Analysis


## Introduction

This is a short overview of the solutions for the Data & Analytics Engineering challenge. On the following sections I will explain how to run the solutions and how this results were achived.


## Requirements & first steps

PostgreSQL is needed to run this files and queries: [PostgreSQL](https://www.postgresql.org/) 

Open a terminal tab on the folder where the files are located and login to the default database running:
```bash
psql postgres
```
Create a new DB named crimesdb and connect to it:
```sql
CREATE DATABASE crimesdb;
```
```sql
\c crimesdb;
```
## Part one - crimes.sql
To execute the first part, you must type:

```sql
 \i 'crimes.sql'
```
This will create the table `crimes`. 
A few considerations:
* `row_id` was selected as Primary Key as is the unique identifier for every record.
* `point` was loaded as `VARCHAR` and then transformed into `POINT`
*  After the table creation, data was loaded calling `loader.sql` 
* Indexes `i1` and `i2` were created to increase query performance
* some `analysis_neighborhood` were loaded as string 'null' but then set to real `NULL`
* Extension `earthdistance` was installed

## Part two - queries.sql
To execute the second part, you must type:

```sql
 \i 'queries.sql'
```
Please note that this requires `crimes.sql` to be runned before to create a load data into the table.
### First query:
`incident_id` was used to count the number of occurrences according to the documentation dictates.
```sql
SELECT 
count(DISTINCT incident_id) AS Burglaries_in_South_of_Market 
FROM 
crimes
WHERE 
(analysis_neighborhood = 'South of Market') 
AND 
(incident_category = 'Burglary') 
AND 
(incident_date BETWEEN '2018-05-01' AND '2018-05-31')
```
Results : 48 Burglaries
### Second query:
`incident_number` were counted grouped by `analysis_neighborhood` and sorted `ASC` ignoring `NULL` values. The query was limited to five in order to retrieve the top 5.
```sql
SELECT 
DISTINCT analysis_neighborhood,
 count (DISTINCT incident_number) AS reported_incidents 
 FROM crimes 
 WHERE (analysis_neighborhood IS NOT null)  
 GROUP BY analysis_neighborhood 
 ORDER BY count(DISTINCT incident_number) ASC LIMIT 5;
```
Results:
```sql
 analysis_neighborhood | reported_incidents 
-----------------------+--------------------
 McLaren Park          |                 57
 Lincoln Park          |                 79
 Seacliff              |                 97
 Presidio              |                158
 Treasure Island       |                268
(5 rows)
```
### Third query:
A CTE was used to group by `police_distric` and select and count the number of required `resolutions` 
```sql
WITH CTE_gp AS 
(SELECT 
DISTINCT police_district,
 count (DISTINCT incident_number) AS active_incidents 
 FROM crimes 
 WHERE (resolution= 'Open or Active')  
 GROUP BY police_district 
 ORDER BY count(DISTINCT incident_number) ASC)
```
Then this CTE was used on two subqueries (one for MAX and one for MIN) :
```sql
(SELECT 'Max' AS max_min, police_district, active_incidents FROM CTE_gp ORDER BY active_incidents DESC LIMIT 1)
UNION
(SELECT 'Min' AS max_min, police_district, active_incidents FROM CTE_gp ORDER BY active_incidents ASC LIMIT 1);
```
Results:
```sql
 max_min | police_district | active_incidents 
---------+-----------------+------------------
 Max     | Central         |            11679
 Min     | Out of SF       |             2020
(2 rows)
```

## Part three - view.sql
# SF Crime Report Analysis



## Part three - view.sql
To execute the first part, you must type:

```sql
 \i 'view.sql'
```
This will create a view named `crimes_aggregrate`
### incident_ts
This column was calculated using this expression which eliminates the decimal part resulting by dividing the num of minutes by 15:
```sql
date_trunc('hour', incident_datetime) + 
date_part('minute', incident_datetime)::INT / 15 * INTERVAL '15 min'
```
### incident_categories
Was created by concatenating all the unique values on a string, grouped by `incident_id`
```sql
    array_to_string(array_agg(incident_category::text),'||')
```
### first_incident_datetime and first_report_datetime 
Were calculated as the min datetime value over a window partitioned by `incident_id` 
```sql
    min(incident_datetime) OVER(PARTITION BY incident_id) as first_incident_datetime,
    min(report_datetime) OVER(PARTITION BY incident_id) as first_report_datetime,
```
### neigborhood_incidents
Counted `incident_id` over a window partitioned by `analysis_neighborhood` and `incident_ts`
```sql
COUNT(incident_id) OVER(PARTITION BY analysis_neighborhood , 
    (
      date_trunc('hour', incident_datetime) + date_part('minute', incident_datetime)::INT / 15 * INTERVAL '15 min'
    )
```

### nearby_suspicious_activity
In order to decide if this flag should be True or False, it calculates all the distances from a record to every other in the TSRANGE. This decision was made in order to use gist indexing and drastically reduce performance time.

[Point based earth distance](https://www.postgresql.org/docs/9.3/earthdistance.html) were used to calculate the distance between points. This operator uses points with `(longitude,latitude)` format so I created the string and casted it to point.

The result was multiplied by 1.60934 to convert from miles to km.

```sql
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
```

