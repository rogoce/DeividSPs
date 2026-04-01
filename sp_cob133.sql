-- Morosidad de Polizas por Cancelar
-- 
-- Creado    : 15/01/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_cobr_sp_cob133_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob133;

CREATE PROCEDURE "informix".sp_cob133(
a_compania     CHAR(3), 
a_agencia      CHAR(3), 
a_fecha        DATE
) RETURNING CHAR(100), -- Asegurado
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
			CHAR(1);   -- gestion

DEFINE v_filtros           CHAR(255);
DEFINE _tipo               CHAR(1);

DEFINE v_nombre_cliente    CHAR(100);
DEFINE v_doc_poliza        CHAR(20); 
DEFINE v_estatus,_gestion  CHAR(1); 
DEFINE v_forma_pago        CHAR(4);
DEFINE v_vigencia_inic     DATE;     
DEFINE v_vigencia_final    DATE;     
DEFINE v_fecha_ult_pago    DATE;
DEFINE v_monto_ult_pago    DEC(16,2);
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
DEFINE v_cod_cliente   	   CHAR(10);
DEFINE v_cobra_poliza  	   CHAR(1);

DEFINE _mes_contable       CHAR(2);
DEFINE _ano_contable       CHAR(4);
DEFINE _periodo            CHAR(7);
DEFINE _cod_formapag       CHAR(3);

--SET DEBUG FILE TO "sp_cob133.trc";

--DROP TABLE tmp_moros;

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 

LET _ano_contable = YEAR(a_fecha);

IF MONTH(a_fecha) < 10 THEN
	LET _mes_contable = '0' || MONTH(a_fecha);
ELSE
	LET _mes_contable = MONTH(a_fecha);
END IF

LET _periodo = _ano_contable || '-' || _mes_contable;

let v_filtros    = "";
let v_cod_agente = "";
let _apartado    = "";
let v_nombre_vendedor = "";
let v_telefono   = "";
let v_nombre_agente = "";
let v_monto_ult_pago = 0.00;
let v_fecha_ult_pago = "";

foreach
 select	no_documento
   into	v_doc_poliza
   from	emipomae
  where	actualizado  = 1
    and cobra_poliza = "P"
  group by no_documento

	let _no_poliza = sp_sis21(v_doc_poliza);

	 SELECT	cod_contratante,
		    estatus_poliza,
		   	cod_formapag,
		   	vigencia_inic,
		    vigencia_final,
			gestion,
			cobra_poliza,
		    prima_bruta,
			fecha_cancelacion
	   INTO	v_cod_cliente,   
		    v_estatus,       
		    _cod_formapag,  
		    v_vigencia_inic, 
		    v_vigencia_final,
		    _gestion,
		    v_cobra_poliza,
		    v_prima_bruta,
			v_fecha_cancelacion
	   FROM	emipomae
	  WHERE no_poliza = _no_poliza;

	if v_cobra_poliza <> "P" then
		continue foreach;
	end if

	CALL sp_cob33(
		 a_compania,
		 a_agencia,	
		 v_doc_poliza,
		 _periodo,
		 a_fecha
		 ) RETURNING v_por_vencer,       
    				 v_exigible,         
    				 v_corriente,        
    				 v_monto_30,         
    				 v_monto_60,         
    				 v_monto_90,
					 v_saldo;         
    				 
 	IF v_saldo = 0 THEN                   
		CONTINUE FOREACH;
 	END IF                                      

	IF v_estatus = "C" THEN
		LET v_vigencia_final = v_fecha_cancelacion;
    END IF

	SELECT nombre
	  INTO v_nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = v_cod_cliente;

	select nombre
	  into v_forma_pago
	  from cobforpa
	 where cod_formapag = _cod_formapag;

   FOREACH
	SELECT fecha, 
	       monto
	  INTO v_fecha_ult_pago,
	  	   v_monto_ult_pago
	  FROM cobredet
	 WHERE doc_remesa   = v_doc_poliza	-- Recibos de la Poliza
	   AND actualizado  = 1			    -- Recibo este actualizado
	   AND tipo_mov     = 'P'       	-- Pago de Prima(P)
       AND periodo     <= _periodo	    -- No Incluye Periodos Futuros
	 ORDER BY fecha DESC
		EXIT FOREACH;
	END FOREACH

	IF v_fecha_ult_pago IS NULL THEN
	    let v_fecha_ult_pago = "";
		LET v_monto_ult_pago = 0;
	END IF

	RETURN v_nombre_cliente, 
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
		   _gestion
		   WITH RESUME;

--	exit foreach;

end foreach

END PROCEDURE;

