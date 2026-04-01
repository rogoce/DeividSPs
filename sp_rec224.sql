-- Procedimiento que disminuye la reserva del reclamo

-- Creado    : 27/06/2008 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec224;

create procedure sp_rec224() returning integer,
            char(50);

define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _reserva_cob			dec(16,2);

DEFINE _cod_cobertura   	CHAR(5);  
DEFINE _cod_cliente     	CHAR(10); 
DEFINE _numrecla        	CHAR(18); 

DEFINE _no_tranrec_char 	CHAR(10); 
DEFINE _no_tran_char    	CHAR(10); 

DEFINE _version		    	CHAR(2);
DEFINE _aplicacion	    	CHAR(3);
DEFINE _valor_parametro 	CHAR(20);
DEFINE _valor_parametro2	CHAR(20);
DEFINE _fecha_no_server  	DATE;
DEFINE _periodo_rec     	CHAR(7);  

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _no_poliza           char(10);
define _reserva_actual      decimal(16,2);
define _cod_ramo            char(3);
DEFINE _exceso              DEC(16,2);
DEFINE _reserva_actual_r	DEC(16,2);
DEFINE _no_reclamo        	char(10);
define _dif_reserva        	DEC(16,2);
DEFINE v_filtros            CHAR(255);
define _cant                smallint;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_rec224.trc";
--trace on;

let _reserva_actual = 0;

{CALL sp_rec02(
"001", 
"001", 
"2013-12",
'*',
'*',
'*',
'*',
'*'
) RETURNING v_filtros; 
}

FOREACH	WITH HOLD
  SELECT numrecla,   
         reserva_actual,   
         exceso
    INTO _numrecla,
	     _reserva_actual,
		 _exceso
    FROM tmp_exceso_reserva 
   WHERE seleccionado = 0

  SELECT no_reclamo
    INTO _no_reclamo
    FROM recrcmae
   WHERE numrecla = _numrecla;

  LET _reserva_actual_r = 0;
  LET _dif_reserva = 0;

--  SELECT reserva_total
--    INTO _reserva_actual_r
--	FROM tmp_sinis
--   WHERE no_reclamo = _no_reclamo;

  LET _cant = 0;
  LET _cod_cobertura = NULL;

  SELECT COUNT(*)
    INTO _cant
    FROM recrccob
   WHERE no_reclamo = _no_reclamo;
   
  IF _cant = 1 THEN
	  SELECT cod_cobertura	    
	    INTO _cod_cobertura	    
	    FROM recrccob
	   WHERE no_reclamo = _no_reclamo;
  ELSE 
	  FOREACH
		  SELECT cod_cobertura	    
		    INTO _cod_cobertura	    
		    FROM recrccob
		   WHERE no_reclamo = _no_reclamo 
		     AND reserva_actual <> 0
			 AND reserva_actual >= _exceso

	      EXIT FOREACH;
	  END FOREACH

      IF _cod_cobertura IS NULL THEN
		  FOREACH
			  SELECT cod_cobertura	    
			    INTO _cod_cobertura	    
			    FROM recrccob
			   WHERE no_reclamo = _no_reclamo 

		      EXIT FOREACH;
		  END FOREACH
	  END IF
  END IF

 { FOREACH
	  SELECT cod_cobertura,
	         reserva_actual
	    INTO _cod_cobertura,
	         _reserva_actual_r
	    FROM recrccob
	   WHERE no_reclamo = _no_reclamo 
	     AND reserva_actual <> 0

      EXIT FOREACH;
  END FOREACH
 }
 -- IF _reserva_actual_r IS NULL THEN
 --	LET _reserva_actual_r = 0;
 -- END IF

 -- LET _dif_reserva = _reserva_actual_r - _exceso;

 -- IF _dif_reserva < 0 THEN
 --	continue foreach;
 -- END IF
      
--  IF _reserva_actual = _reserva_actual_r THEN
	-- Reaseguro a Nivel de Transaccion

	call sp_rec223(_no_reclamo, _exceso, _cod_cobertura) returning _error, _error_desc;
--	call sp_rec226(_no_reclamo, _exceso, _cod_cobertura) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if
  
	update tmp_exceso_reserva
	   set seleccionado  = 1
	 where numrecla      = _numrecla;
        
 --  END IF
END FOREACH
end

return 0, "Actualizacion Exitosa";

end procedure