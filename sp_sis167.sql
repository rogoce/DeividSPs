-- Validacion de Motor Duplicado en Renovacion y Emision
-- Creado    : 16/03/2012 - Autor: Henry Giron 
-- SIS v.2.0 - d_cobr_cierre_caja_automatico_reporte - DEIVID, S.A.
  
drop procedure sp_sis167;
create procedure "informix".sp_sis167(a_no_poliza char(10))
returning char(100),
          smallint;

define _no_motor     	char(30);
define _no_unidad  		char(5);
define _cnt				smallint;
define _unidades        char(100);
define _cod_ramo        char(3);
define _ramo_sis        integer;

define _no_recibo_min,_no_recibo_max   integer;

set isolation to dirty read;


let _unidades = "";

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

if _ramo_sis = 1 then 	   -- Solo soda y automovil

	foreach

	 select no_unidad,
			no_motor
	   into _no_unidad,
			_no_motor
	   from emiauto
	  where no_poliza = a_no_poliza
	 order by no_unidad


	 select count(*)
	   into _cnt
	   from emiauto
	  where no_poliza = a_no_poliza
	    and no_motor  = _no_motor;

	 if _cnt > 1 then
	    let _unidades = trim(_no_motor) || " Unidad: ";

		foreach

			 select no_unidad
			   into _no_unidad
			   from emiauto
			  where no_poliza = a_no_poliza
			    and no_motor  = _no_motor

			  let _unidades = trim(_unidades) || "-" || _no_unidad;

		end foreach

		return _unidades, 1;    
		
	 end if

	end foreach

end if

Return "",0;

end procedure