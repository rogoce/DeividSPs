-- Morosidad por Agente - Detallado
-- 
-- Creado    : 08/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/07/2001 - Autor: ARMANDO MORENO
-- Modificado: 21/01/2003 -adicion de filtro polizas vencidas - Autor: Armando Moreno
-- se hizo mod. para que de las polizas sin pago a 90, se evaluara la vigencia ini de la poliza con respecto
-- a la fecha de generacion, si es >= a 90 debe salir en el reporte. 29/03/2004 Armando.

-- SIS v.2.0 - d_cobr_sp_cob03a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob126b;

CREATE PROCEDURE "informix".sp_cob126b()
 RETURNING CHAR(100), -- Asegurado
			CHAR(20),  -- Poliza	
			CHAR(1),   -- Estatus	
			CHAR(4),   -- Forma Pago
			DATE,      -- Vigencia Inicial
			DATE,      -- Vigencia Final
			DATE,	   -- Fecha Ultimo Pago
			DEC(16,2), -- Monto Ultimo Pago	
			DEC(16,2), -- Prima Original
			DEC(16,2), -- Saldo
			DEC(16,2), -- Por Vencer
			DEC(16,2), -- Exigible
			DEC(16,2), -- Corriente
			DEC(16,2), -- Dias 30
			DEC(16,2), -- Dias 60
			DEC(16,2), -- Dias 90
			CHAR(50),  -- Nombre Agente
			CHAR(10),  -- Telefono
			CHAR(50),  -- Nombre Vendedor
			CHAR(50),  -- Nombre Compania
			CHAR(20),  -- apartado
			CHAR(5),   -- cod_agente
			CHAR(255), -- Filtros
			CHAR(1),   -- GESTION
			DATE;      -- FECHA

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);

DEFINE v_nombre_cliente    CHAR(100);
DEFINE v_doc_poliza        CHAR(20);
DEFINE v_estatus,_gestion  CHAR(1);
DEFINE v_forma_pago        CHAR(4);
DEFINE v_vigencia_inic     DATE;
DEFINE _fecha			   DATE;
DEFINE v_vigencia_final    DATE;     
DEFINE v_fecha_ult_pago    DATE;
DEFINE v_monto_ult_pago    DEC(16,2);
DEFINE _saldo_sum		   DEC(16,2);
DEFINE v_prima_bruta       DEC(16,2);
DEFINE v_saldo             DEC(16,2);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
DEFINE v_nombre_agente     CHAR(50);
DEFINE v_telefono,v_codigo,_no_poliza CHAR(10);
DEFINE v_nombre_vendedor   CHAR(50);
DEFINE v_cod_agente		   CHAR(5);	
DEFINE v_compania_nombre, v_nombre_prod,v_desc   CHAR(50);
DEFINE v_fecha_cancelacion DATE;
DEFINE _cod_vendedor,v_saber CHAR(3);
DEFINE _apartado           	 CHAR(20);
define _monto				INT;

set isolation to dirty read;

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_cob03a.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01("001");
LET  v_filtros		   = "";

foreach
 SELECT	monto
   INTO	_monto
   FROM	tmp_cartadet
  WHERE seleccionado = 1
	exit foreach;
end foreach

FOREACH
	 SELECT	SUM(saldo),
			cod_agente
	   INTO	_saldo_sum,
			v_cod_agente
	   FROM	tmp_cartadet
	  WHERE seleccionado = 1
--	  	AND vigencia_final >= fecha		     --poliza vigente
		AND (fecha - fecha_ult_pago) >= 90	 --SIN PAGO EN 90
--		AND monto_90 > 0					 --CON MOROSIDAD DE MAS DE 90
   GROUP BY cod_agente
   ORDER BY cod_agente

   if _saldo_sum > _monto then
   else
      continue foreach;
   end if
foreach
 SELECT	nombre_cliente, 
		doc_poliza,     
		estatus,        
		forma_pago,     
		vigencia_inic,  
		vigencia_final, 
		fecha_ult_pago,
		monto_ult_pago,
		prima_orig,    
		saldo,          
		por_vencer,     
		exigible,       
		corriente,     
		monto_30,       
		monto_60,       
		monto_90,
		nombre_agente,
		telefono,
		cod_vendedor,
		apartado,
		cod_agente,
		no_poliza,
		gestion,
		fecha,
		monto
   INTO	v_nombre_cliente, 
		v_doc_poliza,     
		v_estatus,        
		v_forma_pago,     
		v_vigencia_inic,  
		v_vigencia_final, 
		v_fecha_ult_pago,
		v_monto_ult_pago,
		v_prima_bruta,    
		v_saldo,          
		v_por_vencer,     
		v_exigible,       
		v_corriente,     
		v_monto_30,       
		v_monto_60,       
		v_monto_90,
		v_nombre_agente,
		v_telefono,
		_cod_vendedor,
		_apartado,
		v_cod_agente,
		_no_poliza,
		_gestion,
		_fecha,
		_monto
   FROM	tmp_cartadet
  WHERE seleccionado = 1
	AND cod_agente = v_cod_agente
--   	AND vigencia_final >= fecha		 --poliza vigente
	AND (fecha - fecha_ult_pago) >= 90	 --SIN PAGO EN 90
--	AND monto_90 > 0					 --CON MOROSIDAD DE MAS DE 90
  ORDER BY nombre_agente, nombre_cliente, doc_poliza, vigencia_inic

	SELECT nombre
	  INTO v_nombre_vendedor
	  FROM agtvende
	 WHERE cod_vendedor = _cod_vendedor;

   if (_fecha - v_vigencia_inic) >= 90 then
   else
      continue foreach;
   end if

	RETURN 	v_nombre_cliente, 
			v_doc_poliza,     
			v_estatus,        
			v_forma_pago,     
			v_vigencia_inic,  
			v_vigencia_final, 
			v_fecha_ult_pago,
			v_monto_ult_pago,
			v_prima_bruta,    
			v_saldo,          
			v_por_vencer,     
			v_exigible,       
			v_corriente,     
			v_monto_30,       
			v_monto_60,       
			v_monto_90,
			v_nombre_agente,
			v_telefono,
			v_nombre_vendedor,
		    v_compania_nombre,
			_apartado,
			v_cod_agente,
		    v_filtros,
			_gestion,
			_fecha
			WITH RESUME;

 end foreach
END FOREACH
					 
END PROCEDURE;

