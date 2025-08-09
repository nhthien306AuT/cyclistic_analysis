-- user group percentage
select 
	member_casual,
	count(*) as ride_count,
	round(100*count(*)/ (select count(*) from tripdata),2) as percentage
from tripdata
group by member_casual;

-- percentage between vehicle types
select 
	rideable_type, 
	member_casual,
	round(count(*) * 100 / sum(count(*)) over(partition by member_casual),2) as percent_in_group
from tripdata
group by member_casual, rideable_type;

-- popular station ranking
with station_counts as(
	select 
		'start_station' as station_type,
		start_station_id as station_id,
		count(*) as ride_count
	from tripdata_valid_station
	where trim(start_station_id) != ''
	group by start_station_id
	union all 
	select 
		'end_station' as station_type,
		end_station_id as station_id,
		count(*) as ride_count
	from tripdata_valid_station 
	where trim(end_station_id) != ''
	group by end_station_id ),
ranked as (
	select *,
		row_number() over(partition by station_type order by ride_count desc) as rn_desc,
		row_number() over(partition by station_type order by ride_count asc) as rn_asc
	from station_counts)
select 
	station_type,
	station_id,
	ride_count,
	case
		when rn_desc <=5 then 'top 5 popular stations'
		when rn_asc <=5 then 'top 5 least popular stations'
		else 'other'
	end as rank_group 
from ranked  
where rn_desc <=5 or rn_asc <=5 
order by station_type, rank_group, ride_count desc; 
	


-- get the average trip duration of member & casual riders
SELECT 
    member_casual,
    ROUND(AVG(TIME_TO_SEC(ride_length)) / 60, 2) AS avg_minutes
FROM tripdata
GROUP BY member_casual;

-- get day of week mode
select 
	member_casual,
	day_of_week,
	count(*) as ride_count
from tripdata 
group by member_casual, day_of_week
order by ride_count;

-- get the month mode
select 
	member_casual,
	month(started_at) as month,
	count(*) as ride_count
from tripdata 
group by member_casual, month
order by member_casual, ride_count;

-- heatmap
select 
	lat,
	lng,
	count(*) as trip_count,
	CASE 
        WHEN COUNT(*) < 100 THEN 'very low'
        WHEN COUNT(*) BETWEEN 100 AND 999 THEN 'low'
        WHEN COUNT(*) BETWEEN 1000 AND 9999 THEN 'normal'
        WHEN COUNT(*) BETWEEN 10000 AND 29999 THEN 'high'
        ELSE 'very high'
    END AS usage_level
from (
	select start_lat as lat, start_lng as lng from tripdata
	union all
	select end_lat as lat, end_lng as lng from tripdata
	) as all_locations
group by lat, lng
order by trip_count;

--  Hour mode
SELECT 
  member_casual,
  day_of_week,
  HOUR(started_at) AS hour,
  'start' AS event_type,
  COUNT(*) AS trip_count
FROM tripdata
GROUP BY member_casual, day_of_week, hour
UNION ALL
SELECT 
  member_casual,
  day_of_week,
  HOUR(ended_at) AS hour,
  'end' AS event_type,
  COUNT(*) AS trip_count
FROM tripdata
GROUP BY member_casual, day_of_week, hour
ORDER BY day_of_week, hour, event_type;







	
