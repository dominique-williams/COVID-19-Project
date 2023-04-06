/*
COVID-19 Data Exploration 

Skills used: Temp Tables, Windows Functions, CTE'S, Joins, Aggregate Functions, Creating Veiws, Converting Data Types

*/

Select *
From CovidDeaths
Where continent is not null
Order by 3,4

-- Select data that I am going to be staring with

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
Order by 1,2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as [Death Percentage]
From CovidDeaths
--Where location like '%states%' 
Where continent is not null
Order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population caught COVID

Select location, date, population, total_cases, (total_cases/population)*100 as [Population Infection Rate]
From CovidDeaths
--Where location like '%states%' 
Where continent is not null
Order by 1,2

--Countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as [Highest Infection Count], MAX((total_cases/population))*100 as [Highest Infection Rate]
From CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, population
Order by [Highest Infection Rate] desc


--Countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as [Total Death Count]
From CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by [Total Death Count] desc

--Breaking thing down by Continent
--Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as [Total Death Count]
From CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by [Total Death Count] desc


--Global Numbers

Select date, SUM(new_cases) as[Total Cases], SUM(cast(new_deaths as int))as [Total Deaths], SUM(cast(new_deaths as int))/SUM(new_cases) as [Death Percentage Globally]
From CovidDeaths
Where continent is not null
Group by date
Order by 1,2

-- Total Population vs Vaccinations
-- Shows percentage of the population that has received at least one Covid Vaccine 

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as [Rolling Vaccinations]
--,([Rolling Vaccinations]/d.population)*100
From CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null
Order by 2,3

--Using CTE to perform calculation on partition by in previous query

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, [Rolling Vaccinations])
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as [Rolling Vaccinations]
--,([Rolling Vaccinations]/d.population)*100
From CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null
--Order by 2,3
)

Select *, ([Rolling Vaccinations]/Population) * 100
From PopvsVac


--Using Temp Table to perform calcultion on partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255), 
Location nvarchar (255), 
Date datetime,
Population numeric,
New_vaccinations numeric,
[Rolling Vaccinations] numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as [Rolling Vaccinations]
--,([Rolling Vaccinations]/d.population)*100
From CovidDeaths d
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
Where d.continent is not null
--Order by 2,3

Select *, ([Rolling Vaccinations]/Population) * 100
From #PercentPopulationVaccinated


--Creating Veiws to store data for visualiztions

Create View GlobalDeaths as
Select date, SUM(new_cases) as[Total Cases], SUM(cast(new_deaths as int))as [Total Deaths], SUM(cast(new_deaths as int))/SUM(new_cases) as [Death Percentage Globally]
From CovidDeaths
Where continent is not null
Group by date
--Order by 1,2

Create View CountryDeathPercentage as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as [Death Percentage]
From CovidDeaths
Where location like '%states%' and continent is not null
--Order by 1,2
