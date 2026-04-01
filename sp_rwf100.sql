-- Morosidad por Asegurado

-- Creado    : 20/04/2004 - Autor: Amado Perez M.
-- Modificado: 20/04/2004 - Autor: Amado Perez M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_rwf100;

--CREATE PROCEDURE sp_rwf10(a_cod_cliente CHAR(10))
CREATE PROCEDURE sp_rwf100(a_no_documento CHAR(20))
RETURNING DEC(16,2);

DEFINE v_cod_cliente  		CHAR(10);  

DEFINE v_documento   		CHAR(20);
DEFINE v_vig_ini			DATE;
DEFINE v_vig_fin			DATE;
DEFINE v_no_unidad	 	    CHAR(5);

DEFINE v_no_poliza	 	    CHAR(10);
define _actualizado			smallint;
DEFINE _no_endoso	 	    CHAR(5);
define _estatus_poliza		smallint;
define _estatus_desc		char(10);
DEFINE _cod_agente          CHAR(5);
DEFINE _cod_cobrador, _cod_supervisor	CHAR(3);
DEFINE _usuario				CHAR(10);
define _mes_char			char(2);
define _ano_char			char(4);
define _periodo			    char(7);
DEFINE v_email_supervisor, v_email_gerente  varchar(30);
define v_email_todos, v_email, v_email_electronico  varchar(255);
define _cod_compania, _cod_sucursal char(3);
define v_saldo_tot, v_por_vencer, _exigible, v_corriente, v_monto_30, v_monto_60, v_monto_90, v_saldo dec(16,2);
define _cod_formapag char(3);

--set debug file to "sp_rwf02.trc";

{create temp table tmp_polizas(
    no_documento char(20),
	no_unidad	 char(5),
	cod_compania char(3),
	cod_sucursal char(3),
	PRIMARY KEY (no_documento)) with no log;
}


SET ISOLATION TO DIRTY READ;

IF  MONTH(current) < 10 THEN
	LET _mes_char = '0'|| MONTH(current);
ELSE
	LET _mes_char = MONTH(current);
END IF

LET _ano_char = YEAR(current);
LET _periodo  = _ano_char || "-" || _mes_char;



FOREACH   
    SELECT cod_compania,
		   sucursal_origen,
		   no_documento,
		   no_poliza,
		   cod_formapag
	  INTO _cod_compania,
		   _cod_sucursal,
		   v_documento,
		   v_no_poliza,
		   _cod_formapag
	  FROM emipomae
	 WHERE no_documento = a_no_documento
	ORDER BY no_poliza DESC
	EXIT FOREACH;
END FOREACH

	CALL sp_cob33(
	_cod_compania,
	_cod_sucursal,
	v_documento,
	_periodo,
	current
	) RETURNING v_por_vencer,
			    _exigible,  
			    v_corriente, 
			    v_monto_30,  
			    v_monto_60,  
			    v_monto_90,  
				v_saldo;



RETURN v_saldo;


--drop table tmp_polizas;

END PROCEDURE;