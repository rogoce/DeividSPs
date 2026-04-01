-- Procedimiento para saber si el reclamo tiene pago a abogado

-- Creado     :	23/07/2014 - Autor: Angel Tello

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec723;		

create procedure sp_rec723(a_numrec char(18))
			returning integer, char(100);


define _no_tranrec  char(18);
define _cod_concep  char(3);
define _mensaje		char(100);
define _cod_abo		char(3);
define _contabo		INTEGER;
define _retun		INTEGER;
define _no_reclamo  char(10);


set isolation to dirty read;

	let _retun = 0;
	let _contabo = 0;
	let _mensaje = 'Existe pago a abogado';
	
	SELECT no_reclamo,
	       cod_abogado
	  INTO _no_reclamo,
	       _cod_abo
	  FROM recrcmae
     WHERE numrecla = a_numrec
	   AND actualizado = 1;
	 
	IF _cod_abo is not null and trim(_cod_abo) <> '001' THEN --Sea distinto a Aseguradora Ancon
		
		SELECT count (*)
		  INTO _contabo
		  FROM rectrmae a , rectrcon b 
		 WHERE b.no_tranrec = a.no_tranrec
		   AND a.no_reclamo = _no_reclamo
		   AND b.cod_concepto = '012';  --legal
		
		IF _contabo = 0  THEN 
			let _retun = 1;
			let _mensaje = 'No se puede cerrar el reclamo, no hay transaccion de pago al abogado.';
		END IF 
	END IF 
	
	-- Verificando si hay trnsacciones en aprobación
        
    	let _contabo = 0;

		SELECT count (*)
		  INTO _contabo
		  FROM rectrmae 
		 WHERE no_reclamo   = _no_reclamo
		   AND wf_aprobado  = 3;  -- En Aprobacion
		
		IF _contabo > 0  THEN 
			let _retun = 1;
			let _mensaje = 'No se puede cerrar el reclamo, hay transacciones en aprobacion';
		END IF 
	

return _retun, _mensaje;	

end procedure
