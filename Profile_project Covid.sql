select *
From [Portfolio Project]..Covid_overledenen
where continent is not null
order by 3,4

select *
From [Portfolio Project]..Covid_gevaccineerd
order by 3,4

--Data die gebruikt wordt

select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..Covid_overledenen
order by 1,2

-- Totaal aantal gevallen vs Totaal aantal doden
-- De waarschijnlijkheid dat je overlijdt als je Covid oploopt in Nederland

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Percentage_Deaths
From [Portfolio Project]..Covid_overledenen
where location like '%neth%'
order by 1,2

--Welk percentage van de Nederlandse bevolking krijgt Covid

select location, date, total_cases, population, (total_cases/population)*100  as Percentage_cases
From [Portfolio Project]..Covid_overledenen
where location like '%neth%'
order by 1,2

--Landen met de hoogste besmettinggraad
select location, max(total_cases) as hoogste_besmettingsgraad, population, max(total_cases/population)*100  as Percentage_cases
From [Portfolio Project]..Covid_overledenen
where continent is not null
group by location, population
order by 4 desc

== Landen met het hoogste sterftecijfer

select location, max(cast (total_deaths as int)) as total_deaths_per_country, max(total_deaths/total_cases)*100 as Percentage_Deaths_per_cases
From [Portfolio Project]..Covid_overledenen
where continent is not null
group by location
order by 2 desc

== Continent met het hoogste sterftecijfer

select location, max(cast (total_deaths as int)) as total_deaths_per_continent
From [Portfolio Project]..Covid_overledenen
where continent is null 
and location != 'High income'
and location != 'Upper middle income'
and location != 'Lower middle income'
and location != 'Low income'
group by location
order by 2 desc

-- Cijfers wereldwijd

--totaal per datum

select date, sum(new_cases) as Cases_worldwide, sum(cast(new_deaths as int)) as Deaths_worldwide, Sum(cast(new_deaths as int))/sum(new_cases)*100 as Percentage_Deaths_Worldwide
From [Portfolio Project]..Covid_overledenen
where continent is not null
group by date
order by 1,2

--totaal tot 02-01-2022

select sum(new_cases) as Cases_worldwide, sum(cast(new_deaths as int)) as Deaths_worldwide, Sum(cast(new_deaths as int))/sum(new_cases)*100 as Percentage_Deaths_Worldwide
From [Portfolio Project]..Covid_overledenen
where continent is not null
order by 1,2

--Vergelijk totale populatie t.o.v. gevaccineerden per dag

select  doo.continent, doo.location, doo.date,doo.population, gev.new_vaccinations, sum(cast(gev.new_vaccinations as int)) over 
(partition by doo.location order by doo.location, doo.date) as aantal_gevaccineerden_cum
From [Portfolio Project]..Covid_overledenen doo
join [Portfolio Project]..Covid_gevaccineerd gev
	on doo.location = gev.location
	and doo.date = gev.date
where doo.continent is not null
order by 2,3


-- Gebruik maken van een CTE

--Percentage van de bevolking is gevaccineerd

With PopvsVac (continent, location, date, population, new_vaccinations, aantal_gevaccineerden_cum)
as
(
select  doo.continent, doo.location, doo.date,doo.population, gev.new_vaccinations, sum(cast(gev.new_vaccinations as int)) over 
(partition by doo.location order by doo.location, doo.date) as aantal_gevaccineerden_cum
From [Portfolio Project]..Covid_overledenen doo
join [Portfolio Project]..Covid_gevaccineerd gev
	on doo.location = gev.location
	and doo.date = gev.date
where doo.continent is not null
--order by 2,3
)
select * ,(aantal_gevaccineerden_cum/population)*100  as percentage_gevaccineerden
From PopvsVac

-- Datavoorbereiding voor latere visualisatie

Create view percentage_gevaccineerden as
select  doo.continent, doo.location, doo.date,doo.population, gev.new_vaccinations, sum(cast(gev.new_vaccinations as int)) over 
(partition by doo.location order by doo.location, doo.date) as aantal_gevaccineerden_cum
From [Portfolio Project]..Covid_overledenen doo
join [Portfolio Project]..Covid_gevaccineerd gev
	on doo.location = gev.location
	and doo.date = gev.date
where doo.continent is not null
order by 2,3

Select *
From percentage_gevaccineerden