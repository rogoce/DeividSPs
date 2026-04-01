-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_pro67aa;

CREATE PROCEDURE sp_pro67aa(a_cod_cliente CHAR(10))
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
		  char(15), -- NOMBRE CTE
		  DEC(16,2),
		  char(10);

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
define _monto           	DEC(16,2);
define _li_cnt              smallint;					 
														 
--SET DEBUG FILE TO "sp_pro67.trc"; 					 
--trace on;												 

CREATE TEMP TABLE tmp_busq(
	no_documento	CHAR(20),
	no_unidad		CHAR(5),
	vig_ini         date,
	vig_fin         date,
	prima_neta      dec(16,2),
	impuesto        dec(16,2),
	prima_bruta     dec(16,2),
	saldo		    dec(16,2),
	estatus_pol     smallint,
	nombre_corredor char(50),
	nombre_ramo     char(50),
	nombre_cte      char(100),
	monto           dec(16,2),
	no_poliza       char(10),
	PRIMARY KEY		(no_poliza)
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

--SACAR INFORMACION DE LA POLIZA

 SELECT	nombre
   INTO v_nombre_cte
   FROM	cliclien
  WHERE cod_cliente = a_cod_cliente;

let v_documento = null;
let _monto = 0;

if v_documento is null then

foreach

	SELECT distinct(no_documento)
	  INTO v_documento
	  FROM emipomae
	 WHERE cod_contratante = a_cod_cliente
	   and actualizado     = 1

	if v_documento is null then
		exit foreach;
	end if

	let v_no_poliza = sp_sis21(v_documento);

	 SELECT	no_documento,
	 		vigencia_inic,
			vigencia_final,
			saldo,
			estatus_poliza,
			actualizado,
			cod_ramo,
			prima_neta,
			prima_bruta,
			impuesto
	   INTO v_documento,
	   		v_vig_ini,
			v_vig_fin,
			v_saldo,
			v_estatus_pol,
			v_actualizado,
			v_cod_ramo,
			v_prima_neta,
			v_prima_bruta,
			v_impuesto
	   FROM	emipomae
	  WHERE no_poliza = v_no_poliza;

	FOREACH
		 SELECT	cod_agente
		   INTO	v_cod_agente
		   FROM	emipoagt
		  WHERE no_poliza = v_no_poliza
		  EXIT FOREACH;
	END FOREACH

	SELECT nombre
	  INTO v_nombre_corredor
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;

	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = v_cod_ramo;

	 Let v_saldo = sp_cob115b("001", "001", v_documento, "");

	select count(*)
	  into _li_cnt
	  from tmp_busq
	 where no_poliza = v_no_poliza;

	if _li_cnt > 0 then
		continue foreach;
	end if

	INSERT INTO tmp_busq(
	no_documento,	
	no_unidad,		
	vig_ini,        
	vig_fin,        
	prima_neta,     
	impuesto,       
	prima_bruta,    
	saldo,		   
	estatus_pol,    
	nombre_corredor,
	nombre_ramo,    
	nombre_cte,     
	monto,          
	no_poliza)
	VALUES (
	v_documento,
	"",		 
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
	_monto,
	v_no_poliza);

end foreach

foreach

	 SELECT	e.prima_neta,
			e.prima_bruta,
			e.impuesto,
			e.no_unidad,
			e.no_poliza
	   INTO v_prima_neta,
			v_prima_bruta,
			v_impuesto,
			v_no_unidad,
			v_no_poliza
	   FROM	emipouni e, emipomae t
	  WHERE e.no_poliza     = t.no_poliza
	    and e.cod_asegurado = a_cod_cliente
		and t.actualizado   = 1

	select count(*)
	  into _li_cnt
	  from tmp_busq
	 where no_poliza = v_no_poliza;

	if _li_cnt > 0 then
		continue foreach;
	end if

	 SELECT	vigencia_inic,
			vigencia_final,
			saldo,
			estatus_poliza,
			actualizado,
			cod_ramo,
			no_documento
	   INTO	v_vig_ini,
			v_vig_fin,
			v_saldo,
			v_estatus_pol,
			v_actualizado,
			v_cod_ramo,
			v_documento
	   FROM	emipomae
	  WHERE no_poliza = v_no_poliza;

	FOREACH
		 SELECT	cod_agente
		   INTO	v_cod_agente
		   FROM	emipoagt
		  WHERE no_poliza = v_no_poliza
		  EXIT FOREACH;
	END FOREACH

	SELECT nombre
	  INTO v_nombre_corredor
	  FROM agtagent
	 WHERE cod_agente = v_cod_agente;

	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = v_cod_ramo;

	 Let v_saldo = sp_cob115b("001", "001", v_documento, ""); 

	INSERT INTO tmp_busq(
	no_documento,	
	no_unidad,		
	vig_ini,        
	vig_fin,        
	prima_neta,     
	impuesto,       
	prima_bruta,    
	saldo,		   
	estatus_pol,    
	nombre_corredor,
	nombre_ramo,    
	nombre_cte,     
	monto,          
	no_poliza)
	VALUES (
	v_documento,
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
	_monto,
	v_no_poliza);

end foreach

foreach
	select no_documento
	  into v_documento
	  from tmp_busq
	  group by no_documento

	let v_no_poliza = sp_sis21(v_documento);

   foreach
	select no_documento,	
		   no_unidad,		
		   vig_ini,        
		   vig_fin,        
		   prima_neta,     
		   impuesto,       
		   prima_bruta,    
		   saldo,
		   estatus_pol,
		   nombre_corredor,
		   nombre_ramo,    
		   nombre_cte,     
		   monto,          
		   no_poliza
	  into v_documento,
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
		   _monto,
		   v_no_poliza
      from tmp_busq
	 where no_poliza = v_no_poliza
	 
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
			"",
			_monto,
			v_no_poliza
			WITH RESUME;
   end foreach
END FOREACH

end if

--si no encuentra es que es dependiente buscar la poliza
if v_documento is null then

 SELECT	count(*)
   INTO	_cantidad
   FROM	emidepen
  WHERE cod_cliente = a_cod_cliente;

if _cantidad > 0 then
		
	foreach

		 SELECT	no_unidad,
				no_poliza
		   INTO	v_no_unidad,
				v_no_poliza
		   FROM	emidepen
		  WHERE cod_cliente = a_cod_cliente
		
		exit foreach;
	end foreach

	 SELECT	cod_asegurado
	   INTO _cod_ase
	   FROM	emipouni
	  WHERE no_poliza = v_no_poliza
	    and no_unidad = v_no_unidad;

	FOREACH
		 SELECT	prima_neta,
				prima_bruta,
				impuesto,
				no_unidad,
				no_poliza
		   INTO v_prima_neta,
				v_prima_bruta,
				v_impuesto,
				v_no_unidad,
				v_no_poliza
		   FROM	emipouni
		  WHERE cod_asegurado = _cod_ase
		    and no_poliza     = v_no_poliza

		 IF v_no_poliza IS NULL	THEN	 --SI NO ENCUENTRA REGISTROS EN emipouni *AMADO 18/06/2002*
		 	SELECT no_poliza
		 	  INTO v_no_poliza
			  FROM emipomae
		 	 WHERE cod_contratante = a_cod_cliente;
		 END IF	     

		 SELECT	no_documento,
		 		vigencia_inic,
				vigencia_final,
				saldo,
				estatus_poliza,
				actualizado,
				cod_ramo
		   INTO	v_documento,
		   		v_vig_ini,
				v_vig_fin,
				v_saldo,
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
		  INTO v_nombre_corredor
		  FROM	agtagent
		 WHERE cod_agente = v_cod_agente;

		SELECT	nombre
		  INTO	v_nombre_ramo
		  FROM	prdramo
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
				"DEPENDIENTE",
				_monto,
				v_no_poliza
				WITH RESUME;
	END FOREACH

end if
end if

DROP TABLE tmp_busq;

END PROCEDURE;