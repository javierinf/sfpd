# SF Crime Report Analysis

## Data & Analytics Engineering

## Introduction 
This challenge will test both schema design and analytics skills by requiring you to analyze crime report data from the San Francisco California police department. Consider the included file [sf_crime_reports.csv](sf_crime_reports.csv). This dataset is in [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) format. The first line contains the column names. For example, here are the first 5 lines of the file:

```csv
analysis_neighborhood,cad_number,cnn,filed_online,incident_category,incident_code,incident_date,incident_datetime,incident_day_of_week,incident_description,incident_id,incident_number,incident_subcategory,incident_time,incident_year,intersection,latitude,longitude,point,police_district,report_datetime,report_type_code,report_type_description,resolution,row_id,supervisor_district
Bernal Heights,180010563,21236000,,Robbery,03073,2018/01/01,2018/01/01 01:30:00 AM,Monday,"Robbery; W/ Other Weapon",618702,180000263,Robbery - Other,01:30,2018,JUSTIN DR \ COLLEGE AVE,37.732261252752224,-122.42348641495892,"(37.732261252752224; -122.42348641495892)",Ingleside,2018/01/01 02:13:00 AM,II,Initial,Open or Active,61870203073,9
Mission,180010504,24170000,,Fire Report,68000,2018/01/01,2018/01/01 01:59:00 AM,Monday,Fire Report,618707,180000326,Fire Report,01:59,2018,16TH ST \ MISSION ST,37.76505133632968,-122.41966897380142,"(37.76505133632968; -122.41966897380142)",Mission,2018/01/01 01:59:00 AM,II,Initial,Open or Active,61870768000,9
South of Market,180010636,20657000,,Assault,04134,2018/01/01,2018/01/01 02:28:00 AM,Monday,Battery,618709,180000348,Simple Assault,02:28,2018,03RD ST \ PERRY ST,37.78211912156566,-122.39684142850209,"(37.78211912156566; -122.39684142850209)",Southern,2018/01/01 02:31:00 AM,II,Initial,Open or Active,61870904134,6
South of Market,180010636,20657000,,Malicious Mischief,28160,2018/01/01,2018/01/01 02:28:00 AM,Monday,"Malicious Mischief; Vandalism to Vehicle",618709,180000348,Vandalism,02:28,2018,03RD ST \ PERRY ST,37.78211912156566,-122.39684142850209,"(37.78211912156566; -122.39684142850209)",Southern,2018/01/01 02:31:00 AM,II,Initial,Open or Active,61870928160,6
```

## Requirements

You will need to install PostgreSQL to complete this challenge.

* [PostgreSQL 10.3+](https://www.postgresql.org/)

## Deliverables

Please submit an archived file (zip, tar, etc.) containing the files listed below. More details on each deliverable will be given in subsequent sections. If you run into any issues or have questions about anything related to this challenge, please reach out to your ASAPP contact and we will get back to you promptly. 

Also, the purpose of this project is to gauge your data analysis and schema design skills, not to unnecessarily take up your time. Please complete as much as you can, and don't feel discouraged if you submit an incomplete solution. We appreciate your time and efforts!

* README.md -- A written overview of each of your solutions and instructions on running them.
* Part 1
  - crimes.sql
* Part 2
  - queries.sql
* Part 3
  - view.sql

## Part 1 - Schema Design & Loading Data

The first step of this challenge is to design a schema for the crime report data. You can inspect the data however you'd like and use your best judgement on what data types to use for each column. We've included [sf_police_data_dictionary.pdf](sf_police_data_dictionary.pdf), which explains each field in the dataset more in depth and can give you some indicators on data types. Use `crimes.sql`, which includes the column names to get you started.

### The Identifiers
Note the difference between `row_id` and `incident_id` as this distinction will be important during analysis. `row_id` is unique per entry throughout the dataset, but an `incident_id` can appear more than once with varying `incident_number` and `incident_code` values.

Here is our understanding of `incident_number`, `incident_id`, and `incident_code`:
* The `incident_number` is the identifier for the overarching problem the police are trying to solve. The documentation mentions that it can be thought of as a case number.
* An incident is a specific occurrence that happened at some point in time and at a specific location within the context of a case. There can be multiple incidences to a case, for example the initial crime being committed and then the suspect being arrested the next day would both be different `incident_id` values with the same case_number (incident_number).
* For `incident_code`, within an incident there can technically be multiple events or activities happening at the same place and time. For example, the police have an existing warrant for a suspect's arrest and apprehend that individual while they are in the process of committing another crime.


Once you've created a crimes schema and built the table in Postgres, the next step is to load the data in `sf_crime_reports.csv` into that table using `loader.sql`. You have to update the path to reference the full path to the file on your computer.

Before continuing, confirm that all of the data was properly loaded.

```sql
rsdb=# select count(*) from crimes;
count  
--------
111531
(1 row)
```

## Part 2 - Analytics

The next part of this challenge is to answer some questions about the SF police report dataset using PostgreSQL. Add each of your queries to `queries.sql` and include each result in a comment.

1. How many burglaries occurred in the South of Market neighborhood between 2018-05-01 and 2018-05-31 inclusive?

2. Across the entire dataset, what are the top five neighborhoods with the fewest number of reported incidents? (Note: ignoring null/unknown neighborhood)

3. Which police district has the most open/active incidents? Which has the fewest?

## Part 3 - Aggregate Design

Design a view that manipulates `crimes` to produce the following fields:

* `incident_ts` - The `incident_datetime` rounded down to the nearest 15-minute mark. There are four 15 minute marks within an hour `:00`, `:15`, `:30`, `:45`. For example, `2018-01-01 07:44:00` would become `2018-01-01 07:30:00`, `2018-01-01 09:15:00` would remain `2018-01-01 09:15:00`, and `2018-01-01 10:04:00` would become `2018-01-01 10:00:00`.
* `incident_id` - ID of the incident
* `incident_categories` - Double-pipe delimited string of all incident_category records for a given `incident_id`. Consider `incident_id` 618701 for example: `Other Miscellaneous||Traffic Violation Arrest||Vehicle Impounded`
* `first_incident_datetime` - Chronologically first value of `incident_datetime` for the incident
* `first_report_datetime` - Chronologically first value of `report_datetime` for the incident
* `neigborhood_incidents` - Total number of unique incidents (including this one) that occurred within the same neighborhood as this incident within the timeframe of ``incident_ts`` (inclusive) to `incident_ts + 15 minutes` (exclusive). For example, if the `first_incident_datetime` was `2018-01-01 07:44:00`, the `incident_ts` would be `2018-01-01 07:30:00` and the upper bound of the timeframe would be `2018-01-01 07:45:00`.

Extra credit
* `nearby_suspicious_activity` - A boolean flag indicating if there was nearby nearby suspicious activity. Using the `latitude` and `longitude` fields, estimate the [geographic distance](https://en.wikipedia.org/wiki/Great-circle_distance) between this incident and all others that occurred within 15 minutes of this. Report true if there exists at least 1 other incident within the last 15 minutes that is within 1 kilometer of this one, false otherwise.

Add your solution to `view.sql`
