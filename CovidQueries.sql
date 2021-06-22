--Select *
--From Portfolio..Stats
--order by 3,4

--Select *
--From Portfolio..Vaccine
--order by 3,4

-- Looking for total case,deaths, and death rate

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Rate
From Portfolio..Stats
where location like 'Philippines'
order by 1,2

-- Looking for total case,population, and Infection rate

Select location,date,Total_cases,population,(total_cases/population)*100 as Infection_Rate
From Portfolio..Stats
order by 1,2

--Looking for countries with the top positivity rate
Select location,max(Total_cases) as Currentcasecount,population,Max((Total_cases/population)*100) as Infection_Rate
From Portfolio..Stats
group by location,population
order by Infection_Rate desc

--looking countries with top death rate or death count
Select location,max(cast(total_deaths as int)) as Currentdeathcount,population,Max((total_deaths/population)*100) as Death_Rate
From Portfolio..Stats
where continent is not null
group by location,population
order by Currentdeathcount desc

--Breaking down by continents
--Death count by continent
Select continent ,max(cast(total_deaths as int)) as Currentdeathcount
From Portfolio..Stats
where continent is not null
group by continent
order by Currentdeathcount desc;

--Global Data

Select date,Sum(new_cases) as Current_Cases, Sum(cast(new_deaths as int)) as Current_Deaths,(Sum(cast(new_deaths as int))/Sum(new_cases))*100 as Deathrate
From Portfolio..Stats
Where continent is not null
group by date
order by 1

-- USing Joins and CTE
With PopvsVac(continent,location,date,population,new_vaccinations,cumulative_vaccinations)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) 
as cumulative_vaccinations
from Portfolio..Stats dea
Join Portfolio..Vaccine vac
on dea.location=vac.location
and dea.date=vac.date

where dea.continent is not null
--order by 2,3
)
Select *,(cumulative_vaccinations/population)*100 as Percent_Vaccinated
From PopvsVac
order by 2,3

--using temp tables

Drop table if exists #PercentVaccinated
Create table #PercentVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulative_vaccinations numeric)

Insert into #PercentVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) 
as cumulative_vaccinations
from Portfolio..Stats dea
Join Portfolio..Vaccine vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
From #PercentVaccinated
order by 2,3

--creating views for data viz
Create view People_Vaccinates as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) 
as cumulative_vaccinations
from Portfolio..Stats dea
Join Portfolio..Vaccine vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

Select *
From People_Vaccinates
order by 2,3
