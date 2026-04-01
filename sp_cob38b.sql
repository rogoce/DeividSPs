-- Impuestos cobrados-- 
-- Creado    : 04/12/2000 - Autor: Lic. Armando Moreno 
-- Modificado: 04/12/2000 - Autor: Lic. Armando Moreno
-- Modificado: 10/04/2003 - Autor: Lic. Armando Moreno que tome en cuenta coas minoritario
-- SIS v.2.0 d_- DEIVID, S.A.

DROP PROCEDURE sp_cob38b;
CREATE PROCEDURE sp_cob38b(a_compania CHAR(3), a_agencia CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7),a_ramo CHAR(255) DEFAULT "*")
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
		          char(1);

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
DEFINE _cod_formapag	  CHAR(3);
DEFINE _ramo_sis,v_tipo_produccion SMALLINT;

-- Para el nuevo proceso
define _porc_partic_coas    decimal(7,4);
define _cod_lider			char(3);

define _no_requis			char(10);
define _fecha_desde			date;
define _fecha_hasta			date;
define _factor_impuesto	 	dec(5,2);
define _cod_origen		 	char(3);
define _cod_grupo		 	char(3);
define _aplica_impuesto  	smallint;
define _imp_gob          	smallint;
define _imp_2			  	dec(16,2);
define _tipo				char(1);
define _tipo_mov			char(1);

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
tipo			char(1)
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
		   cod_origen,
		   cod_formapag,
		   cod_grupo
	  INTO v_cod_contratante,
	  	   v_codramo,
	  	   v_cod_tipoprod,
		   _cod_origen,
		   _cod_formapag,
		   _cod_grupo
	  FROM emipomae
	 WHERE no_poliza = v_no_poliza;

    SELECT tipo_produccion
	  INTO v_tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = v_cod_tipoprod;

	 IF v_tipo_produccion = 4 THEN	--Reaseguro Asumido
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

	/*if v_tipo_produccion = 2 THEN

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
	
	--Pólizas del Grupo del estado o con forma de pago gobierno no pagan impuesto de 2%
	if _cod_formapag = '091' or _cod_grupo in ('00000','1000') then
		let _imp_gob = 0;
	end if
	*/

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
	tipo
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
	_tipo
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
			   cod_origen,
			   cod_formapag,
			   cod_grupo
		  INTO v_cod_contratante,
		  	   v_codramo,
		  	   v_cod_tipoprod,
			   _cod_origen,
			   _cod_formapag,
			   _cod_grupo
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

		--Pólizas del Grupo del estado o con forma de pago gobierno no pagan impuesto de 2%
		/*if _cod_formapag = '091' or _cod_grupo in ('00000','1000') then
			let _imp_gob = 0;
		end if

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

		end if*/

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
		tipo
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
		_tipo
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
			   cod_origen,
			   cod_formapag,
			   cod_grupo
		  INTO v_cod_contratante,
		  	   v_codramo,
		  	   v_cod_tipoprod,
			   _cod_origen,
			   _cod_formapag,
			   _cod_grupo
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

		/*--Pólizas del Grupo del estado o con forma de pago gobierno no pagan impuesto de 2%
		if _cod_formapag = '091' or _cod_grupo in ('00000','1000') then
			let _imp_gob = 0;
		end if

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

		end if*/

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
		tipo
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
		_tipo
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
 SELECT nombre_ramo,
 		sum(prima_neta),
 		sum(imp1),
 		sum(imp5),
 		sum(monto),
 		sum(imp2)
   INTO v_nombre_ramo,
   		v_prima_neta,
   		v_imp_1,
   		v_imp_5,
   		v_monto,
		_imp_2
   FROM tmp_prod
  WHERE seleccionado = 1
  group by 1
  order by 1

	RETURN "",
		   "",
		   "",
		   "",
		   v_prima_neta,
		   v_imp_1,
		   v_imp_5,
		   v_monto,
		   v_nombre_ramo,
		   v_compania_nombre,
		   v_filtros,
		   _imp_2,
		   ""
		   WITH RESUME;

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;