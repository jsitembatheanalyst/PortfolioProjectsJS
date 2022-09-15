SELECT *
FROM Portfolio_Project..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

-- SELECT *
-- FROM Portfolio_Project..CovidVaccinations
-- ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
ORDER BY 1,2

-- Total cases vs Total Deaths 
-- Likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
WHERE location like '%states%' AND continent is NOT NULL
ORDER BY 1,2

-- Total cases vs Population
-- Percentage of the population that got covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as Percent_Population_Infected
FROM Portfolio_Project..CovidDeaths
WHERE location like '%states%' AND continent is NOT NULL
ORDER BY 1,2

-- Countries with the highest infection rates compared to populaiton

SELECT Location, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
FROM Portfolio_Project..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

-- Countries with the highest death count per population

SELECT location, MAX(cast (total_deaths as int)) AS Total_Death_Count
FROM Portfolio_Project..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC

-- Breakdown by continent

SELECT continent, MAX(cast (total_deaths as int)) AS Total_Death_Count
FROM Portfolio_Project..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- Correction from the continent use above, use location in query

SELECT location, MAX(cast (total_deaths as int)) AS Total_Death_Count
FROM Portfolio_Project..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is NULL
GROUP BY location
ORDER BY Total_Death_Count DESC


-- More breakdown

SELECT continent, MAX(cast (total_deaths as int)) AS Total_Death_Count
FROM Portfolio_Project..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- Continents with the highest death counts per population

SELECT continent, MAX(cast (total_deaths as int)) AS Total_Death_Count
FROM Portfolio_Project..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- Redo the queries above but replace location with continent 

-- Global Numbers 

SELECT date, SUM(new_cases) AS Total_Cases,SUM(cast (new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage--total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS Total_Cases,SUM(cast (new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage--total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is NOT NULL
-- GROUP BY date
ORDER BY 1,2


-- Total population vs vaccination

SELECT *
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location=vac.location
	AND dea.date=vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated

	-- or use (convert (int,vac.new_vaccinations)) in plave of (cast....as int)
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 1,2,3


-- Use CTE


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location
	ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated

	-- or use (convert (int,vac.new_vaccinations)) in plave of (cast....as int)
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE 
Drop table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location
	ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated

	-- or use (convert (int,vac.new_vaccinations)) in plave of (cast....as int)
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location=vac.location
	AND dea.date=vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location
	ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated

	-- or use (convert (int,vac.new_vaccinations)) in plave of (cast....as int)
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3