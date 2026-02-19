--Netflix Project

drop table if  exists netflix;

Create table netflix(

	 show_id varchar(10),
	 type varchar(10),
	 title varchar(150),
	 director varchar(210),
	 casts varchar(1000),
	 country varchar(153),
	 date_added varchar(50),
	 release_year int,
	 rating varchar(10),
	 duration varchar(20),
	 listed_in varchar(100),
	 description varchar(250)
);

select * from netflix;

select count(*) as total_content
from netflix;

select count(casts) as total_count
from netflix;

select distinct type from netflix;

--Business Problem to solve by using the Netflix dataset.

--Q1.Count the number of movies vs TV shows

select type,
count(*) as total_content
from netflix
group by type;

--Q2.Find the most common rating for movies and TV shows
select 
type,
rating from
(
select 
type,
rating,
count(*) as total,
rank() over(partition by type order by count(*) desc) as ranking
from netflix
group by type,rating
) t1
where ranking=1;


--Q3.List all movies released in a specific year(e.g 2020)
select * from netflix;

select *
from netflix
where type='Movie' and release_year=2020;

--Q4.Find the top 5 countries with the most content on Netflix

select 
unnest(string_to_array(country,',')) as  new_country,
count(show_id) as total_content
from netflix
group by new_country
order by total_content desc
limit 5;

--Q5.Indentity the Longest Movies

select * from netflix
where type='Movie'
and duration=(select max(duration)from netflix)

--Q6.Find content added in the last 5 years.

select *
from netflix
where to_date(date_added,'dd-Mon-YY')>=current_date- interval '5 years';

--Q7.Find all the movies/TV shows by director 'Rajiv Chilaka'

select * from netflix
where director Ilike '%Rajiv Chilaka%';

--Q8.List all TV shows with more than 5 seasons

explain analyze select * from netflix
where type='TV Show' and 
split_part(duration,' ',1)::numeric >5;

--Q9.Count the number of content items in each genre

select 
unnest(string_to_array(listed_in,',')) as genre,
count(show_id) as total_content
from netflix
group by 1;

--Q10.Find each year and the average numbers of content release by India on Netflix
--return top 5 year with highest avg content release

select 
extract(year from to_date(date_added,'DD-MON-YY')) as year,
count(*) as yearly_content,
round(
count(*)::numeric/(select count(*) from netflix where country='India')::numeric*100,2) as avg_content_per_year
from netflix
where country='India'
group by 1;

--Q11.List all movies that are documentries

select * from netflix
where listed_in ilike '%Documentaries%';

--Q12.Find all content without the  a director

select * from netflix
where director is null;

--Q13.Find how many movies actor 'Salman Khan' appared in last 10 years.

select *
from netflix
where casts Ilike '%Salman Khan%' and release_year>extract(year from current_date)-10;

--Q14.Find the top 10 actors who have appeared in the highest number of movies produced in india.
select 
unnest(string_to_array(casts,',')) as actors,
count(*) as total_content
from netflix
where country ilike '%india'
group by 1
order by 2 desc
limit 10;

--Q15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in
--the description field.Label content containing these keywords as 'Bad' and all other content
--as 'Good'. Count how many items fall into each category.

select * from netflix;

with new_table as(
select *,
case 
when description ilike '%kill%' or
description ilike '%violence%' then 'Bad_Content'
else 'Good_Content'
end as Category
from netflix
)

select category,
count(*) as total_count
from new_table
group by category;








