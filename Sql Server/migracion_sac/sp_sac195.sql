-- Reporte de las Comisiones por Corredor - Totales

-- Creado    : 24/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che04_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_sac195;

CREATE PROCEDURE sp_sac195(a_compania CHAR(3), a_sucursal CHAR(3), a_fecha_desde DATE, a_fecha_hasta DATE, a_verif_tipo_pago SMALLINT DEFAULT 0) 
RETURNING   CHAR(5),
			CHAR(50),   -- Agente
			CHAR(10),   -- Licencia
			DEC(16,2),	-- Comision
			CHAR(5),
			DEC(16,2);	-- Monto

DEFINE v_nombre_agt   CHAR(50);
DEFINE v_monto        DEC(16,2);
DEFINE v_prima        DEC(16,2);
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_cia   CHAR(50);
DEFINE v_no_licencia  CHAR(10);
DEFINE v_monto_vida   DEC(16,2);
DEFINE v_monto_danos  DEC(16,2);
DEFINE v_monto_fianza DEC(16,2);
DEFINE v_arrastre	  DEC(16,2);
DEFINE _cod_agente    CHAR(5);
DEFINE _fecha_ult_comis DATE;  
DEFINE _tipo_pago     SMALLINT; 
DEFINE _tipo_agente   CHAR(1);  
DEFINE v_comision2    DEC(16,2);

define _tercero		  char(5);

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

LET  v_nombre_cia = sp_sis01(a_compania); 

--DROP TABLE tmp_agente;

CALL sp_che02(
a_compania, 
a_sucursal,
a_fecha_desde,
a_fecha_hasta,
0,
a_verif_tipo_pago
);

--SET DEBUG FILE TO "c:\sp_che04.trc";
--TRACE ON;

FOREACH
 SELECT	SUM(comision),
		nombre,
		no_licencia,
		cod_agente
   INTO	v_comision,
		v_nombre_agt,
		v_no_licencia,
		_cod_agente
   FROM	tmp_agente
  GROUP BY nombre, no_licencia, cod_agente
  ORDER BY nombre, no_licencia, cod_agente

  LET v_arrastre = 0;

  IF a_verif_tipo_pago <> 0 THEN

	  SELECT SUM(monto)
	    INTO v_arrastre
		FROM agtsalhi
	   WHERE cod_agente = _cod_agente
	     AND fecha_al = a_fecha_hasta;

	  SELECT fecha_ult_comis,
	         tipo_pago,
			 tipo_agente
	    INTO _fecha_ult_comis,
		     _tipo_pago,
			 _tipo_agente
		FROM agtagent
	   WHERE cod_agente = _cod_agente;

		IF a_verif_tipo_pago <> 0 THEN
		    IF _tipo_agente = "O" THEN
	 			CONTINUE FOREACH;
			END IF
			IF _tipo_pago <> a_verif_tipo_pago THEN
				CONTINUE FOREACH;
			END IF
		END IF
      

	  IF _fecha_ult_comis IS NOT NULL THEN
	  	IF _fecha_ult_comis < a_fecha_hasta THEN
			CONTINUE FOREACH;
		END IF
	  ELSE
		CONTINUE FOREACH;
	  END IF 
  END IF

  IF v_arrastre IS NULL THEN
  	LET v_arrastre = 0;
  END IF

  LET v_comision = v_comision + v_arrastre;

  IF a_verif_tipo_pago = 2 THEN
  	IF v_comision <= 100 THEN
		CONTINUE FOREACH;
  	END IF
  ELIF a_verif_tipo_pago = 1 THEN
  	IF v_comision <= 0 THEN
		CONTINUE FOREACH;
  	END IF
  END IF 

	let _tercero = "A" || _cod_agente[2,5];

	select sld1_saldo
	  into v_monto
	  from cglsaldoaux1
	 where sld1_tipo    = "01"
	   and sld1_cuenta  = "26410"
	   and sld1_ano     = 2010
	   and sld1_periodo = 12
	   and sld1_tercero = _tercero;
	   
--	if v_monto is null then
--		let v_monto = 0;
--	end if	   		

	RETURN  _cod_agente,
			v_nombre_agt,
			v_no_licencia,
			v_comision,
			_tercero,
			v_monto
			WITH RESUME;
	
END FOREACH

DROP TABLE tmp_agente;

END PROCEDURE;