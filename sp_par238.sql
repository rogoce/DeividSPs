-- Registros contables de cheques
--
-- Creado	 : 17/01/2007 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_par238;

CREATE PROCEDURE "informix".sp_par238(
a_no_requis 	CHAR(10)
) RETURNING INTEGER,
			CHAR(50);


DEFINE _no_poliza		CHAR(10);
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_produccion	SMALLINT; 
DEFINE _prima_bruta     DEC(16,2);
DEFINE _prima_neta      DEC(16,2);
DEFINE _impuesto	    DEC(16,2);
DEFINE _suma_impuesto	DEC(16,2);
define _cuenta			char(25);
define _renglon			integer;
define _cod_ramo		char(3);
define _cant_impuestos	integer;
define _cod_impuesto	char(3);
define _cuenta_inc	   	char(25);
define _cuenta_dan	   	char(25);
define _factor_impuesto	dec(5,2);
define _debito      	dec(16,2);
define _credito     	dec(16,2);
define _monto  	    	dec(16,2);

set isolation to dirty read;

SELECT MAX(renglon)
  INTO _renglon	
  FROM chqchcta
 WHERE no_requis = a_no_requis;

IF _renglon IS NULL THEN
	LET _renglon = 0;
END IF

FOREACH
 SELECT	no_poliza,
		monto,
		prima_neta
   INTO	_no_poliza,
        _prima_bruta,
		_prima_neta
   FROM	chqchpol
  WHERE	no_requis = a_no_requis

	SELECT cod_tipoprod,
	       cod_ramo
	  INTO _cod_tipoprod,
	       _cod_ramo
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT tipo_produccion
	  INTO _tipo_produccion
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	-- Prima Neta

	IF _tipo_produccion = 3 THEN 
		LET _cuenta = sp_sis15('PACXCC',  '01', _no_poliza); -- Coaseguro Minoritario
	ELSE						 
		LET _cuenta = sp_sis15('PAPXCSD', '01', _no_poliza); -- Produccion Directa
	END IF

	LET _renglon = _renglon + 1;
	let _debito  = _prima_neta;
	let _credito = 0.00;

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	cuenta,
	debito,
	credito
	)
	VALUES(
	a_no_requis,
	_renglon,
	_cuenta,
	_debito,
	0
	);

	let _impuesto = _prima_bruta - _prima_neta;

	if _impuesto <> 0.00 then

		-- Afectar el Impuesto

		let _suma_impuesto = 0.00;

		 select count(*)
		   into _cant_impuestos
		   from emipolim
		  where no_poliza = _no_poliza;

		foreach	
		 select cod_impuesto
		   into _cod_impuesto
		   from emipolim
		  where no_poliza = _no_poliza

			select factor_impuesto,
			       cta_incendio,
				   cta_danos
			  into _factor_impuesto,
			       _cuenta_inc,
				   _cuenta_dan
			  from prdimpue
			 where cod_impuesto = _cod_impuesto;
				    
			if _cant_impuestos = 1 then
				let _monto = _impuesto;
			else
				let _monto = _prima_neta * _factor_impuesto / 100;
			end if

			let _suma_impuesto = _suma_impuesto + _monto;

			If _cod_ramo in ("001", "003") then       -- Incendio, Multiriesgos
				Let _cuenta = sp_sis15(_cuenta_inc); 
			else								      -- Otros Ramos
				Let _cuenta = sp_sis15(_cuenta_dan); 
			end If

			let _debito  = _monto;
			let _credito = 0.00;
			LET _renglon = _renglon + 1;

			INSERT INTO chqchcta(
			no_requis,
			renglon,
			cuenta,
			debito,
			credito
			)
			VALUES(
			a_no_requis,
			_renglon,
			_cuenta,
			_debito,
			0
			);

		end Foreach

		-- Diferencia en la Multiplicacion por la separacion del impuesto

		if _impuesto <> _suma_impuesto then

			let _debito  = _impuesto - _suma_impuesto;
			let _credito = 0.00;
			
			update chqchcta
			   set debito    = debito  + _debito,
			       credito   = credito + _credito
			 where no_requis = a_no_requis
			   and renglon   = _renglon;

		end if

     end If

END FOREACH

END PROCEDURE;
