-- Procedimiento que carga los comprobantes de reaseguro para que se generen los registros contables
-- 
-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac161;		
create procedure sp_sac161()
returning integer, 
          char(100);
		  	
define _no_registro		char(10);
define _contador,_cnt	smallint;
define _tipo_registro	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _periodo         char(7);
define _cod_ramo        char(7);
define _no_poliza       char(10);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

-- Validacion del periodo de reclamos

call sp_rea054() returning _error, _error_desc;

if _error <> 0 then 
	return _error, _error_desc;
end if

--set debug file to "sp_sac161.trc";
--trace on;

let _contador = 0;

select periodo_verifica
  into _periodo
  from emirepar;
  
foreach
 select no_registro,
        tipo_registro,
		no_documento[1,2],
		no_poliza
   into _no_registro,
        _tipo_registro,
		_cod_ramo,
		_no_poliza
   from sac999:reacomp
  where sac_asientos = 0
    and periodo      = _periodo
	
	if _tipo_registro IN (2,4,5) then
		if _cod_ramo in ('02','20','23','18')  then	
			continue foreach;
		elif _cod_ramo = '19' then -- Cambio para determinar la cuenta
			select count(*)
			  into _cnt
			  from emifacon e, reacomae r
			 where e.cod_contrato = r.cod_contrato
			   and e.no_poliza = _no_poliza
			   and r.serie >= 2024;
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt > 0 then
				continue foreach;
			end if
		end if
	end if	   


	delete from sac999:reacompasiau  where no_registro = _no_registro;
	delete from sac999:reacompasie	 where no_registro = _no_registro;

	call sp_par296(_no_registro) returning _error, _error_desc;

	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
	end if

	update sac999:reacomp
	   set sac_asientos = 1
	 where no_registro  = _no_registro;

end foreach

end 

let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

end procedure;
