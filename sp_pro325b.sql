-- Creado    : 18/02/2010 - Autor: Armando Moreno.
-- estadistica de renovacion

DROP PROCEDURE sp_pro325b;

CREATE PROCEDURE "informix".sp_pro325b()
returning char(7),
		  integer,
		  integer,
		  integer,
		  integer,
		  integer;

define _fecha_selec		date;
define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_hoy       date;
define _dias            integer;
define _cod_ramo		char(3);
define _estatus_final   smallint;
DEFINE _mes_char        CHAR(2);
DEFINE _ano_char		CHAR(4);
DEFINE _periodo         CHAR(7);
define _estatus_aut		smallint;
define _estatus_opc		smallint;
define _estatus_man		smallint;
define _estatus_sin		smallint;
define _tipo_ramo		smallint;
define _no_poliza       char(10);

SET ISOLATION TO DIRTY READ;

begin

create temp table tmp_est(
periodo		char(7),
tipo_ramo	smallint,
cant_tot	integer,
cant_aut    integer,
cant_opc    integer,
cant_man	integer,
cant_sin    integer
) with no log;

foreach
  SELECT fecha_selec,   
         vigencia_inic,   
         vigencia_final,   
         estatus_final,
         no_poliza  
	INTO _fecha_selec,   
		 _vigencia_inic,   
		 _vigencia_final,   
		 _estatus_final,
         _no_poliza
    FROM hemirepo  
   WHERE year(vigencia_final)  = 2010
     AND month(vigencia_final) between 1 and 5

	IF  MONTH(_vigencia_final) < 10 THEN
		LET _mes_char = '0'|| MONTH(_vigencia_final);
	ELSE
		LET _mes_char = MONTH(_vigencia_final);
	END IF

	LET _ano_char = YEAR(_vigencia_final);
	LET _periodo  = _ano_char || "-" || _mes_char;

  SELECT cod_ramo
	INTO _cod_ramo
	FROM emipomae
   WHERE no_poliza = _no_poliza;

	if _cod_ramo in('002','020') then

		let _tipo_ramo = '1';  --AUTO

	elif _cod_ramo in('008') then

		let _tipo_ramo = '6';  --FIANZAS

	elif _cod_ramo in('016','018','019','004') then

		let _tipo_ramo = '3';  --PERSONAS

	else

		let _tipo_ramo = '2';  --PATRIMONIALES
		
	end if

	let _estatus_aut = 0;
	let _estatus_opc = 0;
	let _estatus_man = 0;
	let _estatus_sin = 0;

	if _estatus_final = 3 then	 --automatico
		let _estatus_aut = 1;
	elif _estatus_final = 2 then --manual opciones
		let _estatus_opc = 1;
	elif _estatus_final = 4 then --manual
		let _estatus_man = 1;
	elif _estatus_final is null then
		let _estatus_sin = 1;
	end if

	insert into tmp_est (periodo, tipo_ramo, cant_tot, cant_aut, cant_opc, cant_man, cant_sin)
	values (_periodo, _tipo_ramo, 0, _estatus_aut, _estatus_opc, _estatus_man, _estatus_sin);


end foreach

foreach

	select periodo,
	       tipo_ramo,
		   cant_aut,
		   cant_opc,
		   cant_man,
		   cant_sin
	  into _periodo,
	       _tipo_ramo,
		   _estatus_aut,
		   _estatus_opc,
		   _estatus_man,
		   _estatus_sin
	  from tmp_est


   return _periodo,
   		  _tipo_ramo,
   		  _estatus_aut,
   		  _estatus_opc,
		  _estatus_man,
		  _estatus_sin
		  with resume;

end foreach

drop table tmp_est;

end

END PROCEDURE
