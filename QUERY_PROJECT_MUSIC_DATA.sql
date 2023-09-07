-- 1.who is the most senior employee based on the job title?
select * from employee
order by levels desc
limit 1
-- 2.which counties have the most invoices?
select count(*) as c, billing_country from invoice group by billing_country order by
c desc
-- 3.what are the top 3 values of total invoice?
select total from invoice order by total  desc limit 3
-- 4. which city has the best customer? return the city name and amount of total
-- invoice?
select sum(total) as total_sum,billing_city from invoice group by billing_city 
order by total_sum desc limit 1
-- 5.who is the best customer , which has spent the most money?
select customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total)
as total
from customer join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc limit 1
-- 6.find the email,first_name,last_name of all the rock music listeners? and 
-- arrange the email alphabetically starting with a
select distinct email,first_name ,last_name from customer join invoice on 
customer.customer_id = invoice.customer_id join invoice_line on 
invoice.invoice_id = invoice_line.invoice_id
where track_id  in(select track_id from track join genre on genre.genre_id=
						track.genre_id where genre.name Like 'Rock')
order by email	
-- 7.give the artist name and total number of rock song written by him/her.give the 
-- name and total number of songs of top 10 artists
select artist.artist_id,artist.name ,count(artist.artist_id) as num_of_songs
from track join album on track.album_id = album.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id where genre.name like 'Rock'
group by artist.artist_id
order by num_of_songs desc limit 10
-- 8. Return the name of all the tracks that have song length greater then average
-- song length,return thr name and milliseconds for each track.Order by song length
-- with the longest songs listed first
select name , milliseconds from track
where milliseconds>(select avg(milliseconds) from track)
order by milliseconds desc
-- 9. Find how much amount is spent by each customer on best seeling artist?
-- Return the customers name ,best selling artist name and amount spent.
-- solution: find best selling artist first:
with best_selling_artist as(
	select artist.artist_id as artist_id, artist.name as artist_name,
    sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1	)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity)from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album al on al.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = al.artist_id
group by 1,2,3,4
order by 5 desc
-- 10.Find out the most popular music genre for each country(we find the most
-- popular music genre by with the highest amount of purchases)
with popular_genre as(
select count(invoice_line.quantity) as purchases , customer.country, genre.name,
	genre.genre_id ,
	row_number() over(partition by customer.country
	 order by count(invoice_line.quantity) desc) as row_no
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id  = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc)
	select * from popular_genre where row_no<=1
-- 11.Write a query that returns the country with top customer along with amount 
-- spent
with top_customer as(
select customer.customer_id,first_name,last_name,billing_country,sum(total)as 
	amount_spent, row_number() over(partition by billing_country order by sum(total) desc)
as row_no
	from
invoice join customer on  customer.customer_id = invoice.customer_id
group by 1,2,3,4
order by 4 asc, 5 desc)
select * from top_customer where row_no<=1
