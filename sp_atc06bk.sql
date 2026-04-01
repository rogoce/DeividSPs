-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
-- usado en carta declarativa de salud.
 
-- Creado    : 26/01/2004 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_atc06;

CREATE PROCEDURE "informix".sp_atc06(a_compania CHAR(3),a_sucursal CHAR(3),a_ano integer, a_usuario CHAR(10))
RETURNING	SMALLINT,	  -- TIPO PERSONA
			VARCHAR(30),  -- CEDULA
			CHAR(2),	  -- DV
			VARCHAR(100), -- ASEGURADO
            CHAR(20),	  -- DOCUMENTO
			DEC(16,2),    -- SALDO
			DEC(16,2),	  -- FACTURADO
			DEC(16,2);	  -- MONTO NO CUBIERTO


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
define _no_documento        CHAR(20);
define _cantidad			smallint;	
define _no_unidad2          CHAR(5);
define v_fecha_genera       DATETIME HOUR TO SECOND;
define _agno                CHAR(4);
define _digito_ver          CHAR(2);
define _pasaporte, _tipo_per smallint;

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo1;

let _agno = a_ano;
let _flag = 0;
let _saber_reclamo = 0;
let _saber_cobro   = 0;
let _sindato       = 0;

CREATE TEMP TABLE tmp_saldo1(
        fecha           DATE,
		referencia      CHAR(20),
		no_documento    CHAR(20),
		monto           DEC(16,2),
		prima_neta      DEC(16,2),
		periodo			CHAR(7),
		no_poliza       CHAR(10),
		tipo_fac        CHAR(30)
		) WITH NO LOG;

CREATE TEMP TABLE tmp_rec1(
        fecha           	DATE,
		facturado       	DEC(16,2),
		pagado		    	DEC(16,2),
		monto_no_cubierto 	DEC(16,2),
		no_poliza           CHAR(10)
		) WITH NO LOG;   

CREATE TEMP TABLE tmp_rec2(
        fecha           	DATE,
		facturado       	DEC(16,2),
		pagado		    	DEC(16,2),
		monto_no_cubierto 	DEC(16,2),
		no_poliza           CHAR(10),
		no_unidad           CHAR(5),
		cod_asegurado       CHAR(10),
		seleccionado		SMALLINT DEFAULT 1
		) WITH NO LOG;   

-- SET DEBUG FILE TO "sp_atc03.trc";      
-- TRACE ON;                                                                     


FOREACH	WITH HOLD
 SELECT a.no_poliza,
        a.nueva_renov,
		a.cod_ramo,
		a.no_documento
   INTO _no_poliza,
        _nueva_renov,
		_cod_ramo,
		_no_documento
   FROM emipomae a, prdramo c
  WHERE a.cod_ramo   = c.cod_ramo
    AND a.actualizado  = 1
	AND c.ramo_sis     = 5

 SELECT COUNT(*)
   INTO _cantidad
   FROM emipouni
  WHERE no_poliza = _no_poliza;

 LET v_monto = 0.00;
  
 IF _cantidad = 1 THEN   
	let _flag = 1;
	FOREACH
	 SELECT a.no_recibo,
	        a.monto,
		    a.prima_neta,
		    a.no_remesa,
			b.fecha,
			b.tipo_remesa,
			b.periodo
	   INTO v_documento,
	        v_monto,
		    v_prima,
	   	    _no_remesa,
			v_fecha,
			_tipo_remesa,
			v_periodo
	   FROM cobredet a, cobremae b
	  WHERE a.no_remesa   = b.no_remesa
	    AND a.no_poliza   = _no_poliza
	    AND a.actualizado = 1
		AND a.tipo_mov IN ('P', 'N')
		AND year(b.fecha) = a_ano

		LET v_monto = v_monto * -1;
		LET v_prima = v_prima * -1;

 {		SELECT fecha,
		       tipo_remesa,
			   periodo
		  INTO v_fecha,		
			   _tipo_remesa, 
			   v_periodo   
		  FROM cobremae
		 WHERE no_remesa = _no_remesa;
  }
	    IF   _tipo_remesa = 'C' THEN
	      LET v_referencia = 'COMPROBANTE';
		ELSE
	      LET v_referencia = 'RECIBO';
	    END IF

		LET _tipo_fac = 'REMESA ' || _no_remesa;

		INSERT INTO tmp_saldo1(
		fecha,
		referencia,
		no_documento,
		monto,
		prima_neta,
		periodo,
		no_poliza,
		tipo_fac
		)
		VALUES(
		v_fecha,
		v_referencia,		
		v_documento,
		v_monto,    
		v_prima,    
		v_periodo,   
		_no_poliza,
		_tipo_fac
	    );

	END FOREACH

	 SELECT min(fecha),
			max(fecha),
	        sum(monto)
	   INTO v_fecha_min,
	        v_fecha_max,
	        v_monto
	   FROM tmp_saldo1
	  WHERE year(fecha) = a_ano;

	if v_fecha_min is null then
		let _saber_cobro = 1;
	end if

 END IF

 let _no_poliza = sp_sis21(_no_documento);

 SELECT COUNT(*)
   INTO _cantidad
   FROM emipouni
  WHERE no_poliza = _no_poliza;

 IF _cantidad = 1 THEN
	 let _flag = 1;
 {	 SELECT cod_contratante
 	   INTO _cod_pagador
	   FROM emipomae
	  WHERE no_poliza = _no_poliza;

	 SELECT nombre
	   INTO _nombre_pagador
	   FROM cliclien
	  WHERE cod_cliente = _cod_pagador;
  }
     SELECT cod_asegurado
	   INTO _cod_contratante
	   FROM emipouni
	  WHERE no_poliza = _no_poliza;

	 SELECT nombre,
			cedula,
			tipo_persona,
			digito_ver,
			pasaporte
	   INTO _nombre_asegurado,
	        _cedula,
			_tipo_persona,
			_digito_ver,
			_pasaporte
	   FROM cliclien
	  WHERE cod_cliente = _cod_contratante;

     if _pasaporte = 1 then
		LET _tipo_per = 3;
	 else
		if _tipo_persona = "N" then
			LET _tipo_per = 1;
		else
			LET _tipo_per = 2;
		end if
	 end if

	 SELECT nombre,
			ramo_sis
	   INTO _nombre_ramo,
			_ramo_sis
	   FROM prdramo
	  WHERE cod_ramo = _cod_ramo;

	LET _monto_no_cubierto = 0.00;

	 if _ramo_sis <> 5 then		--si no es salud
		let _pago_prov  = 0;
		let _gasto_fact = 0;
	 else
		select cod_tipotran
		  into _cod_tipotran
		  from rectitra
		 where tipo_transaccion = 4;

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
				_no_poliza,
				_periodo
		   from recrcmae
		  where	no_documento   = _no_documento
		    and actualizado    = 1

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

				 select	sum(facturado),
						sum(monto),
						sum(monto_no_cubierto)
				   into	_gasto_fact,
						_pago_prov,
						_monto_no_cubierto
				   from rectrcob
				  where no_tranrec = _no_tranrec;

				if _fecha_factura is null then
					let _fecha_factura = _fecha_gasto;
				end if

				-- En vez de fecha de la transaccion de puso fecha de factura
				-- Solicitado por Maruquel el 06/02/2007
				-- Cambiado por Demetrio Hurtado

				INSERT INTO tmp_rec1(
				fecha,
				facturado,
				pagado,
				monto_no_cubierto
				)
				VALUES(
				_fecha_factura,
				_gasto_fact,
				_pago_prov,
				_monto_no_cubierto
			    );
			end foreach
		end foreach

		 SELECT sum(facturado),
				sum(pagado),
				sum(monto_no_cubierto)
		   INTO _gasto_fact,
				_pago_prov,
				_monto_no_cubierto
		   FROM tmp_rec1
		  WHERE year(fecha) = a_ano;
	 end if

	if v_monto IS NULL THEN
		let v_monto = 0.00;
	end if

	if _gasto_fact IS NULL THEN
		let _gasto_fact = 0.00;
	end if

	if _pago_prov IS NULL THEN
		let _pago_prov = 0.00;
	end if

	-- Buscando Firma y Cedula de la Carta

   {	SELECT valor_parametro 
	  INTO v_firma_cartas
	  FROM inspaag
	 WHERE codigo_parametro = "firma_cartas"; 

	SELECT valor_parametro 
	  INTO v_cedula_cartas
	  FROM inspaag
	 WHERE codigo_parametro = "cedula_cartas"; 

	SELECT descripcion 
	  INTO v_nombre_completo
	  FROM insuser
	 WHERE usuario = v_firma_cartas; 

	SELECT cargo
	  INTO v_cargo
	  FROM wf_firmas
	 WHERE usuario = trim(v_firma_cartas);

    LET v_fecha_genera = CURRENT;
	}
	RETURN _tipo_per,				  -- TIPO PERSONA
		   trim(_cedula),			  -- CEDULA
	       _digito_ver,			      -- DV
		   trim(_nombre_asegurado),	  -- ASEGURADO
		   _no_documento,			  -- DOCUMENTO
		   abs(v_monto),	          -- SALDO
		   _pago_prov,     		      -- MONTO
		   _monto_no_cubierto   	  -- MONTO NO CUBIERTO
	   	   WITH RESUME;

  ELIF _cantidad > 1 THEN
  	let _flag = 0;
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

	 FOREACH
	     SELECT no_unidad,
		        cod_asegurado
		   INTO _no_unidad2,
		       	_cod_contratante
		   FROM emipouni
		  WHERE activo = 1
		    AND no_poliza = _no_poliza

		 SELECT nombre,
				ramo_sis
		   INTO _nombre_ramo,
				_ramo_sis
		   FROM prdramo
		  WHERE cod_ramo = _cod_ramo;

		 LET _monto_no_cubierto = 0.00;

		 if _ramo_sis <> 5 then		--si no es salud
			let _pago_prov  = 0;
			let _gasto_fact = 0;
		 else
			select cod_tipotran
			  into _cod_tipotran
			  from rectitra
			 where tipo_transaccion = 4;

	        select count(*)
			  into _cantidad
			  from recrcmae
			 where no_documento   = _no_documento
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
						_no_poliza,
						_periodo
				   from recrcmae
				  where	no_documento   = _no_documento
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

						 select	sum(facturado),
								sum(monto),
								sum(monto_no_cubierto)
						   into	_gasto_fact,
								_pago_prov,
								_monto_no_cubierto
						   from rectrcob
						  where no_tranrec = _no_tranrec;

						if _fecha_factura is null then
							let _fecha_factura = _fecha_gasto;
						end if

						-- En vez de fecha de la transaccion de puso fecha de factura
						-- Solicitado por Maruquel el 06/02/2007
						-- Cambiado por Demetrio Hurtado

						INSERT INTO tmp_rec2(
						fecha,
						facturado,
						pagado,
						monto_no_cubierto,
						no_unidad,
						cod_asegurado,
						no_poliza
						)
						VALUES(
						_fecha_factura,
						_gasto_fact,
						_pago_prov,
						_monto_no_cubierto,
						_no_unidad,
						_cod_contratante,
						_no_poliza
					    );
					end foreach
				end foreach
			else
				INSERT INTO tmp_rec2(
				fecha,
				facturado,
				pagado,
				monto_no_cubierto,
				no_unidad,
				cod_asegurado,
				no_poliza
				)
				VALUES(
				date("01/01/"||_agno),
				_gasto_fact,
				_pago_prov,
				_monto_no_cubierto,
				_no_unidad2,
				_cod_contratante,
				_no_poliza
			    );
			end if
	 	 end if
	 END FOREACH

    LET v_fecha_genera = CURRENT;

	FOREACH	WITH HOLD
		SELECT sum(facturado),
			   sum(pagado),
			   sum(monto_no_cubierto),
			   no_unidad,
			   cod_asegurado,
			   no_poliza
		  INTO _gasto_fact,
			   _pago_prov,
			   _monto_no_cubierto,
			   _no_unidad,
			   _cod_contratante,
			   _no_poliza
		  FROM tmp_rec2
		 WHERE year(fecha) = a_ano
		   AND seleccionado = 1
		 GROUP BY no_poliza, no_unidad, cod_asegurado

        SELECT no_documento
		  INTO _no_documento
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;

		if _gasto_fact IS NULL THEN
			let _gasto_fact = 0.00;
		end if

		if _pago_prov IS NULL THEN
			let _pago_prov = 0.00;
		end if

		-- Buscando Datos del Asegurado

		 SELECT nombre,
				cedula,
				tipo_persona,
				digito_ver,
				pasaporte
		   INTO _nombre_asegurado,
		        _cedula,
				_tipo_persona,
				_digito_ver,
				_pasaporte
		   FROM cliclien
		  WHERE cod_cliente = _cod_contratante;

	     if _pasaporte = 1 then
			LET _tipo_per = 3;
		 else
			if _tipo_persona = "N" then
				LET _tipo_per = 1;
			else
				LET _tipo_per = 2;
			end if
		 end if

		-- Buscando Firma y Cedula de la Carta

 {		SELECT valor_parametro 
		  INTO v_firma_cartas
		  FROM inspaag
		 WHERE codigo_parametro = "firma_cartas"; 

		SELECT valor_parametro 
		  INTO v_cedula_cartas
		  FROM inspaag
		 WHERE codigo_parametro = "cedula_cartas"; 

		SELECT descripcion 
		  INTO v_nombre_completo
		  FROM insuser
		 WHERE usuario = v_firma_cartas; 

		SELECT cargo
		  INTO v_cargo
		  FROM wf_firmas
		 WHERE usuario = trim(v_firma_cartas);

	    LET v_fecha_genera = v_fecha_genera + 1 UNITS SECOND;
  }
	    RETURN _tipo_per,				  -- TIPO PERSONA
		       trim(_cedula),			  -- CEDULA
	           _digito_ver,			      -- DV
		       trim(_nombre_asegurado),	  -- ASEGURADO
		       _no_documento,			  -- DOCUMENTO
		       0,	                      -- SALDO
		       _pago_prov,     		      -- MONTO
		       _monto_no_cubierto   	  -- MONTO NO CUBIERTO
			   WITH RESUME;
	END FOREACH

  END IF

DELETE FROM tmp_saldo1;
DELETE FROM tmp_rec1;
DELETE FROM tmp_rec2;

END FOREACH

DROP TABLE tmp_saldo1;
DROP TABLE tmp_rec1;
DROP TABLE tmp_rec2;

END PROCEDURE