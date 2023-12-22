-- Senior most employee based on job title. 
select *
from employee
order by levels desc
limit 1;

-- Which countries have the most invoices?
select billing_country,count(*) as invoice_count from invoice group by billing_country order by invoice_count desc;

-- What are the top 3 values of total invoices?
select total from invoice order by total desc limit 3;

/* Which city has the best customer?
We would like to through a promotional music festival in city we made the most money.
Write a query that has the highest sum of invoice totals. Return both the city names and invoice totals.*/
select billing_city, sum(total) as sum_total from invoice group by billing_city order by sum_total desc limit 1;

/* Who is the best customer? The customer who has spent the most money will be declared as the best customer.
Write a query that returns the person who has spent the most money.*/
select c.customer_id,c.first_name,c.last_name,sum(i.total) as total_spending from customer as c
inner join invoice as i
on c.customer_id = i.customer_id
group by c.customer_id
order by total_spending desc
limit 1;

/* Moderate: -
Write a query to return the email, first name, last name, & Genre of all the Rock music listeners.
Return your list ordered alphabetically by email starting from A.*/
select distinct c.email, c.first_name, c.last_name,g.name
from customer as c
join invoice as i on c.customer_id = i.customer_id
join invoice_line as il on i.invoice_id = il.invoice_id
join track as t on il.track_id = t.track_id
join genre as g on t.genre_id = g.genre_id
where g.name = 'Rock'
order by c.email;

/* Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the artist name and total track count of the top 10 rock band*/
select a.artist_id,a.name, count(a.artist_id) as artist_count
from track  as t 
join album2 as al on t.album_id = al.album_id
join artist as a on a.artist_id = al.artist_id
join genre as g on g.genre_id = t.genre_id
where g.name = 'Rock'
group by a.artist_id
order by artist_count desc;

/* Return all the track names that have a song length longer than the average song length. 
Return the name and milliseconds for each track. Order by song lengthwith the longest song listed first.*/
select name, milliseconds from
track
where milliseconds>(select avg(milliseconds) as m from track) 
order by milliseconds desc;

/* Advance :-
Find how much amount spent by each customer on artists? 
Write a query to return Artists name cutomer name and total spent */
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
