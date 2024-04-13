use music_store;

-- Set 1
-- Q1) Who is the senior most Employee based on jobtitle

select * from employee
order by levels desc
limit 1 ;

-- Q2) Which country have the most invoices

select count(*) as c, billing_country from invoice
group by billing_country
order by c desc ;

-- Q3) What are Top 3 values of total invoice

select  invoice_id, round(total,2) as Total from invoice
order by total desc
limit 3 ;

-- Q4) Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals

select billing_city as City, round(sum(total),2) as Invoice_Total from invoice
Group by billing_city order by invoice_total desc;

-- Q5) Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money

select * from customer;

select * from invoice;

select c.customer_id,c.first_name, c.last_name, round(sum(i.total),2) as Total_spent
from customer as c
join invoice as i
	using(customer_id)
    group by c.customer_id,c.first_name, c.last_name
    order by Total_spent desc;
    
-- Set 2

-- Q1) Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A

-- To get the track_id of "Rock"
	select track_id 
	from track as t
	join genre as g
		on g.genre_id = t.track_id
		where g.name like "Rock";

select distinct email, first_name, last_name 
from customer as c
join invoice as i
	on i.customer_id = c.customer_id
join invoice_line as il
	on il.invoice_id = i.invoice_id
    where track_id in(select track_id 
from track as t
join genre as g
	on g.genre_id = t.track_id
    where g.name like "Rock")
order by email;


-- Q2) Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands

select at.artist_id, at.name, count(at.artist_id) as Number_of_songs from 
track as t
join album2 as a
	on a.album_id = t.album_id
join artist as at
	on at.artist_id = a.artist_id
join genre as g
	on g.genre_id = t.genre_id
    where g.name like "Rock"
Group by at.artist_id, at.name
order by Number_of_songs desc;

-- Q3) Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the
-- longest songs listed first

select name, milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;


-- Set 3
-- Q1) . Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent


WITH best_selling_artist AS (
    SELECT
        a.artist_id AS artist_id,
        a.name AS artist_name,
        ROUND(SUM(il.unit_price * il.quantity), 2) AS total_spent
    FROM
        invoice_line AS il
    INNER JOIN track AS t ON t.track_id = il.track_id
    INNER JOIN album2 AS al ON al.album_id = t.album_id
    INNER JOIN artist AS a ON a.artist_id = al.artist_id
    GROUP BY
        a.artist_id, a.name
    ORDER BY
        total_spent DESC
    LIMIT 1
)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name,
    round(sum(il.unit_price * il.quantity),2) as amount_spent
FROM
    invoice AS i
INNER JOIN customer AS c ON c.customer_id = i.customer_id
INNER JOIN invoice_line AS il ON il.invoice_id = i.invoice_id
INNER JOIN track AS t ON t.track_id = il.track_id
INNER JOIN album2 AS alb ON alb.album_id = t.album_id
INNER JOIN best_selling_artist AS bsa ON bsa.artist_id = alb.artist_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY
    amount_spent DESC;
    
    
    
-- Q2) We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres

 WITH CountryGenreSales as (

select  count(il.quantity) as Purchases, c.country,g.name, g.genre_id, row_number() over(partition by c.country order by count(il.quantity) desc) as rowno
from invoice_line as il
join invoice as i on i.invoice_id = il.invoice_id
join customer as c on c.customer_id = i.customer_id
join track as t on t.track_id = il.track_id
join genre as g on g.genre_id = t.genre_id
group by 2,3,4
order by 2 asc, 1 desc)

select * from CountryGenreSales where rowno <=1;


-- Q3) Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all
-- customers who spent this amount


with CustomerWithCountry as (
select c.customer_id, c.first_name, c.last_name, i.billing_country, round(sum(i.total),2) as Total_spending,
row_number() over(partition by billing_country order by sum(i.total) desc) as row_no
from invoice as i
join customer as c on c.customer_id = i.customer_id 
group by 1,2,3,4
order by 4 asc,5 desc)
select * from CustomerWithCountry where row_no <=1; 















