-- CARTAS A ASEGURADOS COLECTIVO
-- Procedimiento que extrae los Saldos de la Poliza
-- usado en carta declarativa de salud.
 
-- Creado    : 18/01/2008 - Autor: Amado Perez M.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_atc02aaa;

CREATE PROCEDURE "informix".sp_atc02aaa(a_compania CHAR(3),a_sucursal CHAR(3),a_no_documento CHAR(20),a_ano integer, a_usuario CHAR(10), a_unidad CHAR(255) DEFAULT '*', a_membrete SMALLINT DEFAULT 0, a_monto_uni CHAR(255) DEFAULT '*')
RETURNING	CHAR(20),
			VARCHAR(100), -- PAGADOR
			VARCHAR(30),  -- CEDULA
			VARCHAR(100), -- ASEGURADO
			VARCHAR(50),  -- NOMBRE RAMO
			DEC(16,2),	  -- FACTURADO
			DEC(16,2),	  -- MONTO
			CHAR(1),	  -- TIPO PERSONA
			CHAR(10),	  -- USUARIO
			SMALLINT,	  -- AGNO
			VARCHAR(20),
			VARCHAR(20),
			VARCHAR(30),
			VARCHAR(50),
			DEC(16,2),	  -- MONTO NO CUBIERTO
			CHAR(10),
			DATETIME HOUR TO SECOND,
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DEC(16,2);

DEFINE v_fecha		      	DATE;
DEFINE v_fecha_min        	DATE;
DEFINE v_fecha_max        	DATE;
DEFINE _fecha_factura     	DATE;
DEFINE v_referencia       	CHAR(20);
DEFINE v_documento        	CHAR(20);
DEFINE v_monto            	DEC(16,2);
DEFINE v_prima            	DEC(16,2);
DEFINE v_saldo            	DEC(16,2);	 
DEFINE v_periodo          	CHAR(7);
DEFINE v_cod_endomov      	CHAR(3);
DEFINE v_cod_tipocan      	CHAR(3);
DEFINE _cod_tipoprod      	CHAR(3);

DEFINE _no_poliza        	CHAR(10);
DEFINE _cod_contratante  	CHAR(10);
DEFINE _cod_pagador      	CHAR(10);
DEFINE _tipo_fac         	CHAR(30);
DEFINE _nueva_renov      	CHAR(1);
DEFINE _tipo_remesa      	CHAR(1);
DEFINE _no_requis		 	CHAR(10);
DEFINE _no_remesa		 	CHAR(10);
DEFINE _pagado           	SMALLINT;
DEFINE _anulado          	SMALLINT;
DEFINE _ramo_sis	     	SMALLINT;
DEFINE _cod_banco        	CHAR(3);
DEFINE _cod_ramo	     	CHAR(3);
define _nombre_asegurado 	varchar(100);
define _nombre_ramo		 	varchar(50);
define _nombre_pagador   	varchar(100);
define _flag			 	smallint;
define _saber_cobro		 	smallint;
define _saber_reclamo	 	smallint;
define _sindato			 	smallint;
define _cod_tipotran    	char(3);
define _fecha_gasto			date;
define _periodo				char(7);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _numrecla			char(20);
define _fecha_siniestro		date;
define _no_unidad			char(10);
define _no_unidad2			char(5);
define _gasto_fact			dec(16,2);
define _pago_prov			dec(16,2);
define _monto_no_cubierto	dec(16,2);
define v_fecha_rec_min  	date;
define v_fecha_rec_max		date;
define _tipo_persona    	CHAR(1);
define _cedula          	varchar(30);
define v_firma_cartas		varchar(20);
define v_cedula_cartas		varchar(20);
define v_nombre_completo 	varchar(30);
define v_cargo           	varchar(50);
DEFINE _tipo                CHAR(1);
define v_fecha_genera       DATETIME HOUR TO SECOND;
define _cantidad            INTEGER;
DEFINE _agno                char(4);
define _ded, _copago		dec(16,2);
define _coaseguro 			dec(16,2);
define _ahorro 				DEC(16,2);
define _prima_individual    DEC(16,2);
define _prima_result        DEC(16,2);
define _prima_depen			DEC(16,2);
define _prima_br			DEC(16,2);
define _cant_depen,_cnt     integer;
DEFINE _no_poliza2        	CHAR(10);
define _tipo_m              CHAR(1);
define _status              char(1);

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo1;
let _agno = a_ano;
let _flag = 0;
let _saber_reclamo = 0;
let _saber_cobro   = 0;
let _sindato       = 0;
let _ded           = 0;
let _copago        = 0;
let _coaseguro     = 0;
let _ahorro        = 0;
let _prima_individual = 0;
let _prima_result   = 0;
let _prima_depen    = 0;
let _prima_br       = 0;
let _cant_depen     = 0;

CREATE TEMP TABLE tmp_rec1(
        fecha           	DATE,
		facturado       	DEC(16,2),
		pagado		    	DEC(16,2),
		monto_no_cubierto 	DEC(16,2),
		no_unidad           CHAR(5),
		cod_asegurado       CHAR(10),
		deducible           DEC(16,2) default 0,
		copago              DEC(16,2) default 0,
		coaseguro           DEC(16,2) default 0,
		ahorro              DEC(16,2) default 0,
		prima_pagada        DEC(16,2) default 0,
		seleccionado		SMALLINT  default 1
		) WITH NO LOG;   

 let _no_poliza = sp_sis21(a_no_documento);

--set debug file to "sp_atc02aa.trc";
--trace on;

 SELECT cod_ramo,
		cod_contratante
   INTO _cod_ramo,
        _cod_pagador
   FROM emipomae
  WHERE no_poliza = _no_poliza;

 SELECT nombre
   INTO _nombre_pagador
   FROM cliclien
  WHERE cod_cliente = _cod_pagador;

{FOREACH

     SELECT no_unidad
	   INTO _no_unidad2
	   FROM emipouni
	  where no_poliza = _no_poliza

	--determinar la prima individual
	 foreach

		SELECT COUNT(*)
		  INTO _cant_depen
		  FROM emidepen
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad2

		IF _cant_depen = 0 THEN

			SELECT prima_bruta
			  into _prima_individual
			  FROM emipouni
			 WHERE no_poliza = _no_poliza
			   AND no_unidad = _no_unidad2;

			exit foreach;

		end if

	 end foreach

end foreach}

if _prima_individual is null then
	let _prima_individual = 0;
end if

 FOREACH WITH HOLD
     SELECT no_unidad,
	        cod_asegurado
	   INTO _no_unidad2,
	       	_cod_contratante
	   FROM emipouni
	  WHERE no_poliza = _no_poliza

	 SELECT nombre,
			ramo_sis
	   INTO _nombre_ramo,
			_ramo_sis
	   FROM prdramo
	  WHERE cod_ramo = _cod_ramo;

	 LET _monto_no_cubierto = 0.00;
	 LET _pago_prov  = 0;
	 LET _gasto_fact = 0;
	 let _ded           = 0;
	 let _copago        = 0;
	 let _coaseguro     = 0;
	 let _ahorro        = 0;

	 if _ramo_sis <> 5 then		--si no es salud
		let _pago_prov  = 0;
		let _gasto_fact = 0;
	 else
		select cod_tipotran
		  into _cod_tipotran
		  from rectitra
		 where tipo_transaccion = 4;

        let _cantidad = 0;

        select count(*)
		  into _cantidad
		  from recrcmae
		 where no_documento   = a_no_documento
		   and actualizado    = 1
		   and no_unidad      = _no_unidad2;

		If _cantidad > 0 Then 
			foreach
			 select	numrecla,
			        fecha_siniestro,
					no_reclamo,
					no_unidad,
					no_poliza,
					periodo
			   into	_numrecla,
			        _fecha_siniestro,
					_no_reclamo,
					_no_unidad,
					_no_poliza2,
					_periodo
			   from recrcmae
			  where	no_documento   = a_no_documento
			    and actualizado    = 1
				and no_unidad      = _no_unidad2

				foreach
					 select fecha,
							no_tranrec,
							fecha_factura
					   into	_fecha_gasto,
							_no_tranrec,
							_fecha_factura
					   from rectrmae
					  where no_reclamo   = _no_reclamo
					    and actualizado  = 1
						and cod_tipotran = _cod_tipotran
						and pagado = 1

					 select	sum(facturado),
							sum(monto),
							sum(monto_no_cubierto),
							sum(a_deducible),
							sum(co_pago),
							sum(coaseguro),
							sum(ahorro)
					   into	_gasto_fact,
							_pago_prov,
							_monto_no_cubierto,
							_ded,
							_copago,
							_coaseguro,
							_ahorro
					   from rectrcob
					  where no_tranrec = _no_tranrec;

					if _fecha_factura is null then
						let _fecha_factura = _fecha_gasto;
					end if

					-- En vez de fecha de la transaccion se puso fecha de factura
					-- Solicitado por Maruquel el 06/02/2007
					-- Cambiado por Demetrio Hurtado
					INSERT INTO tmp_rec1(
					fecha,
					facturado,
					pagado,
					monto_no_cubierto,
					no_unidad,
					cod_asegurado,
					deducible,
					copago,
					coaseguro,
					ahorro
					)
					VALUES(
					_fecha_factura,
					_gasto_fact,
					_pago_prov,
					_monto_no_cubierto,
					_no_unidad,
					_cod_contratante,
					_ded,
					_copago,
					_coaseguro,
					_ahorro
				    );
				end foreach

			end foreach
		else
			INSERT INTO tmp_rec1(
			fecha,
			facturado,
			pagado,
			monto_no_cubierto,
			no_unidad,
			cod_asegurado,
			deducible,
			copago,
			coaseguro,
			ahorro
			)
			VALUES(
			date("01/01/"||_agno),
			_gasto_fact,
			_pago_prov,
			_monto_no_cubierto,
			_no_unidad2,
			_cod_contratante,
			_ded,
			_copago,
			_coaseguro,
			_ahorro
		    );
		end if
 	 end if
 END FOREACH

LET _tipo_m = sp_sis146(a_monto_uni);

IF a_unidad <> "*" THEN

		LET _tipo = sp_sis04(a_unidad);  -- Separa los Valores del String en una tabla de codigos

		IF _tipo <> "E" THEN -- (I) Incluir los Registros

			UPDATE tmp_rec1
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND no_unidad NOT IN (SELECT codigo FROM tmp_codigos);

		ELSE		        -- (E) Excluir estos Registros

			UPDATE tmp_rec1
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND no_unidad IN (SELECT codigo FROM tmp_codigos);

		END IF

		DROP TABLE tmp_codigos;

END IF

LET v_fecha_genera = CURRENT;

let  _cnt = 0;

FOREACH
	SELECT no_unidad
	  INTO _no_unidad
	  FROM tmp_rec1
	 WHERE year(fecha)  = a_ano
	   AND seleccionado = 1
	 GROUP BY no_unidad, cod_asegurado

	LET _cnt = _cnt + 1;
END FOREACH


if _cnt > 0 then

FOREACH	WITH HOLD
		SELECT sum(facturado),
			   sum(pagado),
			   sum(monto_no_cubierto),
			   sum(deducible),
			   sum(copago),
			   sum(coaseguro),
			   sum(ahorro),
			   no_unidad,
			   cod_asegurado
		  INTO _gasto_fact,
			   _pago_prov,
			   _monto_no_cubierto,
			   _ded,
			   _copago,
			   _coaseguro,
			   _ahorro,
			   _no_unidad,
			   _cod_contratante
		  FROM tmp_rec1
 		 WHERE year(fecha)  = a_ano
		   and seleccionado = 1
		 GROUP BY no_unidad, cod_asegurado

		if _gasto_fact IS NULL THEN
			let _gasto_fact = 0.00;
		end if

		if _pago_prov IS NULL THEN
			let _pago_prov = 0.00;
		end if

		let _prima_result = 0;
		let _prima_depen  = 0;
		let _prima_br     = 0;

        SELECT monto
		  INTO _prima_depen
		  FROM tmp_cod_mt
		 WHERE codigo = _no_unidad;

		{foreach

			select e.prima_bruta
			  into _prima_br
			  from endeduni e, endedmae t
			 where e.no_poliza   = t.no_poliza
			   and e.no_endoso   = t.no_endoso
			   and e.no_poliza   = _no_poliza
			   and e.no_unidad   = _no_unidad
			   and year(t.vigencia_inic) = a_ano
			   and t.cod_endomov = "014"

			let _prima_result = _prima_br - _prima_individual;
			let _prima_depen  = _prima_depen + _prima_result;

		end foreach
	   }
		-- Buscando Datos del Asegurado

		 SELECT nombre,
				cedula,
				tipo_persona
		   INTO _nombre_asegurado,
		        _cedula,
				_tipo_persona
		   FROM cliclien
		  WHERE cod_cliente = _cod_contratante;

		-- Buscando Firma y Cedula de la Carta

		SELECT valor_parametro 
		  INTO v_firma_cartas
		  FROM inspaag
		 WHERE codigo_parametro = "firma_cartas"; 

		SELECT valor_parametro 
		  INTO v_cedula_cartas
		  FROM inspaag
		 WHERE codigo_parametro = "cedula_cartas"; 

		SELECT descripcion,status
		  INTO v_nombre_completo,_status
		  FROM insuser
		 WHERE usuario = v_firma_cartas;

		 if _status = "A" then
		 else

			SELECT valor_parametro 
			  INTO v_firma_cartas
			  FROM inspaag
			 WHERE codigo_parametro = "firma_carta2"; 
			
			SELECT valor_parametro 
			  INTO v_cedula_cartas
			  FROM inspaag
			 WHERE codigo_parametro = "cedula_carta2";

			SELECT descripcion,
			       status 
			  INTO v_nombre_completo,
			       _status
			  FROM insuser
			 WHERE usuario = v_firma_cartas;

		 end if

		SELECT cargo
		  INTO v_cargo
		  FROM wf_firmas
		 WHERE usuario = trim(v_firma_cartas);

	    LET v_fecha_genera = v_fecha_genera + 1 UNITS SECOND;

			RETURN a_no_documento,
			       _nombre_pagador,
				   trim(_cedula),
				   trim(_nombre_asegurado),
				   trim(_nombre_ramo),
		  		   _gasto_fact,
				   _pago_prov,
				   _tipo_persona,
				   a_usuario,
				   a_ano,
				   trim(v_firma_cartas),
				   trim(v_cedula_cartas),
				   trim(v_nombre_completo),
				   trim(v_cargo),
				   _monto_no_cubierto,
				   _no_poliza,
				   v_fecha_genera,
				   _ded,
				   _copago,
				   _coaseguro,
				   _ahorro,
				   _prima_depen
				   WITH RESUME;
END FOREACH

else

FOREACH	WITH HOLD

		SELECT sum(facturado),
			   sum(pagado),
			   sum(monto_no_cubierto),
			   sum(deducible),
			   sum(copago),
			   sum(coaseguro),
			   sum(ahorro),
			   no_unidad,
			   cod_asegurado
		  INTO _gasto_fact,
			   _pago_prov,
			   _monto_no_cubierto,
			   _ded,
			   _copago,
			   _coaseguro,
			   _ahorro,
			   _no_unidad,
			   _cod_contratante
		  FROM tmp_rec1
 		 WHERE seleccionado = 1                           --year(fecha)  = a_ano
		 GROUP BY no_unidad, cod_asegurado

		if _gasto_fact IS NULL THEN
			let _gasto_fact = 0.00;
		end if

		if _pago_prov IS NULL THEN
			let _pago_prov = 0.00;
		end if

		let _prima_result = 0;
		let _prima_depen  = 0;
		let _prima_br     = 0;

        SELECT monto
		  INTO _prima_depen
		  FROM tmp_cod_mt
		 WHERE codigo = _no_unidad;

	   {	foreach
			select e.prima_bruta
			  into _prima_br
			  from endeduni e, endedmae t
			 where e.no_poliza   = t.no_poliza
			   and e.no_endoso   = t.no_endoso
			   and e.no_poliza   = _no_poliza
			   and e.no_unidad   = _no_unidad
			   and year(t.vigencia_inic) = a_ano
			   and t.cod_endomov = "014"

			let _prima_result = _prima_br - _prima_individual;
			let _prima_depen  = _prima_depen + _prima_result;

		end foreach
		}
		-- Buscando Datos del Asegurado

		 SELECT nombre,
				cedula,
				tipo_persona
		   INTO _nombre_asegurado,
		        _cedula,
				_tipo_persona
		   FROM cliclien
		  WHERE cod_cliente = _cod_contratante;

		-- Buscando Firma y Cedula de la Carta

		SELECT valor_parametro 
		  INTO v_firma_cartas
		  FROM inspaag
		 WHERE codigo_parametro = "firma_cartas"; 

		SELECT valor_parametro 
		  INTO v_cedula_cartas
		  FROM inspaag
		 WHERE codigo_parametro = "cedula_cartas"; 

		SELECT descripcion,status 
		  INTO v_nombre_completo,_status
		  FROM insuser
		 WHERE usuario = v_firma_cartas;

		 if _status = "A" then
		 else

			SELECT valor_parametro 
			  INTO v_firma_cartas
			  FROM inspaag
			 WHERE codigo_parametro = "firma_carta2"; 
			
			SELECT valor_parametro 
			  INTO v_cedula_cartas
			  FROM inspaag
			 WHERE codigo_parametro = "cedula_carta2";

			SELECT descripcion,
			       status 
			  INTO v_nombre_completo,
			       _status
			  FROM insuser
			 WHERE usuario = v_firma_cartas;

		 end if

		SELECT cargo
		  INTO v_cargo
		  FROM wf_firmas
		 WHERE usuario = trim(v_firma_cartas);

	    LET v_fecha_genera = v_fecha_genera + 1 UNITS SECOND;

			RETURN a_no_documento,
			       _nombre_pagador,
				   trim(_cedula),
				   trim(_nombre_asegurado),
				   trim(_nombre_ramo),
		  		   0,
				   0,
				   _tipo_persona,
				   a_usuario,
				   a_ano,
				   trim(v_firma_cartas),
				   trim(v_cedula_cartas),
				   trim(v_nombre_completo),
				   trim(v_cargo),
				   0,
				   _no_poliza,
				   v_fecha_genera,
				   0,
				   0,
				   0,
				   0,
				   _prima_depen
				   WITH RESUME;

END FOREACH

end if

--DROP TABLE tmp_rec1;
DROP TABLE tmp_cod_mt;

END PROCEDURE