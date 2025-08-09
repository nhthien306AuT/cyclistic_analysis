-- count rows
SELECT COUNT(*) FROM tripdata;
-- count ride id
SELECT COUNT(DISTINCT ride_id) AS unique_ride_ids FROM tripdata;