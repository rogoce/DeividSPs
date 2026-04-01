-- Reporte de   Vencimientos
-- Creado       : 31/12/2008
-- Autor: Ricardo  Jimenez B.
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_pro51d;

CREATE PROCEDURE "informix".sp_pro51d(a_poliza CHAR(10), a_producto CHAR(5), a_ramo CHAR(3), a_unidad CHAR(5), a_cobertura CHAR(5), a_marca CHAR(5), a_suma DECIMAL(16,2), a_tarifa DECIMAL(16,2), a_uso_auto CHAR(1))
RETURNING DECIMAL(16,2);  -- _ld_deducible

--**********************DECLARACION DE VARIABLE***********************--

DEFINE _ld_tipo_deduc          INTEGER;
DEFINE _ls_tipo_rec_com        CHAR(1);
DEFINE _ls_tipo_rec_col        CHAR(1);
DEFINE _ld_existe              INTEGER;

DEFINE _ld_rec_ded_col   DECIMAL(16,2);
DEFINE _ld_rec_ded_com   DECIMAL(16,2);
DEFINE _ld_deducible     DECIMAL(16,2);
DEFINE _ld_ded_min       DECIMAL(16,2);
DEFINE _ld_deduc_anter   DECIMAL(16,2);
DEFINE _ld_suma          DECIMAL(16,2);
DEFINE _ld_tarifa        DECIMAL(16,2);
DEFINE _ld_prima_act     DECIMAL(16,2);

SET ISOLATION TO DIRTY READ;

--********************INICIALIZACION DE VARIABLES*********************--

LET _ld_existe      = 0;
LET _ld_suma        = a_suma;
LET _ld_tarifa      = a_tarifa;
LET _ld_deducible   = 00.00;
LET _ld_prima_act   = 00.00;

--*******************VERFIFICA SI LA MARCA EXISTE*********************--

SELECT count(*)
  INTO _ld_existe
  FROM emirecmarc
 WHERE cod_marca = a_marca;

IF a_uso_auto = "P" THEN
   --Colision
   IF a_cobertura IN ("00119", "00121") THEN
      LET _ld_prima_act = sp_pro51c(a_poliza, a_producto, a_ramo, a_unidad, a_cobertura, a_suma);
	  LET _ld_deducible = Trunc((_ld_prima_act + (_ld_prima_act * 0.25)), 0);
	  IF  _ld_deducible < 300.00 THEN
		  LET _ld_deducible = 300.00;
	  END IF
   END IF
   --Comprensivo
   IF a_cobertura IN ("00118", "00606", "00120", "00103") THEN

	  LET _ld_prima_act = sp_pro51c(a_poliza, a_producto, a_ramo, a_unidad, "00118", a_suma);
	  LET _ld_deducible  = _ld_prima_act;
	  
	  IF  _ld_existe = 0 THEN
		  --IF a_cobertura IN ("00118", "00606") THEN
			IF _ld_deducible < 150.00 THEN
			   LET _ld_deducible = 150.00;
			END IF
		  --END IF
	  END IF
   END IF

   IF a_cobertura NOT IN ("00118", "00606", "00119", "00121", "00120", "00103") THEN
	  SELECT d.deducible_min,
             d.tipo_deducible,
             d.deducible
        INTO _ld_ded_min,
             _ld_tipo_deduc,
             _ld_deducible
	   	FROM prdcobpd d,
             prdcober c
	   WHERE d.cod_cobertura = c.cod_cobertura
         AND c.cod_ramo      = a_ramo
         AND d.cod_producto  = a_producto
         AND c.cod_cobertura = a_cobertura;

   	  	IF _ld_deducible IS NULL THEN
      	   LET _ld_deducible = 00.00;
   	  	END IF

   	  IF _ld_tipo_deduc = 1 THEN --Fijo

   	  ELIF  _ld_tipo_deduc = 2 THEN --%suma
     	   	LET _ld_deducible = _ld_suma * _ld_deducible / 100;
   	  ELIF  _ld_tipo_deduc = 3 THEN --Por Rango
   	  ELIF  _ld_tipo_deduc = 4 THEN --Prima Anual 
            LET _ld_deducible = _ld_tarifa * _ld_deducible / 100;
   	  END IF

   	  IF _ld_ded_min > 0  AND _ld_deducible < _ld_ded_min THEN
	     LET _ld_deducible = _ld_ded_min;
   	  END IF
	  
   END IF


END IF

IF a_uso_auto = "C" THEN  --si es comercial segun tarifa
   
   SELECT d.deducible_min,
          d.tipo_deducible,
          d.deducible
     INTO _ld_ded_min,
          _ld_tipo_deduc,
          _ld_deducible

     FROM prdcobpd d,
          prdcober c

    WHERE d.cod_cobertura = c.cod_cobertura
      AND c.cod_ramo      = a_ramo
      AND d.cod_producto  = a_producto
      AND c.cod_cobertura = a_cobertura;

   IF _ld_deducible IS NULL THEN
      LET _ld_deducible = 00.00;
   END IF

   IF _ld_tipo_deduc = 1 THEN --Fijo

   ELIF  _ld_tipo_deduc = 2 THEN --%suma
     LET _ld_deducible = _ld_suma * _ld_deducible / 100;
   ELIF  _ld_tipo_deduc = 3 THEN --Por Rango
   ELIF  _ld_tipo_deduc = 4 THEN --Prima Anual 
     LET _ld_deducible = _ld_tarifa * _ld_deducible / 100;
   END IF

   IF _ld_ded_min > 0  AND _ld_deducible < _ld_ded_min THEN
	  LET _ld_deducible = _ld_ded_min;
   END IF

END IF

IF a_cobertura IN ("00118", "00606", "00119", "00121") AND _ld_existe > 0 and a_uso_auto = "P" THEN
   SELECT tipo_rec_compr,
          rec_compr,
     	  tipo_rec_colisi,
     	  rec_colision
     INTO _ls_tipo_rec_com,
          _ld_rec_ded_com,
       	  _ls_tipo_rec_col,
       	  _ld_rec_ded_col
     FROM emirecmarc
    WHERE cod_marca = a_marca;

   IF a_cobertura IN ("00118", "00606") THEN --COMPRENSIVO

	  IF _ls_tipo_rec_com   = 1 THEN --Valor
	 	 LET _ld_deducible  = _ld_deducible +  _ld_rec_ded_com;
      ELIF _ls_tipo_rec_com = 2 THEN --Porcentaje
	 	 LET _ld_deducible  = _ld_deducible + (_ld_deducible * (_ld_rec_ded_com/100));
      END IF

      IF _ld_deducible < 150.00 THEN
	 	 lET _ld_deducible = 150.00;
      END IF

   END IF

   IF a_cobertura IN ("00119", "00121") THEN --COLISION

      IF _ls_tipo_rec_col    = 1 THEN --Valor
	  	 LET _ld_deducible   =_ld_deducible + _ld_rec_ded_col;
      ELIF _ls_tipo_rec_col  = 2 THEN --Porcentaje
	 	 LET _ld_deducible   = _ld_deducible + (_ld_deducible * (_ld_rec_ded_col/100));
      END IF

	  IF _ld_deducible < 150.00 THEN
	 	 lET _ld_deducible = 150.00;
      END IF

   END IF

END IF

RETURN _ld_deducible;

END PROCEDURE;



