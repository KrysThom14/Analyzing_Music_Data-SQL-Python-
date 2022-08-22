--Before running the queries below, I manually 
--updated/simplified the genre column

--Converted duration of songs from milliseconds to seconds
update spotify_top_songs
set duration_ms = duration_ms * 0.001;

alter table spotify_top_songs 
rename column duration_ms to duration_sec;

-------------------------------------------------------------

--Check for any duplicates
select song, artist, count(*)
from spotify_top_songs
group by song, artist
having count(*) > 1;

--Deleted duplicates
with spotify_cte as
(select *, row_number() over(partition by song, artist order by song) as row_num
from spotify_top_songs)
delete from spotify_cte
where row_num > 1;
--Went from 2,000 rows to 1,845 rows

---------------------------------------------------------------

--Check to see which genres were listened to the most
select distinct genre, count(genre) as num_songs
from spotify_top_songs
group by genre
order by num_songs desc;

----------------------------------------------------------------

--Top 20 most popular songs and their respective BPM
select artist, song, popularity, tempo
from spotify_top_songs
order by popularity desc
limit 20;

-----------------------------------------------------------------

--# of explicit songs per genre
select genre, count(explicit) as num_explicit
from spotify_top_songs
where explicit = 'TRUE'
group by genre
order by num_explicit desc;

------------------------------------------------------------------

--# of songs in each genre grouped by year, as well as
--the total # of songs within each year
select year, genre, count(*) as songs_per_genre, 
sum(count(*)) over(partition by year order by year) as songs_per_year
from spotify_top_songs
group by year, genre
order by year;

