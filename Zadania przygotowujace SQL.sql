 ----------------------------------------------------------------------------------------------------
---- Zadania przygotowuj¹ce - Studia podyplomowe "Przetwarzanie danych - Big Data" 
---- Podstawowe polecenia jêzyka SQL 
----------------------------------------------------------------------------------------------------

------------- Tworzenie przyk³adowego schematu KSIÊGARNIA -------------------------------------------------------------------


IF OBJECT_ID('ksiazki', 'U') IS NOT NULL 
	drop table ksiazki

IF OBJECT_ID('autorzy', 'U') IS NOT NULL 
	drop table autorzy


create table autorzy
(id_autor int primary key,
 nazwisko varchar(30),
 kraj varchar(10));

create table ksiazki
(id_ksiazki int identity(1,1) primary key,
 id_autor int references autorzy(id_autor),
 tytul varchar(50),
 cena float,
 rok_wydania int,
 dzial varchar(30));

go

----------------------- Wstawianie przyk³adowych danych ------------------------

insert into autorzy
values(1, 'Abiteboul', 'USA');
insert into autorzy
values(2, 'Szekspir', 'Anglia');
insert into autorzy
values(3, 'Sapkowski', 'Polska');
insert into autorzy
values(4, 'Yen' ,'USA');
insert into autorzy
values(5, 'Cervantes' ,'Hiszpania');

insert into ksiazki
values(1, 'Quering XML', 60, 1997, 'informatyka');
insert into ksiazki
values(1, 'Data on the web', 75, null, 'informatyka');
insert into ksiazki
values(2, 'Poskromienie z³oœnicy', 32, 1999, null);
insert into ksiazki
values( 3, 'Ostatnie ¿yczenie', 25, 1993 ,'sf');
insert into ksiazki
values(3, 'Wie¿a jaskó³ki', null, 1997, 'sf');
insert into ksiazki
values(3, 'Narrenturm', 20, 2002, 'sf');
insert into ksiazki
values(4, 'Fuzzy Logic', 55, 2010, 'informatyka');


select * from autorzy
select * from ksiazki

---------------------------------------------------------------------------------------------------
------------- Polecenie SELECT ----------------------------------------------------------------------

-- cz. 1 - proste zapytania; filtrowanie, sortowanie, u¿ycie funkcji wierszowych, distinct
------------------------------------------------------------------------------------------

-- 1. Podaj nazwiska autorow spoza Polski; uporzadkuj alfabetycznie wedlug nazwisk

	select *
	from autorzy
	where kraj <> 'Polska'
	order by nazwisko

-- 2. Podaj tytu³y ksi¹¿ek wydanych ponad 15 lat temu

	select tytul, year(getdate()) - rok_wydania as [lata od wydania]
	from ksiazki
	where year(getdate()) - rok_wydania > 15

-- 3. ZnajdŸ ksi¹zki w cenie pomiêdzy 30 a 50 z³

	select *
	from ksiazki
	where cena >= 20 AND cena <= 50

	-- lub

	select *
	from ksiazki
	where cena between 20 and 50

-- 4. Podaj ksiazki zawierajace ci¹g 'XML' w tytule

	select * 
	from ksiazki
	where tytul like '%XML%'

-- 5. Jakie (ró¿ne) dzia³y obejmuje zbiór ksi¹¿ek? 

	select distinct dzial
	from ksiazki


-- cz. 2. obs³uga wartoœci pustych: IS NULL, IS NOT NULL, ISNULL()
-------------------------------------------------------------------

-- 6. Jakie (ró¿ne) dzia³y obejmuje zbiór ksi¹¿ek? Pozb¹dŸ siê wartoœci pustej z zad. 5
	
	select distinct dzial
	from ksiazki
	where dzial is not null
	
	-- lub

	select distinct isnull(dzial, '- brak danych -') as [dzial]
	from ksiazki
	
-- cz. 3. - z³¹czenia: INNER JOIN, LEFT OUTER JOIN, RIGHT OUTER JOIN, FULL OUTER JOIN
-------------------------------------------------------------------------------------

-- 7. Dla ka¿dej ksi¹¿ki wyœwietl jej tytu³, nazwisko autora i dzia³. W przypadku braku danych wyœwietl 'BRAK DANYCH'

	select ksiazki.tytul, autorzy.nazwisko, ISNULL(ksiazki.dzial, 'BRAK DANYCH') as [dzial]
	from autorzy JOIN ksiazki
	ON autorzy.id_autor = ksiazki.id_autor

-- 8. Znajdz ksiazki drozsze od 'Fuzzy Logic'

	select k1.tytul
	from ksiazki k1 JOIN ksiazki k2
	on k1.cena > k2.cena
	where k2.tytul = 'Fuzzy Logic'

-- 9. Podaj autorow ksiazek z informatyki

	select distinct a.nazwisko 
	from autorzy a join ksiazki k
	on a.id_autor = k.id_autor
	where k.dzial = 'informatyka'

-- 10. Podaj nazwisko autora, ktorego ksi¹¿ek nie ma obecnie w bazie (wer.1.)

	select a.nazwisko
	from autorzy a left outer join ksiazki k
	on a.id_autor = k.id_autor
	where k.tytul is null

-- cz. 4. - podzapytania w klauzuli WHERE - nieskorelowane, skorelowane; EXISTS
-------------------------------------------------------------------------------

-- 11. Znajdz ksiazki drozsze od 'Fuzzy Logic'

	select tytul
	from ksiazki
	where cena > (select cena
				  from ksiazki
				  where tytul = 'Fuzzy Logic')

-- 12. Podaj autorow ksiazek z informatyki

	select nazwisko
	from autorzy
	where id_autor in ( select id_autor
						from ksiazki
						where dzial = 'informatyka')

-- 13. Podaj nazwisko autora, ktorego ksi¹¿ek nie ma obecnie w bazie (wer.2.)

	select nazwisko
	from autorzy
	where id_autor not in ( select id_autor
							from ksiazki)

-- 14. Podaj nazwisko autora, ktorego ksi¹¿ek nie ma obecnie w bazie (wer.3.)

	select nazwisko
	from autorzy a
	where not exists (select * from ksiazki k where a.id_autor = k.id_autor)

-- 15*. Sprawdz, czy istnieje autor piszacy ksiazki do kazdego z dzialow 

select nazwisko
from autorzy a
where not exists (select dzial
                from ksiazki k1
                where not exists (select *
                                from ksiazki k2
                                where k2.dzial = k1.dzial
                                and k2.id_autor = a.id_autor)
                )

-- cz. 5. - Funkcje agreguj¹ce (MIN, MAX, AVG, SUM, COUNT); GROUP BY
--------------------------------------------------------------------

-- 16. Podaj ³¹czn¹ cenê wszystkich ksiazek Sapkowskiego

	select SUM(cena) srednia
	from ksiazki
	where id_autor = (select id_autor
					from autorzy
					where nazwisko = 'Sapkowski')

-- 17. Dla kazdego z dzia³ów  podaj liczbê ksiazek i ich œredni¹ cenê 

	select dzial, COUNT(*) as [liczba ksiazek], AVG(cena) as [srednia cena]
	from ksiazki
	group by dzial

-- 18. Podaj tytu³ najtanszej ksiazki 

	select tytul, cena
	from ksiazki
	where cena = (select min(cena)
				  from ksiazki)

-- 19. Dla kazdego dzialu podaj tytu³ najtanszej ksiazki 

	select tytul, cena
	from ksiazki k1
	where cena = (select min(cena)
				  from ksiazki k2
				  where k1.dzial = k2.dzial)

-- 20. Podaj autorow, ktorzy napisali przynajmniej dwie ksiazki po roku 1996

	select a.nazwisko, COUNT(*)
	from ksiazki k join autorzy a
	on k.id_autor = a.id_autor
	where rok_wydania > 1996
	group by a.nazwisko
	having COUNT(*) >=2     

-- 21. Znajdz dzial, do ktorego pisze wiecej niz jeden autor

	select dzial, COUNT(distinct id_autor) licz_autorow
	from ksiazki
	group by dzial
	having COUNT(distinct id_autor) > 1

-- 22. Znajdz dzial o najwiekszej liczbie ksiazkek

	select dzial
	from ksiazki
	group by dzial
	having COUNT(*) =
			(select MAX(liczba)
			from
					(select dzial, COUNT(*) liczba
					from ksiazki
					group by dzial) as tab)


---------------------------------------------------------------------------------------------------
------------- Polecenia DML: INSERT, UPDATE, DELETE -----------------------------------------------

-- 23. Wstaw powieœæ Cervantesa pt. "Przemyœlny szlachcic Don Kichote z Manchy" wydan¹ w roku 2010 w cenie 105 z³

	INSERT INTO ksiazki (id_autor, tytul, cena, rok_wydania, dzial)
	VALUES (
		(select id_autor from autorzy where nazwisko = 'Cervantes'),
		'Przemyœlny szlachcic Don Kichote z Manchy',
		105,
		2010,
		'powiesc')

-- 24. Podnieœ cenê ksi¹¿ek Sapkowskiego o 10 z³

	UPDATE Ksiazki
	set cena = cena + 10
	where id_autor = (select id_autor from autorzy where nazwisko = 'Sapkowski')

-- 25. Usuñ wszystkie ksi¹¿ki Cervantesa

	DELETE FROM ksiazki
	where id_autor = (select id_autor from autorzy where nazwisko = 'Cervantes')

---------------------------------------------------------------------------------------------------
------------- Polecenia DDL: CREATE, ALTER, DROP  -------------------------------------------------

-- 26. Utwórz tabelê SPRZEDAZ o kolumnach:
  -- numer sprzeda¿y - klucz podstawowy
  -- data sprzeda¿y - domyœlnie dzisiejsza
  -- id ksiazki - identyfikator sprzedanej ksiazki, klucz obcy
  -- liczba sztuk - liczba zakupionych sztuk, nie mniej ni¿ 1, nie wiecej niz 10
  -- cena sprzedazy - typu money

  CREATE TABLE Sprzedaz
  (numer int primary key,
   data date default getdate(),
   ksiazka int references Ksiazki(id_ksiazki),
   sztuk int CHECK (sztuk between 1 and 10),
   cena money
   )

-- 27. Zmodyfikuj tabelê Sprzeda¿ dodaj¹c now¹ kolumnê: zaplata - o wartosciach ze zbioru: "gotowka", "karta"

	ALTER TABLE Sprzedaz
	ADD zaplata varchar(10) 
	
	ALTER TABLE Sprzedaz
	ADD constraint ck_sprz_zapl CHECK (zaplata in ('gotowka', 'karta'))

-- 28. Usuñ tabelê Sprzedaz

	DROP TABLE Sprzedaz
