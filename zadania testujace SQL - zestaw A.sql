----------------------------------------------------------------------------------------------------
---- Zadania testuj�ce - Studia podyplomowe "Przetwarzanie danych - Big Data"   --------------
---- Podstawowe polecenia j�zyka SQL  - do samodzielnego wykonania
---- Zestaw A 
----------------------------------------------------------------------------------------------------

------------- Tworzenie przyk�adowego schematu -------------------------------------------------------------------
/*
IF OBJECT_ID('Filmy', 'U') IS NOT NULL 
	drop table Filmy

IF OBJECT_ID('Gatunki', 'U') IS NOT NULL 
	drop table Gatunki


create table Gatunki
(id int primary key,
nazwa varchar(20)
)

create table Filmy
(id int primary key identity(1,1),
tytul varchar(40),
gatunek int references Gatunki(Id),
cena money,
czas int,
rezyser varchar(30),
produkcja varchar(20)
)

insert into Gatunki
values(1,	'sensacyjny')
insert into Gatunki
values(2,	'dramat')
insert into Gatunki
values(3,	'komedia')
insert into Gatunki
values(4,	'biograficzny')

insert into Filmy
values('Olivier, Olivier',	2,	54,	110,	'Agnieszka Holland', 'Francja')
insert into Filmy
values('Spioch',	3,	50,	110,	'Woody Allen', 'USA')
insert into Filmy
values('Leon Zawodowiec',	1,	60,	100,	'Luc Besson', 'Francja')
insert into Filmy
values('Sprzedawcy',	3,	41,	90,	'Kevin Smith', null)
insert into Filmy
values('W pogoni za Amy',	3,	40,	 125,	'Kevin Smith', 'USA')
*/

select * from Gatunki
select * from Filmy


-----------------------------------------------------------------------------------------------
------------- Zadania SELECT -------------------------------------------------------------------

-- 1. Podaj tytu�y film�w wyre�yserowanych przez Kevina Smitha lub Woody Allena w cenie powy�ej 40 z�; posortuj alfabetycznie wed�ug tytu�u.

     
	--tytul
	----------------------------------------------------
	--Spioch
	--Sprzedawcy

     select tytul
	  from Filmy
	  where cena > 40 and (rezyser like '%Allen' or rezyser like '%Smith')
	  order by tytul;                                    
-- 2. Dla ka�dego film podaj jego tytu�, kraj produkcji i nazw� gatunku. Dla warto�ci brakuj�cych (null) wy�wietl 'brak danych'


	--tytul                                    produkcja            nazwa
	------------------------------------------ -------------------- --------------------
	--Olivier, Olivier                         Francja              dramat
	--Spioch                                   USA                  komedia
	--Leon Zawodowiec                          Francja              sensacyjny
	--Sprzedawcy                               brak danych          komedia
	--W pogoni za Amy                          USA                  komedia

	select f.tytul, ISNULL(f.produkcja,'Brak danych') as produkcja, g.nazwa
	 from Filmy f join Gatunki g
	 on f.gatunek = g.id
	 

-- 3. Podaj tytu�y i ceny komedii.
	-- a) z��czenie 
	-- b) podzapytanie

	--tytul                                    cena
	------------------------------------------ ---------------------
	--Spioch                                   50,00
	--Sprzedawcy                               41,00
	--W pogoni za Amy                          40,00

	   select f.tytul, f.cena
	   from Filmy f join Gatunki g
	   on f.gatunek = g.id
	   where g.nazwa like 'komedia'; 

	  select tytul, cena
	   from Filmy
	   where gatunek = (select id
	                    from Gatunki
						where nazwa like 'komedia'); 

-- 4. Podaj tytu�y film�w trwaj�cych d�u�ej (czas) ni� film "Leon zawodowiec"
	-- a) z��czenie 
	-- b) podzapytanie

	--tytul
	------------------------------------------
	--Olivier, Olivier
	--Spioch
	--W pogoni za Amy

	 select tytul, czas 
	 from Filmy
	 where czas > (select czas 
	               from Filmy
				   where tytul like 'Leon zawodowiec') 

     select f1.tytul
	 from Filmy f1 join Filmy f2
	 on f1.czas > f2.czas
	 where f2.tytul like 'Leon zawodowiec'  

-- 5. Podaj informacj� o tych gatunkach filmowych, kt�rych nie ma obecnie w wypo�yczalni. 
	-- a) z��czenie 
	-- b) podzapytanie
	-- c) not exists

	--nazwa
	----------------------
	--biograficzny

	 select g.nazwa 
	 from Gatunki g left join Filmy f
	 on g.id = f.gatunek
	 where f.tytul is null; 

	 select nazwa
	 from Gatunki
	 where id not in (Select gatunek
	              from Filmy) 

	
    select nazwa 
	from Gatunki g
	where not exists (Select * from Filmy f where g.id = f.gatunek)

	


-- 6. Dla ka�dego gatunku podaj jego nazw� i liczb� film�w tego gatunku

	--nazwa                liczba
	---------------------- -----------
	--biograficzny         0
	--dramat               1
	--komedia              3
	--sensacyjny           1

    select g.nazwa, count(*)
	from Filmy f join Gatunki g
	on f.gatunek = g.id
	group by g.nazwa;
	

-- 7. Podaj tytu� najdro�szego filmu. (podzapytanie i funkcje agregujace, bez TOP)

	--tytul
	------------------------------------------
	--Leon Zawodowiec
	
	  select tytul, cena
	  from Filmy
	  where cena = (select max(cena)
	                from Filmy)


-- 8. Podaj tytu� najdro�szej komedii.

	--tytul
	------------------------------------------
	--Spioch

	select f.tytul
	from Filmy f 
    where   f.cena = (select max(cena)
	                 from Filmy f join Gatunki g
					 on f.gatunek = g.id
					 where	g.nazwa like 'komedia')
					 
	  

------------- Zadania DDL -------------------------------------------------------------------

-- Utw�rz tabel� Egzemplarze o atrybutach:
	-- id_egzemplarza - liczba, klucz podstawowy
	-- nosnik - typ znakowy, przyjmuje warto�ci 'DVD', 'Blu-ray', 'Video CD'
	-- status_egz - bit, domyslna warto�� 1 (oznacza - dost�pny)
	-- id_filmu - klucz obcy do Filmu

	  create table Egzemplarze(
	               id_egzemplarza int not null primary key,
				   nosnik varchar(10) constraint nos_chk CHECK(nosnik in ('DVD','Blu-ray','Video CD')),
				   status_egz bit default 1,
				   id_film int references Filmy(id)
				   )
				   

  drop table Egzemplarze;
  select id from Filmy where tytul like 'Leon Zawodowiec'

------------- Zadania DML -------------------------------------------------------------------

---- Napisz polecenie wstawiaj�ce nowy egzemplarz filmu 'Leon Zawodowiec' na DVD
 --  insert into Egzemplarze(nosnik,id_film) values('DVD',(select id from Filmy where tytul like 'Leon Zawodowiec'))
-- Napisz polecenie, kt�re obni�a cen� wszystkich komedii o 5 z�.
-- Napisz polecenie/polecenia usuwaj�ce film 'Leon Zawodowiec' z bazy danych

-- Usu� wszystkie tabele (Gatunki, Filmy, Egzemplarze) z bazy 



---------------------------------------------------
   Select Table_name as "Table name"
From Information_schema.Tables
Where Table_type = 'BASE TABLE' and Objectproperty 
(Object_id(Table_name), 'IsMsShipped') = 0 
