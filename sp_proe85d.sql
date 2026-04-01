-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada

-- Creado:	25/06/2014 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe85d;
 
create procedure sp_proe85d(a_poliza CHAR(10), a_unidad CHAR(5))
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
define _vigencia_fin    date;
define _ano_auto        integer;

--set debug file to "sp_proe85a.trc";
--trace on;

set isolation to dirty read;

-- Fecha inicial de uso de la tabla emivecla1 para Pólizas nuevas y renovaciones
let _fecha_nueva 	= "22/01/2021";
let _fecha_renov    = "01/04/2021";

select vigencia_inic, 
       vigencia_final,
	   nueva_renov
  into _vigencia_ini,
       _vigencia_fin,
	   _nueva_renov
  from emipomae
 where no_poliza = a_poliza;
  
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


--let _ano_tarifa = _ano_tarifa + 1;
   
select cod_modelo,
       ano_auto
  into _cod_modelo,
       _ano_auto
  from emivehic
 where no_motor = _no_motor;
 
--let _ano_tarifa = year(_vigencia_ini) - _ano_auto + 1;

--if _ano_tarifa = 0 then
--	let _ano_tarifa = 1;
--end if

 select grupo
  into _grupo
  from emimodel
 where cod_modelo = _cod_modelo;
 
if _grupo is null or trim(_grupo) = "" then
	return 0;
end if

-- *************************************************************************************  
--if (_nueva_renov = 'N' and _vigencia_ini >= _fecha_nueva) or (_nueva_renov = 'R' and _vigencia_fin >= _fecha_renov) then
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

{else
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
end if}
-- *************************************************************************************

if _porc_desc is null then
	let _porc_desc = 0;
end if

return _porc_desc;

end procedure
