-- Procedimiento para calcular el endoso ENDOSO ANCON H.M.C.
--
-- Creado    : 21/01/2025 - Autor: Federico Coronado.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_end19;
CREATE PROCEDURE sp_end19(a_poliza CHAR(10), a_endoso CHAR(5))
			RETURNING   int;

DEFINE _cod_producto   		varchar(5);
DEFINE _cod_cobertura		varchar(5);
DEFINE _prima_endoso        DECIMAL(16,2);
DEFINE _prima_total         DECIMAL(16,2);
DEFINE _count				int;
DEFINE _no_unidad			VARCHAR(5);
DEFINE _acepta_desc    		INTEGER;
DEFINE _recargo				DECIMAL(16,2);
DEFINE _recargo_dep 		DECIMAL(16,2);
DEFINE _prima_endoso_ori    DECIMAL(16,2);
DEFINE _cod_cliente         char(10);


BEGIN

SET ISOLATION TO DIRTY READ;

 --SET DEBUG FILE TO "sp_end19.trc";
 --TRACE ON;                                                                     

foreach
	select cod_producto, no_unidad
	into _cod_producto, _no_unidad 
	 from endeduni
	where no_poliza = a_poliza
	  and no_endoso = a_endoso
	 
	SELECT count(*) 
	  INTO _count
	  FROM emidepen  
	 WHERE emidepen.no_poliza = a_poliza  
	   AND emidepen.no_unidad = _no_unidad
	   AND emidepen.activo 	  = 1; 
	  
	  let _prima_total = 0;
	  
	foreach
		select cod_cobertura, prima_endoso, prdcobpd.acepta_desc
		  into _cod_cobertura, _prima_endoso, _acepta_desc	
		  from prdcobpd
		 where cod_producto = _cod_producto 
		   and prima_endoso <> 0
		   
		IF _prima_endoso IS NULL THEN
			LET _prima_endoso = 0.00;
		END IF
		
		let _prima_endoso_ori = _prima_endoso;
		
		IF _acepta_desc IS NULL THEN
		   LET _acepta_desc = 0;
		END IF
		
		-- Buscar Recargo unidad
		LET _recargo = 0.00;
		--If _acepta_desc = 1 Then
		   CALL sp_proe37(a_poliza, a_endoso, _no_unidad, _prima_endoso) RETURNING _recargo;
		--End If
		
		let _prima_endoso = _prima_endoso + _recargo;
		
		if _count > 0 THEN
			foreach
				select cod_cliente
				  into _cod_cliente
				  from emidepen
				 where no_poliza = a_poliza
				   and no_unidad = _no_unidad
				   AND activo 	 = 1
				   LET _recargo_dep = 0.00;
				-- Buscar Recargo Dependiente
				CALL sp_proe51(a_poliza, _no_unidad, _cod_cliente, _prima_endoso_ori)RETURNING _recargo_dep;
				
				let _prima_endoso = _prima_endoso + _prima_endoso_ori + _recargo_dep;
			end foreach
		end if
		
		update endedcob
		   set prima_anual 	= _prima_endoso,
			   prima       	= _prima_endoso,
			   prima_neta  	= _prima_endoso
		where no_poliza 	= a_poliza
		  and no_unidad 	= _no_unidad
		  and no_endoso 	= a_endoso
		  and cod_cobertura = _cod_cobertura;
		--let _prima_total = _prima_total + _prima_endoso;
	end foreach
end foreach

RETURN 0;
END
END PROCEDURE;