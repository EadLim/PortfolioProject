SELECT * 
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM PortofolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND continent IS NOT NULL

--Looking at Total cases vs Total Deaths in USA

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL

--Looking at Total cases vs Population in USA
--Shows what percentage of Population got Covid
SELECT location, date, population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location LIKE '%states%'

--Looking at countries with highest infection Rate Cases compared to Population
SELECT location, population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC
--WHERE location LIKE '%states%'

--Showing Countries with the highest death count per population
SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing continents with the highest death count per population
SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS
SELECT  SUM(new_cases) AS Total_Cases , SUM(CAST(new_deaths AS INT)) AS Total_Deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeaths

--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccination 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths DEA
JOIN PortofolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
--AND VAC.new_vaccinations IS NOT NULL
ORDER BY 2,3

-- USE CTE
WITH PopVsVac (Continent, Location, Date , Population, new_vaccinations,RollingPeopleVaccinated)
AS (
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths DEA
JOIN PortofolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
--AND VAC.new_vaccinations IS NOT NULL
--ORDER BY 2,3 
)
SELECT *, (RollingPeopleVaccinated/Population *100)
FROM PopVsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
DATE datetime, 
Population Numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths DEA
JOIN PortofolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
--WHERE DEA.continent IS NOT NULL 

SELECT *, (RollingPeopleVaccinated/Population *100)
FROM #PercentPopulationVaccinated


--CREATING VIEW to store data for  later Visualizations 
CREATE VIEW  PercentPopulationVaccinated
AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(INT,VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM PortofolioProject..CovidDeaths DEA
JOIN PortofolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
--AND VAC.new_vaccinations IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated