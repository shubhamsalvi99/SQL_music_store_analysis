--senior employee in organization
Select * from employee
order by levels desc
limit 1;

-- Countries with most invoices
Select count(billing_country) as invoices, billing_country 
from invoice
group by billing_country
order by invoices desc;

-- Top 3 values of total in invoices
Select total as total_invoices
from invoice
order by total_invoices desc
limit 3;

-- returns city which made most money
Select billing_city,sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc;

-- best customer
Select cu.customer_id, cu.first_name,cu.last_name, sum(i.total) as total_amount from customer cu
join invoice i
on cu.customer_id=i.customer_id
group by cu.customer_id
order by total_amount desc
limit 1;

-- name of customer who listen rock music
SELECT DISTINCT cu.email, cu.first_name, cu.last_name 
FROM customer cu
Join invoice i
on cu.customer_id= i.customer_id
join invoice_line il 
on i.invoice_id=il.invoice_id
join track t
on il.track_id=t.track_id
join genre g
on t.genre_id=g.genre_id
where g.name like 'Rock'
order by email;

--top 10 Singers/Band who have sang most song in rock genre
SELECT a.name, COUNT(a.artist_id) AS number_of_songs
FROM Artist a
JOIN Album al ON a.artist_id = al.artist_id
JOIN Track t ON al.album_id = t.album_id
WHERE genre_id = (
    SELECT genre_id FROM Genre WHERE name LIKE 'Rock'
)
GROUP BY a.artist_id
ORDER BY number_of_songs DESC
LIMIT 10

-- Songs have duration more than average time
select name, milliseconds 
from track
where milliseconds > (
	select avg(milliseconds)
	from track
	)
order by milliseconds desc;

--How much amoun spent by each customers on artists? 
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres. */

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
SELECT * FROM popular_genre WHERE RowNo <= 1

  
/* Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount.*/
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
