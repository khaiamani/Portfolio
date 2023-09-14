--SELECT *
--FROM CovidDeath
--ORDER BY 3,4

--SELECT *
--FROM CovidVacc
--ORDER BY 3,4


-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, ROUND((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100, 2) AS death_percentage
FROM CovidDeath
WHERE location LIKE 'Malaysia'
ORDER BY 1, 2


-- Total Cases vs Population
CREATE VIEW total_cases_location AS
SELECT location, date, population, CONVERT(float, total_cases) AS total_cases, ROUND((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100, 2) AS case_percentage
FROM CovidDeath
WHERE continent IS NOT NULL
      AND location IN (
	                   SELECT location
					   FROM CovidDeath
					   WHERE location NOT LIKE 'High income' AND location NOT LIKE 'Upper middle income' AND location NOT LIKE 'Lower middle income' AND location NOT LIKE 'Low income' AND location NOT LIKE 'World'
					   )
ORDER BY total_cases DESC -- converted total_cases because when order by, '99' > '9871'.  Does not make sense.


SELECT location, date, population, total_cases, ROUND((total_cases / population) * 100, 2) AS case_percentage
FROM CovidDeath
--WHERE location LIKE 'Malaysia'
ORDER BY total_cases DESC -- old query


-- Highest Cases per Population by Country

SELECT location, population, MAX(total_cases) AS highest_case_count, ROUND(MAX((total_cases / population)) * 100, 2) AS highest_case_percentage
FROM CovidDeath
GROUP BY location, population
ORDER BY  highest_case_percentage DESC -- Highest percentage is Cyprus, 73.76 but the max count is 999 ? 

CREATE VIEW max_case_location
SELECT location, population, MAX(CONVERT(float, total_cases)) AS highest_case_count, ROUND(MAX(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100, 2) AS highest_case_percentage
FROM CovidDeath
GROUP BY location, population
ORDER BY  highest_case_percentage DESC -- Corrected it by converting total_cases & population into float, now the max count is 660854 (73.76) of the population, which is correct.


-- Highest Deaths per Population by Country

SELECT location, MAX(CONVERT(float, total_deaths)) AS highest_death_count
FROM CovidDeath
GROUP BY location
ORDER BY highest_death_count DESC -- highest death count is world, followed by High income ?. Number 5 is Asia, something not right.  

SELECT location, MAX(CONVERT(float, total_deaths)) AS highest_death_count
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC -- When looking at the whole data, noticed that when continent is NULL, it grouped it into continent such as 'Asia' in the country column.  So, filtered it by WHERE continent IS NOT NULL.


-- Total Deaths by Continent

SELECT continent, MAX(CONVERT(float, total_deaths)) AS total_deaths
FROM CovidDeath
WHERE continent IS NOT NULL
      AND location IN (
	                   SELECT location
					   FROM CovidDeath
					   WHERE location NOT LIKE 'High income' AND location NOT LIKE 'Upper middle income' AND location NOT LIKE 'Lower middle income' AND location NOT LIKE 'Low income' AND location NOT LIKE 'World'
					   )
GROUP BY continent
ORDER BY total_deaths DESC 


-- Death Rate in the World Sort by Date

SELECT date, 
       SUM(new_cases) AS total_cases,
	   SUM(CONVERT(int, new_deaths)) AS total_deaths,
	   ROUND(SUM(CAST(new_deaths AS int)) / SUM(NULLIF(new_cases,0)) * 100, 2) AS death_percentage
FROM CovidDeath
GROUP BY date



-- JOIN Table


SELECT *
FROM CovidDeath AS CD
JOIN CovidVacc AS CV
     ON CD.location = CV.location
	 AND CD.date = CV.date
ORDER BY CD.date

-- Total Population vs Vaccinations

SELECT CD.continent, 
       CD.location, 
	   CD.date, 
	   CD.population, 
	   CV.new_vaccinations,
	   SUM(NULLIF(CAST(CV.new_vaccinations AS bigint), 0)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS rolling_vaccine
FROM CovidDeath AS CD
JOIN CovidVacc AS CV
     ON CD.location = CV.location
	 AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2, 3

-- using CTE

WITH pop_vacc (continent, location, date, population, new_vaccinations, rolling_vaccine) AS (

SELECT CD.continent, 
       CD.location, 
	   CD.date, 
	   CD.population, 
	   CV.new_vaccinations,
	   SUM(CAST(CV.new_vaccinations AS bigint)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS rolling_vaccine
FROM CovidDeath AS CD
JOIN CovidVacc AS CV
     ON CD.location = CV.location
	 AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
)

SELECT * , ROUND((rolling_vaccine / population) * 100, 2) AS rolling_vaccine_percentage
FROM pop_vacc
ORDER BY 2, 3


-- Using Temp Table

DROP TABLE IF EXISTS #vacc_pop_percentage
CREATE TABLE #vacc_pop_percentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccine numeric
)

INSERT INTO #vacc_pop_percentage
SELECT CD.continent, 
       CD.location, 
	   CD.date, 
	   CD.population, 
	   CV.new_vaccinations,
	   SUM(CAST(CV.new_vaccinations AS bigint)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS rolling_vaccine
FROM CovidDeath AS CD
JOIN CovidVacc AS CV
     ON CD.location = CV.location
	 AND CD.date = CV.date
WHERE CD.continent IS NOT NULL

SELECT *, ROUND((rolling_vaccine / population) * 100, 2) AS rolling_vaccine_percentage
FROM #vacc_pop_percentage



-- Creating View for visualizations

CREATE VIEW vacc_pop_percentage AS 
SELECT CD.continent, 
       CD.location, 
	   CD.date, 
	   CD.population, 
	   CV.new_vaccinations,
	   SUM(CAST(CV.new_vaccinations AS bigint)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS rolling_vaccine
FROM CovidDeath AS CD
JOIN CovidVacc AS CV
     ON CD.location = CV.location
	 AND CD.date = CV.date
WHERE CD.continent IS NOT NULL

CREATE VIEW highest_death_count_country AS
SELECT location, MAX(CONVERT(float, total_deaths)) AS highest_death_count
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
