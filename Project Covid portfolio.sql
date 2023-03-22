Select *
from PortfolioProject..CovidDeaths
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in my country
--	How many cases in the country and how many deaths do they have per entire cases, what is the % rate people who died who had Covid

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Ukraine'
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid

Select total_cases, population, location, date, (total_cases/population)*100 as CovidPercentage
from CovidDeaths
where location = 'Ukraine'
Order by 1,2

-- Looking at countires with highest infaction rate compared to population

Select location, population, Max(total_cases) as highestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfacted
from CovidDeaths
--where location = 'Ukraine'
Group by location, population
Order by PercentPopulationInfacted Desc


-- Showing countries with the highest death count per population

Select location, Max(cast(total_deaths as int)) as highestDeathCount
from CovidDeaths
where location = 'Canada'
and continent is not null
Group by location
Order by highestDeathCount Desc

-- Breaking things down by continent

Select location, Max(cast(total_deaths as int)) as highestDeathCount
from CovidDeaths
--where location = 'Canada'
Where continent is null
Group by location
Order by highestDeathCount Desc

-- Other way who we can get correct 
--Select continent, Max(cast(total_deaths as int)) as highestDeathCount
--from CovidDeaths
----where location = 'Canada'
--Where continent is not null
--Group by continent
--Order by highestDeathCount Desc

-- Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as highestDeathCount
from CovidDeaths
--where location = 'Canada'
Where continent is not null
Group by continent
Order by highestDeathCount Desc

-- Global numbers

Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location = 'Ukraine'
Where continent is not null
--Group by date
order by 1,2

-- Let's join two tables (coviddeaths and covid vaccinations) together based on Location and date

Select *
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- using vaccination per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using CTE

With PopulationvsVaccination (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) as ( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopulationvsVaccination


--Using temp table

Drop table if exists #PercentPopulationvsVaccination
Create table #PercentPopulationvsVaccination
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationvsVaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationvsVaccination


-- Creating a view to store data for later viz

Create view PercentPopulationvsVaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3