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
	
------------------------------------------------------------------------------------------------------------
	
-- List of songs on spotify that reached the top of the billboards for at least one week 
-- 186 total rows displayed
select distinct spotify_top_songs.artist, spotify_top_songs.song, spotify_top_songs.popularity, billboard_top.peak_rank
from spotify_top_songs
left join billboard_top on spotify_top_songs.song = billboard_top.song
where billboard_top.peak_rank = 1
order by spotify_top_songs.popularity desc;

------------------------------------------------------------------------------------------------------------

-- According to spotify, the majority of songs that last the longest on the billboard charts
-- tend to not be explicit
select distinct spotify_top_songs.explicit, billboard_top.weeks_on_board
from spotify_top_songs
left join billboard_top on spotify_top_songs.song = billboard_top.song
where billboard_top.weeks_on_board > 1
order by billboard_top.weeks_on_board desc;

------------------------------------------------------------------------------------------------------------

-- While it looks like songs with lower bpm tended to be lower on the charts compared to higher bpm songs,
-- it's a bit of a toss up on peak rank once a song gets past the 114+ bpm range
select distinct (max(spotify_top_songs.tempo) - min(spotify_top_songs.tempo)) as bpm_range, 
billboard_top.peak_rank
from spotify_top_songs
left join billboard_top on spotify_top_songs.song = billboard_top.song
group by billboard_top.peak_rank
order by bpm_range;

	