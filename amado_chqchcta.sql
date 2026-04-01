--DROP PROCEDURE amado_chqchcta;

CREATE PROCEDURE amado_chqchcta() 
RETURNING INTEGER; 

DEFINE _no_requis, _no_requis_c		CHAR(10);
DEFINE _cod_agente      char(5);

define _error			integer;
define _error_desc		char(50);

define _fecha_ult_comis_orig date;
define _fecha_ult_comis      date;

BEGIN WORK;

begin 
	ON EXCEPTION SET _error 
	    rollback work;
		RETURN _error;                                          
	END EXCEPTION                             

 --SET DEBUG FILE TO "amado_chqcomis.trc"; 
 --TRACE ON;                                                                


FOREACH
	SELECT no_requis, 
	       cod_agente 
	  INTO _no_requis,
		   _cod_agente
	  FROM chqchmae
	 WHERE origen_cheque in ('2','7')
	   AND fecha_captura = '28/05/2009'

	call sp_par205(_no_requis) returning _error, _error_desc;

	if _error <> 0 then
		return _error;
	end if
 END FOREACH
end
COMMIT WORK;
return 0;
END PROCEDURE