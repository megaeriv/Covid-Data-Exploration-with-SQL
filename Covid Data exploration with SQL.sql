select * 
From PortfolioProject..['covid-deaths$']
Where continent is not null
order by 3,4

--select * 
--From PortfolioProject..['covid-vaccinations$']
--order by 3,4



---Death data to be used
select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['covid-deaths$']
order by 1,2

--Cases vs Deaths
--DeathPercentage showing percentage chance of dieing if covid contracted 
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
Where location like '%kingdom%'
order by 1,2

--Cases vs Population
-- CasePercentage shows percentage of population infected
select location, date, population, total_cases,  (total_cases/population)*100 as CasePercentage
From PortfolioProject..['covid-deaths$']
Where continent is not null
order by 1,2

--Infection rate relative to Population 
select location,  population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['covid-deaths$']
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Countires with Highest deathcount 
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Continents with Highest deathcount
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['covid-deaths$']
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers
select  SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths$']
where continent is not null
order by 1,2


--Total world population vs Vaccinations

--With CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/Population)* 100
from PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 


select *, (RollingPeopleVaccinated/Population)* 100
from #PercentPopulationVaccinated

--Creating View for visualizations

Create View #PercentPopulationVaccinated as 
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['covid-deaths$'] dea
Join PortfolioProject..['covid-vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
