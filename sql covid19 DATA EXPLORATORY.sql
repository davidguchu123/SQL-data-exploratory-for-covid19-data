select*
from coviddeaths1
order by 3,4;

select location,`date`,total_cases,new_cases,total_deaths,population
from coviddeaths1
order by 1,2;
#total_cases vs total_deaths in africa
select location,`date`,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from coviddeaths1
where location like "Africa"
order by deathratio desc;
#what percentage of population in Africa got covid
select location,`date`,population,total_cases,(total_cases/population)*100 as percentage_population 
from coviddeaths1
where location like "Africa";
#top 30 countries with highest infection rate compared to population
select location,`date`,population,total_cases as highest_infectioncount,(total_cases/population)*100 as percentage_population 
from coviddeaths1
order by percentage_population desc
limit 30
;
#countries with highest death count per population
select location,`date`,population,total_cases
from coviddeaths1
where continent is not null
order by total_cases desc;
#break down by continent

ALTER TABLE coviddeaths1
MODIFY total_cases INT;
SET sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

select continent,population,max(total_cases) as highest
from coviddeaths1
where continent != ''
group by continent
order by highest desc;	
#continent with highest death count
select continent,population,max(total_deaths) as highestdeath
from coviddeaths1
where continent != ''
group by continent
order by highest desc;	
#Global numbers

select `date`,sum(new_cases) as total_cases,sum(new_deaths) as total_death,(sum(new_deaths)/sum(new_cases))*100 as death_percentage
from coviddeaths1
where continent!=''
group by date
order by 1,2;

with totals as (
select `date`,sum(new_cases) as total_cases,sum(new_deaths) as total_death,(sum(new_deaths)/sum(new_cases))*100 as death_percentage
from coviddeaths1
where continent!=''
group by date
order by 1,2)
select sum(total_cases),sum(total_death) 
from totals;

#total_population vs vaccination
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS total_vaccinations
FROM coviddeaths1 AS cd
JOIN covidvaccination1 AS cv
    ON cd.date = cv.date
    AND cd.location = cv.location
WHERE cd.continent IS NOT NULL
ORDER BY cd.continent, cd.location, cd.date;
#using cte
WITH population_vaccination AS (
    SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.date) AS total_vaccinations
    FROM coviddeaths1 AS cd
    JOIN covidvaccination1 AS cv
        ON cd.date = cv.date
        AND cd.location = cv.location
    WHERE cd.continent IS NOT NULL
)
SELECT *,(total_vaccinations / population) * 100 AS cumulative_vaccination_percent
FROM population_vaccination;
#CREATING A VIEW BASED ON THE DATA
CREATE VIEW continent_highest_deaths AS
SELECT continent,MAX(total_deaths) AS highestdeath
FROM coviddeathscontinent_highest_deaths1
WHERE continent != ''
GROUP BY continent
ORDER BY highestdeath DESC;
select*
from continent_highest_deaths
	


