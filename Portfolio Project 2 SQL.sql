select *
FROM CovidDeaths
order by 1,2

select *
From CovidDeaths

-- Looking at total Cases vs Total Deaths
-- Shows the Likelihood of deaths in your country
select location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as 'Percentage of Deaths'
FROM CovidDeaths
Where location like '%Kingdom%'
order by 1,2

-- Looking at the total cases vs population
-- Shows what percentage of population got COVID
select location, date, total_cases, population, (Total_cases/Population)*100 as 'Percentage of population that had COVID'
FROM CovidDeaths
Where location like '%Kingdom%'
order by 1,2

-- Looking at countries with the Highest Infection Rate comapared to Population
select Location, Max(total_cases) as 'Highest Infection Count', Population, MAX((Total_cases/Population))*100 as 'Percentage of population that had COVID'
FROM CovidDeaths
Group by Location, Population
Order by [Percentage of population that had COVID] desc

-- Shows Highest death count per population
select Location, Max(cast(total_deaths as int)) as Total_Deaths
FROM CovidDeaths
-- Where location like 'United Kingdom'
Group by Location
Order by [Total_Deaths] desc

-- Seperate by Continents
Select continent, Max(cast(total_deaths as int)) as Total_deaths
From CovidDeaths
Where [Total_deaths] is not null
Group by continent
order by [Total_deaths] desc

-- Global numbers
select date, sum(new_cases) as 'New Cases', sum(cast(new_deaths as int)) as 'New Deaths', sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Percentage of Death'
from CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Looking at total population vs vaccination
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Rolling count of vaccinations
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations as 'New Vaccination',
SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as 'Rolling Count',
([Rolling Count]/dea.population)*100
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Creating CTE
-- Population vs Vaccination

With PopulationvsVac (Continent, Location, Date, Population, [New Vaccination], [Rolling Count])
As(
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations as 'New Vaccination',
SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as 'Rolling Count'
--('Rolling Count'/dea.population)*100
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
select *, ([Rolling Count]/Population)*100 as 'Percentage of population vaccinated'
from PopulationvsVac



--Creating a Temp Table
-- Same as previous

Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingCount numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations as 'New Vaccination',
SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as 'Rolling Count'
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
select *, ([RollingCount]/Population)*100 as 'Percentage of population vaccinated'
from #PercentPopulationVaccinated


-- Creating View to sort visual data for later

CREATE View PercentPopulationVaccinated as
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations as 'New Vaccination',
SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as 'Rolling Count'
from CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null



