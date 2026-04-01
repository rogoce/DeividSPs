-- Procedimiento que carga las facturas para que se generen los registros contables
-- 
-- Creado    : 31/10/2002 - Autor: Marquelda Valdelamar
-- Modificado: 26/04/2007 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_sac59;		

create procedure "informix".ap_sac59()
returning integer, 
          char(100);
		  	
define _no_poliza   char(10); 
define _no_endoso	char(5);
define _no_factura  char(10); 

define _error_cod	integer;
define _error_isam	integer;
define _error_desc	char(100);
define _periodo     char(7);

set isolation to dirty read;

begin 
on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_desc;
end exception

--set debug file to "sp_sac59.trc";
--trace on;

select periodo_verifica
  into _periodo
  from emirepar;
 
let _periodo = '2018-12';
 
foreach
 select no_poliza,
		no_endoso,
		no_factura
   into _no_poliza,
	    _no_endoso,
		_no_factura
   from endedmae
  where actualizado  = 1
    and sac_asientos = 0
	and periodo      = _periodo
	and no_poliza not in (select distinct e.no_poliza
  from emipomae e, endedmae d
 where e.no_poliza = d.no_poliza
   and d.periodo = '2017-07'
   and e.cod_tipoprod = '004')
  	  	
	delete from endasiau
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	delete from endasien
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	call sp_par59(_no_poliza, _no_endoso) returning _error_cod, _error_desc;

	if _error_cod <> 0 then
		return _error_cod, trim(_error_desc) || " " || _no_factura || " " || _no_poliza || " " || _no_endoso with resume;
	end if

	update endedmae
	   set sac_asientos = 1
	 where no_poliza    = _no_poliza
	   and no_endoso    = _no_endoso;

end foreach;

end

let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";	

return _error_cod, _error_desc;

end procedure;
