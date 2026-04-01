-- Procedimiento para buscar el valor del Recargo del dependiente
-- f_emision_busca_recargo
--
-- Creado    : 25/10/2010 - Autor: Amado Perez M.
-- Modificado: 25/10/2010 - Autor: Amado Perez M.
--Modificado : 09/07/2024 -Armando M. cálculo del recargo
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe53;
CREATE PROCEDURE sp_proe53(a_poliza CHAR(10), a_unidad CHAR(5))
			RETURNING   DECIMAL(16,2);			 -- ld_descuento

DEFINE li_lin, li_return   		INTEGER;
DEFINE ld_porc, ld_porc_recargo	DECIMAL(10,4);
DEFINE ld_recargo,_prima_au		DECIMAL(16,2);
DEFINE ls_cod_recargo	   		CHAR(3);
DEFINE _cod_cliente             CHAR(10);
DEFINE ld_recargo_tot	   		DECIMAL(16,2);
DEFINE _prima 					DECIMAL(16,2);
DEFINE _meses                   SMALLINT;
DEFINE ls_cod_producto          VARCHAR(10);
DEFINE _prima_endoso            VARCHAR(10);

BEGIN

SET ISOLATION TO DIRTY READ;

 
-- SET DEBUG FILE TO "sp_proe53.trc";
-- TRACE ON;                

LET ld_recargo = 0.00;
LET ld_recargo_tot = 0.00;
LET a_poliza = a_poliza;
LET a_unidad = a_unidad;

SELECT cod_perpago
  INTO ls_cod_recargo
  FROM emipomae
 WHERE no_poliza = a_poliza;

SELECT meses
  INTO _meses
  FROM cobperpa
 WHERE cod_perpago = ls_cod_recargo;
 
IF ls_cod_recargo = '008' THEN --ANUAL tiene 0 en meses, por eso le ponemos 12 para los cálculos -- Amado 24-04-2025 SD# 13499
	LET _meses = 12;
END IF
 
 select cod_producto
   into ls_cod_producto
   from emipouni
  where no_poliza = a_poliza
   and no_unidad = a_unidad;
 
 SELECT sum(prima_endoso)
  INTO _prima_endoso
  FROM prdcobpd
 WHERE cod_producto = ls_cod_producto;
 
IF _prima_endoso IS NULL THEN
	LET _prima_endoso = 0.00;
END IF

FOREACH	WITH HOLD
	SELECT prima,
	       cod_cliente
	  INTO _prima,
		   _cod_cliente
	  FROM emidepen  
	 WHERE emidepen.no_poliza = a_poliza  
	   AND emidepen.no_unidad = a_unidad
	   AND emidepen.activo = 1

	IF _prima IS NULL THEN
		LET _prima = 0.00;
	END IF

	LET _prima     = _prima * _meses;
	let _prima_au  = _prima;
	let ld_recargo = 0.00;

    FOREACH
		SELECT por_recargo
		  INTO ld_porc_recargo
		  FROM emiderec
		 WHERE no_poliza = a_poliza  
		   AND no_unidad = a_unidad
		   AND cod_cliente = _cod_cliente

		IF ld_porc_recargo IS NULL THEN
			LET ld_porc_recargo = 0.00;
		END IF

		LET ld_recargo = _prima_au * (ld_porc_recargo / 100);
		let _prima_au  = _prima_au + ld_recargo;

		IF ld_recargo IS NULL THEN
			LET ld_recargo = 0.00;
		END IF

		LET ld_recargo_tot = ld_recargo_tot + ld_recargo;
	END FOREACH

END FOREACH

IF ld_recargo_tot IS NULL THEN
	LET ld_recargo_tot = 0.00;
END IF

RETURN ld_recargo_tot;
END
END PROCEDURE;