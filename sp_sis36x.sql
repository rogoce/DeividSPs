-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis36x;
CREATE PROCEDURE "informix".sp_sis36x(a_periodo CHAR(7)) 
RETURNING char(10),char(20),char(8),smallint,smallint;

DEFINE _no_poliza,_no_poliza2    char(10);
DEFINE _no_documento char(20);
DEFINE _user_added   char(8);
define _estatus,_cnt,_cnt2,_estatus_pol      smallint;


-- Descomponer los periodos en fechas

{LET _ano = a_periodo[1,4];
LET _mes = a_periodo[6,7];

IF _mes = 12 THEN
   LET _mes = 1;
   LET _ano = _ano + 1;
ELSE
   LET _mes = _mes + 1;
END IF

LET _fecha = MDY(_mes, 1, _ano);
LET _fecha = _fecha - 1;

let _fecha = _fecha + 1 units day;
RETURN _fecha;}

foreach
	select no_poliza,no_documento,user_added,estatus
	  into _no_poliza,_no_documento,_user_added,_estatus
	  from emirepo
	 where estatus not in(5,9,1)
	   and user_added = 'MJARAMIL'
	 
	select count(*)
	  into _cnt
	  from emideren
	 where no_poliza = _no_poliza;
	 
	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt = 0 then
		
		select count(*)
		  into _cnt2
		  from emirepol
		 where no_poliza = _no_poliza;

		if _cnt2 is null then
			let _cnt2 = 0;
		end if
		if _cnt2 = 0 then
			--delete from emirepo
			--where no_poliza = _no_poliza;
			let _no_poliza2 = sp_sis21(_no_documento);
			select estatus_poliza into _estatus_pol from emipomae
			where no_poliza = _no_poliza2;
			return _no_poliza,_no_documento,_user_added,_estatus,_estatus_pol with resume;
		end if
	end if
	
end foreach

END PROCEDURE;