---QUESTION-1: Who is the senior most employee based on job title?

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1



---QUESTION-2: Which countries have the most Invoices?

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC



---QUESTION-3: What are top 3 values of total invoice? 

SELECT total 
FROM invoice
ORDER BY total DESC




---QUESTION-4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
---Write a query that returns one city that has the highest sum of invoice totals. 
---Return both the city name & sum of all invoice totals 

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;




---QUESTION-5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
---Write a query that returns the person who has spent the most money.

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;




---QUESTION-6 : write a query to return the email, first name, last name, and genre of all Rock music listeners.
---return your list ordered alphabetically by email starting with a.


SELECT DISTINCT email, first_name, last_name 
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email





---QUESTION-7 : lets invite the artists who have written the most rock music in our dataset. 
---write a query that returns the artist name and total track count of the top 10 rock band.


SELECT artist.name, COUNT(DISTINCT(track.name)) as track_count
FROM artist
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.name
ORDER BY track_count DESC
LIMIT 10



---QUESTION-8 : return all the track name that has the song length longer than the average song length. 
---return the name and milisecond for each track. 
---order by the song length with the longest songs listed first.

SELECT name , milliseconds
FROM track
WHERE milliseconds > ( 
	SELECT AVG(milliseconds) 
	FROM track
	)
ORDER BY milliseconds DESC



---QUESTION-9 : find how much amount spent by each customer on artist. 
---write a query to return customer name, artist name and total spent.

WITH best_selling_artist AS(
	SELECT artist.artist_id as artist_id, artist.name as artist_name, 
	SUM(invoice_line.unit_price * invoice_line.quantity) AS total_amount
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)

SELECT customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.artist_name,
SUM(invoice_line.unit_price * invoice_line.quantity) AS amount_spent
FROM invoice
JOIN customer on customer.customer_id = invoice.customer_id
JOIN invoice_line on invoice_line.invoice_id = invoice.invoice_id
JOIN track on track.track_id = invoice_line.track_id
JOIN album on album.album_id = track.album_id
JOIN best_selling_artist ON best_selling_artist.artist_id = album.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC




---QUESTION-10 : we want to find out most popular music genre for each country. we determined that 
---the most popular genre as the genre with the highest amount of purchases. write a query that returns 
---each country along with the top genre.for country where the maximum number of purchases is shared 
---return all genres

WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country,genre.name, genre.genre_id,
		ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
	FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <=1



---QUESTION-11 : Write a query that determines the customer that has spent the most on music for each country. 
---Write a query that returns the country along with the top customer and how much they spent. 
---For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH highest_spender AS(
	SELECT customer.customer_id, customer.first_name, customer.last_name,invoice.billing_country, SUM(total) AS total_spend,
		ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC, 5 DESC

)
SELECT * FROM highest_spender
WHERE RowNo <=1












