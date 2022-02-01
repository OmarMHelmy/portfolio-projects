
--Deaths table
SELECT *
FROM Portfolio..covidDeaths
WHERE continent is not null

-- Total cases vs Total Deaths(% of deaths)
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio..covidDeaths
WHERE location like 'Egypt' AND	continent is not null
ORDER BY 1,2


-- Total cases vs population(% of infection)
SELECT Location,date,total_cases,population	, (total_cases/population)*100 AS InfectionPercentage
FROM Portfolio..covidDeaths
WHERE location like 'Egypt' and continent is not null
ORDER BY 1,2

-- countries with highest infection %
SELECT Location,population	,MAX(total_cases) as LatestInfectionCount, MAX((total_cases/population))*100 AS InfectionPercentage
FROM Portfolio..covidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY InfectionPercentage DESC


--Countries with highest death count
SELECT Location, MAX(CAST(total_deaths as int)) as DeathCount
FROM Portfolio..covidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY DeathCount DESC


--Global Numbers
SELECT SUM(new_cases) AS Total_Cases,SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  AS DeathPercentage
FROM Portfolio..covidDeaths
WHERE continent is not null


--vaccinations table
--vaccination %

SELECT deaths.continent,deaths.location,deaths.date,deaths.population, vax.new_vaccinations
, SUM(CAST(vax.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date)  as CountofVaxxedPeople
FROM Portfolio..covidDeaths AS deaths
JOIN Portfolio..covidVaccinations AS vax
	ON deaths.location=vax.location and deaths.date=vax.date
WHERE deaths.continent is not null
ORDER BY 2,3


WITH VaxxedPopu( continent,location,date,population,new_vaccinations,CountofVaxxedPeople)
AS(
SELECT deaths.continent,deaths.location,deaths.date,deaths.population, vax.new_vaccinations
, SUM(CAST(vax.new_vaccinations as bigint)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date)  as CountofVaxxedPeople
FROM Portfolio..covidDeaths AS deaths
JOIN Portfolio..covidVaccinations AS vax
	ON deaths.location=vax.location and deaths.date=vax.date
WHERE deaths.continent is not null
)
Select * , (CountofVaxxedPeople/population)*100 AS Percentage_of_vaxxed_people
From VaxxedPopu
