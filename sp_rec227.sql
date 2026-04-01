-- Procedimiento que cierra del reclamo

-- Creado    : 11/04/2014 - Autor: Amado Perez M. 
drop procedure sp_rec227;

create procedure sp_rec227() returning integer,
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

define _no_tramite      char(10);
define _incidente		integer;
define _user_added      char(10);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_rec224.trc";
--trace on;

let _reserva_actual = 0;


FOREACH	WITH HOLD
  SELECT numrecla,   
         reserva   
    INTO _numrecla,
	     _reserva_actual
    FROM tmp_cierra_reserva 
   WHERE procesado = 0
     AND dias = 2

  SELECT no_reclamo,
		 no_tramite,
		 incidente,
		 user_added
    INTO _no_reclamo,
		 _no_tramite,
		 _incidente,
		 _user_added
    FROM recrcmae
   WHERE numrecla = _numrecla;

	-- Proceso que cierra las reservas

	call sp_rec158(_no_reclamo, _reserva_actual) returning _error, _error_desc;

    if _error = 0 then
		insert into wfcieres (no_reclamo,no_tramite,incidente,user_added)
		values(_no_reclamo,_no_tramite,_incidente,_user_added);
	  
		update tmp_cierra_reserva
		   set procesado  = 1
		 where numrecla   = _numrecla;
    else
		select sum(reserva_actual)
		  into _reserva_actual
		  from recrccob
		 where no_reclamo = _no_reclamo;

		update tmp_cierra_reserva
		   set reserva_actual  = _reserva_actual
		 where numrecla   = _numrecla;
	end if
        
END FOREACH
end

return 0, "Actualizacion Exitosa";

end procedure