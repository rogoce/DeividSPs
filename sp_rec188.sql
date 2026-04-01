-- Procedimiento que valida que las transacciones aprobadas en WF esten actualizadas 
--
-- Creado    : 13/10/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.


-- Lo arregla el procedure sp_rwf37(no_tranrec)

drop procedure sp_rec188;

create procedure "informix".sp_rec188()
returning integer,
	      char(8),
	      datetime year to second,
	      char(10);

define _no_tranrec		char(10);
define _wf_incidente	integer;
define _wf_apr_j		char(8); 
define _wf_apr_j_fh		datetime year to second; 
define _wf_apr_js		char(8);  
define _wf_apr_js_fh	datetime year to second;

set isolation to dirty read;

foreach
 select wf_incidente, 
        wf_apr_j, 
        wf_apr_j_fh, 
        wf_apr_js, 
        wf_apr_js_fh,
		no_tranrec
   into _wf_incidente,
		_wf_apr_j,	
		_wf_apr_j_fh,	
		_wf_apr_js,	
		_wf_apr_js_fh,
		_no_tranrec
   from rectrmae
  where wf_aprobado = 1
    and actualizado = 0
    and periodo     >= "2011-01"
  order by wf_incidente	desc

	if _wf_apr_j is null then

		return _wf_incidente,
			   _wf_apr_js,
			   _wf_apr_js_fh,
			   _no_tranrec
			   with resume;	
	else
	
		return _wf_incidente,
			   _wf_apr_j,
			   _wf_apr_j_fh,
			   _no_tranrec
			   with resume;	

	end if

end foreach

return 0, "", "", "";

end procedure
