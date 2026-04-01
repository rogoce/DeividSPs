-- Analisis Siniestros Vs Prima Suscrita por Mes (Formato Roll 12)
-- 3 Meses Actuales Vs 3 Meses Año Anterior
-- 
-- Creado    : 14/04/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 14/04/2004 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_pro142;

create procedure "informix".sp_pro142(
a_compania 	char(3), 
a_agencia 	char(3), 
a_periodo2 	char(7)
)
returning char(50),
		  integer,
		  integer,
		  integer,
		  integer,
		  integer,
		  integer,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  integer,
		  integer,
		  integer,
		  integer,
		  integer,
		  integer,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
          char(50),
          char(50),
		  char(50),
		  char(7),
		  char(7),
		  char(7),
		  char(7),
		  char(7),
		  char(7);

define _cod_ramo      	char(3);
define _cod_subramo   	char(3);
define _cod_grupo     	char(5);

define _rec_abierto1   	integer;
define _rec_abierto2   	integer;
define _rec_abierto3   	integer;
define _rec_abierto4   	integer;
define _rec_abierto5   	integer;
define _rec_abierto6   	integer;

define _incurrido_neto1 dec(16,2);
define _incurrido_neto2 dec(16,2);
define _incurrido_neto3 dec(16,2);
define _incurrido_neto4 dec(16,2);
define _incurrido_neto5 dec(16,2);
define _incurrido_neto6 dec(16,2);

define _cant_unidades1	integer;
define _cant_unidades2	integer;
define _cant_unidades3	integer;
define _cant_unidades4	integer;
define _cant_unidades5	integer;
define _cant_unidades6	integer;

define _prima_suscrita1	dec(16,2);
define _prima_suscrita2	dec(16,2);
define _prima_suscrita3	dec(16,2);
define _prima_suscrita4	dec(16,2);
define _prima_suscrita5	dec(16,2);
define _prima_suscrita6	dec(16,2);

define _promedio_sin1	dec(16,2);
define _promedio_sin2	dec(16,2);
define _promedio_sin3	dec(16,2);
define _promedio_sin4	dec(16,2);
define _promedio_sin5	dec(16,2);
define _promedio_sin6	dec(16,2);

define _promedio_pri1	dec(16,2);
define _promedio_pri2	dec(16,2);
define _promedio_pri3	dec(16,2);
define _promedio_pri4	dec(16,2);
define _promedio_pri5	dec(16,2);
define _promedio_pri6	dec(16,2);

define _promedio_uni1	dec(16,2);
define _promedio_uni2	dec(16,2);
define _promedio_uni3	dec(16,2);
define _promedio_uni4	dec(16,2);
define _promedio_uni5	dec(16,2);
define _promedio_uni6	dec(16,2);

define _promedio_mon1	dec(16,2);
define _promedio_mon2	dec(16,2);
define _promedio_mon3	dec(16,2);
define _promedio_mon4	dec(16,2);
define _promedio_mon5	dec(16,2);
define _promedio_mon6	dec(16,2);

define _nombre_ramo		char(50);
define _nombre_subramo	char(50);
define _nombre_grupo	char(50);
define _nombre_compania char(50);

define a_periodo1		char(7);
define _fecha			date;
define _periodo_orig	char(7);

define _titulo1			char(7);
define _titulo2			char(7);
define _titulo3			char(7);
define _titulo4			char(7);
define _titulo5			char(7);
define _titulo6			char(7);

create temp table temp_roll_12(
cod_ramo      	char(3),
cod_subramo   	char(3),
cod_grupo     	char(5),
rec_abierto1   	integer,
rec_abierto2   	integer,
rec_abierto3   	integer,
rec_abierto4   	integer,
rec_abierto5   	integer,
rec_abierto6   	integer,
incurrido_neto1 dec(16,2),
incurrido_neto2 dec(16,2),
incurrido_neto3 dec(16,2),
incurrido_neto4 dec(16,2),
incurrido_neto5 dec(16,2),
incurrido_neto6 dec(16,2),
cant_unidades1	integer,
cant_unidades2	integer,
cant_unidades3	integer,
cant_unidades4	integer,
cant_unidades5	integer,
cant_unidades6	integer,
prima_suscrita1	dec(16,2),
prima_suscrita2	dec(16,2),
prima_suscrita3	dec(16,2),
prima_suscrita4	dec(16,2),
prima_suscrita5	dec(16,2),
prima_suscrita6	dec(16,2),
no_poliza		char(10) default null
) with no log;

let _nombre_compania = sp_sis01(a_compania);
let _fecha = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _periodo_orig = a_periodo2;

let _fecha     = _fecha - 11 units month;
let a_periodo1 = sp_sis39(_fecha);
let a_periodo1 = a_periodo2;
let _titulo6   = a_periodo2;
call sp_pro125(a_compania, a_agencia, a_periodo1, a_periodo2, 6);

let _fecha     = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _fecha     = _fecha - 1  units month;
let a_periodo2 = sp_sis39(_fecha);
let _fecha     = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _fecha     = _fecha - 11 units month;
let a_periodo1 = sp_sis39(_fecha);
let a_periodo1 = a_periodo2;
let _titulo5   = a_periodo2;
call sp_pro125(a_compania, a_agencia, a_periodo1, a_periodo2, 5);

let _fecha     = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _fecha     = _fecha - 1  units month;
let a_periodo2 = sp_sis39(_fecha);
let _fecha     = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _fecha     = _fecha - 11 units month;
let a_periodo1 = sp_sis39(_fecha);
let a_periodo1 = a_periodo2;
let _titulo4   = a_periodo2;
call sp_pro125(a_compania, a_agencia, a_periodo1, a_periodo2, 4);

let a_periodo2 = _periodo_orig;
let _fecha     = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _fecha     = _fecha - 12 units month;
let a_periodo2 = sp_sis39(_fecha);
let _fecha     = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _fecha     = _fecha - 11 units month;
let a_periodo1 = sp_sis39(_fecha);
let a_periodo1 = a_periodo2;
let _titulo3   = a_periodo2;
call sp_pro125(a_compania, a_agencia, a_periodo1, a_periodo2, 3);

let _fecha     = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _fecha     = _fecha - 1  units month;
let a_periodo2 = sp_sis39(_fecha);
let _fecha     = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _fecha     = _fecha - 11 units month;
let a_periodo1 = sp_sis39(_fecha);
let a_periodo1 = a_periodo2;
let _titulo2   = a_periodo2;
call sp_pro125(a_compania, a_agencia, a_periodo1, a_periodo2, 2);

let _fecha     = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _fecha     = _fecha - 1  units month;
let a_periodo2 = sp_sis39(_fecha);
let _fecha     = mdy(a_periodo2[6,7], 1, a_periodo2[1,4]);
let _fecha     = _fecha - 11 units month;
let a_periodo1 = sp_sis39(_fecha);
let a_periodo1 = a_periodo2;
let _titulo1   = a_periodo2;
call sp_pro125(a_compania, a_agencia, a_periodo1, a_periodo2, 1);

foreach
 select cod_ramo,
		cod_subramo,
		cod_grupo,
		sum(rec_abierto1),
		sum(rec_abierto2),
		sum(rec_abierto3),
		sum(rec_abierto4),
		sum(rec_abierto5),
		sum(rec_abierto6),
	    sum(incurrido_neto1),
		sum(incurrido_neto2),
		sum(incurrido_neto3),
		sum(incurrido_neto4),
		sum(incurrido_neto5),
		sum(incurrido_neto6),
		sum(cant_unidades1),
		sum(cant_unidades2),
		sum(cant_unidades3),
		sum(cant_unidades4),
		sum(cant_unidades5),
		sum(cant_unidades6),
		sum(prima_suscrita1),
		sum(prima_suscrita2),
		sum(prima_suscrita3),
		sum(prima_suscrita4),
		sum(prima_suscrita5),
		sum(prima_suscrita6)
   into _cod_ramo,
		_cod_subramo,
		_cod_grupo,
		_rec_abierto1,
		_rec_abierto2,
		_rec_abierto3,
		_rec_abierto4,
		_rec_abierto5,
		_rec_abierto6,
	    _incurrido_neto1,
		_incurrido_neto2,
		_incurrido_neto3,
		_incurrido_neto4,
		_incurrido_neto5,
		_incurrido_neto6,
		_cant_unidades1,
		_cant_unidades2,
		_cant_unidades3,
		_cant_unidades4,
		_cant_unidades5,
		_cant_unidades6,
		_prima_suscrita1,
		_prima_suscrita2,
		_prima_suscrita3,
		_prima_suscrita4,
		_prima_suscrita5,
		_prima_suscrita6
   from temp_roll_12
  group by 1, 2, 3

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;
	
	select nombre
	  into _nombre_subramo
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	select nombre
	  into _nombre_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	-- Promedios de Siniestros y Unidades

	if _rec_abierto1 = 0 then
		let _promedio_sin1 = 0.00;
		let _promedio_uni1 = 0.00;
	else
		let _promedio_sin1 = _incurrido_neto1 / _rec_abierto1;
		let _promedio_uni1 = _cant_unidades1 / _rec_abierto1;
	end if

	if _rec_abierto2 = 0 then
		let _promedio_sin2 = 0.00;
		let _promedio_uni2 = 0.00;
	else
		let _promedio_sin2 = _incurrido_neto2 / _rec_abierto2;
		let _promedio_uni2 = _cant_unidades2 / _rec_abierto2;
	end if

	if _rec_abierto3 = 0 then
		let _promedio_sin3 = 0.00;
		let _promedio_uni3 = 0.00;
	else
		let _promedio_sin3 = _incurrido_neto3 / _rec_abierto3;
		let _promedio_uni3 = _cant_unidades3 / _rec_abierto3;
	end if

	if _rec_abierto4 = 0 then
		let _promedio_sin4 = 0.00;
		let _promedio_uni4 = 0.00;
	else
		let _promedio_sin4 = _incurrido_neto4 / _rec_abierto4;
		let _promedio_uni4 = _cant_unidades4 / _rec_abierto4;
	end if

	if _rec_abierto5 = 0 then
		let _promedio_sin5 = 0.00;
		let _promedio_uni5 = 0.00;
	else
		let _promedio_sin5 = _incurrido_neto5 / _rec_abierto5;
		let _promedio_uni5 = _cant_unidades5 / _rec_abierto5;
	end if

	if _rec_abierto6 = 0 then
		let _promedio_sin6 = 0.00;
		let _promedio_uni6 = 0.00;
	else
		let _promedio_sin6 = _incurrido_neto6 / _rec_abierto6;
		let _promedio_uni6 = _cant_unidades6 / _rec_abierto6;
	end if

	-- Promedios de Primas

	if _cant_unidades1 = 0 then
		let _promedio_pri1 = 0.00;
	else
		let _promedio_pri1 = _prima_suscrita1 / _cant_unidades1;
	end if

	if _cant_unidades2 = 0 then
		let _promedio_pri2 = 0.00;
	else
		let _promedio_pri2 = _prima_suscrita2 / _cant_unidades2;
	end if

	if _cant_unidades3 = 0 then
		let _promedio_pri3 = 0.00;
	else
		let _promedio_pri3 = _prima_suscrita3 / _cant_unidades3;
	end if

	if _cant_unidades4 = 0 then
		let _promedio_pri4 = 0.00;
	else
		let _promedio_pri4 = _prima_suscrita4 / _cant_unidades4;
	end if

	if _cant_unidades5 = 0 then
		let _promedio_pri5 = 0.00;
	else
		let _promedio_pri5 = _prima_suscrita5 / _cant_unidades5;
	end if

	if _cant_unidades6 = 0 then
		let _promedio_pri6 = 0.00;
	else
		let _promedio_pri6 = _prima_suscrita6 / _cant_unidades6;
	end if

	-- Promedios de Montos

	if _prima_suscrita1 = 0.00 then
		let _promedio_mon1 = 0.00;
	else
		let _promedio_mon1 = _incurrido_neto1 / _prima_suscrita1;
	end if
	
	if _prima_suscrita2 = 0.00 then
		let _promedio_mon2 = 0.00;
	else
		let _promedio_mon2 = _incurrido_neto2 / _prima_suscrita2;
	end if
	
	if _prima_suscrita3 = 0.00 then
		let _promedio_mon3 = 0.00;
	else
		let _promedio_mon3 = _incurrido_neto3 / _prima_suscrita3;
	end if
	
	if _prima_suscrita4 = 0.00 then
		let _promedio_mon4 = 0.00;
	else
		let _promedio_mon4 = _incurrido_neto4 / _prima_suscrita4;
	end if
	
	if _prima_suscrita5 = 0.00 then
		let _promedio_mon5 = 0.00;
	else
		let _promedio_mon5 = _incurrido_neto5 / _prima_suscrita5;
	end if
	
	if _prima_suscrita6 = 0.00 then
		let _promedio_mon6 = 0.00;
	else
		let _promedio_mon6 = _incurrido_neto6 / _prima_suscrita6;
	end if
	
	return _nombre_grupo,
		   _rec_abierto1,
		   _rec_abierto2,
		   _rec_abierto3,
		   _rec_abierto4,
		   _rec_abierto5,
		   _rec_abierto6,
	       _incurrido_neto1,
	       _incurrido_neto2,
	       _incurrido_neto3,
	       _incurrido_neto4,
	       _incurrido_neto5,
	       _incurrido_neto6,
		   _promedio_sin1,
		   _promedio_sin2,
		   _promedio_sin3,
		   _promedio_sin4,
		   _promedio_sin5,
		   _promedio_sin6,
	       _prima_suscrita1,
	       _prima_suscrita2,
	       _prima_suscrita3,
	       _prima_suscrita4,
	       _prima_suscrita5,
	       _prima_suscrita6,
	       _cant_unidades1,
	       _cant_unidades2,
	       _cant_unidades3,
	       _cant_unidades4,
	       _cant_unidades5,
	       _cant_unidades6,
		   _promedio_pri1,
		   _promedio_pri2,
		   _promedio_pri3,
		   _promedio_pri4,
		   _promedio_pri5,
		   _promedio_pri6,
		   _promedio_uni1,
		   _promedio_uni2,
		   _promedio_uni3,
		   _promedio_uni4,
		   _promedio_uni5,
		   _promedio_uni6,
		   _promedio_mon1,
		   _promedio_mon2,
		   _promedio_mon3,
		   _promedio_mon4,
		   _promedio_mon5,
		   _promedio_mon6,
		   _nombre_subramo,
		   _nombre_ramo,
		   _nombre_compania,
		   _titulo1,
		   _titulo2,
		   _titulo3,
		   _titulo4,
		   _titulo5,
		   _titulo6
		   with resume;
	       
end foreach

drop table temp_roll_12;

end procedure
