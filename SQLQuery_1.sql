USE PortfolioProject;
select *
from dbo.CovidDeaths
order by 3,4

-- select data that we are going to be using
select location,date,total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs. total deaths
-- show the likelihood of dying if you contract covid in your country
select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%china%'
and continent is not null
order by 1,2

-- looking at total cases vs. population
-- shows what percentage of population got covid
select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
from dbo.CovidDeaths
-- where location like '%china%'
order by 1,2



-- looking at countries with highest infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from dbo.CovidDeaths
where continent is not null
group by location,population
order by PercentPopulationInfected DESC

-- showing countries with highest death count per population
select location, max(total_deaths) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc -- we found that 'world''europe' 'asia' which are not countries

-- select location,population,MAX(total_deaths) as TotalDeathsCount, MAX(total_deaths/population)*100 as PercentPopulationDeath
-- from dbo.CovidDeaths
-- where continent is not null
-- group by location,population
-- order by PercentPopulationDeath DESC

-- Let's break things down by continent
-- showing contintents with the highest death count per population
select continent, max(total_deaths) as TotalDeathCount
From CovidDeaths
where continent is not null -- and location not like '%income%'
Group by continent
order by TotalDeathCount desc

-- select * from CovidDeaths
-- where location like '%income%'

-- select continent, max(total_deaths) as TotalDeathCount,max(total_deaths/population)*100 as PercentPopulationDeath
-- From CovidDeaths
-- where continent is not null -- and location not like '%income%'
-- Group by continent
-- order by PercentPopulationDeath desc


-- GLOBAL NUMBERS
select date, sum(new_cases),sum(new_deaths)--, sum(new_deaths)/sum(new_cases) as DeathPercentage
from dbo.CovidDeaths
-- where location like '%china%'
where continent is not null
group by date
order by 1,2


-- looking at total population vs. Vaccinations

-- use cte
with PopvsVac(Continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
    sum(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
   -- ,(RollingPeopleVaccinated/population)*100
from CovidVaccinations vac
join CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2,3
)

select *, (RollingPeopleVaccinated/population)*100 from PopvsVac

-- temp table

Drop table if EXISTS #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date datetime,
    Population numeric,
    New_Vaccinations numeric,
    RollingPeopleVaccinated NUMERIC
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
    sum(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
   -- ,(RollingPeopleVaccinated/population)*100
from CovidVaccinations vac
join CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
-- where dea.continent is not null
-- ORDER BY 2,3
select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated




-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, 
    sum(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
   -- ,(RollingPeopleVaccinated/population)*100
from CovidVaccinations vac
join CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2,3


select * from PercentPopulationVaccinated