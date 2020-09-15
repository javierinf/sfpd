-- 
-- Run this COPY statement to load the sf_crime_reports.csv into your table.
-- Be sure to replace table name `crimes` with the actual name of your table if you named it differently.
-- Also, the '/path/to/file/' filepath needs to be updated to be the full path to the file on your computer.
--
\COPY crimes (analysis_neighborhood,cad_number,cnn,filed_online,incident_category,incident_code,incident_date,incident_datetime,incident_day_of_week,incident_description,incident_id,incident_number,incident_subcategory,incident_time,incident_year,intersection,latitude,longitude,point,police_district,report_datetime,report_type_code,report_type_description,resolution,row_id,supervisor_district)
FROM '/path/to/file/sf_crime_reports.csv'
WITH DELIMITER ',' CSV HEADER ;


-- Confirm the result:
-- COPY 111531
