-- Procedimiento para buscar los reclamos con la ultima transaccion sea cerrar reclamos para completar los incidentes en workflow
-- 
-- creado: 11/05/2005 - Autor: Amado Perez.

DROP PROCEDURE sp_yos03;
CREATE PROCEDURE "informix".sp_yos03(a_no_reclamo CHAR(10), a_cod_cobertura CHAR(5), a_monto DEC(16,2), a_no_tranrec char(10)) 
	RETURNING INTEGER as ajustado;  

DEFINE _no_reclamo			CHAR(10);
DEFINE _cod_tipotran		CHAR(3);
DEFINE _no_tramite, _transaccion			CHAR(10);
DEFINE _incidente           INTEGER;
DEFINE _numrecla			CHAR(18);
DEFINE _estatus_reclamo		CHAR(1);
DEFINE _variacion           DEC(16,2);
DEFINE _no_tranrec          CHAR(10);
DEFINE _suma_monto			DEC(16,2);
DEFINE _suma_variacion		DEC(16,2);

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_rwf43.trc";
--trace on;

-- 0 = aumento de reserva
-- 1 = reserva Inicial 

	UPDATE recrccob
	   SET reserva_inicial = a_monto,
	       reserva_actual  = a_monto
	 WHERE no_reclamo = a_no_reclamo
	   AND cod_cobertura = a_cod_cobertura;
	   
	-- si viene nulo busca el no_tranrec y actualiza si no actualiza el a_no_tranrec enviado   
	if a_no_tranrec is null or a_no_tranrec = '' then
		SELECT no_tranrec 
		  INTO _no_tranrec
		  FROM rectrmae
		 WHERE no_reclamo = a_no_reclamo
		   and cod_tipotran = '001'; --reserva inicial
	else
		let _no_tranrec = a_no_tranrec;
	end if
 	   
	UPDATE rectrcob
	   SET monto = a_monto,
	       variacion  = a_monto
	 WHERE no_tranrec = _no_tranrec
	   AND cod_cobertura = a_cod_cobertura;
	
	select sum(monto),
		   sum(variacion)
	  into _suma_monto,
	       _suma_variacion
	  from rectrcob
	 WHERE no_tranrec = _no_tranrec; 
	
	UPDATE rectrmae
	   SET monto 	  = _suma_monto,
	       variacion  = _suma_variacion
	 WHERE no_tranrec = _no_tranrec;	   
	   
---

	   
   RETURN 1;
END PROCEDURE