/*
Covid-19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
FROM PortfolioProject..['Covid deaths']
Where continent is not null
Order by location,date

--Select data we are starting with

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..['Covid deaths']
where continent is not null
Order by location,date

--Country Mortality Rate 

Select location,date,total_cases,total_deaths,
(cast(total_deaths as decimal)/total_cases)*100 as MortalityRate
From PortfolioProject..['Covid deaths']
Where location like '%kingdom%'
and continent is not null
Order by location,date

--Country Mortality Rate View

Create view CountryMortality as
Select location,date,total_cases,total_deaths,
(cast(total_deaths as decimal)/total_cases)*100 as MortalityRate
From PortfolioProject..['Covid deaths']
Where location like '%kingdom%'
and continent is not null
--Order by location,date


--Country Infection Percentage

Select location,date,total_cases,population,
(total_cases/population)*100 as InfectionPercentage
From PortfolioProject..['Covid deaths']
Where location like '%kingdom%'
and continent is not null
Order by location,date

--Country Infection Percentage View

Create view CountryInfectionPercentage as
Select location,date,total_cases,population,
(total_cases/population)*100 as InfectionPercentage
From PortfolioProject..['Covid deaths']
Where location like '%kingdom%'
and continent is not null
--Order by location,date

--Ranking Countries by Highest Infection Percentage
Select location,population,MAX(total_cases) as HighestInfectionCount,
(MAX(total_cases)/MAX(population))*100 as InfectionPercentage
From PortfolioProject..['Covid deaths']
where continent is not null
Group by location,population
Order by InfectionPercentage desc

--View

Create view HighestInfectionPercentage as
Select location,population,MAX(total_cases) as HighestInfectionCount,
(MAX(total_cases)/MAX(population))*100 as InfectionPercentage
From PortfolioProject..['Covid deaths']
where continent is not null
Group by location,population
--Order by InfectionPercentage desc

--Ranking Countries by Death Count
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid deaths']
where continent is not null
Group by location
Order by TotalDeathCount desc

--View

Create view CountryDeathCount as
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid deaths']
where continent is not null
Group by location
--Order by TotalDeathCount desc

--Break things down by continent

--Deaths per Continent

Select continent,SUM(cast(new_deaths as int)) as DeathsPerContinent
From PortfolioProject..['Covid deaths']
where continent is not null 
Group by continent
Order by DeathsPerContinent desc

--View

Create view DeathsPerContinent as
Select continent,SUM(cast(new_deaths as int)) as DeathsPerContinent
From PortfolioProject..['Covid deaths']
where continent is not null 
Group by continent
--Order by DeathsPerContinent desc

--Ranking Mortality Rate in different Continents- two different ways
Select location, sum(new_cases) as ContinentCases,
sum(cast(new_deaths as decimal)) as ContinentDeaths,
(sum(convert(int,new_deaths))/sum(new_cases))*100 as ContinentMortalityRate
FROM PortfolioProject..['Covid deaths'] dea
WHERE continent is null and location not like '%income%' and location not like 'World' and location not like '%Union'
Group by location
Order by ContinentMortalityRate desc

--View

create view ContinentMortality as
Select location, sum(new_cases) as ContinentCases,
sum(cast(new_deaths as decimal)) as ContinentDeaths,
(sum(convert(int,new_deaths))/sum(new_cases))*100 as ContinentMortalityRate
FROM PortfolioProject..['Covid deaths'] dea
WHERE continent is null and location not like '%income%' and location not like 'World' and location not like '%Union'
Group by location
--Order by ContinentMortalityRate desc

SELECT continent,SUM(new_cases) as ContinentCases,
SUM(cast(new_deaths as decimal))as ContinentDeaths,
(SUM(cast(new_deaths as decimal))/SUM(new_cases))*100 as ContientMortalityRate
FROM PortfolioProject..['Covid deaths']
WHERE continent is not null
GROUP BY continent
ORDER BY ContientMortalityRate desc


--Global Scale

SELECT Sum(new_cases) as GlobalCases,Sum(cast(new_deaths as int)) as GlobalDeaths,Sum(cast(new_deaths as int))/Sum(new_cases)*100 as GlobalMortalityRate
FROM [PortfolioProject].[dbo].['Covid deaths']
WHERE continent is not null

--Vaccination Rate

SELECT death.continent,death.location,death.date,death.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (Partition by death.location order by death.location,death.date) as VaccineCount
FROM [PortfolioProject].[dbo].['Covid deaths'] death
JOIN [PortfolioProject].[dbo].['Covid vaccinations'] vac
ON death.location=vac.location
and death.date=vac.date
where death.continent is not null
order by death.location,death.date

--View

create view VaccineRate as
SELECT death.continent,death.location,death.date,death.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (Partition by death.location order by death.location,death.date) as VaccineCount
FROM [PortfolioProject].[dbo].['Covid deaths'] death
JOIN [PortfolioProject].[dbo].['Covid vaccinations'] vac
ON death.location=vac.location
and death.date=vac.date
where death.continent is not null
--order by death.location,death.date

--Using CTE to perform Calculation on Partition By in previous query

With Vaccine(continent,location,date,population,new_vaccinations,VaccineCount)
as 
(
SELECT death.continent,death.location,death.date,death.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (Partition by death.location order by death.location,death.date) as VaccineCount
FROM [PortfolioProject].[dbo].['Covid deaths'] death
JOIN [PortfolioProject].[dbo].['Covid vaccinations'] vac
ON death.location=vac.location
and death.date=vac.date
where death.continent is not null
--order by death.location,death.date
)
Select *,(VaccineCount/population)*100 AS VaccinationRate
From Vaccine

--Using Temp Table in place of CTE

Drop table if exists #PercentPopVaccinated
Create table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
VaccineCount numeric
)

Insert into #PercentPopVaccinated
SELECT death.continent,death.location,death.date,death.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) 
over (Partition by death.location order by death.location,death.date) as VaccineCount
FROM [PortfolioProject].[dbo].['Covid deaths'] death
JOIN [PortfolioProject].[dbo].['Covid vaccinations'] vac
ON death.location=vac.location
and death.date=vac.date
where death.continent is not null
--order by death.location,death.date

Select *,(VaccineCount/population)*100 AS VaccinationRate
From #PercentPopVaccinated

--Temp Table View
Create view PercentPopVaccinated as
SELECT death.continent,death.location,death.date,death.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) 
over (Partition by death.location order by death.location,death.date) as VaccineCount
FROM [PortfolioProject].[dbo].['Covid deaths'] death
JOIN [PortfolioProject].[dbo].['Covid vaccinations'] vac
ON death.location=vac.location
and death.date=vac.date
where death.continent is not null
--order by death.location,death.date
