-- Reportes de los Asegurados de la Poliza de Salud
-- al momento de la facturacion

-- Creado    : 19/10/2000 - Autor: Demetrio Hurtado Almanza
-- Modificado: 19/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_prod_sp_pro42_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro42;

CREATE PROCEDURE sp_pro42()
RETURNING CHAR(100),	-- Asegurado
		  CHAR(1),		-- Plan
		  CHAR(30),		-- Cedula
		  DATE,			-- Fecha Nac.
		  DATE,			-- Fecha Emis.
		  DATE,			-- Fecha Efec.
		  DEC(16,2),	-- Prima Neta
		  DEC(16,2),	-- Impuesto
		  DEC(16,2),	-- Prima Bruta
		  CHAR(100),	-- Contratante
		  CHAR(20),		-- Numero Poliza
		  DATE,			-- Vigencia Inicial
		  CHAR(50),		-- Subramo
		  CHAR(50),		-- Compania
		  DATE,			-- V.I.
		  DATE;			-- V.F.

DEFINE v_nombre_cli      CHAR(100);
DEFINE v_plan            CHAR(1); 
DEFINE v_cedula          CHAR(30); 
DEFINE v_fecha_nac       DATE; 
DEFINE v_fecha_emis      DATE; 
DEFINE v_fecha_efec      DATE; 
DEFINE v_prima_neta      DEC(16,2);
DEFINE v_impuesto_uni    DEC(16,2);
DEFINE v_prima_brut_uni  DEC(16,2);
DEFINE v_nombre_cliente  CHAR(100);
DEFINE v_no_documento    CHAR(20); 
DEFINE v_vigencia_inic   DATE; 
DEFINE v_nombre_subramo  CHAR(50); 
DEFINE v_nombre_compania CHAR(50); 
DEFINE v_vigencia_i      DATE; 
DEFINE v_vigencia_f      DATE; 

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	nombre,
		plan,
		cedula,
		fecha_nac,
		fecha_emis,
		fecha_efec,
		prima_net,
		impuesto,
		prima_bru,
		contratante,
		doc_poliza,
		vigen_inic,
		subramo,
		compania,
		vigencia_i,
		vigencia_f
   INTO	v_nombre_cli,
		v_plan,
		v_cedula,
		v_fecha_nac,
		v_fecha_emis,
		v_fecha_efec,
		v_prima_neta,
		v_impuesto_uni,
		v_prima_brut_uni,
		v_nombre_cliente,
		v_no_documento,
		v_vigencia_inic,
		v_nombre_subramo,
		v_nombre_compania,
		v_vigencia_i,
		v_vigencia_f
   FROM	tmp_certif

	RETURN  v_nombre_cli,
			v_plan,
			v_cedula,
			v_fecha_nac,
			v_fecha_emis,
			v_fecha_efec,
			v_prima_neta,
			v_impuesto_uni,
			v_prima_brut_uni,
			v_nombre_cliente,
			v_no_documento,
			v_vigencia_inic,
			v_nombre_subramo,
			v_nombre_compania,
			v_vigencia_i,
			v_vigencia_f
			WITH RESUME;

END FOREACH

END PROCEDURE;
