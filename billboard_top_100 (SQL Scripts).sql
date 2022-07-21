-- Initial exploration of data set
select *
from billboard_top
limit 10;

-----------------------------------------------------------------------------------------------------------

-- How many unique artists (w/ or w/o features) in data set
select count(distinct artist)
from billboard_top;

-----------------------------------------------------------------------------------------------------------

-- Observing the Date range of the data
select max(date), min(date)
from billboard_top;

-----------------------------------------------------------------------------------------------------------

-- Artists with the most songs on Billboard Top 100 
select artist, count(distinct song) as num_songs
from billboard_top
group by artist
order by num_songs desc
limit 10;

-----------------------------------------------------------------------------------------------------------

-- Top 10 Songs with the most weeks on the Billboard Top 100
select song, artist, count(distinct date) as num_weeks_on_board
from billboard_top
group by song, artist
order by num_weeks_on_board desc
limit 10;

-----------------------------------------------------------------------------------------------------------

-- List of songs within the top 15 spots with the most weeks on the Billboard Top 100 (grouped by year); 
-- Years with less songs shown means there was a much larger gap between the top song(s) 
-- and the less popular songs for that year
select distinct years, song, artist
from
	(select distinct years, song, artist,
	row_number() over (partition by years) as ranking
	from
		(select distinct years, song, artist, num_weeks_on_board, rank_id
		from
			(select years, song, artist, num_weeks_on_board,
			rank() over (partition by a.years order by a.num_weeks_on_board desc) as rank_id
			from
				(select extract(year from date) as years, song, artist, num_weeks_on_board
				from billboard_top
				group by date, song, artist, num_weeks_on_board
				order by date, song, artist, num_weeks_on_board) a
			order by years, song, artist) b
		where rank_id <= 15 and years >= 1999 and years <= 2019
		order by years) c) d;

