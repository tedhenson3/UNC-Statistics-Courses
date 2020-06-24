create table babies_2017 (
common_name varchar(15),
sex varchar(2),	
freq numeric(10,1)

);

COPY babies_2017
FROM 'C:\Program Files\PostgreSQL\11\data\yob2017.csv'
WITH (FORMAT CSV, HEADER);



create table babies_2007 (
common_name varchar(15),
sex varchar(2),	
freq numeric(10,1)

);

COPY babies_2007
FROM 'C:\Program Files\PostgreSQL\11\data\yob2007.csv'
WITH (FORMAT CSV, HEADER);


/*Question 1 */
select sum(freq) from babies_2017;

/* 3526563 babies */

/* Question 2 */
select distinct COUNT(common_name) from babies_2017;

/* 32468 distinct names */

/* Question 3 */
select freq
from 
babies_2007 
where common_name =  'Ted';

/* 61 babies named Ted */


/* Question 4 */

CREATE TABLE boys(
 common_name varchar(15),
sex varchar(2),	
freq numeric(10,1));
			 
CREATE TABLE girls(
 common_name varchar(15),
sex varchar(2),	
freq numeric(10,1));
			 
			 
insert into girls (common_name, sex, freq)
 SELECT common_name, sex, freq
FROM babies_2017
where sex = 'F';
			 
			 
insert into boys (common_name, sex, freq)
 SELECT common_name, sex, freq
FROM babies_2017
where sex = 'M';
			 
select distinct boys.common_name
from boys left join girls 
on boys.common_name = girls.common_name
where girls.common_name is not null;
			 
/* Yes. The query above will print the list of names. */
			 


/* Question 5 */
select sex, sum(freq)
from babies_2017
group by sex;

/* More boy babies */


/* Question 6 */
			 
			 			 
CREATE TABLE comb_07 (
total_freq numeric(10,1));
			 
			 
insert into comb_07 (total_freq)
SELECT 
     sum(freq)
FROM babies_2007
where babies_2007.common_name ILIKE 'U%';
		  
				   
CREATE TABLE comb_17 (
total_freq numeric(10,1));
			 
			 
insert into comb_17 (total_freq)
SELECT 
     sum(freq)
FROM babies_2017
where babies_2017.common_name ILIKE 'U%';
				   
select(select sum(total_freq) from comb_17) + 
				   (select sum(total_freq) from comb_07)
				   as result
	
/* 5962 babies */
				   

/* Question 7 */
select common_name
from babies_2017
where sex = 'M' 
and 
common_name like any ('{"A%", "E%", "I%", "O%", "U%"}')
				   order by freq desc limit 5;
				   
/* Elija, Oliver, Alexander, Ethan, and Aiden */

/* Question 8 */
select common_name
from babies_2017
where sex  = 'F'
order by freq desc limit 10;
				   
/* Olivia, Ava, Isabella, Sophia, Mia, 
  Charlotte, Amelia, Evelyn, Abigail, and Harper */


/* Question 9 */
select common_name, freq_2017, freq_2007 from (
select common_name, sex, freq as freq_2017, foo.freq_2007
from babies_2017
left join (select common_name as oldname, 
		   freq as freq_2007 from babies_2007) as foo
on babies_2017.common_name = foo.oldname
where foo.oldname is not null and 
babies_2017.sex = 'F') as foo2;

/* Question 10 */
				   
CREATE TABLE boys_2007(
 common_name varchar(15),
sex varchar(2),	
freq numeric(10,1));
			 
CREATE TABLE boys_17(
 common_name varchar(15),
sex varchar(2),	
freq numeric(10,1));
			 
			 
insert into boys_17 (common_name, sex, freq)
 SELECT common_name, sex, freq
FROM babies_2017
where sex = 'M';
			 
			 
insert into boys_2007 (common_name, sex, freq)
 SELECT common_name, sex, freq
FROM babies_2007
where  sex = 'M'
			 order by freq;
			 
				   
select distinct(common_name), freq_2017, freq_2007 from (
select common_name, freq as freq_2017, foo.freq_2007
from boys_17
left join (select common_name as oldname, 
		   freq as freq_2007 from boys_07) as foo
on boys_17.common_name = foo.oldname
where foo.oldname is  null) as foo2
				   order by freq_2017 desc;

/* Yes, the query above prints their names. */

/* Question 11 */

select distinct(common_name),
			 freq_2007  -  freq_2017  as 
			 decrease
			 from (
select common_name, freq as freq_2017, foo.freq_2007
from boys_17
left join (select common_name as oldname, 
		   freq as freq_2007 from boys_07) as foo
on boys_17.common_name = foo.oldname
where foo.oldname is  not null) as foo2
				   order by decrease limit 1;


/* Liam had the biggest decrease in raw numbers */
			 
/* Question 12 */
select distinct(common_name),
			 round(cast(freq_2017  -  freq_2007 as decimal(10,1)) 
			/ freq_2007 * 100, 4)  as 
			 increase
			 from (
select common_name, freq as freq_2017, foo.freq_2007
from boys_17
left join (select common_name as oldname, 
		   freq as freq_2007 from boys_07) as foo
on boys_17.common_name = foo.oldname
where foo.oldname is  not null) as foo2
				   order by increase desc limit 1;

/* Kyrie had the biggest percent increase */
			 
/* Question 13 */
CREATE TABLE boys_07_2 (
 common_name varchar(15),
sex varchar(2),	
freq numeric(10,1));
			 
CREATE TABLE boys_17_2 (
 common_name varchar(15),
sex varchar(2),	
freq numeric(10,1));
			 
insert into boys_17_2 (common_name, sex, freq)
 SELECT common_name, sex, freq
FROM babies_2017
where sex = 'M'
order by freq desc limit 100;
			 
insert into boys_07_2 (common_name, sex, freq)
 SELECT common_name, sex, freq
FROM babies_2007
where  sex = 'M'
			 order by freq desc limit 100;

			 
select count(*) from (select distinct(common_name), freq_2017, freq_2007 from (
select common_name, freq as freq_2017, foo.freq_2007
from boys_17_2
left join (select common_name as oldname, 
		   freq as freq_2007 from boys_07_2) as foo
on boys_17_2.common_name = foo.oldname
where foo.oldname is not null) as foo2
				   order by freq_2017 desc) as foo3;

/* 69 Names */
			 
			 
/* Question 14 */
CREATE TABLE boys17 (
 common_name varchar(15),
sex varchar(2),	
freq numeric(10,1));
			 
CREATE TABLE girls17 (
 common_name varchar(15),
sex varchar(2),	
freq numeric(10,1));
			 
insert into boys17 (common_name, sex, freq)
 SELECT common_name, sex, freq
FROM babies_2017
where sex = 'M' and freq >= 500
order by freq desc;
			 
insert into girls17 (common_name, sex, freq)
 SELECT common_name, sex, freq
FROM babies_2017
where sex = 'F' and freq >= 500
order by freq desc;

			 
select distinct(common_name) from (
select common_name, freq as freq_2017, foo.freq_2007
from boys17
left join (select common_name as oldname, 
		   freq as freq_2007 from girls17) as foo
on boys17.common_name = foo.oldname
where foo.oldname is not null) as foo2;
			 
/* Query above will print the names */

			 
			 
/* Question 15 */
			 

			 
CREATE TABLE girls17red1 (
 name_length numeric(10,1));
			 
			 
insert into girls17red1 (name_length)
 SELECT char_length(common_name)
FROM babies_2017
where sex = 'F';
					 
select cast(avg(name_length)  as decimal(10,2)) from girls17red1;
										 
 

			 
CREATE TABLE boys17red1 (
 name_length numeric(10,1));
			 
			 
insert into boys17red1 (name_length)
 SELECT char_length(common_name)
FROM babies_2017
where sex = 'M';
					 
select cast(avg(name_length)  as decimal(10,2)) from boys17red1;


CREATE TABLE girls07red1 (
 name_length numeric(10,1));
			 
			 
insert into girls07red1 (name_length)
 SELECT char_length(common_name)
FROM babies_2007
where sex = 'F';
					 
select cast(avg(name_length)  as decimal(10,2)) from girls07red1;
										 
 

			 
CREATE TABLE boys07red1 (
 name_length numeric(10,1));
			 
			 
insert into boys07red1 (name_length)
 SELECT char_length(common_name)
FROM babies_2007
where sex = 'M';
					 
select cast(avg(name_length)  as decimal(10,2)) from boys07red1;
										 
										 
/* It could be interesting to investigate how name 
	lengths have changed since 2007 between males and females */

