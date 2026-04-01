-- CONSULTA DE PRIMAS POR COBRAR
-- Procedimiento que extrae los Saldos de la Poliza
-- usado en carta declarativa de salud.
 
-- Creado    : 26/01/2004 - Autor: Armando Moreno M.
-- Modificado: 06/02/2012 - Autor: Roman Gordon			**Se modifico los montos pagados,no cubiertos y los presentados para que solo tome en 
--														  cuenta los realizados al cliente. 
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_atc011;

create procedure "informix".sp_atc011(
a_compania		char(3),
a_sucursal		char(3),
a_no_documento	char(20),
a_ano			integer,
a_usuario		char(10),
a_membrete		smallint default 0)

returning	char(20),					-- a_no_documento,
			varchar(100),				-- trim(_nombre_pagador),
            date,						-- v_fecha_min,
			date,						-- v_fecha_max,  
			dec(16,2),					-- abs(v_monto),
			varchar(30),				-- trim(_cedula),
			varchar(100),				-- trim(_nombre_asegurado),
			varchar(50),				-- trim(_nombre_ramo),
			smallint,					-- _flag,
			date,						-- v_fecha_rec_min,
			date,						-- v_fecha_rec_max,
			dec(16,2),					-- _gasto_fact,
			dec(16,2),					-- _pago_prov,
			char(1),					-- _tipo_persona,
			char(10),					-- a_usuario,
			smallint,					-- a_ano,
			varchar(20),				-- trim(v_firma_cartas),
			varchar(20),				-- trim(v_cedula_cartas),
			varchar(30),				-- trim(v_nombre_completo),
			varchar(50),				-- trim(v_cargo),
			dec(16,2),					-- _monto_no_cubierto,
			char(10),					-- _no_poliza,
			datetime year to second,	-- v_fecha_genera,
			char(2);					-- _digito_ver;

define _nombre_asegurado 	varchar(100);
define _nombre_pagador   	varchar(100);
define _nombre_ramo		 	varchar(50);
define v_cargo           	varchar(50);
define v_nombre_completo 	varchar(30);
define v_firma_cartas		varchar(20);
define v_cedula_cartas		varchar(20);
define _tipo_fac         	char(30);
define v_referencia       	char(20);
define v_documento        	char(20);
define _numrecla			char(20);
define _no_poliza        	char(10);
define _cod_contratante  	char(10);
define _cod_pagador      	char(10);
define _cod_cliente			char(10);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _no_unidad			char(10);
define _no_requis		 	char(10);
define _no_remesa		 	char(10);
define _periodo				char(7);
define v_periodo          	char(7);
define _cod_banco        	char(3);
define _cod_ramo	     	char(3);
define _cod_tipotran    	char(3);
define v_cod_endomov      	char(3);
define v_cod_tipocan      	char(3);
define _cod_tipoprod      	char(3);
define _cod_tipopago		char(3);
define _digito_ver			char(2);
define _status              char(1);
define _tipo_persona    	char(1);
define _nueva_renov      	char(1);
define _tipo_remesa      	char(1);
define v_monto            	dec(16,2);
define v_prima            	dec(16,2);
define v_saldo            	dec(16,2);
define _gasto_fact			dec(16,2);
define _pago_prov			dec(16,2);
define _monto_no_cubierto	dec(16,2);
define _pagado           	smallint;
define _anulado          	smallint;
define _ramo_sis	     	smallint;
define _flag			 	smallint;
define _saber_cobro		 	smallint;
define _saber_reclamo	 	smallint;
define _sindato			 	smallint;
define _fecha_gasto			date;
define _fecha_siniestro		date;
define v_fecha_rec_min  	date;
define v_fecha_rec_max		date;
define v_fecha		      	date;
define v_fecha_min        	date;
define v_fecha_max        	date;
define _fecha_factura     	date;
define v_fecha_genera		datetime year to second;
define _cedula				varchar(30);


SET ISOLATION TO DIRTY READ;

--DROP TABLE tmp_saldo1;

let _flag = 0;
let _saber_reclamo = 0;
let _saber_cobro   = 0;
let _sindato       = 0;

create temp table tmp_saldo1(
        fecha           date,
		referencia      char(20),
		no_documento    char(20),
		monto           dec(16,2),
		prima_neta      dec(16,2),
		periodo			char(7),
		no_poliza       char(10),
		tipo_fac        char(30)
		) with no log;

create temp table tmp_rec1(
        fecha           	date,
		facturado       	dec(16,2),
		pagado		    	dec(16,2),
		monto_no_cubierto 	dec(16,2),
		cod_cliente         char(10),
		no_tranrec          char(10)
		) with no log;   



foreach
 select no_poliza,
        nueva_renov,
		cod_ramo
   into _no_poliza,
        _nueva_renov,
		_cod_ramo
   from emipomae
  where no_documento = a_no_documento
    and actualizado  = 1

	foreach
	 select a.no_recibo,
	        a.monto,
		    a.prima_neta,
		    a.no_remesa,
			b.fecha,
		    b.tipo_remesa,
			b.periodo
	   into v_documento,
	        v_monto,
		    v_prima,
	   	    _no_remesa,
			v_fecha,		
			_tipo_remesa,
			v_periodo   
	   from cobredet a, cobremae b
	  where a.no_remesa   = b.no_remesa
	    and a.no_poliza   = _no_poliza
	    and a.actualizado = 1
		and a.tipo_mov in ('P', 'N')
		and b.tipo_remesa <> 'T'

	   --	LET v_monto = v_monto * -1;
	   --	LET v_prima = v_prima * -1;

		{SELECT fecha,
		       tipo_remesa,
			   periodo
		  INTO v_fecha,		
			   _tipo_remesa, 
			   v_periodo   
		  FROM cobremae
		 WHERE no_remesa = _no_remesa;

        IF _tipo_remesa = 'T' THEN -->Se excluye elimininacion de centavos
			CONTINUE FOREACH;
		END IF
		}
	    if   _tipo_remesa = 'C' then
	      let v_referencia = 'COMPROBANTE';
		else
	      let v_referencia = 'RECIBO';
	    end if

		let _tipo_fac = 'REMESA ' || _no_remesa;

		insert into tmp_saldo1(
		fecha,
		referencia,
		no_documento,
		monto,
		prima_neta,
		periodo,
		no_poliza,
		tipo_fac
		)
   		values(
		v_fecha,
		v_referencia,		
		v_documento,
		v_monto,    
		v_prima,    
		v_periodo,   
		_no_poliza,
		_tipo_fac
	    );

	end foreach

    -- devolucion de prima
	foreach 
	 select a.fecha_impresion,
			b.no_documento,
			b.prima_neta,
			b.monto
	   into v_fecha,
			v_documento,
			v_prima,
			v_monto
	   from chqchmae a, chqchpol b
	  where a.no_requis = b.no_requis
	    and year(a.fecha_impresion) = a_ano
		and b.no_poliza = _no_poliza
		and a.pagado           = 1
		and a.origen_cheque    = 6
	--	and anulado          = 0

	--	foreach
		{ select no_documento,
				prima_neta,
				monto
		   into v_documento,
				v_prima,
				v_monto
		   from chqchpol
		  where no_poliza = _no_poliza
	   }
	        let v_prima = v_prima * -1;
	        let v_monto = v_monto * -1;

			insert into tmp_saldo1(
			fecha,
			referencia,
			no_documento,
			monto,
			prima_neta,
			periodo,
			no_poliza,
			tipo_fac
			)
			values(
			v_fecha,
			"",		
			v_documento,
			v_monto,    
			v_prima,    
			"",   
			_no_poliza,
			""
		    );

	 --	end foreach

	end foreach

    -- devolucion de prima anulados
	foreach 
	 select a.fecha_impresion,
			b.no_documento,
			b.prima_neta,
			b.monto
	   into v_fecha,
			v_documento,
			v_prima,
			v_monto
	   from chqchmae a, chqchpol b
	  where a.no_requis = b.no_requis
	    and year(a.fecha_impresion) = a_ano
		and b.no_poliza = _no_poliza
		and a.pagado           = 1
		and a.origen_cheque    = 6
		and a.anulado          = 1

	   {	FOREACH
		 SELECT no_documento,
				prima_neta,
				monto
		   INTO v_documento,
				v_prima,
				v_monto
		   FROM chqchpol
		  WHERE no_poliza = _no_poliza
		}
			insert into tmp_saldo1(
			fecha,
			referencia,
			no_documento,
			monto,
			prima_neta,
			periodo,
			no_poliza,
			tipo_fac
			)
			values(
			v_fecha,
			"",		
			v_documento,
			v_monto,    
			v_prima,    
			"",   
			_no_poliza,
			""
		    );

		--end foreach

	end foreach
    
end foreach

 select min(fecha),
		max(fecha),
        sum(monto)
   into v_fecha_min,
        v_fecha_max,
        v_monto
   from tmp_saldo1
  where year(fecha) = a_ano;

if v_fecha_min is null then
	let _saber_cobro = 1;
end if

 let _no_poliza = sp_sis21(a_no_documento);

 select cod_contratante,
		cod_pagador
   into _cod_contratante,
        _cod_pagador
   from emipomae
  where no_poliza = _no_poliza;

 select nombre,
		cedula,
		tipo_persona,
		digito_ver
   into _nombre_pagador,
        _cedula,
		_tipo_persona,
		_digito_ver
   from cliclien
  where cod_cliente = _cod_pagador;

 select nombre
   into _nombre_asegurado
   from cliclien
  where cod_cliente = _cod_contratante;

 select nombre,
		ramo_sis
   into _nombre_ramo,
		_ramo_sis
   from prdramo
  where cod_ramo = _cod_ramo;

let _monto_no_cubierto = 0.00;

 if _ramo_sis <> 5 then		--si no es salud
	let _flag = 1;
	let _pago_prov  = 0;
	let _gasto_fact = 0;
	let v_fecha_rec_min = today;
	let v_fecha_rec_max = today;
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
	  where	no_documento   = a_no_documento
	    and actualizado    = 1

		foreach
			 select fecha,
					no_tranrec,
					fecha_factura,
					cod_tipopago,
					cod_tipotran,
					cod_cliente
			   into	_fecha_gasto,
					_no_tranrec,
					_fecha_factura,
					_cod_tipopago,
					_cod_tipotran,
					_cod_cliente					
			   from rectrmae
			  where no_reclamo   = _no_reclamo
			    and actualizado  = 1
				and cod_tipotran in ('004','013')


			if _cod_tipopago = '003' and _cod_tipotran = '004' then --Pago a Asegurado
				select sum(facturado),
					   sum(monto),
					   sum(monto_no_cubierto)
				  into _gasto_fact,
					   _pago_prov,
					   _monto_no_cubierto
				  from rectrcob
				 where no_tranrec = _no_tranrec;

			elif _cod_tipotran = '013' and _cod_cliente = _cod_contratante then

				let _gasto_fact = 0.00;
				let _pago_prov	= 0.00;
				
				select sum(monto_no_cubierto),
				       sum(facturado)
				  into _monto_no_cubierto,
				       _gasto_fact
				  from rectrcob
				 where no_tranrec = _no_tranrec;
				
			else
				let	_gasto_fact = 0.00;
				let	_pago_prov	= 0.00;
				let	_monto_no_cubierto = 0.00;
		   	end if

			if _fecha_factura is null then
				let _fecha_factura = _fecha_gasto;
			end if

			-- En vez de fecha de la transaccion de puso fecha de factura
			-- Solicitado por Maruquel el 06/02/2007
			-- Cambiado por Demetrio Hurtado

			insert into tmp_rec1(
			fecha,
			facturado,
			pagado,
			monto_no_cubierto,
			cod_cliente,
			no_tranrec
			)
			values(
			_fecha_factura,
			_gasto_fact,
			_pago_prov,
			_monto_no_cubierto,
			_cod_cliente,
			_no_tranrec
		    );
		end foreach
	end foreach

	 select min(fecha),
			max(fecha),
	        sum(facturado),
			sum(pagado),
			sum(monto_no_cubierto)
	   into v_fecha_rec_min,
	        v_fecha_rec_max,
	        _gasto_fact,
			_pago_prov,
			_monto_no_cubierto
	   from tmp_rec1
	  where year(fecha) = a_ano;

	if v_fecha_rec_min is null then
		let _saber_reclamo = 1;
	end if
 end if

drop table tmp_saldo1;
--drop table tmp_rec1;

if _saber_cobro = 1 and _saber_reclamo = 1 then  --no tiene datos
	let _sindato = 1;
elif _saber_reclamo = 1 then
	let _sindato = 2;
	let _flag = 1;
end if

if v_monto is null then
	let v_monto = 0.00;
end if

if _gasto_fact is null then
	let _gasto_fact = 0.00;
end if

if _pago_prov is null then
	let _pago_prov = 0.00;
end if

-- Buscando Firma y Cedula de la Carta

select valor_parametro 
  into v_firma_cartas
  from inspaag
 where codigo_parametro = "firma_cartas"; 

select valor_parametro 
  into v_cedula_cartas
  from inspaag
 where codigo_parametro = "cedula_cartas"; 

select descripcion,status 
  into v_nombre_completo,_status
  from insuser
 where usuario = v_firma_cartas;
 
 if _status = "A" then
 else

	select valor_parametro 
	  into v_firma_cartas
	  from inspaag
	 where codigo_parametro = "firma_carta2"; 
	
	select valor_parametro 
	  into v_cedula_cartas
	  from inspaag
	 where codigo_parametro = "cedula_carta2";

	select descripcion,
	       status 
	  into v_nombre_completo,
	       _status
	  from insuser
	 where usuario = v_firma_cartas;

 end if 

select cargo
  into v_cargo
  from wf_firmas
 where usuario = trim(v_firma_cartas);

let v_fecha_genera = current;

  return a_no_documento,
		 trim(_nombre_pagador),
         v_fecha_min,
		 v_fecha_max,  
		 abs(v_monto),
		 trim(_cedula),
		 trim(_nombre_asegurado),
		 trim(_nombre_ramo),
		 _flag,
		 v_fecha_rec_min,
		 v_fecha_rec_max,
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
		 _digito_ver;

END PROCEDURE