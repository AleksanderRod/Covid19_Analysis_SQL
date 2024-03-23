SELECT * 
FROM TryingToGetData..covidDeaths
--where continent is not null
ORDER BY 3,4


-- SELECT * 
-- FROM TryingToGetData..covidVaccinations
-- order by 1,4

-- Selecting the Data that we need
SELECT Location, date, total_deaths, new_cases, total_deaths, population
FROM TryingToGetData.. covidDeaths
ORDER BY 1,4

-- getting the total cases vs the total deaths
-- Death_Percentage gives you a precent of possible death per case
SELECT Location, date, total_cases, total_deaths, new_cases, total_deaths, population, Death_Percentage = (total_deaths/total_cases)*100
FROM TryingToGetData.. covidDeaths
--where location like '%states%'
ORDER BY 1,2 desc

-- percentage of population that got covid
Select Location, date, total_cases, total_deaths, new_cases, total_deaths, population, PercentageInfection = (new_cases/population)*100
from TryingToGetData.. covidDeaths
-- where location like '%states%'
order by 2 desc

-- looking at countries with highest infection rate compared to pop.
Select Location, population, MAX(total_cases) as HighestInfectionCount , PercentageInfection = MAX((total_cases/population))*100
from TryingToGetData.. covidDeaths
-- where location like '%states%'
group by Location, population
order by PercentageInfection desc

-- Which countries had the highest death count per population
Select Location,  MAX(total_deaths) as TotalDeathCount 
from TryingToGetData.. covidDeaths
-- where location like '%states%'
where continent is not null		--  filters out the non countries of the data
group by Location
order by TotalDeathCount desc

-- Which continents had the highest total deaths
Select continent,  MAX(total_deaths) as TotalDeathCount 
from TryingToGetData.. covidDeaths
-- where location like '%states%'
where continent is not null		
group by continent
order by TotalDeathCount desc

-- SPLITTING COUNTRIES ACCORDING TO CONTIENENT
-- GETTING THEIR HIGHEST DEATH
-- North American 
SELECT location,  MAX(total_deaths) as TotalDeathCount 
FROM TryingToGetData.. covidDeaths
WHERE continent like '%North America%' AND continent is not null		
GROUP BY location
ORDER BY TotalDeathCount desc

-- South American
SELECT location,  MAX(total_deaths) as TotalDeathCount 
FROM TryingToGetData.. covidDeaths
WHERE continent like '%South America%' AND continent is not null		
GROUP BY location
ORDER BY TotalDeathCount desc

-- Asia
SELECT location,  MAX(total_deaths) as TotalDeathCount 
FROM TryingToGetData.. covidDeaths
WHERE continent like '%Asia%' AND continent is not null		
GROUP BY location
ORDER BY TotalDeathCount desc

-- Eurpoe
SELECT location,  MAX(total_deaths) as TotalDeathCount 
FROM TryingToGetData.. covidDeaths
WHERE continent like '%Europe%' AND continent is not null		
GROUP BY location
ORDER BY TotalDeathCount desc

-- Africa
SELECT location,  MAX(total_deaths) as TotalDeathCount 
FROM TryingToGetData.. covidDeaths
WHERE continent like '%Africa%' AND continent is not null		
GROUP BY location
ORDER BY TotalDeathCount desc

-- Oceania
SELECT location,  MAX(total_deaths) as TotalDeathCount 
FROM TryingToGetData.. covidDeaths
WHERE continent like '%Oceania%' AND continent is not null		
GROUP BY location
ORDER BY TotalDeathCount desc

-- Global Numbers
Select SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from TryingToGetData.. covidDeaths
where continent is not null
order by 1,2

SELECT date, SUM(total_cases) as Total_cases, SUM(total_deaths) as Total_Deaths, SUM(total_deaths)/SUM(total_cases)*100 as DeathPercentage
FROM TryingToGetData.. covidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2
/* just checking if the above numbers are correct and somehow they are
Select date, SUM(total_cases) as Total_cases, SUM(total_deaths) as Total_Deaths, SUM(total_deaths)/SUM(total_cases) as DeathPercentage
from TryingToGetData.. covidDeaths
where location like '%world%'
GROUP BY date
order by 1,2
-------------------------------------
Select location,date, MAX(total_Deaths)
from TryingToGetData.. covidDeaths
where location like '%world%'
GROUP BY location, date
order by 1,2
*/


-- total population vs vaccinations with a rolling count of people vaccinated 
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM TryingToGetData..covidDeaths dea
JOIN TryingToGetData..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null AND dea.new_vaccinations is not null ----------------- added this so we could get rid of al the null nonsense 
ORDER BY 2,3

-- we are going to use a CTE
WITH popVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM TryingToGetData..covidDeaths dea
JOIN TryingToGetData..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPerVacc
FROM 
    popVsVac
ORDER BY Location, Date;

-- making sure the numbers are correct 
/*
select location, population, SUM(new_vaccinations)
from TryingToGetData.. covidVaccinations
where location like '%Germany%'
group by location, population
*/

-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccination numeric,
	RollingPeopleVaccinated numeric
	)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM TryingToGetData..covidDeaths dea
JOIN TryingToGetData..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPerVacc
FROM 
    #PercentPopulationVaccinated
ORDER BY Location, Date;

-- CREATING A VIEW
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM TryingToGetData..covidDeaths dea
JOIN TryingToGetData..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated