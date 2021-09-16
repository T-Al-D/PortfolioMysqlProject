-- syntax for writing simple querys. Not all keywords need to be used, but it is important to KEEP THE ORDER !

-- CREATE VIEW AS ....			-> view (with a name) is created instead of query 
-- SELET .... AS .... 			-> select is a column (projection) , as is an alias (for another name)
-- FROM  ....					-> From which relation(table)?
-- 	 WHERE  .... LIKE %...%     -> where is for conditional selection, use like%_% if searched for certain letteres
--   OR...BETWEEN...AND  ...	-> used between the "where" if multiple conditions are needed / or possible
-- 	 GROUP BY  ....				-> same attributes are listed (only) once
-- 	 HAVING ...					-> use this if alias is present or with aggregationfunction (SUM, MAX, ...)
-- 	 ORDER BY  ....ASC/DESC		-> sorting the query through factors (primary, secondary,...) ascending or descending
-- 	 LIMIT	....				-> maximum tablelength

-- syntax for complex querys with JOIN 

-- select A.column, B.column, .... from tableA A ______ join tableB B on A.column = B.column ;  
--                       -> fill in the blank for inner, left/right outer join or natural join
-- inner join			 ->  fusing of same columns, column without fitting partner exculded
-- natural join 		 ->  if 2 columns are the same di inner join else cross join
-- outer join			 ->  outer join where one (or both if full) table is displayed (completely) and fused with the other table if possible

-- (DDL , Data Definition Language) creating a new table called "Lessons" with following attributes, InnoDB is usually default in MySql
create table if not exists realparsmodel.lessons (
lessonID smallint auto_increment not null,
subject varchar(250) not null,
startDate date,
dueDate date,
status tinyint default 0,
priority tinyint default 3,
description text,
primary key (lessonID)
)engine = InnoDB;

-- (DML, Data Manipulation Language)  -- insertion into table
insert into realparsmodel.lessons values
(1, "Safety", null, null, null, null, "Important lesson for everyone!");

insert into realparsmodel.lessons (lessonID, subject, description)
values (2, "Hygiene", "Important for medical professionals and social wokers!");

insert into realparsmodel.lessons (lessonID, subject, priority, description)
values (3, "Enviroment", 0, "Not Mandatory, only if interested");

insert into realparsmodel.lessons (lessonID, subject, priority, description)
values (null, "Teamwork & social Interaction", 2, "Mandatory for everyone!");

 -- deletion of table
drop table if exists realparsmodel.lessons;

-- deletion of single row
delete from realparsmodel.lessons where lessonID = 2;

-- transactions a atomic wich means they can only work als one, else all change are going to be reversed to the Beginning
set autocommit = 0;	  -- -> important if you want to control the commits yourself
start transaction;

insert into realparsmodel.lessons (lessonID, subject, priority, description)
values (null, "Microsoft course", 2, "Mandatory for the majority");
alter table realparsmodel.lessons drop dueDate;
alter table realparsmodel.lessons add people int;
select * from realparsmodel.lessons;

rollback; 		  	 -- -> during a transaction (before commit) can reset previous data
commit;    			 -- -> only if you are sure about permanent changes

-- update a complete column (only available without safemode) or a single row in the table 
update realparsmodel.lessons l set l.startDate = "2021-10-01";
update realparsmodel.lessons l set l.startDate = "2021-10-01" where l.lessonID = 1;

-- All students from USA with the letter 'J' as the first letter in their first names, sorted in ascending order of studentNumber
SELECT studentNumber, FirstName, LastName FROM realparsmodel.students
WHERE country = "USA" AND FirstName LIKE "%J%"
ORDER BY studentNumber ASC;

-- All courses with the buyPrice between 80 and 95, tablename is "courses"
select courseCode, courseName, courseLine, buyPrice as courses
from realparsmodel.courses where buyPrice between 80 and 95 ;

-- sum of all item and amount of orders under a certain orderNumber. primary sort through orderAmount, secondary itemCount
select orderNumber, count(orderNumber) as orderAmount, sum(quantityOrdered) as itemCount
from realparsmodel.orderdetails as od
group by orderNumber
having itemCount between 500 and 600 order by orderAmount, itemCount;

-- All Students which cancelled their orders (exists operator returns either true or false!)
select studentNumber, LastName, FirstName from realparsmodel.students where exists 
(select * from realparsmodel.orders o where o.status = "Cancelled");

-- the first 75 orders with orderNumers, studentNumber, quantity (each individual value under 125), totalValue of the order under 4000, orderd after orderNumber
select o.orderNumber, o.studentNumber, od.priceEach, od.quantityOrdered, (od.priceEach * od.quantityOrdered) as totalValue
from realparsmodel.orderdetails as od
inner join realparsmodel.orders as o on od.orderNumber = o.orderNumber
where priceEach <= 125
having totalValue < 4000 
order by o.orderNumber limit 75;

-- Example for Anti-Semi-Join , Query with all employees which are not in the USA
select employeeNumber, officeCode ,firstName, lastName
from realparsmodel.employees where officeCode not in
(select officeCode from realparsmodel.offices where country = "USA");

-- all emplyees (with eventually the students they are in charge of) 
select e.employeeNumber, e.lastName, e.jobTitle, s.studentNumber
from realparsmodel.employees e left outer join realparsmodel.students s on e.employeeNumber = s.salesRepEmployeeNumber
order by e.employeeNumber asc;

-- Union , fusing 2 queries together (example all students whether they are involved in payments or not)
select s.studentNumber from realparsmodel.students s
union
select p.studentNumber from realparsmodel.payments p;

-- Intersect doesn´t exist in MySQL but instead in/exist can be used (all courselines which exists in courses and courselines)
select cl.courseLine from realparsmodel.courselines cl
where exists (select c.courseLine from realparsmodel.courses c) ;

-- Creating a view for simpicity of safety, instead granting access to all tables only show most important information, if view exists then replace
-- example: all Students (from the student table) with their addresses and the amout of orders they made,  coalesce func. sets default if value null
create or replace view realparsmodel.studentOrders as
select s.studentNumber, s.FirstName, s.LastName, s.city, s.addressLine1,
coalesce((s.addressLine2), "") as addresAddition,
(select count(o.studentNumber) orderAmount from realparsmodel.orders o 
where s.studentNumber = o.studentNumber) as orderAmount  
from realparsmodel.students s
order by s.studentNumber asc;

drop view if exists realparsmodel.studentorders;