/*
Ezequiel Torres' Covid 19 Data Exploration Project

The Skills/Concepts displayed: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
FROM P1..CovidDeaths
WHERE continent IS NOT null 
ORDER BY 3,4

--SELECT *
--FROM P1..CovidVaccinations
--ORDER BY 3,4

--Starting Query

SELECT Location, date, total_cases, new_cases, total_deaths
FROM P1..CovidDeaths
WHERE continent IS NOT null 
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in specific country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM P1..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT null 
ORDER BY 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid


SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS PercentofPopulationInfected
FROM P1..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, (total_cases/population)*100 as PercentofPopulationInfected
FROM P1..CovidDeaths
-- WHERE Location LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentofPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM P1..CovidDeaths
-- WHERE Location LIKE '%states%'
WHERE Continent IS NOT null
GROUP BY Location
ORDER BY TotalDeathCount DESC



-- Breaking it up by Continent
-- Showing continents with the highest death count per population


SELECT Continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM P1..CovidDeaths
-- WHERE Location LIKE '%states%'
WHERE Continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM P1..CovidDeaths
--WHERE location LIKE '%states%'
WHERE Continent IS NOT null
--ORDER BY data
ORDER by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM P1..CovidDeaths dea
Join P1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From P1..CovidDeaths dea
Join P1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

--, (RollingPeopleVaccinated/population)*100

From P1..CovidDeaths dea

Join P1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

--, (RollingPeopleVaccinated/population)*100

From P1..CovidDeaths dea

Join P1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


