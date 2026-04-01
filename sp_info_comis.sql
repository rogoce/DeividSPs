-- Reporte especial para seguros centralizados de las Comisiones por Corredor - Detallado

-- Creado    : 15/06/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_info_comis;
CREATE PROCEDURE sp_info_comis()
  RETURNING CHAR(20)  as Poliza,
			CHAR(100) as Asegurado,
			DEC(16,2) as Monto,
			DEC(16,2) as Prima,
			DEC(5,2)  as porc_partic,
			DEC(5,2)  as porc_comis,
			DEC(16,2) as comision,
			DATE      as fecha_impresion,
			CHAR(5)   as cod_agente,
			CHAR(50)  as nom_agente,
			CHAR(10)  as recibo,
            char(10)  as no_requis,
			integer   as no_cheque;

DEFINE _tipo          CHAR(1);
DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10); 
DEFINE v_fecha,_fec_imp    DATE;     
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_partic  DEC(5,2); 
DEFINE v_porc_comis   DEC(5,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
DEFINE v_fecha_desde  DATE;
DEFINE v_fecha_hasta  DATE;
DEFINE _fecha_comis,_vig_ini,_vig_fin   DATE;
DEFINE _cod_cliente  CHAR(10);
DEFINE _no_requis    CHAR(10);
define _no_cheque  integer;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

let _no_requis = null;
let _no_cheque = 0;

FOREACH
	 SELECT	cod_agente,
			no_poliza,
			no_recibo,
			fecha,
			monto,
			prima,
			porc_partic,
			porc_comis,
			comision,
			nombre,
			no_documento,
			no_requis
	   INTO	v_cod_agente,
			v_no_poliza,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_no_documento,
			_no_requis
	   FROM	chqcomis
	  WHERE cod_agente   in('02825','02831','02830','02302','02324','02319')
		and seleccionado = 1
		and fecha_genera  >= '31/12/2024'
		and fecha_genera <= '31/12/2025'
	  ORDER BY nombre, fecha, no_recibo, no_documento
	  
	select fecha_impresion,no_cheque
 	  into _fec_imp,_no_cheque 
	  from chqchmae
	 where no_requis = _no_requis;

	IF v_no_poliza = '00000' THEN -- Comision Descontada
		LET v_nombre_clte = 'COMISION DESCONTADA ...';	
	ELSE
		SELECT cod_contratante,
		       vigencia_inic,
			   vigencia_final
		  INTO _cod_cliente,
		       _vig_ini,
			   _vig_fin
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

		SELECT nombre
		  INTO v_nombre_clte
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;
	END IF
	RETURN  v_no_documento,
			v_nombre_clte,
			v_monto,
			v_prima,			
			v_porc_partic,
			v_porc_comis,
			v_comision,
			_fec_imp,
			v_cod_agente,
			v_nombre_agt,
			v_no_recibo,
			_no_requis,
			_no_cheque
			WITH RESUME;
	
END FOREACH
END PROCEDURE;