-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza
-- Copia sp_proe85a para preliminar en las renovaciones
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe85b;
 
create procedure sp_proe85b(a_poliza CHAR(10), a_unidad CHAR(5))
returning dec(16,2);

define _no_motor		char(50);
define _ano_tarifa		smallint;
define _cod_modelo		char(5);
define _porc_desc		dec(16,2);
define _max_ano			smallint;
define _grupo       	char(5);
define _vigencia_ini	date;
define _nueva_renov     char(1);
define _fecha_nueva    	date;
define _fecha_renov    	date;
define _fecha_hoy       date;
define _ano 			integer;
define _dia2            integer;
define _mes2            integer;

--set debug file to "sp_proe85b.trc";
--trace on;

set isolation to dirty read;

-- Fecha inicial de uso de la tabla emivecla1 para Pólizas nuevas y renovaciones
let _fecha_nueva 	= "22/01/2021";
let _fecha_renov    = "01/04/2021";

select vigencia_inic, 
	   nueva_renov
  into _vigencia_ini,
	   _nueva_renov
  from emipomae
 where no_poliza = a_poliza;
 
 if _nueva_renov = 'R' then
	let _fecha_hoy = current;
	 if month(_vigencia_ini) >= month(_fecha_renov) then
		let _ano 			= year(_fecha_hoy);
		LET _dia2      		= DAY(_vigencia_ini);
		LET _mes2       	= MONTH(_vigencia_ini);
		LET _vigencia_ini = mdy(_mes2,_dia2,_ano);
	 end if
end if
 
  
select no_motor,
       ano_tarifa
  into _no_motor,
       _ano_tarifa
  from emiauto
 where no_poliza = a_poliza
   and no_unidad = a_unidad;

if _ano_tarifa = 0 then
	let _ano_tarifa = 1;
end if

let _ano_tarifa = _ano_tarifa + 1;
   
select cod_modelo
  into _cod_modelo
  from emivehic
 where no_motor = _no_motor;

 
select grupo
  into _grupo
  from emimodel
 where cod_modelo = _cod_modelo;
 
if _grupo is null or trim(_grupo) = "" then
	return 0;
end if

-- *************************************************************************************  
if _nueva_renov = 'N' and _vigencia_ini >= _fecha_nueva or _nueva_renov = 'R' and _vigencia_ini >= _fecha_renov then
	select max(ano)
	  into _max_ano
	  from emivecla1
	 where grupo = _grupo;

	if _ano_tarifa > _max_ano then
		let _ano_tarifa = _max_ano;
	end if


	select porc_desc
	  into _porc_desc
	  from emivecla1
	 where grupo = _grupo
	   and ano   = _ano_tarifa;

else
	select max(ano)
	  into _max_ano
	  from emivecla
	 where grupo = _grupo;

	if _ano_tarifa > _max_ano then
		let _ano_tarifa = _max_ano;
	end if


	select porc_desc
	  into _porc_desc
	  from emivecla
	 where grupo = _grupo
	   and ano   = _ano_tarifa;
end if
-- *************************************************************************************

if _porc_desc is null then
	let _porc_desc = 0;
end if

return _porc_desc;

end procedure
