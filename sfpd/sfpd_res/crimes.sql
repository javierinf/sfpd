DROP DATABASE IF EXISTS crimesdb;
CREATE DATABASE crimesdb;
\c crimesdb;

DROP TABLE  IF EXISTS crimes CASCADE;
CREATE TABLE crimes (
  analysis_neighborhood VARCHAR(50),
  cad_number INTEGER,
  cnn VARCHAR(255),
  filed_online BOOLEAN,
  incident_category VARCHAR(50),
  incident_code INTEGER,
  incident_date DATE,
  incident_datetime TIMESTAMP,
  incident_day_of_week VARCHAR(15),
  incident_description VARCHAR(255),
  incident_id INTEGER,
  incident_number INTEGER,
  incident_subcategory VARCHAR(40),
  incident_time TIME,
  incident_year INTEGER,
  intersection VARCHAR(100),
  latitude float8,
  longitude float8,
  point VARCHAR(255),
  police_district VARCHAR(30),
  report_datetime TIMESTAMP,
  report_type_code VARCHAR(50),
  report_type_description VARCHAR(255),
  resolution VARCHAR(50),
  row_id VARCHAR(50) PRIMARY KEY,
  supervisor_district VARCHAR(50)
);

\i 'loader.sql';

CREATE INDEX i1 on crimes (incident_datetime DESC);
CREATE INDEX i2 on crimes USING gist (tsrange(incident_datetime - interval '15 min',incident_datetime + interval '15 min','[]'));


UPDATE crimes
set point = replace(point,';',',');
ALTER TABLE crimes 
ALTER COLUMN point TYPE POINT USING point::point;

UPDATE crimes
set analysis_neighborhood = NULL WHERE analysis_neighborhood='null';

CREATE EXTENSION IF NOT EXISTS earthdistance CASCADE;

