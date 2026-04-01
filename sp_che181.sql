-- Reporte de las Comisiones por Corredor - Detallado

-- Creado    : 23/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che181;

CREATE PROCEDURE sp_che181() RETURNING CHAR(20),	-- Poliza
			CHAR(100),	-- Asegurado
			CHAR(10),	-- Recibo
			DATE,		-- Fecha
			DEC(16,2),	-- Monto
			DEC(16,2),	-- Prima
			DEC(5,2),	-- % Partic
			DEC(5,2),	-- % Comis
			DEC(16,2),	-- Comision
			CHAR(50),   -- Agente
			CHAR(50),	-- Compania
			CHAR(255);  -- filtros

DEFINE _tipo          CHAR(1);

DEFINE v_cod_agente   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto        DEC(16,2);
DEFINE v_no_recibo    CHAR(10); 
DEFINE v_fecha        DATE;     
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_partic  DEC(5,2); 
DEFINE v_porc_comis   DEC(5,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt   CHAR(50);
DEFINE v_nombre_cia   CHAR(50);
define _cnt_aplica	  smallint;
define _comision_adelanto	dec(16,2);
define _no_recibo	  CHAR(10);
DEFINE v_filtros        CHAR(255);
DEFINE _cod_cliente  CHAR(10);
DEFINE v_saber  CHAR(10);
define v_desc_grupo  varchar(50);
define v_codigo     char(5);
define _cadena   CHAR(255); 

LET v_saber = "";
LET _cadena = ""; 

--SET DEBUG FILE TO "\\NEMESIS\Ancon\Store Procedures\Debug\sp_che03c.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  v_nombre_cia = sp_sis01('001'); 
LET v_filtros = "";

CREATE TEMP TABLE tmp_salida(
	no_documento	CHAR(20),
	nombre_clte		CHAR(100),
	no_recibo		CHAR(10),
	fecha			DATE,
	monto           DEC(16,2),
	prima           DEC(16,2),
	porc_partic		DEC(5,2),
	porc_comis		DEC(5,2),
	comision		DEC(16,2),
    nombre_agt      CHAR(50),
	nombre_cia      CHAR(50)
	) WITH NO LOG;
	
SET ISOLATION TO DIRTY READ;


foreach

	SELECT no_documento
	  into v_no_documento
	  from marshverif
	 where adelanto = 0

    foreach
	
		select no_documento,
		       fecha,
			   comision,
			   no_recibo,
			   no_poliza,
			   nombre,
			   monto,
			   prima,
			   porc_partic,
			   porc_comis
		  into v_no_documento,
		       v_fecha,
			   v_comision,
			   v_no_recibo,
			   v_no_poliza,
			   v_nombre_agt,
			   v_monto,
			   v_prima,
			   v_porc_partic,
			   v_porc_comis
		  from chqcomis
		 where no_documento = v_no_documento
		   and cod_agente in ('00270','01814','01853')
		   
		SELECT cod_contratante
		  INTO _cod_cliente
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

		SELECT nombre
		  INTO v_nombre_clte
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;

		insert into tmp_salida(
			no_documento,
			nombre_clte,
			no_recibo,
			fecha,
			monto,
			prima,
			porc_partic,
			porc_comis,
			comision,
			nombre_agt,
			nombre_cia)
			values(
			v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_nombre_cia
			);		 
		   
	   { RETURN  v_no_documento,
				v_nombre_clte,
				v_no_recibo,
				v_fecha,
				0,
				0,
				0,
				0,
				v_comision,
				v_nombre_agt,
				v_nombre_cia
			WITH RESUME;}
	end foreach
end foreach

foreach
	select  no_documento,
			nombre_clte,
			no_recibo,
			fecha,
			monto,
			prima,
			porc_partic,
			porc_comis,
			comision,
			nombre_agt,
			nombre_cia
	 into   v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_nombre_cia
	 from   tmp_salida
	ORDER BY nombre_agt, fecha, no_recibo, no_documento
	
	RETURN  v_no_documento,
			v_nombre_clte,
			v_no_recibo,
			v_fecha,
			v_monto,
			v_prima,
			v_porc_partic,
			v_porc_comis,
			v_comision,
			v_nombre_agt,
			v_nombre_cia,
			v_filtros
			WITH RESUME;
end foreach

DROP TABLE tmp_salida;

END PROCEDURE;