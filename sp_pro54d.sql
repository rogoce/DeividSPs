-- sp_pro54d Calculo de -Descuentos+Recargos+Impuestos=Total
-- Creado    : 20/07/2016 - Autor: Henry Giron
-- Modificado: 20/07/2016 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro54d;
CREATE PROCEDURE "informix".sp_pro54d(a_poliza CHAR(10), a_unidad CHAR(5), a_periodo char(7))
RETURNING   Smallint,    
			Smallint,    		
			CHAR(50),
			CHAR(50),
			DEC(16,2),				
			DEC(16,2),		
			CHAR(5),
			CHAR(10);
						

DEFINE _error		  INTEGER;
DEFINE ls_cobertura   CHAR(5);	
DEFINE ls_unidad   	  CHAR(5);	
DEFINE ls_producto    CHAR(5);	
DEFINE ls_ramo        CHAR(3);

DEFINE ld_factor_vigencia   DECIMAL(9,6);  --10,4
DEFINE ld_prima             DECIMAL(16,2);
DEFINE ld_prima_resta		DECIMAL(16,2);
DEFINE ld_prima_anual		DECIMAL(16,2);
DEFINE ld_prima_new     	DECIMAL(16,2);
DEFINE ld_descuento			DECIMAL(16,2);
DEFINE ld_recargo			DECIMAL(16,2);
DEFINE ld_recargo_dep		DECIMAL(16,2);
DEFINE ld_prima_neta		DECIMAL(16,2);
DEFINE ld_prima_dep         DECIMAL(16,2);
DEFINE ld_prima_aux      	DECIMAL(16,2);
DEFINE _descuento_mod       DECIMAL(16,2);

DEFINE li_acepta_desc    	INTEGER;
DEFINE li_tipo_ramo			SMALLINT;
define _linea_rapida        smallint;
DEFINE _descuento_max		DECIMAL(5,2);
DEFINE _tipo_descuento      SMALLINT;

DEFINE _desc_cob 			DECIMAL(16,2);
DEFINE _nueva_renov         CHAR(1);
DEFINE _tipo_auto           SMALLINT;
DEFINE _desc_porc           DECIMAL(7,4);
DEFINE _descuento_feria     DECIMAL(5,2);
define _no_documento        CHAR(20);
DEFINE ld_impuesto			DECIMAL(16,2);
define v_factor_imp         DECIMAL(5,2);
define v_nombre_imp         CHAR(20);
define  _orden1          Smallint;
define  _orden2           Smallint;   		
define  _titulo           CHAR(50);
define  _nombre           CHAR(50);
define  _factor		     DEC(16,2);				
define  _monto		     DEC(16,2);		
define  _unidad        	 CHAR(5);
define  _poliza      	 CHAR(10);

define _restar_imp       	dec(16,2);
define _porc_impuesto       dec(5,2);
       
drop table if exists tmp_datos;	   
-- Crear la tabla
CREATE TEMP TABLE tmp_datos(
		orden1           Smallint,    
		orden2           Smallint,    		
		titulo           CHAR(50),
		nombre           CHAR(50),
		factor		     DEC(16,2),				
		monto		     DEC(16,2),		
		unidad        	 CHAR(5),
		poliza      	 CHAR(10)
		) WITH NO LOG;   
		
BEGIN

--ON EXCEPTION SET _error 
 	--RETURN _error;         
--END EXCEPTION

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_proe01.trc";      
--TRACE ON;                                                                     

let ld_factor_vigencia = 1.000000;
let _linea_rapida      = 0;
let ld_impuesto      = 0;
let ld_prima      = 0;
let ld_descuento = 0.00;
let ld_recargo = 0.00;
let _porc_impuesto = 0.00;
let _restar_imp = 0.00; 

SELECT factor_vigencia, cod_ramo,linea_rapida, nueva_renov, no_documento
  INTO ld_factor_vigencia, ls_ramo,_linea_rapida, _nueva_renov, _no_documento
  FROM emipomae 
 WHERE no_poliza = a_poliza;

Select prdramo.ramo_sis 
  Into li_tipo_ramo
  From prdramo
 Where prdramo.cod_ramo = ls_ramo;

SELECT cod_producto,prima  
  INTO ls_producto,ld_prima_new 
  FROM emicartasal2
 WHERE periodo = a_periodo
   AND no_documento = _no_documento;
   
   
	 -- Restar impuesto	--01/08/2016 Henry, solicitud de MVILLARR
	select sum(factor_impuesto)
	  into _porc_impuesto
	  from emipolim p, prdimpue i
	 where p.cod_impuesto = i.cod_impuesto
	   and p.no_poliza    = a_poliza;

	if _porc_impuesto is null then
		let _porc_impuesto = 0;
	end if

	let _restar_imp =  (ld_prima_new - ( ld_prima_new / (1+(_porc_impuesto / 100))  ) ); 
	let ld_prima_new = ld_prima_new - _restar_imp ;   
   --
   
	INSERT INTO tmp_datos(
		orden1,    
		orden2,    		
		titulo,
		nombre,
		factor,				
		monto,		
		unidad,
		poliza
		)
		VALUES(
		1,
		1,
		"",
		"SUBTOTAL DE PRIMAS:",
		1,
		ld_prima_new,
		a_unidad,
		a_poliza
		);   
		
let ld_prima_anual = ld_prima_new;		


FOREACH
 SELECT emipocob.cod_cobertura            
   INTO ls_cobertura            
   FROM emipocob
  WHERE emipocob.no_poliza = a_poliza
	AND emipocob.no_unidad = a_unidad
	order by emipocob.orden asc

	LET _descuento_max  = 0;
	LET _tipo_descuento = 0;
	let _descuento_mod  = 0;
				
	SELECT prdcobpd.acepta_desc, descuento_max, tipo_descuento
	  INTO li_acepta_desc, _descuento_max, _tipo_descuento 
	  FROM prdcobpd
	 WHERE prdcobpd.cod_producto  = ls_producto
	   AND prdcobpd.cod_cobertura = ls_cobertura;
			
	IF li_acepta_desc IS NULL THEN
	   LET li_acepta_desc = 0;
	END IF

	let ld_prima_dep = 0;				
	LET ld_prima = ld_factor_vigencia * ld_prima_anual;		
	LET ld_prima_resta = ld_prima - ld_prima_dep; --> Amado 17/11/2010
			
	-- Buscar Descuento
	LET ld_descuento = 0.00;
	LET _desc_porc = 0;
	LET _desc_cob = 0;
	let _descuento_feria = 0;
	LET ld_prima_aux = ld_prima;

	If li_acepta_desc = 1 Then
	   if _tipo_descuento = 1 and _nueva_renov = 'N' then	--> Descuento RC, solo polizas nuevas
			let _tipo_auto = 0;
			let _tipo_auto = sp_proe75(a_poliza,a_unidad);
			if _tipo_auto = 0 then
				let _descuento_max = 0;
			end if 
			let _desc_porc   = _descuento_max / 100;
			let _desc_cob    = ld_prima * _desc_porc;
			let ld_prima_aux = ld_prima - _desc_cob;
	   elif _tipo_descuento = 2 and _nueva_renov = 'N' then --> Descuento Combinado Casco, solo polizas nuevas
			let _descuento_max = sp_proe72(a_poliza,a_unidad);
			let _descuento_mod = sp_proe80(a_poliza,a_unidad);
			let _descuento_feria = sp_proe82(a_poliza,a_unidad); -- MotorShow2015
			let _descuento_mod = _descuento_mod + _descuento_feria; 
			let _descuento_max = _descuento_max + _descuento_mod;
			let _desc_porc   = _descuento_max / 100;
			let _desc_cob    = ld_prima * _desc_porc;
			let ld_prima_aux = ld_prima - _desc_cob;
	   elif _tipo_descuento IN (1, 2) and _nueva_renov = 'R' THEN --> Descuento para las renovaciones
			let _descuento_max = sp_proe74(a_poliza, a_unidad, ls_producto, ls_cobertura); 
			let _desc_porc   = _descuento_max / 100;
			let _desc_cob    = ld_prima * _desc_porc;
			let ld_prima_aux = ld_prima - _desc_cob;
	   end if		   
	   -- Buscar Descuento
	   CALL sp_proe21(a_poliza, a_unidad, ld_prima_aux) RETURNING ld_descuento;
	   LET ld_descuento = ld_descuento + _desc_cob;

	End If

	If ld_descuento > 0 Then
	   LET ld_prima_resta = ld_prima - ld_prima_dep - ld_descuento; 
	End If
	
	if ld_descuento > 0 then
		INSERT INTO tmp_datos(
		orden1,    
		orden2,    		
		titulo,
		nombre,
		factor,				
		monto,		
		unidad,
		poliza
		)
		VALUES(
		2,
		1,
		"DESCUENTOS",
		"",
		1,
		ld_descuento,
		a_unidad,
		a_poliza
		);   
	end if
	

	-- Buscar Recargo
	LET ld_recargo = 0.00;
	If li_acepta_desc = 1 Then
	   CALL sp_proe22(a_poliza, a_unidad, ld_prima_resta) RETURNING ld_recargo;
	End If

	-- Buscar Recargo por dependiente
	If li_acepta_desc = 1 Then
		LET ld_recargo_dep = 0.00;
		IF ld_prima_anual <> 0.00 THEN
			CALL sp_proe53(a_poliza, a_unidad) RETURNING ld_recargo_dep;
			LET ld_recargo = ld_recargo + ld_recargo_dep;
		END IF
	end if
	
	
	if ld_recargo > 0 then
			INSERT INTO tmp_datos(
		orden1,    
		orden2,    		
		titulo,
		nombre,
		factor,				
		monto,		
		unidad,
		poliza
		)
		VALUES(
		3,
		1,
		"RECARGOS",
		"",
		1,
		ld_recargo,
		a_unidad,
		a_poliza
		);   
	end if
	-- Calcular Prima Neta
	LET ld_prima_neta = ld_prima + ld_recargo - ld_descuento;	
		--let ld_prima_anual = 0.00;	 
END FOREACH

	FOREACH
			SELECT prdimpue.nombre,
			 prdimpue.factor_impuesto
		INTO v_nombre_imp,
			 v_factor_imp
		FROM prdimpue,
			 emipolim,
			 emipouni
	   WHERE ( emipolim.cod_impuesto = prdimpue.cod_impuesto ) and
			 ( emipolim.no_poliza = emipouni.no_poliza ) and
			 ( ( emipouni.no_poliza = a_poliza ) AND
			 ( emipouni.no_unidad = a_unidad ) )			 
			 
			--let _porc_imp   = v_factor_imp / 100;
			--let _suma_imp   = ld_prima_neta * _porc_imp;
			let ld_impuesto = ld_impuesto + (v_factor_imp/100 * ld_prima_neta);			 

		if ld_impuesto > 0 then	 
			INSERT INTO tmp_datos(
			orden1,    
			orden2,    		
			titulo,
			nombre,
			factor,				
			monto,		
			unidad,
			poliza
			)
			VALUES(
			4,
			1,
			"IMPUESTOS",
			v_nombre_imp,
			v_factor_imp,
			ld_impuesto,
			a_unidad,
			a_poliza
			); 
		end if	
	END FOREACH		
		
	-- Calcular Prima Neta
	LET ld_prima_neta = ld_prima + ld_recargo - ld_descuento + ld_impuesto;		
	if ld_prima_neta > 0 then
	
		INSERT INTO tmp_datos(
			orden1,    
			orden2,    		
			titulo,
			nombre,
			factor,				
			monto,		
			unidad,
			poliza
			)
			VALUES(
			5,
			1,
"",			
			"T O T A L  A  P A G A R :",
			
			1,
			ld_prima_neta,
			a_unidad,
			a_poliza
			); 	
	end if

FOREACH
	  SELECT orden1,	
			  orden2,
			  titulo,
			  nombre,
			  factor,
			  monto,
			  unidad,
			  poliza
		INTO _orden1,	
			_orden2,
			_titulo,
			_nombre,
			_factor,
			_monto,
			_unidad,
			_poliza
		FROM tmp_datos

	   
	RETURN _orden1,	
			_orden2,
			_titulo,
			_nombre,
			_factor,
			_monto,
			_unidad,
			_poliza
		   WITH RESUME;   	

END FOREACH

END
drop table if exists tmp_datos;	   
END PROCEDURE;

