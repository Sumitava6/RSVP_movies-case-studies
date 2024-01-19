create database imdb;

use imdb;

-- showing various tables in the database

show tables;

-- answer 1.
select * from director_mapping;
-- 3867 rows

select count(*) from genre;
-- 14662 rows

select count(*) from movie;
-- 7997 rows

select count(*) from names;
-- 25735 rows

select count(*) from ratings;
-- 7997 rows

select count(*) from role_mapping;
-- 15615 rows


-- answer 2.
select
 sum(case when id is null then 1 else 0 end) as id_nullvalues,
 sum(case when title is null then 1 else 0 end) as title_nullvalues,
 sum(case when year is null then 1 else 0 end) as year_nullvalues,
 sum(case when date_published is null then 1 else 0 end) as date_published_nullvalues,
 sum(case when duration is null then 1 else 0 end) as duration_nullvalues,
 sum(case when country is null then 1 else 0 end) as country_nullvalues, -- 20 null values
 sum(case when worlwide_gross_income is null then 1 else 0 end) as worlwide_gross_income_nullvalues, -- 3724 null values
 sum(case when languages is null then 1 else 0 end) as languages_nullvalues, -- 194 null values
 sum(case when production_company is null then 1 else 0 end) as production_company_nullvalues -- 528 null values
 
from movie;


-- answer 3.

-- part 1
select year, count(id) as number_of_movies from movie group by year;
-- year number_of_movies
-- 2017	3052
-- 2018	2944
-- 2019	2001


-- part 2
select month(date_published) as month_number, count(id) as number_of_movies from movie 
group by month(date_published)
order by month(date_published);

-- month_number    number_of_movies
-- 1	                804
-- 2                	640
-- 3	                824
-- 4	                680
-- 5                 	625
-- 6	                580
-- 7	                493
-- 8	                678
-- 9	                809
-- 10	                801
-- 11	                625
-- 12	                438


-- answer 4.

select year, count(id) as number_of_movies from movie
where country = 'India' or country = 'USA'
group by country
having year= 2019;
 
 -- year    number_of_movies
 -- 2019       1007
 
 
 -- answer 5.
 
select distinct genre from genre;



-- answer 6.

select genre, count(movie_id) as highest_number_of_movies from genre
inner join movie on genre.movie_id = movie.id
where year = 2019
group by genre
order by highest_number_of_movies desc
limit 1;


-- genre      highest_number_of_movies
--  Drama             1078


-- answer 7.

with movie_with_one_genre as
(
select movie_id, count(genre) as number_of_movies from genre
group by movie_id
having number_of_movies=1
)

select count(movie_id) as number_of_movies from movie_with_one_genre;

-- 3289 movies are with one genre.


-- answer 8.
 
 
 select genre, avg(duration) as avg_duration from genre
 inner join movie on genre.movie_id = movie.id
 group by genre
 order by avg_duration desc;
 


-- answer 9.

with genre_rank as 
(
select genre, count(movie_id) as movie_count, rank() over (
order by count(movie_id) desc
)
as genre_rank from genre
group by genre
)
select * from genre_rank
where genre = 'Thriller';

-- genre     movie_count    genre_rank
-- Thriller	   1484         	3


-- segment 2

-- answer 10.

select min(avg_rating) as min_avg_rating, max(avg_rating) as max_avg_rating,
 min(total_votes) as min_total_votes, max(total_votes) as max_total_votes,
 min(median_rating) as min_median_rating, max(median_rating) as max_median_rating from ratings;
 
 
 
 -- answer 11.
 

 select title, avg_rating, rank() over (
 order by avg_rating desc
 ) as movie_rank from ratings
 inner join movie on ratings.movie_id = movie.id
group by title
limit 10;




-- answer 12.

select median_rating, count(movie_id) as movie_count
from ratings
group by median_rating
order by median_rating ;



-- answer 13.


with production_house_with_hit_movies as
(
select production_company, count(id) as movie_count, dense_rank() over
( order by count(id) desc
)  as prod_company_rank from ratings
inner join movie on ratings.movie_id = movie.id 
where median_rating > 8 AND production_company IS NOT NULL
group by production_company
)
select * from production_house_with_hit_movies
where prod_company_rank = 1;

 

-- answer 14.

select genre, count(genre.movie_id) as movie_count from genre
inner join ratings on genre.movie_id = ratings.movie_id 
inner join movie on genre.movie_id = movie.id 
where year = 2017 and month(date_published) = 3 and movie.country = 'USA' 
and ratings.total_votes > 1000
group by genre
order by  movie_count;




-- answer 15.

select title, ratings.avg_rating, genre.genre from genre
inner join movie on genre.movie_id = movie.id
inner join ratings on movie.id = ratings.movie_id
where title like 'The%' and ratings.avg_rating > 8 ;




-- answer 16.

select median_rating, count(movie_id) as total_movies from movie
inner join ratings on ratings.movie_id = movie.id
where median_rating = 8 and date_published between '2018-04-01' and '2019-04-01' 
group by median_rating;



-- answer 17.

select languages, total_votes from movie
inner join ratings on movie.id = ratings.movie_id
where languages like 'German' or languages like 'Italian'
group by languages
order by total_votes ;



-- segment 3

-- answer 18.

select
sum(case when name is null then 1 else 0 end) as name_nulls,
sum(case when height is null then 1 else 0 end) as height_nulls,
sum(case when date_of_birth is null then 1 else 0 end) as date_of_birth_nulls,
sum(case when known_for_movies is null then 1 else 0 end) as known_for_movies_nulls
from names;



-- answer 19.

with movies_of_top_genre as
(
select genre, count(movie.id) as movie_count, 
rank() over( order by count(movie.id) desc) as genre_rank from movie
inner join genre on movie.id = genre.movie_id
inner join ratings on movie.id = ratings.movie_id
where avg_rating > 8
group by genre
order by movie_count desc
limit 3
)
select name as director_name, count(director_mapping.movie_id) as movie_count from director_mapping
inner join genre using (movie_id)
inner join names on director_mapping.name_id = names.id
inner join movies_of_top_genre using (genre)
inner join ratings using (movie_id)
where avg_rating > 8
group by director_name
order by movie_count desc
limit 3;




-- answer 20.

select distinct name as actor_name, count(ratings.movie_id) as movie_count from ratings
inner join role_mapping on role_mapping.movie_id = ratings.movie_id
inner join names on role_mapping.name_id = names.id
where category = 'Actor' and median_rating >= 8
group by actor_name
order by movie_count desc
limit 2;




-- answer 21.

select production_company, sum(total_votes) as vote_count, 
rank() over( order by sum(total_votes) desc ) as prod_comp_rank from ratings
inner join movie on movie.id = ratings.movie_id
where production_company is not null
group by production_company
limit 3;




-- answer 22.


with top_Indian_actor as
(
select distinct name as actor_name, 
total_votes  , count(ratings.movie_id) as movie_count,
round(sum(avg_rating*total_votes)/sum(total_votes),2) as actor_avg_rating 
from movie
inner join ratings on movie.id = ratings.movie_id
inner join role_mapping on role_mapping.movie_id = movie.id
inner join names on names.id = role_mapping.name_id
where country = 'India' and category = 'actor'
group by name
having movie_count >= 5
)
select * , dense_rank() over ( order by actor_avg_rating desc) as actor_rank
from top_Indian_actor ;



-- answer 23.

with top_Indian_actresses as
(
select name as actress_name, total_votes, count(movie.id) as movie_count,
round(sum(total_votes*avg_rating)/sum(total_votes),2) as actress_avg_rating from movie
inner join ratings on ratings.movie_id = movie.id
inner join role_mapping on role_mapping.movie_id = movie.id
inner join names on role_mapping.name_id = names.id
where languages like '%Hindi%' and country = 'India' and category = 'actress'
group by actress_name
having movie_count >=3
)
select *, rank() over ( order by actress_avg_rating desc) as actresses_rank
from top_Indian_actresses
limit 5;




-- answer 24.


select title,
case
when avg_rating > 8 then "Superhit movies"
when avg_rating between 7 and 8 then "Hit movies"
when avg_rating between 5 and 7 then "One-time-watch movies"
else "Flop movies" end as avg_rating_category
from  ratings
inner join movie on ratings.movie_id = movie.id
inner join genre on genre.movie_id = movie.id
where genre = 'thriller'
;




-- segment 4

-- answer 25.

select genre, round(avg(duration),2) as avg_duration,
sum(round(avg(duration),2)) over ( order by genre rows unbounded preceding) as running_total_duration,
avg(round(avg(duration),2)) over (order by genre rows unbounded preceding) as moving_avg_duration
from movie
inner join genre on genre.movie_id = movie.id
group by genre; 




-- answer 26.

with top_3_genre as 
(
select genre, count(movie_id) as no_of_movies from genre
inner join movie on genre.movie_id = movie.id
group by genre
order by no_of_movies desc
limit 3
),
 movie_summary as

(
select genre,year, title as movie_name,
cast(replace(replace(ifnull(worlwide_gross_income,0),'INR',''),'$','') as decimal(10)) as worlwide_gross_income,
dense_rank() over (partition by year order by worlwide_gross_income desc) as movie_rank from movie
inner join genre on movie.id = genre.movie_id
where genre in (select genre from top_3_genre )
)
select * from movie_summary
 where movie_rank <= 5
 order by year;
 
 
 
 
 
 -- answer 27.
 
 select production_company, count(id) as movie_count,
 dense_rank() over(order by count(id) desc ) as prod_comp_rank from movie
 inner join ratings on movie.id = ratings.movie_id
 where median_rating >= 8
 and production_company is not null 
 and position(',' in languages)> 0
 group by production_company
 limit 2;
 
 
 
 
 -- answer 28.
 
 select name as actress_name, sum(total_votes) as total_votes, 
 count(ratings.movie_id) as movie_count,
 round(sum(total_votes*avg_rating)/sum(total_votes),2) as actress_avg_rating,
 dense_rank() over ( order by round(sum(total_votes*avg_rating)/sum(total_votes),2) desc) as actress_rank from movie
 inner join ratings on movie.id = ratings.movie_id
 inner join genre on movie.id = genre.movie_id
 inner join role_mapping on movie.id = role_mapping.movie_id
 inner join names on role_mapping.name_id = names.id
 where genre = 'Drama' and avg_rating > 8 and category = 'actress'
 group by name
 limit 3;





-- answer 29.


with next_date_published_summary as
(
select director_mapping.name_id,NAME,
director_mapping.movie_id,duration,ratings.avg_rating,
total_votes,movie.date_published,
lead(date_published,1) over(partition by director_mapping.name_id order by date_published,movie_id ) as next_date_published
from director_mapping
inner join names on names.id = director_mapping.name_id
inner join movie on movie.id = director_mapping.movie_id
inner join ratings on ratings.movie_id = movie.id ),

 top_director_summary as
(
select *,
Datediff(next_date_published, date_published) as date_difference
from next_date_published_summary
 )
select name_id as director_id,
name as director_name,
Count(movie_id) as number_of_movies,
Round(Avg(date_difference),2) as avg_inter_movie_days,
Round(Avg(avg_rating),2) as avg_rating,
Sum(total_votes) as total_votes,
Min(avg_rating) as min_rating,
Max(avg_rating) as max_rating,
Sum(duration) as total_duration
from  top_director_summary
group by director_id
order by Count(movie_id) desc
 limit 9;







