-- Procedimiento que calcula el descuento por: Vehiculos Clasificados

-- Creado:	12/01/2017 - Autor: Amado Perez M

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe85c;
 
create procedure sp_proe85c(a_poliza CHAR(10), a_unidad CHAR(5), a_endoso CHAR(5))
returning dec(16,2);

define _no_motor	char(50);
define _ano_tarifa	smallint;
define _cod_modelo	char(5);
define _porc_desc	dec(16,2);
define _max_ano		smallint;
define _cod_grupo   char(5);
define _grupo       char(5);
define _vigencia_ini	date;
define _nueva_renov     char(1);
define _fecha_nueva    	date;
define _fecha_renov    	date;

--set debug file to "sp_proe85c.trc";
--trace on;

set isolation to dirty read;
-- Fecha inicial de uso de la tabla emivecla1 para Pólizas nuevas y renovaciones
let _fecha_nueva 	= "01/01/2021";
let _fecha_renov    = "01/04/2021";

let _cod_grupo = null;
let _no_motor = null;  

select cod_grupo,
	   vigencia_inic, 
	   nueva_renov
  into _cod_grupo,
       _vigencia_ini,
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
   
if _no_motor is null then
	select no_motor,
           ano_tarifa
	  into _no_motor,
           _ano_tarifa
	  from endmoaut
	 where no_poliza = a_poliza
	   and no_endoso = a_endoso
	   and no_unidad = a_unidad;
end if   

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
