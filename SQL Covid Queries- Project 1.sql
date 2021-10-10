--select *
--from PortfolioProject..[CovidVaccinations]
--order by location, date

select *
from PortfolioProject..[CovidDeaths]
order by location, date

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..[CovidDeaths]
order by 1,2

-- Looking at Total cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as 'Percent of deaths'
from PortfolioProject..[CovidDeaths]
order by 1,2

--Percent of deaths for Australia

select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as 'Percent of deaths'
from PortfolioProject..[CovidDeaths]
where location= 'Australia'
order by 1,2

--Looking at Total cases vs Population

select location, date, total_cases, population, (total_cases / population) * 100 as 'Percent of cases'
from PortfolioProject..[CovidDeaths]
order by 1,2

-- To lookup percent of cases as per country vs population

select location, date, total_cases, population, (total_cases / population) * 100 as 'Percent of cases'
from PortfolioProject..[CovidDeaths]
order by 5 desc

--Country with highest percent of cases

select location, max (total_cases) as 'Max total cases', population, max(total_cases / population) * 100 as 'Percent of cases'
from PortfolioProject..[CovidDeaths]
group by location, population
having max(total_cases / population) * 100 is not Null

--Showing countries with highest death count vs population

select location, max(total_deaths/population)* 100 as 'Percent of deaths'
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc

--Showing continent with highest death count per population


select continent, max(cast(total_deaths as int)) as 'Total deaths per Continent'
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by 2 desc

--showing Global Numbers

select sum(new_cases) as newcases, sum(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null

select *
from PortfolioProject..CovidDeaths cd
inner join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date

--looking at total population vs vaccinations
select  cd.location, cd.date, cd.population, cv.new_vaccinations
from PortfolioProject..CovidDeaths cd
inner join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
order by location,cd.date asc

--Rollingnewvaccinations rate
select  cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(new_vaccinations as int)) over (partition by cd.location order by cd.date) as Rollingnewvaccinations
from PortfolioProject..CovidDeaths cd
inner join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
order by location,cd.date asc

--Defined CTE

with CTE 
AS (
select  cd.location, cd.date, cd.population, cv.new_vaccinations, 
sum(cast(new_vaccinations as int)) over (partition by cd.location order by cd.date) as Rollingnewvaccinations
from PortfolioProject..CovidDeaths cd
inner join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
)

--Looking for Total new vaccinations vs Population

--select CTE.*, (Rollingnewvaccinations/ population) * 100 AS 'Percentofrollingnewvac'
--from CTE

--Used CTE to lookup maximum number of vaccinations and percent of rolling new vaccinations as per country

select CTE.location, MAX(CTE.new_vaccinations) AS Maxnumberofvaccinations, MAX(Rollingnewvaccinations/ population) * 100 AS 'Percentofrollingnewvac'
from CTE
GROUP BY CTE.location


-- Temp table created to show percent of rolling new vaccinations
drop table if exists #CovidRollingVac
create table #CovidRollingVac
(
location nvarchar(50),
date date,
population int,
new_vaccinations int, 
total_deaths int,
Rollingnewvaccinations int
)

insert into #CovidRollingVac(location,date,population,new_vaccinations,total_deaths,Rollingnewvaccinations)
(
select cd.location, cd.date, cd.population, cv.new_vaccinations, cd.total_deaths,
sum(cast(new_vaccinations as int)) over (partition by cd.location order by cd.date) as Rollingnewvaccinations
from PortfolioProject..CovidDeaths cd
inner join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null
)

select location,MAX(population) as maximumpopulation,max(total_deaths) as totalmaxdeath,max(Rollingnewvaccinations) as rollingnewvaccinations, MAX(CAST(Rollingnewvaccinations AS FLOAT)/CAST(population AS FLOAT)) *100  as percentofrollingvac from #CovidRollingVac
group by location
order by percentofrollingvac desc
