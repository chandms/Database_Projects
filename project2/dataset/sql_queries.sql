select cc.name from borders bd 
join country cc on cc.code = country1
where length = (select max(length) from borders);

-- 0.141 sec


select c.name, c.country from city c,
(select max(population) as pop, country from city group by country) x
where c.country = x.country and c.population = x.pop  order by c.country

-- 0.142 sec

select c.name, gdp, agriculture,inflation from economy e
join country c on c.code = e.country
where agriculture> service and agriculture> industry and
agriculture> inflation  and agriculture> unemployment; 


-- 0.134 sec

select  cc.name, count_of_ethnic_group, percentage_of_major_ethnicity from
(select count(ethnic_group_name)as count_of_ethnic_group,max(ethnic_group_percentage) as percentage_of_major_ethnicity,
country_code from ethnicgroup eth group by country_code
order by count_of_ethnic_group desc) ethnic
join country cc on cc.code = ethnic.country_code;

-- 0.161 s


select count(a.country_code) from
(select count(ethnic_group_name) as eth_cnt, country_code  from ethnicgroup group by country_code) a,
(select count(language) as lang_cnt , country from language group by country) b
where a.country_code = b.country and a.eth_cnt = b.lang_cnt;

-- 0.157 sec

select country, gdp, p.INFANT_MORTALITY from economy e 
join population p on p.country_code = e.country and gdp is not null
order by gdp desc
fetch first 10 rows only;

--0.153 sec

select x.name, cc.name, x.num_of_rel as number_of_religion_practiced from
(select a.num_of_rel, r.name, a.country from
(select count(name) as num_of_rel, country from religion group by country) a
join religion r on r.country = a.country) x
join country cc on cc.code = x.country
where x.num_of_rel = (select max(num_of_rel) from
(select b.num_of_rel, ri.name, b.country from
(select count(name) as num_of_rel, country from religion group by country) b
join religion ri on ri.country = b.country))

-- 0.502 sec

select count(country)/100 as commonwealth_proportion from
(select country,gdp from economy where gdp is not null order by gdp desc
fetch first 100 rows only) a where a.country in( select country from ismember where 
organization = (select abbreviation from organization where name = 'Commonwealth'))

-- 0.114 s


select c1.name as country_name, c1.population/c1.area as population_density, c2.ENCOMPASSES_CONTINENT as continent from country c1 join
country_continent c2 on c1.code = c2.code join 
(select max(population_density) as population_density, continent  from
(select c.code,population/area as population_density, cc.ENCOMPASSES_CONTINENT as continent from country c 
join country_continent cc on cc.code = c.code) group by continent)  b
on b.population_density=(c1.population/c1.area) and b.continent = c2.ENCOMPASSES_CONTINENT


-- 0.144 s


select cc.name, cc.capital from country cc join
(select code as country, capital from country c
join airport a on a.city = c.capital and a.airport_province = c.province and a.country_code = c.code
group by capital,province,code having count(a.iatacode)>1) x
on x.country = cc.code

-- 0.761 s







