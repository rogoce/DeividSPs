-- Impuestos cobrados-- 
-- Creado    : 04/12/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 04/12/2000 - Autor: Lic. Armando Moreno
-- Modificado: 10/04/2003 - Autor: Lic. Armando Moreno que tome en cuenta coas minoritario
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_cob38xxx_sac;
CREATE PROCEDURE "informix".sp_cob38xxx_sac(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7),a_ramo CHAR(255) DEFAULT "*")
		RETURNING CHAR(10),
				  CHAR(30),
		          CHAR(100), 
				  DATE,
		          DECIMAL(16,2),
		          DECIMAL(16,2),
		          DECIMAL(16,2),
		          DECIMAL(16,2),
		          CHAR(50),
		          CHAR(50),
		          CHAR(255),
		          dec(16,2),
		          char(1),
char(15),integer,dec(16,2),dec(16,2);				  

DEFINE v_nombre_ramo   	  CHAR(50);
DEFINE v_cod_tipoprod 	  CHAR(3);
DEFINE v_nombre_cliente   CHAR(100);
DEFINE v_imp_1			  DECIMAL(16,2);
DEFINE _factor_imp		  DECIMAL(16,2);
DEFINE v_imp_5			  DECIMAL(16,2);
DEFINE v_impuesto		  DECIMAL(16,2);
DEFINE v_prima_neta 	  DECIMAL(16,2);
DEFINE v_monto	 		  DECIMAL(16,2);
DEFINE v_compania_nombre  CHAR(50);
DEFINE v_filtros          CHAR(255);
DEFINE v_cod_contratante  CHAR(10);
DEFINE v_no_documento     CHAR(30);
DEFINE v_no_recibo        CHAR(10);
DEFINE v_fecha		      DATE;
DEFINE v_no_poliza		  CHAR(10);
DEFINE v_codramo		  CHAR(3);
DEFINE v_cod_impuesto	  CHAR(3);
DEFINE _ramo_sis,v_tipo_produccion SMALLINT;
define _remesa			  CHAR(10);
define _nombre 		      CHAR(50);

-- Para el nuevo proceso
define _porc_partic_coas    decimal(7,4);
define _cod_lider			char(3);

define _no_requis			char(10);
define _fecha_desde			date;
define _fecha_hasta			date;
define _factor_impuesto	 	dec(5,2);
define _cod_origen		 	char(3);
define _aplica_impuesto  	smallint;
define _imp_gob          	smallint;
define _imp_2			  	dec(16,2);
define _tipo				char(1);
define _tipo_mov			char(1);

define _comprobante         char(15);
define _sac_notrx           integer;
define _tecnico             dec(16,2);
define _mayor               dec(16,2);

	
let _comprobante = '';
let _sac_notrx = 0;
let _tecnico = 0;
let _mayor = 0;

set isolation to dirty read;

--DROP TABLE tmp_prod;

CREATE TEMP TABLE tmp_prod(
no_recibo   	CHAR(10)  NOT NULL,
cod_ramo       	CHAR(3)   ,
no_documento   	CHAR(20)  NOT NULL,
cod_contratante CHAR(10)  ,
fecha		 	DATE   	  NOT NULL,
prima_neta      DECIMAL(16,2),
imp1		    DECIMAL(16,2),
imp5		    DECIMAL(16,2),
monto	        DECIMAL(16,2),
seleccionado   	SMALLINT  DEFAULT 1 NOT NULL,
imp2		    DECIMAL(16,2),
nombre_ramo		char(50),
tipo			char(1),
comprobante char(15),
sac_notrx       integer,
tecnico         DECIMAL(16,2),
mayor  		    DECIMAL(16,2),
remesa          CHAR(10),
nombre          CHAR(50)
) WITH NO LOG;

--CREATE INDEX iend1_tmp_prod ON tmp_prod(cod_ramo);

select par_ase_lider
  into _cod_lider
  from parparam
 where cod_compania = a_compania;

-- Nombre de la Compania

lET v_compania_nombre = sp_sis01(a_compania);

--{
FOREACH
 SELECT no_poliza,
	    no_recibo,
	    doc_remesa,
	    fecha,
	    prima_neta,
	    impuesto,
	    monto,
		tipo_mov
   INTO v_no_poliza,
  	    v_no_recibo,
  	    v_no_documento,
  	    v_fecha,
  	    v_prima_neta,
  	    v_impuesto,
  	    v_monto,
		_tipo_mov
   FROM cobredet
  WHERE cod_compania  = a_compania
    AND actualizado  = 1
    AND tipo_mov     IN ("P","N")
  	and periodo      >= a_periodo1 
    and periodo      <= a_periodo2
	and monto        <> 0
--    and doc_remesa   = "0200-01260-01"
--    AND renglon     <> 0

	if _tipo_mov = "P" then
		let _tipo = "R";
	else
		let _tipo = "N";
	end if

    SELECT cod_contratante,
    	   cod_ramo,
    	   cod_tipoprod,
		   cod_origen
	  INTO v_cod_contratante,
	  	   v_codramo,
	  	   v_cod_tipoprod,
		   _cod_origen
	  FROM emipomae
	 WHERE no_poliza = v_no_poliza;

    SELECT tipo_produccion
	  INTO v_tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = v_cod_tipoprod;

	 IF v_tipo_produccion = 4 THEN
		 CONTINUE FOREACH;
	 END IF

	select aplica_impuesto
	  into _aplica_impuesto
	  from parorig
	 where cod_origen = _cod_origen;

	select imp_gob,
	       nombre
	  into _imp_gob,
	       v_nombre_ramo
	  from prdramo
	 where cod_ramo = v_codramo;

	 if v_tipo_produccion = 2 THEN

		select porc_partic_coas
		  into _porc_partic_coas
		  from emicoama
		 where no_poliza    = v_no_poliza
		   and cod_coasegur = _cod_lider;
		
		if _porc_partic_coas is null then
			let _porc_partic_coas = 100;
		end if

		let v_prima_neta = v_prima_neta * _porc_partic_coas / 100;

	end if

	-- BUSCAR LOS IMPUESTOS Y EFECTUAR OPERACION

	LET v_imp_1 = 0;
	LET v_imp_5 = 0;

    FOREACH
	    SELECT cod_impuesto
		  INTO v_cod_impuesto
		  FROM emipolim
		 WHERE no_poliza = v_no_poliza

	    SELECT factor_impuesto
		  INTO _factor_imp
		  FROM prdimpue
		 WHERE cod_impuesto = v_cod_impuesto;

		 IF _factor_imp = 1.00 THEN
		 	LET v_imp_1 = v_prima_neta * _factor_imp / 100;
		 ELIF _factor_imp = 5.00 THEN
		 	LET v_imp_5 = v_prima_neta * _factor_imp / 100;
		 END IF
	END FOREACH

	let _imp_2 = 0.00;

	If _aplica_impuesto = 1 Then -- Verifica si a la Poliza se le Aplican los Impuestos (Exterior No Llevan) 

		If _imp_gob = 1 Then -- Verifica si al Ramo se le Aplican los Impuestos

			foreach
			 select factor
			   into _factor_impuesto
			   from parimpgo

				let _imp_2 = _imp_2 + (v_prima_neta * _factor_impuesto / 100);
				
			end foreach

		end if

	end if
	
	let _comprobante = '';
	let _sac_notrx = 0;
	let _tecnico = 0;
	let _mayor = 0;
	let _remesa = '';
	let _nombre = '';
	
	foreach
    select sac_notrx,sum(debito-credito) 	
	into _sac_notrx,_tecnico
	from cobasien c, cobredet r
	where c.no_remesa = r.no_remesa
	and r.doc_remesa = v_no_documento
	and c.renglon = r.renglon
	and r.no_recibo = v_no_recibo
	and c.cuenta = '26504'	        
	group by 1
	exit foreach;
	
	end foreach	
	
	foreach
	select res_comprobante,sum(res_debito-res_credito) 
	into _comprobante,_mayor
	from cglresumen
	where res_fechatrx = v_fecha
	and res_cuenta = '26504'
	and res_notrx = _sac_notrx
	group by 1
	exit foreach;
	
	end foreach
	
	if _tecnico is null then
		let _tecnico = 0;
	end if
	if _mayor is null then
		let _mayor = 0;
	end if	
	
    foreach
	select no_remesa
	into _remesa
	from cobredet 
	where doc_remesa = v_no_documento
	and no_recibo = v_no_recibo
	exit foreach;	
	end foreach	
    foreach
	select trim(recibi_de)
	into _nombre
	from cobremae 
	where no_remesa = _remesa
	exit foreach;	
	end foreach		
			

	INSERT INTO tmp_prod(
	no_recibo,
	cod_ramo,
	no_documento,
 	cod_contratante,
 	fecha,
 	prima_neta,
 	imp1,
 	imp5,
 	monto,
 	seleccionado,
 	imp2,
	nombre_ramo,
	tipo,
	comprobante,
	sac_notrx,
	tecnico,
	mayor,
	remesa,
	nombre	
	)
	VALUES(
	v_no_recibo,
	v_codramo,
	v_no_documento,
	v_cod_contratante,
	v_fecha,
	v_prima_neta,
	v_imp_1,
	v_imp_5,
	v_monto,
	1,
	_imp_2,
	v_nombre_ramo,
	_tipo,
	_comprobante,
	_sac_notrx,
	_tecnico,
	_mayor,
	_remesa,
	_nombre	
	);

END FOREACH;
--}

let _fecha_desde = mdy(a_periodo1[6,7], 1, a_periodo1[1,4]);
let _fecha_hasta = sp_sis36(a_periodo2);

-- Cheques de Devolucion de Primas Pagados

let _tipo = "C";

--{
foreach
 select no_requis,
        no_cheque,
		fecha_impresion
   into _no_requis,
        v_no_recibo,
		v_fecha
   from chqchmae
  where cod_compania    = a_compania
    and pagado          = 1
	and anulado         in (0, 1)
	and origen_cheque   = "6"
    and fecha_impresion >= _fecha_desde
	and fecha_impresion <= _fecha_hasta
--	and no_requis     = "305724"

	foreach
	 select no_documento,
	        no_poliza,
			prima_neta,
			monto
	   into v_no_documento,
	        v_no_poliza,
			v_prima_neta,
			v_monto
	   from chqchpol
	  where no_requis = _no_requis

		let v_prima_neta = v_prima_neta * - 1;
		let v_monto      = v_monto      * - 1;

	    SELECT cod_contratante,
	    	   cod_ramo,
	    	   cod_tipoprod,
			   cod_origen
		  INTO v_cod_contratante,
		  	   v_codramo,
		  	   v_cod_tipoprod,
			   _cod_origen
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

	    SELECT tipo_produccion
		  INTO v_tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = v_cod_tipoprod;

		 IF v_tipo_produccion = 4 THEN
			 CONTINUE FOREACH;
		 END IF

		select aplica_impuesto
		  into _aplica_impuesto
		  from parorig
		 where cod_origen = _cod_origen;

		select imp_gob,
		       nombre
		  into _imp_gob,
		       v_nombre_ramo
		  from prdramo
		 where cod_ramo = v_codramo;

		 IF v_tipo_produccion = 2 THEN

			select porc_partic_coas
			  into _porc_partic_coas
			  from emicoama
			 where no_poliza    = v_no_poliza
			   and cod_coasegur = _cod_lider;
			
			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if

			let v_prima_neta = v_prima_neta * _porc_partic_coas / 100;

		end if

		--BUSCAR LOS IMPUESTOS Y EFECTUAR OPERACION

		LET v_imp_1 = 0;
		LET v_imp_5 = 0;

	    FOREACH
		    SELECT cod_impuesto
			  INTO v_cod_impuesto
			  FROM emipolim
			 WHERE no_poliza = v_no_poliza

		    SELECT factor_impuesto
			  INTO _factor_imp
			  FROM prdimpue
			 WHERE cod_impuesto = v_cod_impuesto;

			 IF _factor_imp = 1.00 THEN
			 	LET v_imp_1 = v_prima_neta * _factor_imp / 100;
			 ELIF _factor_imp = 5.00 THEN
			 	LET v_imp_5 = v_prima_neta * _factor_imp / 100;
			 END IF
		END FOREACH

		let _imp_2 = 0.00;

		If _aplica_impuesto = 1 Then -- Verifica si a la Poliza se le Aplican los Impuestos (Exterior No Llevan) 

			If _imp_gob = 1 Then -- Verifica si al Ramo se le Aplican los Impuestos

				foreach
				 select factor
				   into _factor_impuesto
				   from parimpgo

					let _imp_2 = _imp_2 + (v_prima_neta * _factor_impuesto / 100);
					
				end foreach

			end if

		end if

		let _comprobante = '';
		let _sac_notrx = 0;
		let _tecnico = 0;
		let _mayor = 0;		
		let _remesa = '';
		let _nombre = '';		
		
		{select sac_notrx,sum(debito-credito) 	
		into _sac_notrx,_tecnico
		from CHQCHCTA c, CHQCHMAE r, CHQCHPOL p
		where c.no_requis = r.no_requis
		and c.no_requis = p.no_requis
		and p.no_documento = v_no_documento
		and c.cuenta = r.cuenta
		and r.no_cheque = v_no_recibo
		and c.cuenta = '26504'	        
		group by 1;
		
		select res_comprobante,sum(res_debito-res_credito) 
		into _comprobante,_mayor
		from cglresumen
		where res_fechatrx = v_fecha
		and res_cuenta = '26504'
		and res_notrx = _sac_notrx
		group by 1;}
		
		if _tecnico is null then
			let _tecnico = 0;
		end if
		if _mayor is null then
			let _mayor = 0;
		end if	
		
		foreach
		select no_remesa
		into _remesa
		from cobredet 
		where doc_remesa = v_no_documento
		and no_recibo = v_no_recibo
		exit foreach;	
		end foreach	
		foreach
		select trim(recibi_de)
		into _nombre
		from cobremae 
		where no_remesa = _remesa
		exit foreach;	
		end foreach			
	
		-- Insercion / Actualizacion a la tabla temporal tmp_prod		
		INSERT INTO tmp_prod(
		no_recibo,
		cod_ramo,
		no_documento,
	 	cod_contratante,
	 	fecha,
	 	prima_neta,
	 	imp1,
	 	imp5,
	 	monto,
	 	seleccionado,
	 	imp2,
		nombre_ramo,
		tipo,
		comprobante,
		sac_notrx,
		tecnico,
		mayor,
		remesa,
		nombre		
		)
		VALUES(
		v_no_recibo,
		v_codramo,
		v_no_documento,
		v_cod_contratante,
		v_fecha,
		v_prima_neta,
		v_imp_1,
		v_imp_5,
		v_monto,
		1,
		_imp_2,
		v_nombre_ramo,
		_tipo,
		_comprobante,
		_sac_notrx,
		_tecnico,
		_mayor,
		_remesa,
		_nombre
		);

	end foreach

end foreach
--}

-- Cheques de Devolucion de Primas Anulados

let _tipo = "A";

--{
foreach
 select no_requis,
        no_cheque,
		fecha_anulado
   into _no_requis,
        v_no_recibo,
		v_fecha
   from chqchmae
  where cod_compania    = a_compania
    and pagado          = 1
	and anulado         = 1
	and origen_cheque   = "6"
    and fecha_anulado  >= _fecha_desde
	and fecha_anulado  <= _fecha_hasta
--	and no_requis     = "305724"

	foreach
	 select no_documento,
	        no_poliza,
			prima_neta,
			monto
	   into v_no_documento,
	        v_no_poliza,
			v_prima_neta,
			v_monto
	   from chqchpol
	  where no_requis = _no_requis

--		let v_prima_neta = v_prima_neta * - 1;
--		let v_monto      = v_monto      * - 1;

	    SELECT cod_contratante,
	    	   cod_ramo,
	    	   cod_tipoprod,
			   cod_origen
		  INTO v_cod_contratante,
		  	   v_codramo,
		  	   v_cod_tipoprod,
			   _cod_origen
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

	    SELECT tipo_produccion
		  INTO v_tipo_produccion
		  FROM emitipro
		 WHERE cod_tipoprod = v_cod_tipoprod;

		 IF v_tipo_produccion = 4 THEN
			 CONTINUE FOREACH;
		 END IF

		select aplica_impuesto
		  into _aplica_impuesto
		  from parorig
		 where cod_origen = _cod_origen;

		select imp_gob,
		       nombre
		  into _imp_gob,
		       v_nombre_ramo
		  from prdramo
		 where cod_ramo = v_codramo;

		 IF v_tipo_produccion = 2 THEN

			select porc_partic_coas
			  into _porc_partic_coas
			  from emicoama
			 where no_poliza    = v_no_poliza
			   and cod_coasegur = _cod_lider;
			
			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if

			let v_prima_neta = v_prima_neta * _porc_partic_coas / 100;

		end if

		--BUSCAR LOS IMPUESTOS Y EFECTUAR OPERACION

		LET v_imp_1 = 0;
		LET v_imp_5 = 0;

	    FOREACH
		    SELECT cod_impuesto
			  INTO v_cod_impuesto
			  FROM emipolim
			 WHERE no_poliza = v_no_poliza

		    SELECT factor_impuesto
			  INTO _factor_imp
			  FROM prdimpue
			 WHERE cod_impuesto = v_cod_impuesto;

			 IF _factor_imp = 1.00 THEN
			 	LET v_imp_1 = v_prima_neta * _factor_imp / 100;
			 ELIF _factor_imp = 5.00 THEN
			 	LET v_imp_5 = v_prima_neta * _factor_imp / 100;
			 END IF
		END FOREACH

		let _imp_2 = 0.00;

		If _aplica_impuesto = 1 Then -- Verifica si a la Poliza se le Aplican los Impuestos (Exterior No Llevan) 

			If _imp_gob = 1 Then -- Verifica si al Ramo se le Aplican los Impuestos

				foreach
				 select factor
				   into _factor_impuesto
				   from parimpgo

					let _imp_2 = _imp_2 + (v_prima_neta * _factor_impuesto / 100);
					
				end foreach

			end if

		end if
		
	    let _comprobante = '';
		let _sac_notrx = 0;
		let _tecnico = 0;
		let _mayor = 0;
		let _remesa = '';
		let _nombre = '';
		
		{select sac_notrx,sum(debito-credito) 	
		into _sac_notrx,_tecnico
		from CHQCHCTA c, CHQCHMAE r, CHQCHPOL p
		where c.no_requis = r.no_requis
		and c.no_requis = p.no_requis
		and p.no_documento = v_no_documento
		and c.cuenta = r.cuenta
		and r.no_cheque = v_no_recibo
		and c.cuenta = '26504'	        
		group by 1;
		
		select res_comprobante,sum(res_debito-res_credito) 
		into _comprobante,_mayor
		from cglresumen
		where res_fechatrx = v_fecha
		and res_cuenta = '26504'
		and res_notrx = _sac_notrx
		group by 1;}
		
		if _tecnico is null then
			let _tecnico = 0;
		end if
		if _mayor is null then
			let _mayor = 0;
		end if			

		INSERT INTO tmp_prod(
		no_recibo,
		cod_ramo,
		no_documento,
	 	cod_contratante,
	 	fecha,
	 	prima_neta,
	 	imp1,
	 	imp5,
	 	monto,
	 	seleccionado,
	 	imp2,
		nombre_ramo,
		tipo,
		comprobante,
		sac_notrx,
		tecnico,
		mayor,
		remesa,
		nombre				
		)
		VALUES(
		v_no_recibo,
		v_codramo,
		v_no_documento,
		v_cod_contratante,
		v_fecha,
		v_prima_neta,
		v_imp_1,
		v_imp_5,
		v_monto,
		1,
		_imp_2,
		v_nombre_ramo,
		_tipo,
		_comprobante,
		_sac_notrx,
		_tecnico,
		_mayor,
		_remesa,
		_nombre	
		);

	end foreach

end foreach
--}

-- Procesos para Filtros

LET v_filtros = "";

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

	   UPDATE tmp_prod
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

	   UPDATE tmp_prod
	   	  SET seleccionado = 0
		WHERE seleccionado = 1
		  AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH 
 SELECT no_recibo,
 		no_documento,
 		cod_contratante,
 		fecha,
 		prima_neta,
 		imp1,
 		imp5,
 		cod_ramo,
 		monto,
 		imp2,
		nombre_ramo,
		tipo,
		comprobante,
		sac_notrx,
		tecnico,
		mayor		
   INTO v_no_recibo,
   		v_no_documento,
   		v_cod_contratante,
   		v_fecha,
   		v_prima_neta,
   		v_imp_1,
   		v_imp_5,
   		v_codramo,
   		v_monto,
		_imp_2,
		v_nombre_ramo,
		_tipo,
		_comprobante,
		_sac_notrx,
		_tecnico,
		_mayor		
   FROM tmp_prod
  WHERE seleccionado = 1

--Selecciona los nombres de Clientes
         SELECT	nombre
  	       INTO v_nombre_cliente
           FROM	cliclien
          WHERE cod_cliente = v_cod_contratante;

RETURN    v_no_recibo,
   		  v_no_documento,
		  v_nombre_cliente,
		  v_fecha,
		  v_prima_neta,
		  v_imp_1,
		  v_imp_5,
		  v_monto,
		  v_nombre_ramo,
		  v_compania_nombre,
		  v_filtros,
		  _imp_2,
		  _tipo,
		_comprobante,
		_sac_notrx,
		_tecnico,
		_mayor		  
		  WITH RESUME;

END FOREACH;

--DROP TABLE tmp_prod;

END PROCEDURE;