-- Procedimiento para buscar el valor del Prima del dependiente
-- f_emision_busca_recargo
--
-- Creado    : 25/10/2010 - Autor: Amado Perez M.
-- Modificado: 25/10/2010 - Autor: Amado Perez M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_proe54;
CREATE PROCEDURE sp_proe54(a_poliza CHAR(10), a_unidad CHAR(5))
			RETURNING   DECIMAL(16,2);			 -- Prima del dependiente

DEFINE li_lin, li_return   		INTEGER;
DEFINE ld_porc, ld_porc_recargo	DECIMAL(10,4);
DEFINE ld_recargo		   		DECIMAL(16,2);
DEFINE ls_cod_recargo	   		CHAR(3);
DEFINE _cod_cliente             CHAR(10);
DEFINE ld_recargo_tot	   		DECIMAL(16,2);
DEFINE _prima 					DECIMAL(16,2);
DEFINE _meses                   SMALLINT;
DEFINE _count                   SMALLINT;
DEFINE ls_cod_producto          VARCHAR(10);
DEFINE _prima_endoso            VARCHAR(10);

BEGIN

SET ISOLATION TO DIRTY READ;

-- SET DEBUG FILE TO "\\sp_pro44.trc";
-- TRACE ON;                                                                     

LET _prima = 0;

SELECT cod_perpago
  INTO ls_cod_recargo
  FROM emipomae
 WHERE no_poliza = a_poliza;

SELECT meses
  INTO _meses
  FROM cobperpa
 WHERE cod_perpago = ls_cod_recargo;

IF ls_cod_recargo = '008' AND _meses = 0 THEN
	LET _meses = 12;
END IF

SELECT SUM(prima) 
  INTO _prima
  FROM emidepen  
 WHERE emidepen.no_poliza = a_poliza  
   AND emidepen.no_unidad = a_unidad
   AND emidepen.activo = 1;

IF _prima IS NULL THEN
	LET _prima = 0.00;
END IF

SELECT count(*) 
  INTO _count
  FROM emidepen  
 WHERE emidepen.no_poliza = a_poliza  
   AND emidepen.no_unidad = a_unidad
   AND emidepen.activo = 1;
   
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
   
let _prima_endoso = _prima_endoso * _count;     
LET _prima = _prima * _meses;

RETURN _prima;
END
END PROCEDURE;