SELECT * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null;

--SELECT * 
--from PortfolioProject.dbo.CovidVaccinations



---Data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2;



---Total Cases vs Total Death

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Rate
from PortfolioProject.dbo.CovidDeaths
where location like '%Germany%'
and continent is not null
order by 1,2;



--- Total Cases vs Populaiton (%)

Select Location, date, total_cases, population, (total_cases/population)*100 as TotalCases_Rate
from PortfolioProject.dbo.CovidDeaths
where location like '%Germany%'
and continent is not null
order by 1,2;



--- Highest Infection rate by countries

Select Location, population, MAX(total_cases) as Highest_Infection, Max((total_cases/population)*100) as TotalCases_Rate
from PortfolioProject.dbo.CovidDeaths
--where location like '%Germany%'
where continent is not null
group by Location, population
order by TotalCases_Rate DESC;



--- Highest Death count per country

Select Location, MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject.dbo.CovidDeaths
--where location like '%Germany%'
where continent is not null
group by Location
order by Total_Death_Count DESC;



--- Highest Death count per continent

Select Continent, MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject.dbo.CovidDeaths
--where location like '%Germany%'
where continent is not null
group by Continent
order by Total_Death_Count DESC;



--- Global numbers 

Select SUM(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as Total_Death_Rate
from PortfolioProject.dbo.CovidDeaths
--where location like '%Germany%'
where continent is not null
--Group by date
order by 1,2;



--- Total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as Added_Vaccination
from PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--- CTE

With Pop_Vac (Continent, Location, date, Population, new_vaccinations, Added_Vaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as Added_Vaccination
from PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Added_Vaccination/Population)*100
from Pop_Vac




--- TEMP Table

DROP TABLE if exists Vaccinated_Population_Percentage
Create table Vaccinated_Population_Percentage
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	Added_Vaccination numeric
	)
Insert into Vaccinated_Population_Percentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as Added_Vaccination
from PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (Added_Vaccination/Population)*100 as Vacc_Rate
from Vaccinated_Population_Percentage




---View

Create View _Vaccinated_Population_Percentage_ as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location 
	Order by dea.location, dea.date) as Added_Vaccination
from PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
from _Vaccinated_Population_Percentage_
