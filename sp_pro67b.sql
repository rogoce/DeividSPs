-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro67b;

CREATE PROCEDURE sp_pro67b(a_cod_agente CHAR(5))
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
		  CHAR(100),
		  char(15); -- NOMBRE CTE

DEFINE v_cod_cliente  		CHAR(10);
DEFINE _cod_ase		  		CHAR(10);
DEFINE v_nombre_corredor	CHAR(50); 
DEFINE v_documento   		CHAR(20);
DEFINE v_vig_ini			DATE;
DEFINE v_vig_fin			DATE;
DEFINE v_prima_neta			DEC(16,2);
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
define _cantidad			integer;
define a_cod_cliente        char(10);
define _cod_asegurado       char(10);
define _leasing             smallint;

--SET DEBUG FILE TO "sp_pro67b.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

--SACAR INFORMACION DE LA POLIZA


let v_documento = null;
let v_prima_bruta = null;
let v_impuesto    = null;
let v_prima_neta  = null;
let v_no_unidad   = null;

foreach

	select distinct(t.no_documento)
	  into v_documento
	  from emipomae t, emipoagt e
	 where e.cod_agente  = a_cod_agente
	   and e.no_poliza   = t.no_poliza
	   and t.actualizado = 1

	if v_documento is null then
		exit foreach;
	end if

	let v_no_poliza = sp_sis21(v_documento);

	 SELECT	vigencia_inic,
			vigencia_final,
			saldo,
			estatus_poliza,
			actualizado,
			cod_ramo,
			cod_contratante,
			leasing
	   INTO	v_vig_ini,
			v_vig_fin,
			v_saldo,
			v_estatus_pol,
			v_actualizado,
			v_cod_ramo,
			a_cod_cliente,
			_leasing
	   FROM	emipomae
	  WHERE no_poliza = v_no_poliza;

	if _leasing = 1 then
	  foreach
		select cod_asegurado 
		  into _cod_asegurado
		  from emipouni
		 where no_poliza = v_no_poliza 
		let a_cod_cliente = _cod_asegurado; 
		 exit foreach;
	  end foreach	 
	end if	
	foreach

		 SELECT	prima_neta,
				prima_bruta,
				impuesto,
				no_unidad
		   INTO v_prima_neta,
				v_prima_bruta,
				v_impuesto,
				v_no_unidad
		   FROM	emipouni
		  WHERE no_poliza     = v_no_poliza
		    and cod_asegurado = a_cod_cliente

		exit foreach;

	end foreach

    let v_cod_agente = a_cod_agente;
	if v_prima_bruta is null then
		let v_prima_bruta = 0;
	end if	

	 SELECT	nombre
	   INTO v_nombre_cte
	   FROM	cliclien
	  WHERE cod_cliente = a_cod_cliente;

	SELECT nombre
	  INTO v_nombre_corredor
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;

	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = v_cod_ramo;

   	 Let v_saldo = sp_cob115b("001", "001", v_documento, ""); 

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
			v_nombre_cte,
			""
			WITH RESUME;
END FOREACH

END PROCEDURE;