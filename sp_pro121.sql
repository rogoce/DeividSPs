-- Consulta de Clientes Global  para callcenter

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

--DROP PROCEDURE sp_pro121;

CREATE PROCEDURE sp_pro121(a_cod_cliente CHAR(10))
RETURNING CHAR(20),	 -- POLIZA
		  CHAR(5),	 -- UNIDAD
		  DATE,      -- VIG INI
		  DATE,      -- VIG FIN
		  DEC(16,2), -- PRIMA NETA
		  DEC(16,2), -- IMPUESTO
		  DEC(16,2), -- PRIMA BRUTA
		  DEC(16,2), -- SALDO
		  SMALLINT,	 -- ESTATUS POLIZA
		  CHAR(50),	 -- NOMBRE CORREDOR
		  CHAR(50),	 -- NOMBRE RAMO
		  CHAR(100); -- NOMBRE CTE

DEFINE v_cod_cliente  		CHAR(10);  
DEFINE v_nombre_corredor	CHAR(50); 
DEFINE v_documento   		CHAR(20);
DEFINE v_vig_ini			DATE;
DEFINE v_vig_fin			DATE;
DEFINE _fecha_hoy			DATE;
DEFINE v_prima_neta			DEC(16,2);
DEFINE v_exigible			DEC(16,2);
DEFINE v_prima_bruta		DEC(16,2);
DEFINE v_impuesto			DEC(16,2);
DEFINE v_saldo				DEC(16,2);
DEFINE v_estatus_pol	    SMALLINT;
DEFINE v_actualizado	    SMALLINT;
DEFINE v_no_poliza	 	    CHAR(10);
DEFINE v_no_unidad	 	    CHAR(5);
DEFINE v_cod_agente	 	    CHAR(5);
DEFINE v_nombre_ramo		CHAR(50);
DEFINE v_cod_ramo			CHAR(3);
DEFINE v_nombre_cte			CHAR(100);
define _periodo			    char(7);
define _mes_char            CHAR(2);
define _ano_char		    CHAR(4);

--SET DEBUG FILE TO "sp_pro67.trc";-- Nombre de la Compania
--TRACE ON;

SET ISOLATION TO DIRTY READ;

--SACAR INFORMACION DE LA POLIZA

let _fecha_hoy   = today;
let v_saldo = 0;

IF  MONTH(_fecha_hoy) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_hoy);
ELSE
	LET _mes_char = MONTH(_fecha_hoy);
END IF

LET _ano_char = YEAR(_fecha_hoy);
LET _periodo  = _ano_char || "-" || _mes_char;

 SELECT	nombre
		INTO
		v_nombre_cte
   FROM	cliclien
  WHERE cod_cliente = a_cod_cliente;

FOREACH

	select e.no_documento
	  into v_documento
	  from emipomae e, emipouni i
	 where e.no_poliza = i.no_poliza
	   and i.cod_asegurado = a_cod_cliente
	   and e.actualizado = 1
     group by e.no_documento

	 let v_no_poliza = sp_sis21(v_documento);

  foreach
	 SELECT	prima_neta,
			prima_bruta,
			impuesto,
			no_unidad
			INTO
	 		v_prima_neta,
			v_prima_bruta,
			v_impuesto,
			v_no_unidad
	   FROM	emipouni
	  WHERE no_poliza = v_no_poliza

	  exit foreach;
  end  foreach


	CALL sp_cob33(
	'*',
	'*',
	v_documento,
	_periodo,
	_fecha_hoy
	) RETURNING v_exigible,
			    v_exigible,  
			    v_exigible, 
			    v_exigible,  
			    v_exigible,  
			    v_exigible,
			    v_saldo
			    ;

	 SELECT	vigencia_inic,
			vigencia_final,
			estatus_poliza,
			actualizado,
			cod_ramo
			INTO
	   		v_vig_ini,
			v_vig_fin,
			v_estatus_pol,
			v_actualizado,
			v_cod_ramo
	   FROM	emipomae
	  WHERE no_poliza = v_no_poliza;

	  IF v_actualizado IS NULL THEN
		LET v_actualizado = 0;
	  END IF

	  IF v_actualizado <> 1 THEN
		CONTINUE FOREACH;
	  END IF

	FOREACH
		 SELECT	cod_agente
		  INTO	v_cod_agente
		   FROM	emipoagt
		  WHERE no_poliza = v_no_poliza
		  EXIT FOREACH;
	END FOREACH

	 SELECT	nombre
			INTO
			v_nombre_corredor
	   FROM	agtagent
	  WHERE cod_agente = v_cod_agente;

	 SELECT	nombre
			INTO
			v_nombre_ramo
	   FROM	prdramo
	  WHERE cod_ramo = v_cod_ramo;

	RETURN  v_documento,
			v_no_unidad,		 
			v_vig_ini,
			v_vig_fin,     
			v_prima_neta, 
			v_impuesto,
			v_prima_bruta,
			v_saldo,
			v_estatus_pol,
			v_nombre_corredor,
			v_nombre_ramo,
			v_nombre_cte
			WITH RESUME;
END FOREACH

END PROCEDURE;