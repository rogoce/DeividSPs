-- Procedimiento para traer el # de semana de un mes
--
-- Creado    : 14/02/2008 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 14/02/2008 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis106;

CREATE PROCEDURE "informix".sp_sis106(a_fecha date)
	   RETURNING   INTEGER;

DEFINE week1, week2    Integer;
DEFINE frstDay DATE;
DEFINE frstMes DATE;
DEFINE dia     Int;
DEFINE mes     Int;
DEFINE agno    Int;

LET mes = month(a_fecha);
LET agno = year(a_fecha);

LET frstDay = MDY(1, 1, agno); 
LET frstMes = MDY(mes, 1, agno); 

--LET frstDay = CURRENT;

LET week2    = (a_fecha - frstDay) / 7 + 1;
LET week1    = (frstMes - frstDay) / 7 + 1;

	   RETURN trunc(week2 - week1);
END PROCEDURE
