

SELECT * FROM portfolioProject..covid_death;

--Selecting the needed column
SELECT location,date, total_cases,new_cases,total_deaths, population
FROM portfolioProject..covid_death
ORDER BY 1,2;

--Total cases Vs Total deaths.
SELECT location,date, total_cases,total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
FROM portfolioProject..covid_death
where location like '%Germany%'
ORDER BY 1,2;


--Total Cases and the population (percentage of population with covid)
SELECT location,date, total_cases,population, (total_cases/ population)*100 as infectionRate
FROM portfolioProject..covid_death
where location like '%Germany%'
ORDER BY 1,2;

--Country with the highest infection rate
SELECT location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 as infectionRate
FROM portfolioProject..covid_death
GROUP BY location, population
ORDER by infectionRate desc;

---Death Count per population for different countries
SELECT location, MAX(cast(total_deaths as int)) as totalDeathCount
FROM portfolioProject..covid_death
WHERE continent is not null
GROUP BY location
ORDER by totalDeathCount desc;

---Death Count per population for different continent
SELECT continent, MAX(cast(total_deaths as int)) as totalDeathCount
FROM portfolioProject..covid_death
WHERE continent is not null
GROUP BY continent
ORDER by totalDeathCount desc;

--Global Figures
SELECT date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM portfolioProject..covid_death
WHERE continent is not null
--where location like '%Germany%'
GROUP BY date
ORDER by TotalDeath desc;

--Total Number of Death
SELECT SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM portfolioProject..covid_death
WHERE continent is not null
--where location like '%Germany%'
--GROUP BY date
ORDER by TotalDeath desc;

--Vacination table
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
FROM portfolioProject..covid_death dea
JOIN portfolioProject..covid_vacination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3;


SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_Vaccinations as int))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioProject..covid_death dea
JOIN portfolioProject..covid_vacination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER by 2,3;

--Using CTI
WITH PoPvsVAC (continent, location, date, population, RollingPeopleVaccinated, new_vaccinations )
AS
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_Vaccinations as int))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioProject..covid_death dea
JOIN portfolioProject..covid_vacination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2,3;
)
SELECT *
FROM PoPvsVAc;

--CREATE temp Table
DROP TABLE IF EXIST  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_Vaccinations as int))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioProject..covid_death dea
JOIN portfolioProject..covid_vacination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;


--Create View
CREATE VIEW  PercentPopulationVaccinated as
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_Vaccinations as int))
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolioProject..covid_death dea
JOIN portfolioProject..covid_vacination vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
