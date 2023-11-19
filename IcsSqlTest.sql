-- Посаженников Алексей
-- Справочник сотрудников
create table Employee (
	ID int not null primary key
	,Code varchar(10) not null unique
	,Name varchar(255)
);

insert into Employee (ID, Code, Name)
values 
	(1, 'E01', 'Ivanov Ivan Ivanovich')
	,(2, 'E02', 'Petrov Petr Petrovich')
	,(3, 'E03', 'Sidorov Sidr Sidorovich')
 	,(4, 'E04', 'Semenov Semen Semenovich')
	-- Полный тёзка сотрудника E02
	,(5, 'E05', 'Petrov Petr Petrovich');

-- Отпуска сотрудников
create table Vacation (
	ID int not null auto_increment primary key
	,ID_Employee int not null references Employee(ID)
	,DateBegin date not null
	,DateEnd date not null
);

insert into Vacation (ID_Employee, DateBegin, DateEnd)
values 
	(1, '2019-08-10', '2019-09-01')
	,(2, '2019-05-01', '2019-05-15')
	,(1, '2019-12-29', '2020-01-14')
	,(3, '2020-01-14', '2020-01-14')
	,(4, '2021-02-01', '2021-02-14');
  
/* 
    Вывести коды и периоды отпусков сотрудников, которые были в отпуске одновременно
    в 2020 году
    Одновременный отпуск - когда хотя бы 1 день отпусков у двух сотрудников совпадает
    Дополнение:
    - в случае декретного отпуска сотрудник мог уйти в отпуск в 2019-ом году, а вернуться в 2021-ом
    На выходе:
    - таблица со столбцами (КодСотрудника1, НачалоОтпуска, КонецОтпуска, КодСотрудника2, НачалоОтпуска, КонецОтпуска)
    - должна вернуться одна строка с парой "E01 - E03". При этом "E03 - E01" - это дубль, которого не должно быть в итоговом результате
    Ограничения:
    - правильными считаются решения без использования конструкций "group by", "distinct"
    - нет дублирования кода
    - решение должно быть без использования вспомогательных функций greatest(), least()
    - засчитываются решения БЕЗ использования OR, CASE, CTE
*/
/*
    Создадим переменную в виде таблицы в которой будут коды сотрудников и даты их отпусков
    Сразу отфильтруем тех сотрудников чей отпуск начался не позднее 2020-12-31 
    и тех у кого отпуск закончился не ранее 2020-01-01
*/
declare @EmployeeVacations TABLE (
	ID int not null
	,Code varchar(10) not null
	,ID_Employee int not null
	,DateBegin date not null
	,DateEnd date not null
);

insert into @EmployeeVacations (ID,Code,ID_employee,DateBegin,DateEnd)
	select
		e.id
		,e.code
		,v.ID_Employee
		,v.DateBegin
		,v.DateEnd
	from employee as e
		join vacation as v on v.id_employee = e.id
	where v.DateBegin <= '2020-12-31' 
		and v.DateEnd >= '2020-01-01';
          
-- Сделаем selfjoin для получения всех сочетаний сотрудников
select
	l.code as КодСотрудника1
	,l.DateBegin as НачалоОтпуска1
	,l.DateEnd as КонецОтпуска1
	,r.code as КодСотрудника2
	,r.DateBegin as НачалоОтпуска2
	,r.DateEnd as КонецОтпуска2
from @EmployeeVacations as l
	-- уберем дубли и отфильтруем пересекающиеся даты отпусков
	join @EmployeeVacations as r on r.code > l.code                    
		and r.DateBegin >= l.DateEnd                                   
		and r.DateEnd <= l.DateBegin;

