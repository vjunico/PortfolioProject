--select *
--from CovidDeaths

--select * 
--from CovidVaccinations

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,5) as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Indonesia' and continent is not null
order by 1,2


-- Looking at Total Cases vs Total Population
-- Shows what percentage of population got covid
select location, date, population, total_cases, round((total_cases/population)*100,5) as CasesPercentage
from PortfolioProject..CovidDeaths
where location = 'Indonesia' and continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, round(MAX(total_cases/population)*100,5) as CasesPercentage
from PortfolioProject..CovidDeaths
--where location = 'Indonesia'
where continent is not null
group by location, population
order by 4 DESC

-- Showing Countries with the highest Death Count per Population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'Indonesia'
where continent is not null
group by location
order by 2 DESC

-- Showing Continent with the highest Death Count per Population
select location as Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'Indonesia'
where continent is null and location in (select distinct continent from PortfolioProject..CovidDeaths)
group by location
order by 2 DESC

-- Global Numbers

select /*date, */sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

with PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinations)
as (
	select dea.continent, dea.location, dea.date, dea.population, convert(numeric, isnull(vac.new_vaccinations,'0')) as new_vaccinations
	,sum(convert(numeric, isnull(vac.new_vaccinations,'0'))) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null)
	--order by 2,3)
select *, (total_vaccinations/population)*100 total_vac_percentage
from PopvsVac

-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, convert(numeric, isnull(vac.new_vaccinations,'0')) as new_vaccinations
,sum(convert(numeric, isnull(vac.new_vaccinations,'0'))) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
