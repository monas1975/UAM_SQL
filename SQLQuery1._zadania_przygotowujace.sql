SELECT *
from ksiazki;

SELECT *
from autorzy;

-- 1. Podaj nazwiska autorow spoza Polski; uporzadkuj alfabetycznie wedlug nazwisk
         select nazwisko
		 from autorzy
		 where kraj <> 'Polska'
		 order by nazwisko; 

-- 2. Podaj tytu�y ksi��ek wydanych ponad 15 lat temu
          select tytul, rok_wydania
		  from ksiazki
		  where rok_wydania<(YEAR(SYSDATETIME()))-15;

-- 3. Znajd� ksi�zki w cenie pomi�dzy 30 a 50 z�
     select *
	  from ksiazki
	  where cena>=30 and cena <=50; 
-- 4. Podaj ksiazki zawierajace ci�g 'XML' w tytule
       select *
	   from ksiazki
	   where tytul like '%XML%'; 
-- 5. Jakie (r�ne) dzia�y obejmuje zbi�r ksi��ek? 
         select distinct dzial
		 from ksiazki; 
-- cz. 2. obs�uga warto�ci pustych: IS NULL, IS NOT NULL, ISNULL()
-------------------------------------------------------------------
-- 6. Jakie (r�ne) dzia�y obejmuje zbi�r ksi��ek? Pozb�d� si� warto�ci pustej z zad. 5
       select distinct dzial
		 from ksiazki
		 where dzial is not null;
-- cz. 3. - z��czenia: INNER JOIN, LEFT OUTER JOIN, RIGHT OUTER JOIN, FULL OUTER JOIN
-------------------------------------------------------------------------------------

-- 7. Dla ka�dej ksi��ki wy�wietl jej tytu�, nazwisko autora i dzia�. W przypadku braku danych wy�wietl 'BRAK DANYCH'
      SELECT tytul, nazwisko,isnull(dzial,'brak danych') as dzial
	   from ksiazki inner join autorzy
	   on ksiazki.id_autor = autorzy.id_autor; 

-- 8. Znajdz ksiazki drozsze od 'Fuzzy Logic'
         select *
		 from ksiazki
		 where cena >
		 (select cena
		 from ksiazki
		 where tytul like 'Fuzzy Logic') 

		 select *
		 from ksiazki k1 join ksiazki k2
		 on k1.cena > k2.cena
		 where k2.tytul like 'Fuzzy Logic'; 

-- 9. Podaj autorow ksiazek z informatyki
       select distinct autorzy.nazwisko,ksiazki.dzial
	   from ksiazki join autorzy
	   on ksiazki.id_autor = autorzy.id_autor
	   where ksiazki.dzial like 'informatyka'

	select distinct a.nazwisko 
	from autorzy a join ksiazki k
	on a.id_autor = k.id_autor
	where k.dzial = 'informatyka'  

-- 10. Podaj nazwisko autora, ktorego ksi��ek nie ma obecnie w bazie (wer.1.)
     select *
	 from autorzy a left join ksiazki k
	 on a.id_autor = k.id_autor
	 where k.tytul is null; 

-- cz. 4. - podzapytania w klauzuli WHERE - nieskorelowane, skorelowane; EXISTS
-------------------------------------------------------------------------------
-- 11. Znajdz ksiazki drozsze od 'Fuzzy Logic'
        select *
		from ksiazki
		where cena > (
		select cena
		from ksiazki
		where tytul like 'Fuzzy Logic') 

-- 12. Podaj autorow ksiazek z informatyki
       select distinct nazwisko
	   from autorzy
	   where id_autor in (
	   select distinct id_autor
	   from ksiazki
	   where dzial like 'informatyka') 

-- 13. Podaj nazwisko autora, ktorego ksi��ek nie ma obecnie w bazie (wer.2.)
        select nazwisko
		from autorzy
		where id_autor not in (
		select id_autor
		from ksiazki) 

-- 14. Podaj nazwisko autora, ktorego ksi��ek nie ma obecnie w bazie (wer.3.)
        select *
		from autorzy a
		where not exists(select *from ksiazki k where a.id_autor = k.id_autor) 

-- 15*. Sprawdz, czy istnieje autor piszacy ksiazki do kazdego z dzialow
          select nazwisko
		  from autorzy a
		  where not exists( select dzial
		                  from ksiazki k1
						  where not exists(select *
						                  from ksiazki k2
										  where k2.dzial = k1.dzial
										  and k2.id_autor =a.id_autor)
										  ) 

-- 16. Podaj ��czn� cen� wszystkich ksiazek Sapkowskiego
         select sum(cena)
		 from ksiazki
		 where id_autor = (select id_autor
		                         from autorzy
								 where nazwisko like 'Sapkowski') 

-- 17. Dla kazdego z dzia��w  podaj liczb� ksiazek i ich �redni� cen� 
        select dzial, count(id_ksiazki), avg(cena)
		from ksiazki
		group by dzial; 

-- 18. Podaj tytu� najtanszej ksiazki
       select tytul, cena
	   from ksiazki k
	   where k.cena = (select min(cena)
	                         from ksiazki) 
-- 19. Dla kazdego dzialu podaj tytu� najtanszej ksiazki
        select dzial, tytul, cena
		from ksiazki k1
		where cena = (select min(cena)
		              from ksiazki k2
					  where k1.dzial = k2.dzial) 

-- 20. Podaj autorow, ktorzy napisali przynajmniej dwie ksiazki po roku 1996
       select a.nazwisko,count(*)
	   from ksiazki k join autorzy a
	   on k.id_autor = a.id_autor
	   where rok_wydania > 1996
	   group by a.nazwisko
	   having count(*) >=2

-- 21. Znajdz dzial, do ktorego pisze wiecej niz jeden autor
       select dzial,count(distinct id_autor) as licz_autor
	   from ksiazki
	   group by dzial
	   having count(distinct id_autor)>1; 

	   
-- 22. Znajdz dzial o najwiekszej liczbie ksiazkek
       Select dzial
	   from ksiazki
	   group by dzial
	   having count(*) = (
	                       select max(liczba)
						        from (
								select dzial,count(*) liczba						
							   from ksiazki
							   group by dzial) as tab);           

------------- Polecenia DML: INSERT, UPDATE, DELETE -----------------------------------------------

-- 23. Wstaw powie�� Cervantesa pt. "Przemy�lny szlachcic Don Kichote z Manchy" wydan� w roku 2010 w cenie 105 z�
    INSERT INTO ksiazki values(
	 (select id_autor from autorzy where nazwisko ='Cervantes'),'Przemy�lny szlachcic Don Kichote z Manchy',105,2010,'powiesc')

-- 24. Podnie� cen� ksi��ek Sapkowskiego o 10 z�
    update ksiazki
	set cena=cena+10
	where id_autor = (select id_autor from autorzy where nazwisko = 'Sapkowski') 

	-- 25. Usu� wszystkie ksi��ki Cervantesa

	 DELETE FROM ksiazki
	 where id_ksiazki = 11

	---------------------------------------------------------------------------------------------------
------------- Polecenia DDL: CREATE, ALTER, DROP  -------------------------------------------------

-- 26. Utw�rz tabel� SPRZEDAZ o kolumnach:
  -- numer sprzeda�y - klucz podstawowy
  -- data sprzeda�y - domy�lnie dzisiejsza
  -- id ksiazki - identyfikator sprzedanej ksiazki, klucz obcy
  -- liczba sztuk - liczba zakupionych sztuk, nie mniej ni� 1, nie wiecej niz 10
  -- cena sprzedazy - typu money

   create table sprzedaz
  (numer int primary key,
   data date default getdate(),
   ksiazka int references Ksiazki(id_ksiazki),
   sztuk int CHECK(sztuk between 1 and 10),
   cena money
   ) 
   ;

  -- select * from spredaz;
   
   Select Table_name as "Table name"
From Information_schema.Tables
Where Table_type = 'BASE TABLE' and Objectproperty 
(Object_id(Table_name), 'IsMsShipped') = 0 

  select * from sprzedaz;
 
-- 27. Zmodyfikuj tabel� Sprzeda� dodaj�c now� kolumn�: zaplata - o wartosciach ze zbioru: "gotowka", "karta" 
   alter table Sprzedaz
   add zaplata varchar(10)

   alter table Sprzedaz
   add constraint ck_sprz_zapl CHECK (zaplata in ('gotowka', 'karta')) 

   
-- 28. Usu� tabel� Sprzedaz
   DROP TABLE Sprzedaz
 

