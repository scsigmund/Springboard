/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT *
FROM `Facilities`
WHERE membercost >0

/* Q2: How many facilities do not charge a fee to members? */

4

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance FROM `Facilities` WHERE membercost > 0 and (membercost < (monthlymaintenance * .2))

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid
IN ( 1, 5 )


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance <=100
THEN 'cheap'
ELSE 'expensive'
END AS labelname
FROM Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM `Members`


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT name, CONCAT( firstname, surname )
FROM Facilities AS f
INNER JOIN Bookings AS b ON f.facid = b.facid
INNER JOIN Members AS m ON b.memid = m.memid
ORDER BY firstname, surname

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT name, CONCAT( firstname, surname ) ,
CASE WHEN b.memid =0
THEN guestcost * slots
ELSE membercost * slots
END AS cost, STR_TO_DATE( starttime, '%Y-%m-%d' )
FROM Facilities AS f
INNER JOIN Bookings AS b ON f.facid = b.facid
INNER JOIN Members AS m ON b.memid = m.memid
WHERE STR_TO_DATE( starttime, '%Y-%m-%d' ) = STR_TO_DATE( '2012-09-14', '%Y-%m-%d' )
AND 1 =
CASE WHEN guestcost * slots >30
AND b.memid =0
THEN 1
WHEN membercost * slots >30
AND b.memid <>0
THEN 1
END
ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT name, concat(firstname, surname), booking.cost
FROM Facilities as f inner join Bookings as b on f.facid = b.facid inner join Members as m using(memid) inner join 
(SELECT bookid, CASE WHEN b.memid =0
THEN guestcost * slots
ELSE membercost * slots
END AS cost, STR_TO_DATE( starttime, '%Y-%m-%d' ) as bookDate FROM Bookings as b inner join Facilities as f on b.facid = f.facid) as booking on b.bookid = booking.bookid
WHERE booking.bookDate = STR_TO_DATE('2012-09-14', '%Y-%m-%d') and booking.cost > 30
order by booking.cost desc

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

cur.execute("SELECT name, sum(bookcost.cost) FROM Facilities as f inner join (SELECT b.facid, CASE WHEN b.memid =0 THEN guestcost * slots ELSE membercost * slots END AS cost FROM Bookings as b inner join Facilities as f on b.facid = f.facid) AS bookcost ON f.facid = bookcost.facid GROUP BY name HAVING sum(bookcost.cost) < 1000")
revenue_1000 = (cur.fetchall())

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

cur.execute("SELECT surname || ','  || firstname as full_name, recommendedby from Members order by surname, firstname")
mems = (cur.fetchall())
print(mems)

/* Q12: Find the facilities with their usage by member, but not guests */

cur.execute("SELECT DISTINCT name, firstname ||' ' ||surname as fullname FROM Facilities AS f INNER JOIN Bookings AS b ON f.facid = b.facid INNER JOIN Members AS m ON b.memid = m.memid WHERE m.memid <> 0 ORDER BY firstname, surname")
onlymems = (cur.fetchall())
print(onlymems)

/* Q13: Find the facilities usage by month, but not guests */

cur.execute("SELECT DISTINCT name, COUNT(*) as usage, strftime('%m',b.starttime) as month FROM Facilities AS f INNER JOIN Bookings AS b ON f.facid = b.facid INNER JOIN Members AS m ON b.memid = m.memid WHERE m.memid <> 0 Group by name, month ORDER BY firstname, surname")
monthuse = (cur.fetchall())
print(monthuse)