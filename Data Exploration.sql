Use PortfolioProject
go

SELECT *
from CovidDeath

SELECT *
from CovidVaccination
ORDER BY 3, 4

--Looking at the likelihood of dying after contraction COVID-19
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeath
WHERE location LIKE '%States%'
Order by 1,2

--Looking at total cases vs population
--Shows what percentage of population has COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 as CovidInfectionPercentage
FROM CovidDeath
WHERE location LIKE '%States%'
Order by 1,2

--Looking at countries with the highest infection rate compared to population

SELECT Location, Population, MAX(total_cases)as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeath
GROUP BY Location, Population
order by 1,2

--Showing the countries with the highest death count per population 
SELECT Location, MAX(cast(total_deaths as int))as TotalDeathCount
FROM CovidDeath
where continent is not null
GROUP BY Location
order by TotalDeathCount desc


--Let's break it down by continent
--Showing the countries with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int))as TotalDeathCount
FROM CovidDeath
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--1
--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeath
WHERE continent is not null
order by 1, 2

--2
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeath
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeath
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeath
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


--Looking at Total Population vs Vaccinations

With PopvsVAc (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE

Drop Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Create View to store data for later visualisations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeath dea
join CovidVaccination vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 

