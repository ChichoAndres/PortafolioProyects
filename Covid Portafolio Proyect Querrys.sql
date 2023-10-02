select * 
from PortafolioProyect.dbo.CovidDeaths$
where continent is not null
order by 3, 4

--select * 
--from PortafolioProyect.dbo.CovidVacunation$
--order by 3, 4

--- Select Data that we are going to be using

select location,date,total_cases, new_cases, total_deaths, population
from PortafolioProyect.dbo.CovidDeaths$
order by 1,2

-- look at the total cases vs total death
--- shows likelihood of dying if you contract covid in your contry
select 
location,
date,
total_cases, 
total_deaths,
(cast(total_deaths as float)) / (cast (total_cases as float))*100 as DeathPercentage
from PortafolioProyect.dbo.CovidDeaths$
where location like '%states%'
order by 1,2 

--- Loking at Total Cases vs Population
--- shows what percentage of population got covid
select 
location,
date,
population,
total_cases, 
(cast(total_cases as float)/ population)*100 as PercentPopulationInfeced
from PortafolioProyect.dbo.CovidDeaths$
---where location like '%states%'
order by 1,2


--- Looking at countris with highesy infection rate compared to population
select 
location,
population,
max(total_cases) as hisghestInfectionCount,
max((cast(total_cases as float)/ population))*100 as PercentPopulationInfeced
from PortafolioProyect.dbo.CovidDeaths$
where location like '%states%'
Group by location, population
order by PercentPopulationInfeced DESC

--- Showing countries with highest death count per Population

select 
location,
MAX(cast(total_deaths as int)) As TotalDeathCount
from PortafolioProyect.dbo.CovidDeaths$
---where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount DESC

--- Showing continets with the highest death per population

select 
continent,
MAX(cast(total_deaths as int)) As TotalDeathCount
from PortafolioProyect.dbo.CovidDeaths$
---where location like '%states%'
where continent is NOT null
Group by continent
order by TotalDeathCount DESC

--- Global numbers--CHECK


select 

SUM(new_cases) as total_cases, SUM(cast(new_deaths as FLOAT)) as total_deaths,
sum(cast( new_deaths as int)) / sum(new_cases) * 100 as DeathPercentaje
from PortafolioProyect.dbo.CovidDeaths$
---where location like '%states%'
where continent is not null
 ---new_cases > 0 and new_deaths > 0
order by 1,2 


---- covid vacunation
--- LOOKING AT TOTAL POP VS VACCINATIONS

SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations as int)) over (partition by d.location ORDER BY D.LOCATION, D.DATE) 
AS RollingPeopleVaccinated
FROM PortafolioProyect..CovidDeaths$ d
JOIN PortafolioProyect..CovidVacunation$ V 
ON D.location = V.location 
AND D.date = V.date
where d.continent is not null
ORDER BY 2, 3

--- use cte

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations as int)) over (partition by d.location ORDER BY D.LOCATION, D.DATE) 
AS RollingPeopleVaccinated
FROM PortafolioProyect..CovidDeaths$ d
JOIN PortafolioProyect..CovidVacunation$ V 
ON D.location = V.location 
AND D.date = V.date
where d.continent is not null
--ORDER BY 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations as int)) over (partition by d.location ORDER BY D.LOCATION, D.DATE) 
AS RollingPeopleVaccinated
FROM PortafolioProyect..CovidDeaths$ d
JOIN PortafolioProyect..CovidVacunation$ V 
ON D.location = V.location 
AND D.date = V.date
---waere d.continent is not null
--ORDER BY 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Createing view to store data for later visualizations

create view PercentPopulationVaccinated as 
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
, SUM(cast(V.new_vaccinations as int)) over (partition by d.location ORDER BY D.LOCATION, D.DATE) 
AS RollingPeopleVaccinated
FROM PortafolioProyect..CovidDeaths$ d
JOIN PortafolioProyect..CovidVacunation$ V 
ON D.location = V.location 
AND D.date = V.date
where d.continent is not null
--ORDER BY 2, 3

select * from PercentPopulationVaccinated