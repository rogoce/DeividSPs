DROP PROCEDURE amado_chqcomis;

CREATE PROCEDURE amado_chqcomis() 
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

    FOREACH
		SELECT fecha_ult_comis
		  INTO _fecha_ult_comis_orig
		  FROM agtbitacora
		 WHERE cod_agente = _cod_agente
		   and date(fecha_modif) < '28/05/2009'
	  ORDER BY fecha_modif DESC
	  EXIT FOREACH;
	END FOREACH


	IF _fecha_ult_comis_orig IS NOT NULL  THEN
		UPDATE chqcomis
		   SET no_requis   = _no_requis
		 WHERE cod_agente  = _cod_agente
		   AND fecha_desde >= _fecha_ult_comis_orig
 		   AND fecha_hasta <= '27/05/2009'
		   AND no_requis is null;
   	ELSE
   		UPDATE chqcomis
   		   SET no_requis   = _no_requis
   		 WHERE cod_agente  = _cod_agente
		   AND fecha_desde >= '21/05/2009'
   		   AND no_requis is null;
	END IF

	UPDATE chqcomis
	   SET no_requis   = _no_requis
	 WHERE cod_agente  = _cod_agente
	   AND no_requis   = "RV";

    FOREACH
		 select no_requis
		   into _no_requis_c
		   from chqchmae
		  where cod_agente = _cod_agente
		    and origen_cheque in (2, 7)
			and anulado = 1
			and no_requis is not null
			and no_requis <> _no_requis
			and fecha_anulado <= '27/05/2009'
			and fecha_anulado >= "01/03/2007"

		 If _no_requis_c is not null And Trim(_no_requis_c) <> "" Then
			 update chqcomis
			    set no_requis = _no_requis
			  where no_requis = _no_requis_c;
		 End If
    END FOREACH
 END FOREACH
end
COMMIT WORK;
return 0;
END PROCEDURE