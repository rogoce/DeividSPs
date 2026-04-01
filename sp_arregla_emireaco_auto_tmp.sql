-- Procedimiento para arreglar recreaco a partir de rectrrea 5/95
-- Creado:     04/10/2024 - Autor Armando Moreno M.

drop procedure sp_arregla_emireaco_auto_tmp;
create procedure sp_arregla_emireaco_auto_tmp(a_no_poliza char(10), a_no_unidad char(5))
returning	integer;

define _error_desc			char(100);
define _error,_no_cambio,_valor		        integer;
define _error_isam	        integer;
define _no_unidad           char(5);
define _v_i,_v_f             date;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

if a_no_poliza = '3041765' then
	set debug file to "sp_reainv_amm1.trc";
	trace on;
end if

let _valor = 0;

let _no_cambio = 0;

select max(no_cambio)
  into _no_cambio
  from emireaco
 where no_poliza = a_no_poliza;
 
 if _no_cambio is null then
	let _no_cambio = 0;
 end if	
 
let _no_unidad = null;

 select min(no_unidad)
   into _no_unidad
   from emireaco
  where no_poliza = a_no_poliza
    and no_cambio = _no_cambio;
	
if _no_unidad is not null then
	select *
	  from emireama
	 where no_poliza = a_no_poliza
	   and no_cambio = _no_cambio
	   and no_unidad = _no_unidad
	   into temp emireama_t;
	   
	foreach
		select vigencia_inic,
		       vigencia_final
		  into _v_i,
               _v_f
		  from emireama
	     where no_poliza = a_no_poliza
	       and no_unidad = a_no_unidad
		 
		exit foreach;
	end foreach
	
	update emireama_t
	   set vigencia_inic = _v_i,
	       vigencia_final = _v_f,
		   no_unidad = a_no_unidad
	 where no_poliza = a_no_poliza;
    
    insert into emireama
    select * from emireama_t;
	
    drop table emireama_t;
	--****emireaco
	select *
	  from emireaco
	 where no_poliza = a_no_poliza
	   and no_cambio = _no_cambio
	   and no_unidad = _no_unidad
	   into temp emireaco_t;
	   
	update emireaco_t
	   set no_unidad = a_no_unidad
	 where no_poliza = a_no_poliza;
    
    insert into emireaco
    select * from emireaco_t;
	
	drop table emireaco_t;
else
	let _valor = 1;
end if
return _valor;
end
end procedure;