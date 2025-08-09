-- check duplicate
SELECT ride_id, COUNT(*) AS count
FROM tripdata
GROUP BY ride_id
HAVING COUNT(*) > 1;

-- check logic start-end
select  *
FROM tripdata
WHERE ended_at < started_at;

-- Remove logic start-end
DELETE FROM tripdata
WHERE ended_at < started_at;

-- check 1m>trips>24hrs
SELECT *
FROM tripdata
WHERE TIMESTAMPDIFF(second, started_at, ended_at) < 60
   OR TIMESTAMPDIFF(second, started_at, ended_at) > 86400;

-- Remove 1m>trips>24hrs
delete
FROM tripdata
WHERE TIMESTAMPDIFF(second, started_at, ended_at) < 60
   OR TIMESTAMPDIFF(second, started_at, ended_at) > 86400;

-- value classification 
SELECT DISTINCT rideable_type 
FROM tripdata;

SELECT DISTINCT member_casual  
FROM tripdata;

-- check white space
SELECT *
FROM tripdata
WHERE LENGTH(rideable_type) != LENGTH(TRIM(rideable_type))
   OR LENGTH(start_station_name) != LENGTH(TRIM(start_station_name))
   OR LENGTH(start_station_id) != LENGTH(TRIM(start_station_id))
   OR LENGTH(end_station_name) != LENGTH(TRIM(end_station_name))
   OR LENGTH(end_station_id) != LENGTH(TRIM(end_station_id))
   OR LENGTH(member_casual) != LENGTH(TRIM(member_casual));

-- remove whitespace
UPDATE tripdata
SET 
    start_station_name = TRIM(start_station_name),
    start_station_id = TRIM(start_station_id),
    end_station_name = TRIM(end_station_name),
    end_station_id = TRIM(end_station_id);
    
-- Filter rows where exactly all 4 columns are empty
SELECT *
FROM tripdata
WHERE TRIM(start_station_name) = ''
   and TRIM(end_station_name) = ''
   and TRIM(start_station_id) = ''
   and TRIM(end_station_id) = '';

-- Filter rows where exactly 1 out of 4 columns is non-empty
SELECT *
FROM tripdata
WHERE
    (TRIM(start_station_name) != '') +
    (TRIM(end_station_name) != '') +
    (TRIM(start_station_id) != '') +
    (TRIM(end_station_id) != '') = 1;

-- create new colunmn for ride length
alter table tripdata 
add column ride_length varchar(8);

update tripdata 
set ride_length= SEC_TO_TIME(TIMESTAMPDIFF(second, started_at, ended_at));
  
ALTER TABLE tripdata
MODIFY COLUMN ride_length VARCHAR(8)
AFTER ended_at;

-- create new column for day of week
ALTER TABLE tripdata 
ADD COLUMN day_of_week INT;

UPDATE tripdata
SET day_of_week = (WEEKDAY(started_at) + 1) % 7 + 1;

ALTER TABLE tripdata
MODIFY COLUMN  day_of_week int
after rideable_type;

-- clean id coloumns
UPDATE tripdata
SET start_station_id = CAST(FLOOR(start_station_id) AS CHAR)
WHERE start_station_id REGEXP '^[0-9]+\\.0$';

UPDATE tripdata
SET end_station_id = CAST(FLOOR(end_station_id) AS CHAR)
WHERE end_station_id REGEXP '^[0-9]+\\.0$';

-- remove null from lat, long columns
delete from tripdata  
where end_lat is null or end_lng is null;

-- create table for top station
CREATE TABLE tripdata_valid_station AS
SELECT *
FROM tripdata
WHERE NOT (
    (TRIM(start_station_name) = '')
 AND (TRIM(end_station_name) = '')
 AND (TRIM(start_station_id) = '')
 AND (TRIM(end_station_id) = '')
);





