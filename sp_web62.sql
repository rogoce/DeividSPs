-- Consulta de Clientes Global

-- Creado    : 14/06/2001 - Autor: Armando Moreno M.
-- Modificado: 14/06/2001 - Autor: Armando Moreno M.
-- Copia:      sp_pro67aa federico Coronado
-- SIS v.2.0 - d_prod_sp_prd67_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_web62;

CREATE PROCEDURE sp_web62(a_cod_cliente CHAR(10))
RETURNING CHAR(50)	 	 as ramo,  				-- Ramo
		  CHAR(20)	 	 as no_documento, 			-- no_documento
		  integer       as estado, 				-- estado
		  char(100)     as asegurado, 		 	-- contratante
		  char(100)     as contratante, 		-- pagador
		  date			 as vigencia_inic, 		-- vigencia Inicial
		  date			 as vigencia_final, 		-- vigencia Inicial
		  DEC(16,2) 	 as saldo, 				-- SALDO
		  date	         as f_aviso, 			-- fecha_aviso
		  integer	     as nopagos, 			-- no pagos
		  CHAR(50)	     as formapago, 			-- forma de pago,
		  dec(16,2)     as exigible,
		  DEC(16,2)     as primabruta,			-- Prima Bruta
		  char(50)      as subramo,
		  char(3)		as cod_ramo,
		  integer       as leasing,
		  char(10)      as cod_pagador,				-- Nombre subramo
		  char(3)       as cod_subramo;

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
DEFINE v_nombre_subramo		CHAR(50);					 
DEFINE v_cod_ramo			CHAR(3);
DEFINE v_cod_subramo		CHAR(3);					 
DEFINE v_nombre_cte			CHAR(100);	
DEFINE v_nombre_pagador		CHAR(100);				 
define _cantidad			integer;					 
define _monto           	DEC(16,2);
define _li_cnt              smallint;	
define v_fecha_aviso_canc   date;	
define v_nopagos            integer;
define v_formapago          char(3);
define _subramo             char(3);
define v_cod_pagador        char(10);
define v_nombre_formapag    char(50);
define _suma_asegurada		DEC(16,2);
define _nombre_producto		varchar(50);
define _nombre_marca		varchar(50);
define _nombre_modelo		varchar(50);
define _ano_auto			integer;
define _placa	 			varchar(10);
define _fecha_hoy			date;
define _periodo             char(7);
DEFINE v_por_vencer        DEC(16,2);
DEFINE v_exigible          DEC(16,2);
DEFINE v_corriente         DEC(16,2);
DEFINE v_monto_30          DEC(16,2);
DEFINE v_monto_60          DEC(16,2);
DEFINE v_monto_90          DEC(16,2);
define v_leasing           integer;
define v_fecha_tope        date;

													 
--SET DEBUG FILE TO "sp_web62.trc"; 					 
--trace on;
												 

CREATE TEMP TABLE tmp_busq(
	no_documento	CHAR(20),
	no_unidad		CHAR(5),
	vig_ini         date,
	vig_fin         date,
	prima_bruta     dec(16,2),
	saldo		    dec(16,2),
	estatus_pol     smallint,
	nombre_pagador  char(50),
	nombre_ramo     char(50),
	nombre_cte      char(100),
	exigible        dec(16,2),
	nombre_subramo  char(50),
	no_poliza       char(10),
	cod_ramo        char(3),
	fecha_aviso     date,
	no_pagos        integer,
	forma_pago      char(50),
	leasing         integer,
	cod_pagador     char(10),
	PRIMARY KEY		(no_poliza)
	) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

--SACAR INFORMACION DE LA POLIZA

 SELECT	nombre
   INTO v_nombre_cte
   FROM	cliclien
  WHERE cod_cliente = a_cod_cliente;

let v_documento 		= null;
let v_exigible			= 0;
let v_fecha_aviso_canc 	= "";
let _subramo 			= "";
let v_nopagos 			= 0;
let v_formapago 		= "";
let v_nombre_pagador 	= '';
let v_nombre_corredor 	= "";
let _fecha_hoy			= current;
let _periodo			= sp_sis39(_fecha_hoy);
let v_fecha_tope        = today - 365 units day;


if v_documento is null then
-- Contratante
foreach

	SELECT distinct(no_documento)
	  INTO v_documento
	  FROM emipomae
	 WHERE cod_contratante = a_cod_cliente
	   and actualizado     = 1
	   and vigencia_final >= v_fecha_tope

	if v_documento is null then
		exit foreach;
	end if

	let v_no_poliza = sp_sis21(v_documento);

	 SELECT	no_documento,
	 		vigencia_inic,
			vigencia_final,
			saldo,
			estatus_poliza,
			fecha_aviso_canc,
			cod_ramo,
			prima_neta,
			prima_bruta,
			impuesto,
			cod_pagador,
			cod_subramo,
			no_pagos,
			cod_formapag,
			leasing
	   INTO v_documento,
	   		v_vig_ini,
			v_vig_fin,
			v_saldo,
			v_estatus_pol,
			v_fecha_aviso_canc,
			v_cod_ramo,
			v_prima_neta,
			v_prima_bruta,
			v_impuesto,
			v_cod_pagador,
			_subramo,
			v_nopagos,
			v_formapago,
			v_leasing
	   FROM	emipomae
	  WHERE no_poliza = v_no_poliza;

	 SELECT	nombre
	   INTO v_nombre_pagador
	   FROM	cliclien
	  WHERE cod_cliente = v_cod_pagador;

	SELECT nombre
	  INTO v_nombre_subramo
	  FROM prdsubra
	 WHERE cod_ramo = v_cod_ramo
	   and cod_subramo = _subramo;

	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = v_cod_ramo;

	select nombre 
	  into v_nombre_formapag
	  from cobforpa 
	 where cod_formapag = v_formapago;

	  call sp_cob33('001','001',v_documento,_periodo,_fecha_hoy) returning v_por_vencer, v_exigible, v_corriente,  v_monto_30,  v_monto_60, v_monto_90, v_saldo; 

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
	prima_bruta,    
	saldo,		   
	estatus_pol,    
	nombre_pagador,
	nombre_ramo,    
	nombre_cte,     
	exigible,
    nombre_subramo,	
	no_poliza,
	cod_ramo,
	fecha_aviso,
	no_pagos,
	forma_pago,
	leasing,
	cod_pagador)
	VALUES (
	v_documento,
	"",		 
	v_vig_ini,
	v_vig_fin,     
	v_prima_bruta,
	v_saldo,
	v_estatus_pol,
	v_nombre_pagador,
	v_nombre_ramo,
	v_nombre_cte,
	v_exigible,
	v_nombre_subramo,
	v_no_poliza,
	v_cod_ramo,
	v_fecha_aviso_canc,
	v_nopagos,
	v_nombre_formapag,
	v_leasing,
	v_cod_pagador);

end foreach
-- Asegurado Principal
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
		and activo = 1
		and t.vigencia_final >= v_fecha_tope

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
			v_fecha_aviso_canc,
			cod_ramo,
			no_documento,
			cod_pagador,
			cod_subramo,
			no_pagos,
			cod_formapag,
			leasing
	   INTO	v_vig_ini,
			v_vig_fin,
			v_saldo,
			v_estatus_pol,
			v_fecha_aviso_canc,
			v_cod_ramo,
			v_documento,
			v_cod_pagador,
			_subramo,
			v_nopagos,
			v_formapago,
			v_leasing
	   FROM	emipomae
	  WHERE no_poliza = v_no_poliza;

	 SELECT	nombre
	   INTO v_nombre_pagador
	   FROM	cliclien
	  WHERE cod_cliente = v_cod_pagador;

	SELECT nombre
	  INTO v_nombre_subramo
	  FROM prdsubra
	 WHERE cod_ramo = v_cod_ramo
	   and cod_subramo = _subramo;

	SELECT nombre
	  INTO v_nombre_ramo
	  FROM prdramo
	 WHERE cod_ramo = v_cod_ramo;
	 
	 select nombre 
	  into v_nombre_formapag
	  from cobforpa 
	 where cod_formapag = v_formapago;

	 call sp_cob33('001','001',v_documento,_periodo,_fecha_hoy) returning v_por_vencer, v_exigible, v_corriente,  v_monto_30,  v_monto_60, v_monto_90, v_saldo; 

	INSERT INTO tmp_busq(
	no_documento,	
	no_unidad,		
	vig_ini,        
	vig_fin,              
	prima_bruta,    
	saldo,		   
	estatus_pol,    
	nombre_pagador,
	nombre_ramo,    
	nombre_cte,     
	exigible,
    nombre_subramo,	
	no_poliza,
	cod_ramo,
	fecha_aviso,
	no_pagos,
	forma_pago,
	leasing,
	cod_pagador)
	VALUES (
	v_documento,
	v_no_unidad,		 
	v_vig_ini,
	v_vig_fin,     
	v_prima_bruta,
	v_saldo,
	v_estatus_pol,
	v_nombre_pagador,
	v_nombre_ramo,
	v_nombre_cte,
	v_exigible,
	v_nombre_subramo,
	v_no_poliza,
	v_cod_ramo,
	v_fecha_aviso_canc,
	v_nopagos,
	v_nombre_formapag,
	v_leasing,
	v_cod_pagador);

end foreach

foreach
	select no_documento
	  into v_documento
	  from tmp_busq
	  group by no_documento
	  order by no_documento

	let v_no_poliza = sp_sis21(v_documento);

   foreach
	select no_documento,	
		   no_unidad,		
		   vig_ini,        
		   vig_fin,             
		   prima_bruta,    
		   saldo,
		   estatus_pol,
		   nombre_pagador,
		   nombre_ramo,    
		   nombre_cte,     
		   exigible,
		   nombre_subramo,
		   no_poliza, 
		   cod_ramo,
		   fecha_aviso,
		   no_pagos,
		   forma_pago,
		   leasing,
		   cod_pagador
	  into v_documento,
		   v_no_unidad,		 
		   v_vig_ini,
		   v_vig_fin,     
		   v_prima_bruta,
		   v_saldo,
		   v_estatus_pol,
		   v_nombre_pagador,
		   v_nombre_ramo,
		   v_nombre_cte,
		   v_exigible,
		   v_nombre_subramo,
		   v_no_poliza,
		   v_cod_ramo,
		   v_fecha_aviso_canc,
		   v_nopagos,
		   v_nombre_formapag,
		   v_leasing,
		   v_cod_pagador
      from tmp_busq
	 where no_poliza = v_no_poliza 
	 
	 select cod_subramo
	   into _subramo
	   from emipomae
	  where no_poliza = v_no_poliza;
	 

	RETURN  v_nombre_ramo,
			v_documento,
			v_estatus_pol,				
			v_nombre_cte,
			v_nombre_pagador,     
			v_vig_ini, 
			v_vig_fin,
			v_saldo,
			v_fecha_aviso_canc,
			v_nopagos,
			v_nombre_formapag,
			v_exigible,
			v_prima_bruta,
			v_nombre_subramo,
			v_cod_ramo,
			v_leasing,
			v_cod_pagador,
			_subramo
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
				fecha_aviso_canc,
				cod_ramo,
				actualizado,
				cod_subramo,
			    no_pagos,
			    cod_formapag,
				leasing,
				cod_pagador
		   INTO	v_documento,
		   		v_vig_ini,
				v_vig_fin,
				v_saldo,
				v_estatus_pol,
				v_fecha_aviso_canc,
				v_cod_ramo,
				v_actualizado,
				_subramo,
				v_nopagos,
				v_formapago,
				v_leasing,
				v_cod_pagador
		   FROM	emipomae
		  WHERE no_poliza = v_no_poliza
		    and vigencia_final >= v_fecha_tope;

		  IF v_actualizado IS NULL THEN
			LET v_actualizado = 0;
		  END IF

		  IF v_actualizado <> 1 THEN
			CONTINUE FOREACH;
		  END IF

		 SELECT	nombre
		   INTO v_nombre_pagador
		   FROM	cliclien
		  WHERE cod_cliente = v_cod_pagador;

		SELECT nombre
		  INTO v_nombre_subramo
		  FROM prdsubra
		 WHERE cod_ramo = v_cod_ramo
		   and cod_subramo = _subramo;

		SELECT nombre
		  INTO v_nombre_ramo
		  FROM prdramo
		 WHERE cod_ramo = v_cod_ramo;
		 
		select nombre 
		  into v_nombre_formapag
		  from cobforpa 
		 where cod_formapag = v_formapago;

		call sp_cob33('001','001',v_documento,_periodo,_fecha_hoy) returning v_por_vencer, v_exigible, v_corriente,  v_monto_30,  v_monto_60, v_monto_90, v_saldo; 

		RETURN  v_nombre_ramo,
				v_documento,
				v_estatus_pol,				
				v_nombre_cte,
				v_nombre_pagador,     
				v_vig_ini, 
				v_vig_fin,
				v_saldo,
				v_fecha_aviso_canc,
				v_nopagos,
				v_nombre_formapag,
				v_exigible,
				v_prima_bruta,
				v_nombre_subramo,
				v_cod_ramo,
				v_leasing,
				v_cod_pagador,
				_subramo
				WITH RESUME;
	END FOREACH

end if
end if

DROP TABLE tmp_busq;

END PROCEDURE;