-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
-- usado en carta declarativa de salud.
 
-- Creado    : 26/01/2004 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_atc06;

CREATE PROCEDURE "informix".sp_atc06(a_ano integer)
RETURNING	SMALLINT,	  -- TIPO PERSONA
			VARCHAR(30),  -- CEDULA
			CHAR(2),	  -- DV
			VARCHAR(100), -- ASEGURADO
            CHAR(20),	  -- DOCUMENTO
			DEC(16,2),    -- SALDO
			DEC(16,2),	  -- FACTURADO
			DEC(16,2),	  -- MONTO NO CUBIERTO
			char(10),
			smallint,
			dec(16,2);


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
define _gasto_fact,_deducible	dec(16,2);
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

define _tipo_error			smallint;

SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo1;

let _agno 			= a_ano;
let _flag 			= 0;
let _saber_reclamo	= 0;
let _saber_cobro   	= 0;
let _sindato       	= 0;

CREATE TEMP TABLE tmp_saldo1(
		no_documento    	CHAR(20),
		monto           	DEC(16,2),
		no_poliza       	CHAR(10),
		pagado		    	DEC(16,2),
		monto_no_cubierto 	DEC(16,2),
		no_unidad           CHAR(5),
		cod_asegurado       CHAR(10),
		deducible           dec(16,2),
		fecha               date
		) WITH NO LOG;

-- SET DEBUG FILE TO "sp_atc03.trc";      
-- TRACE ON;                                                                     

let v_monto = 0.00;
let _flag   = 1;

foreach
 select no_recibo,
        monto,
	    prima_neta,
	    no_remesa,
		no_poliza,
		doc_remesa
   into v_documento,
        v_monto,
	    v_prima,
   	    _no_remesa,
		_no_poliza,
		_no_documento
   from cobredet
  where cod_compania = "001"
    and actualizado  = 1
	and tipo_mov     in ('P', 'N')
	and periodo[1,4] = a_ano

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> "018" then 
		continue foreach;
	end if

	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cantidad > 1 then
		continue foreach;
	end if

	select cod_asegurado,
	       no_unidad
	  into _cod_contratante,
	       _no_unidad
	  from emipouni
	 where no_poliza = _no_poliza;

	let v_monto = v_monto * -1;
	let v_prima = v_prima * -1;

	INSERT INTO tmp_saldo1(
	no_documento,
	monto,
	no_poliza,
	pagado,		    	
	monto_no_cubierto,
	no_unidad,        
	cod_asegurado    
	)
	VALUES(
	_no_documento,
	v_monto,    
	_no_poliza,
	0,
	0,
	_no_unidad,
	_cod_contratante
	);
	
end foreach

select cod_tipotran
  into _cod_tipotran
  from rectitra
 where tipo_transaccion = 4;

-- En vez de fecha de la transaccion se puso fecha de factura
-- Solicitado por Maruquel el 06/02/2007
-- Cambiado por Demetrio Hurtado

foreach
 select	no_reclamo,
        fecha,
        no_tranrec,
        fecha_factura
   into	_no_reclamo,
        _fecha_gasto,
        _no_tranrec,
        _fecha_factura
   from rectrmae
  where	cod_compania = "001"
    and actualizado  = 1
	and pagado       = 1
    and cod_tipotran = _cod_tipotran
    and (year(fecha_factura) = a_ano or (fecha_factura is null and year(fecha) = a_ano))

	select no_poliza,
	       no_unidad
	  into _no_poliza,
	       _no_unidad
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo,
	       no_documento
	  into _cod_ramo,
	       _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> "018" then 
		continue foreach;
	end if

	select cod_asegurado
	  into _cod_contratante
	  from emipouni
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	select sum(facturado),
	       sum(monto),
	       sum(monto_no_cubierto),
		   sum(a_deducible)
	  into _gasto_fact,
	       _pago_prov,
	       _monto_no_cubierto,
		   _deducible
	  from rectrcob
	 where no_tranrec = _no_tranrec;

	INSERT INTO tmp_saldo1(
	no_documento,
	monto,
	no_poliza,
	pagado,		    	
	monto_no_cubierto,
	no_unidad,        
	cod_asegurado,
	deducible,
	fecha    
	)
	VALUES(
	_no_documento,
	0,    
	_no_poliza,
	_pago_prov,
	_monto_no_cubierto,
	_no_unidad,
	_cod_contratante,
	_deducible,
	_fecha_factura
	);

end foreach

foreach
 select sum(monto),
	    sum(pagado),
	    sum(monto_no_cubierto),
		sum(deducible),
	    no_unidad,
	    cod_asegurado,
	    no_documento
   into v_monto,
	    _pago_prov,
	    _monto_no_cubierto,
		_deducible,
	    _no_unidad,
	    _cod_contratante,
   	    _no_documento
   from tmp_saldo1
  where year(fecha) = a_ano
  group by no_documento, no_unidad, cod_asegurado

	 select nombre,
			cedula,
			tipo_persona,
			digito_ver,
			pasaporte
	   into _nombre_asegurado,
	        _cedula,
			_tipo_persona,
			_digito_ver,
			_pasaporte
	   from cliclien
	  where cod_cliente = _cod_contratante;

    if _pasaporte = 1 then
		LET _tipo_per = 3;
	else
		if _tipo_persona = "N" then
			LET _tipo_per = 1;
		else
			LET _tipo_per = 2;
		end if
	end if

	let _tipo_error = 0;

	if _pasaporte = 1 then
		let _tipo_error = 0;
	elif _cedula is null or _cedula = ""  then
		let _tipo_error = 1;
	elif _digito_ver is null or _digito_ver = "" then
		let _tipo_error = 2;
	end if
	
  --	if _tipo_error <> 0 then

		RETURN _tipo_per,				  -- TIPO PERSONA
			   trim(_cedula),			  -- CEDULA
		       _digito_ver,			      -- DV
			   trim(_nombre_asegurado),	  -- ASEGURADO
			   _no_documento,			  -- DOCUMENTO
			   abs(v_monto),	          -- SALDO
			   _pago_prov,     		      -- MONTO
			   _monto_no_cubierto,   	  -- MONTO NO CUBIERTO
			   _cod_contratante,
			   _tipo_error,
			   _deducible
		   	   WITH RESUME;

   --	end if

end foreach

drop table tmp_saldo1;

end procedure