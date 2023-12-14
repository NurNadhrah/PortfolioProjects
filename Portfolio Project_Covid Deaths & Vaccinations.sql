SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4


SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3, 4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Shows possibility of death if person living in US contract covid
SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/CONVERT(float,total_cases))*100 AS DeathPercentageOverTotalCases
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2


--Show what percentage of Malaysia population got covid
SELECT location, date, population, CONVERT(float, total_cases), (CONVERT(float, total_cases)/population)*100 AS CasesPercentageOverPopulation
FROM PortfolioProject..CovidDeaths
WHERE location = 'Malaysia'
ORDER BY 1, 2


--Shows countries with highest infection rate compared to population
SELECT location, population, MAX(CONVERT(float, total_cases)) AS HighestInfectionCount, (MAX(CONVERT(float, total_cases))/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC


--Show countries with highest death count
SELECT location, MAX(CONVERT(float, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Show continent with highest death count
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE location IN ('Asia', 'Africa', 'Europe', 'North America', 'South America', 'Oceania')
GROUP BY location
ORDER BY TotalDeathCount DESC


--Total of new cases and new deaths including all countries per day
SELECT date, SUM(new_cases) AS Total_new_cases, SUM(new_deaths) AS Total_new_Deaths
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY date
ORDER BY 1


--Deaths percentage per day including all countries across the world
SELECT date, SUM(CONVERT(float, total_cases)) AS Total_cases, SUM(CONVERT(float, total_deaths)) AS Total_Deaths, 
SUM(CONVERT(float, total_deaths))/SUM(CONVERT(float, total_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY date
ORDER BY 1 desc


--CTE
--Show total people vaccinated after added for each day
--Show total percentage of population vaccinated
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
FROM PopvsVac


-- temp table
--Show total people vaccinated after added for each day
--Show total percentage of population vaccinated
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated


--create view
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated