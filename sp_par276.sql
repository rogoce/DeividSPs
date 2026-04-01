-- Procedure que genera los asientos contables para los cheques
-- Creado el: 16/12/2008 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/09/2013 - Autor: Roman Gordon	-- Se Agrego el procedure sp_sis171a para llenar Chqreaco y chqreafa  
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par276;
create procedure sp_par276(
a_no_requis	  	char(10),
a_origen_cheque	char(1)
) returning integer,
			char(50);

-- Variables Generales

define _cuenta			char(25);
define _cuenta_banco	char(25);
define _renglon			integer;
define _debito      	dec(16,2);
define _credito     	dec(16,2);
define _centro_costo	char(3);
define _cod_banco		char(3);
define _cod_chequera	char(3);
define _cod_origen		char(3);
define _cta_chequera  	smallint;
define _monto  	    	dec(16,2);
define _fecha_impresion	date;
define _bono_salud      smallint;

-- Otros Cheques

define _centro_costo2	char(3);
define _monto_cheque   	dec(16,2);

-- Devolucion de Primas

define _no_poliza		CHAR(10);
define _no_documento	char(20);
define _prima_bruta     DEC(16,2);
define _prima_neta      DEC(16,2);
define _cod_tipoprod    CHAR(3);  
define _cod_ramo		char(3);
define _tipo_produccion	smallint; 
define _impuesto	    DEC(16,2);
define _suma_impuesto	DEC(16,2);
define _cant_impuestos	integer;
define _cod_impuesto	char(3);
define _factor_impuesto	dec(5,2);
define _cuenta_inc	   	char(25);
define _cuenta_dan	   	char(25);
define _porc_comis_agt  dec(5,2);
define _porc_partic_agt	dec(5,2);
define _prima_suscrita  dec(16,2);


-- Cheques de Reclamos

define _transaccion		char(10);
define _no_tranrec		char(10);

-- Cheques de Comisiones

define _monto_ajuste		dec(16,2);
define _monto_comision		dec(16,2);
define _comision			dec(16,2);
define _porc_partic_coas	decimal(7,4);
define _cod_agente			char(10);
define _tipo_agente			char(1);
define _tipo_requis			char(1);
define _cod_coasegur 		char(3);
define _cod_lider	 		char(3);
define _cod_auxiliar 		char(5);
define _cod_subramo			char(3);
define _adelanto_comis		smallint;
define _comision_ganada		dec(16,2);
define _comision_saldo		dec(16,2);
define _prima_chqcomis		dec(16,2);
define _cta_auxiliar        char(1);
define _dif_monto			dec(16,2);

-- Variables de Error

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

if a_no_requis = '1108563' then
	set debug file to "sp_par276.trc";
	trace on;
end if
-- Cuenta del Banco

select cod_banco,
       cod_chequera,
	   monto,
	   centro_costo,
	   fecha_impresion
  into _cod_banco,
       _cod_chequera,
	   _monto_cheque,
	   _centro_costo2,
	   _fecha_impresion
  from chqchmae
 where no_requis = a_no_requis;

select cod_origen,
	   cta_chequera
  into _cod_origen,
	   _cta_chequera
  from chqbanco
 where cod_banco = _cod_banco;

if _cod_origen = '001' then
	if _cta_chequera = 1 then
		let _cuenta_banco = sp_sis15('BACHEQL', '02', _cod_banco, _cod_chequera); -- Chequera Bancos Locales
	else
		let _cuenta_banco = sp_sis15('BACHEBL', '02', _cod_banco); -- Chequera Bancos Locales
	end if
else
	let _cuenta_banco = sp_sis15('BACHEBE', '02', _cod_banco); -- Chequera Bancos Extranjeros
end if

-- Registros Contables

let _renglon = 0;

if a_origen_cheque = '6' then -- Devolucion de Primas

	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;

	select par_ase_lider
	  into _cod_lider
	  from parparam
	 where cod_compania = "001";

	--Llenar Chqreaco y chqreafa  
	call sp_sis171a(a_no_requis) returning _error,_error_desc;
	if _error <> 0 then
		return _error,_error_desc;
	end if
	--
	foreach
	 select	no_poliza,
			monto,
			prima_neta,
			no_documento
	   into	_no_poliza,
	        _prima_bruta,
			_prima_neta,
			_no_documento
	   from	chqchpol
	  where	no_requis = a_no_requis

		select cod_tipoprod,
		       cod_ramo
		  into _cod_tipoprod,
		       _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;
		
		if _cod_ramo = '024' then
			call sp_par2763en1(a_no_requis,a_origen_cheque,_no_poliza) returning _error, _error_desc;
			continue foreach;
		end if

		call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

		select tipo_produccion
		  into _tipo_produccion
		  from emitipro
		 where cod_tipoprod = _cod_tipoprod;

		-- Prima Neta

		if _tipo_produccion = 3 then 
			let _cuenta = sp_sis15('PACXCC',  '01', _no_poliza); -- Coaseguro Minoritario
		else
			let _cuenta = sp_sis15('PAPXCSD', '01', _no_poliza); -- Produccion Directa
		end if
		
		select max(renglon)
		  into _renglon
		  from chqchcta
		 where no_requis = a_no_requis;
		 
		if _renglon is null then
			let _renglon = 0;
		end if
		let _renglon = _renglon + 1;
		let _debito  = _prima_neta;
		let _credito = 0.00;

		insert into chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo,
		no_poliza
		)
		values(
		a_no_requis,
		_renglon,
		_cuenta,
		_debito,
		0,
		_centro_costo,
		_no_poliza
		);

		-- Impuestos

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
				let _renglon = _renglon + 1;

				INSERT INTO chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito,
				centro_costo,
				no_poliza
				)
				VALUES(
				a_no_requis,
				_renglon,
				_cuenta,
				_debito,
				0,
				_centro_costo,
				_no_poliza
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

		---------------------------------------------------------------------------------------
		
		-- Provision de Comision y Comision por Pagar (Auxiliar)

		if _tipo_produccion in (1, 2, 3) then
		
			select porc_partic_coas
			  into _porc_partic_coas
			  from emicoama
			 where no_poliza    = _no_poliza
			   and cod_coasegur = _cod_lider;
			
			if _porc_partic_coas is null then
				let _porc_partic_coas = 100;
			end if

			let _prima_suscrita = _prima_neta * _porc_partic_coas / 100;

			foreach
			 select	porc_comis_agt,
					porc_partic_agt,
					cod_agente
			   into	_porc_comis_agt,
					_porc_partic_agt,
					_cod_agente
			   from chqchpoa
			  where	no_requis    = a_no_requis
			    and no_documento = _no_documento
	
				select tipo_agente
				  into _tipo_agente
				  from agtagent
				 where cod_agente = _cod_agente;

				if _tipo_agente = "O" then -- Oficina
					continue foreach;
				end if

				if _porc_comis_agt = 0 THEN
					continue foreach;
				end if

				let _monto = _prima_suscrita * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);

				if _monto = 0.00 Then
					continue foreach;
				end if

				let _cod_auxiliar = "A" || _cod_agente[2,5]; -- En SAC no alcanza para poner los 5 digitos

				-- Provision de Comision

				Let _debito  = 0.00;
				Let _credito = 0.00;

				IF _monto >= 0 THEN
					LET _credito = _monto;
				ELSE
					LET _credito = _monto * -1;
				END IF

				let _cuenta  = sp_sis15('PPCOMXPCO', '01', _no_poliza); 
				let _renglon = _renglon + 1;

				INSERT INTO chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito,
				centro_costo,
				no_poliza
				)
				VALUES(
				a_no_requis,
				_renglon,
				_cuenta,
				_debito,
				_credito,
				_centro_costo,
				_no_poliza
				);

				-- Comisiones por Pagar Auxiliar

				Let _debito  = 0.00;
				Let _credito = 0.00;

				if _monto >= 0 then
					Let _debito  = _monto;
				else
					Let _debito  = _monto * -1;
				end if

				let _cuenta  = sp_sis15('CPCXPAUX', '01', _no_poliza); 
				let _renglon = _renglon + 1;

				INSERT INTO chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito,
				centro_costo,
				no_poliza,
				cod_auxiliar
				)
				VALUES(
				a_no_requis,
				_renglon,
				_cuenta,
				_debito,
				_credito,
				_centro_costo,
				_no_poliza,
				_cod_auxiliar
				);

				insert into	chqctaux(
				no_requis,
				renglon,
				cuenta,
				cod_auxiliar,
				debito,
				credito,
				centro_costo
				)
				values(
				a_no_requis,
				_renglon,
				_cuenta,
				_cod_auxiliar,
				_debito,
				_credito,
				_centro_costo
				);

			end foreach
			
		end if		

		
		---------------------------------------------------------------------------------------	

		-- Cuenta del Banco

		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo,
		no_poliza
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		0,
		_prima_bruta,
		_centro_costo,
		_no_poliza
		);

	end foreach

elif a_origen_cheque = '3' then -- Cheques de Reclamos

	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;

	let _cuenta  = sp_sis15('BCXPP'); 

	foreach
	 select transaccion,
			monto
	   into _transaccion,
			_monto
	   from chqchrec
	  where no_requis = a_no_requis

		select no_tranrec
		  into _no_tranrec
		  from rectrmae
		 where transaccion = _transaccion;

		update rectrmae
		   set pagado       = 1,
			   no_requis    = a_no_requis,
			   fecha_pagado = _fecha_impresion
		 where transaccion  = _transaccion;

		call sp_sac93(_no_tranrec, 2) returning _error, _error_desc, _centro_costo;

		IF _monto > 0 THEN
			LET  _debito  = _monto;
			LET  _credito = 0;
		ELSE
			LET  _debito  = 0;
			LET  _credito = _monto * -1;
		END IF

		-- Cuenta de Reclamos por Pagar

		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_debito,
		_credito,
		_centro_costo
		);
		
		-- Cuenta del Banco

		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		_credito,
		_debito,
		_centro_costo
		);

	end foreach

elif a_origen_cheque = '2' then -- Cheques de Comisiones

	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;

	select par_ase_lider
	  into _cod_lider
	  from parparam
	 where cod_compania = "001";
	let _bono_salud = 0;
	foreach
	 select no_poliza,
	        comision,
			cod_agente,
			anticipo_comis,
			prima,
			porc_partic,
			porc_comis,
			bono_salud
	   into _no_poliza,
	        _comision,
			_cod_agente,
			_adelanto_comis,
			_prima_chqcomis,
			_porc_partic_agt,
			_porc_comis_agt,
			_bono_salud
	   from chqcomis
	  where no_requis = a_no_requis
    
		let _monto_ajuste   = 0.00;
		let _monto_comision = 0.00;

		if _no_poliza = "00000" then -- Comision Descontada
		
			call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

			let _cod_ramo    = "002";
			let _cod_subramo = "001";

		else -- Comision Pagada
		
			call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

			select cod_ramo,
			       cod_subramo
			  into _cod_ramo,
			       _cod_subramo
			  from emipomae
			 where no_poliza = _no_poliza;

		end if	

		let _monto = _comision;

		let _monto_ajuste   = _monto_ajuste   + _monto;
		let _monto_comision = _monto_comision + _comision;
		 
		-- Comision por Pagar

		let _debito  = 0.00;
		let _credito = 0.00;

		if _monto > 0 then
			let _debito  = _monto;
		else
			let _credito = _monto * -1;
		end if
		
		if _adelanto_comis = 1 then
			select no_documento
			  into _no_documento
			  from emipomae
			 where no_poliza = _no_poliza;

			let _comision_ganada = _prima_chqcomis * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);

			update cobadeco
			   set comision_saldo	= comision_saldo - _comision_ganada,
				   comision_ganada	= comision_ganada + _comision_ganada
			 where no_documento		= _no_documento;
			
			let _comision_saldo = 0.00;
			
			select comision_saldo
			  into _comision_saldo
			  from cobadeco
			 where no_documento = _no_documento;

			if abs(_comision_saldo) <= 0.10 then
				{delete from cobadeco
				 where no_documento = _no_documento;}
			end if
			
			let _cuenta = sp_sis15('CPCADECOM', '01', _no_poliza); 
		else
		    if _bono_salud = 0 then
				let _cuenta = sp_sis15('CPCXPAUX',  '03', _cod_agente);
			else	
				Let _cuenta    = sp_sis15('PGCOMCO', '01', _no_poliza);	--para bono de 100 polizas de salud, va a la cta de gasto. 14/04/2015
			end if	
		end if

		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_debito,
		_credito,
		_centro_costo
		);

		let _cod_auxiliar = sp_sis89(2, _cod_agente);
		
		SELECT cta_auxiliar
		  INTO _cta_auxiliar
		  FROM cglcuentas
		 WHERE cta_cuenta = _cuenta;
		 
		if _cod_auxiliar is not null And _cta_auxiliar = 'S' then

			insert into	chqctaux(
			no_requis,
			renglon,
			cuenta,
			cod_auxiliar,
			debito,
			credito,
			centro_costo
			)
			values(
			a_no_requis,
			_renglon,
			_cuenta,
			_cod_auxiliar,
			_debito,
			_credito,
			_centro_costo
			);

		end if

		-- Coaseguro por Pagar

	   {	
	   foreach	
		select cod_coasegur,
		       porc_partic_coas
		  into _cod_coasegur,
		       _porc_partic_coas
		  from emicoama
		 where no_poliza    =  _no_poliza
    	   and cod_coasegur <> _cod_lider

			let _debito  = 0.00;
			let _credito = 0.00;

			let _monto = _comision * _porc_partic_coas / 100;
			let _monto_ajuste = _monto_ajuste + _monto;

			if _monto > 0 then
				let _debito  = _monto;
			else
				let _credito = _monto * -1;
			end if

			let _cuenta  = sp_sis15("PPCOASXP", '01', _no_poliza);   
			let _renglon = _renglon + 1;

			INSERT INTO chqchcta(
			no_requis,
			renglon,
			cuenta,
			debito,
			credito,
			centro_costo
			)
			VALUES(
			a_no_requis,
			_renglon,
			_cuenta,
			_debito,
			_credito,
			_centro_costo
			);

			let _cod_auxiliar = sp_sis89(1, _cod_coasegur);

			if _cod_auxiliar is not null then

				insert into	chqctaux(
				no_requis,
				renglon,
				cuenta,
				cod_auxiliar,
				debito,
				credito,
				centro_costo
				)
				values(
				a_no_requis,
				_renglon,
				_cuenta,
				_cod_auxiliar,
				_debito,
				_credito,
				_centro_costo
				);

			end if

		end foreach
	   }

		-- Ajuste por Calculo

		let _monto = _monto_comision - _monto_ajuste;

		if _monto <> 0.00 then

			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0 then
				let _debito  = _monto;
			else
				let _credito = _monto * -1;
			end if
			if _bono_salud = 0 then
				let _cuenta  = sp_sis15('CPCXPAUX', '03', _cod_agente);
			else
				LET _cuenta = sp_sis15('PGCOMCO', '01', _no_poliza);	--para bono de 100 polizas de salud, va a la cta de gasto. 14/04/2015
			end if			
			let _renglon = _renglon + 1;

			INSERT INTO chqchcta(
			no_requis,
			renglon,
			cuenta,
			debito,
			credito,
			centro_costo
			)
			VALUES(
			a_no_requis,
			_renglon,
			_cuenta,
			_debito,
			_credito,
			_centro_costo
			);

			let _cod_auxiliar = sp_sis89(2, _cod_agente);
			
			SELECT cta_auxiliar
			  INTO _cta_auxiliar
			  FROM cglcuentas
			 WHERE cta_cuenta = _cuenta;
		 
			if _cod_auxiliar is not null And _cta_auxiliar = 'S' then			

				insert into	chqctaux(
				no_requis,
				renglon,
				cuenta,
				cod_auxiliar,
				debito,
				credito,
				centro_costo
				)
				values(
				a_no_requis,
				_renglon,
				_cuenta,
				_cod_auxiliar,
				_debito,
				_credito,
				_centro_costo
				);

			end if

		end if

		-- Cuenta del Banco

		let _renglon = _renglon + 1;

		let _debito  = 0.00;
		let _credito = 0.00;

		if _comision > 0 then
			let _credito = _comision;
		else
			let _debito = _comision * -1;
		end if

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		_debito,
		_credito,
		_centro_costo
		);

	end foreach

elif a_origen_cheque = '7' then -- Honorarios Profesionales

	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;

	select par_ase_lider
	  into _cod_lider
	  from parparam
	 where cod_compania = "001";

	foreach
	 select no_poliza,
	        comision,
			cod_agente,
			bono_salud
	   into _no_poliza,
	        _comision,
			_cod_agente,
			_bono_salud
	   from chqcomis
	  where no_requis = a_no_requis
    
		let _monto_ajuste   = 0.00;
		let _monto_comision = 0.00;

		if _no_poliza = "00000" then -- Comision Descontada
		
			call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

			let _cod_ramo    = "002";
			let _cod_subramo = "001";

		else -- Comision Pagada
		
			call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

			select cod_ramo,
			       cod_subramo
			  into _cod_ramo,
			       _cod_subramo
			  from emipomae
			 where no_poliza = _no_poliza;

		end if	

		let _monto = _comision;
		
		let _monto_ajuste   = _monto_ajuste   + _monto;
		let _monto_comision = _monto_comision + _comision;
		 
		-- Comision por Pagar

		let _debito  = 0.00;
		let _credito = 0.00;

		if _monto > 0 then
			let _debito  = _monto;
		else
			let _credito = _monto * -1;
		end if
		if _bono_salud = 0 then
			LET _cuenta = sp_sis15('CPCXPAUX', '03', _cod_agente);
		else
			LET _cuenta = sp_sis15('PGCOMCO', '01', _no_poliza);	--para bono de 100 polizas de salud, va a la cta de gasto. 14/04/2015
		end if

		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_debito,
		_credito,
		_centro_costo
		);

		let _cod_auxiliar = sp_sis89(2, _cod_agente);
		
		SELECT cta_auxiliar
		  INTO _cta_auxiliar
		  FROM cglcuentas
		 WHERE cta_cuenta = _cuenta;
		 
		if _cod_auxiliar is not null And _cta_auxiliar = 'S' then

			insert into	chqctaux(
				no_requis,
				renglon,
				cuenta,
				cod_auxiliar,
				debito,
				credito,
				centro_costo
				)
				values(
				a_no_requis,
				_renglon,
				_cuenta,
				_cod_auxiliar,
				_debito,
				_credito,
				_centro_costo
				);

		end if

		-- Coaseguro por Pagar

	   {	
	   foreach	
		select cod_coasegur,
		       porc_partic_coas
		  into _cod_coasegur,
		       _porc_partic_coas
		  from emicoama
		 where no_poliza    =  _no_poliza
    	   and cod_coasegur <> _cod_lider

			let _debito  = 0.00;
			let _credito = 0.00;

			let _monto = _comision * _porc_partic_coas / 100;
			let _monto_ajuste = _monto_ajuste + _monto;

			if _monto > 0 then
				let _debito  = _monto;
			else
				let _credito = _monto * -1;
			end if

			let _cuenta  = sp_sis15("PPCOASXP", '01', _no_poliza);   
			let _renglon = _renglon + 1;

			INSERT INTO chqchcta(
			no_requis,
			renglon,
			cuenta,
			debito,
			credito,
			centro_costo
			)
			VALUES(
			a_no_requis,
			_renglon,
			_cuenta,
			_debito,
			_credito,
			_centro_costo
			);

			let _cod_auxiliar = sp_sis89(1, _cod_coasegur);

			if _cod_auxiliar is not null then

				insert into	chqctaux(
				no_requis,
				renglon,
				cuenta,
				cod_auxiliar,
				debito,
				credito,
				centro_costo
				)
				values(
				a_no_requis,
				_renglon,
				_cuenta,
				_cod_auxiliar,
				_debito,
				_credito,
				_centro_costo
				);

			end if

		end foreach
		}

		-- Ajuste por Calculo

		let _monto = _monto_comision - _monto_ajuste;

		if _monto <> 0.00 then

			let _debito  = 0.00;
			let _credito = 0.00;

			if _monto > 0 then
				let _debito  = _monto;
			else
				let _credito = _monto * -1;
			end if
			if _bono_salud = 0 then
				LET _cuenta  = sp_sis15('CPCXPAUX', '03', _cod_agente);
			else
				LET _cuenta = sp_sis15('PGCOMCO', '01', _no_poliza);	--para bono de 100 polizas de salud, va a la cta de gasto. 14/04/2015
			end if	

			let _renglon = _renglon + 1;

			INSERT INTO chqchcta(
			no_requis,
			renglon,
			cuenta,
			debito,
			credito,
			centro_costo
			)
			VALUES(
			a_no_requis,
			_renglon,
			_cuenta,
			_debito,
			_credito,
			_centro_costo
			);

			let _cod_auxiliar = sp_sis89(2, _cod_agente);
			
			SELECT cta_auxiliar
			  INTO _cta_auxiliar
			  FROM cglcuentas
			 WHERE cta_cuenta = _cuenta;
		 
			if _cod_auxiliar is not null And _cta_auxiliar = 'S' then

				insert into	chqctaux(
				no_requis,
				renglon,
				cuenta,
				cod_auxiliar,
				debito,
				credito,
				centro_costo
				)
				values(
				a_no_requis,
				_renglon,
				_cuenta,
				_cod_auxiliar,
				_debito,
				_credito,
				_centro_costo
				);

			end if

		end if

		-- Cuenta del Banco

		let _renglon = _renglon + 1;

		let _debito  = 0.00;
		let _credito = 0.00;

		if _comision > 0 then
			let _credito = _comision;
		else
			let _debito = _comision * -1;
		end if

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		_debito,
		_credito,
		_centro_costo
		);

	end foreach

elif a_origen_cheque = '8' then -- Bonificacion de Cobranza

	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;

	foreach
	 select no_poliza,
	        cod_origen,
	        cod_ramo,
			cod_subramo,
		 	comision
	   into _no_poliza,
	        _cod_origen,
	   		_cod_ramo,
			_cod_subramo,
			_monto
	   from chqboni
	  where no_requis = a_no_requis

		call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

		-- Registros Contables de Honorarios por Pagar

		let _renglon = _renglon + 1 ;
		let _cuenta  = sp_sis15('INSRIE', "04", _cod_origen, _cod_ramo, _cod_subramo); --SE PONE POR CORREO DE ZULEYKA 19/10/2023
		
		insert into chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_monto,
		0,
		_centro_costo
		);

		let _cod_auxiliar = "05815";		 --Solicitud de Yasmin correo del 07/03/2024
		if _cod_auxiliar is not null then
			insert into	chqctaux(
			no_requis,
			renglon,
			cuenta,
			cod_auxiliar,
			debito,
			credito,
			centro_costo
			)
			values(
			a_no_requis,
			_renglon,
			_cuenta,
			_cod_auxiliar,
			_monto,
			0,
			_centro_costo
			);
		end if
		-- Cuenta del Banco

		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		0.00,
		_monto,
		_centro_costo
		);
		
	end foreach
	
elif a_origen_cheque = 'F' then -- Bonificacion de 1% Web

	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;

	foreach
	 select no_poliza,
	        cod_origen,
	        cod_ramo,
			cod_subramo,
		 	comision
	   into _no_poliza,
	        _cod_origen,
	   		_cod_ramo,
			_cod_subramo,
			_monto
	   from chqweb
	  where no_requis = a_no_requis

		call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

		-- Registros Contables de Honorarios por Pagar

		let _renglon = _renglon + 1 ;
		let _cuenta  = sp_sis15('INSRIE', "04", _cod_origen, _cod_ramo, _cod_subramo);    --SE PONE POR CORREO DE ZULEYKA 19/10/2023

		insert into chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_monto,
		0,
		_centro_costo
		);

		let _cod_auxiliar = "05817";		 --Solicitud de Yasmin correo del 07/03/2024
		if _cod_auxiliar is not null then
			insert into	chqctaux(
			no_requis,
			renglon,
			cuenta,
			cod_auxiliar,
			debito,
			credito,
			centro_costo
			)
			values(
			a_no_requis,
			_renglon,
			_cuenta,
			_cod_auxiliar,
			_monto,
			0,
			_centro_costo
			);
		end if
		-- Cuenta del Banco

		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		0.00,
		_monto,
		_centro_costo
		);

	end foreach
elif a_origen_cheque = '9' then -- Incentivo de Fidelidad

	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;

	foreach
	 select no_poliza,
	        cod_origen,
	        cod_ramo,
			cod_subramo,
		 	comision
	   into _no_poliza,
	        _cod_origen,
	   		_cod_ramo,
			_cod_subramo,
			_monto
	   from chqfidel
	  where no_requis = a_no_requis

		call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

		-- Registros Contables de Incentivo

		let _renglon = _renglon + 1 ;
		let _cuenta  = sp_sis15('PGCOMCO', "04", _cod_origen, _cod_ramo, _cod_subramo);

		insert into chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_monto,
		0,
		_centro_costo
		);

		-- Cuenta del Banco

		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		0.00,
		_monto,
		_centro_costo
		);

	end foreach

elif a_origen_cheque = 'D' then -- Bonificacion por Rentabilidad

	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;

	let _cod_origen = "001";

	call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

	foreach
	 select sum(comision)
	   into _monto
	   from chqrenta3
	  where no_requis = a_no_requis

		let _renglon = _renglon + 1 ;
        let _cuenta  = "266200171";	 -- Solicitud de Zuleyka A. caso 3396

		insert into chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_monto,
		0,
		_centro_costo
		);

		-- Se coloca en comentario: solicitud: ARMANDO fecha: 21/4/2016 Realizo: HENRY	tipos: D, H, G 
  
		let _cod_auxiliar = "03068";		 --Solicitud de Zuleyka A. caso 3396
		if _cod_auxiliar is not null then
			insert into	chqctaux(
			no_requis,
			renglon,
			cuenta,
			cod_auxiliar,
			debito,
			credito,
			centro_costo
			)
			values(
			a_no_requis,
			_renglon,
			_cuenta,
			_cod_auxiliar,
			_monto,
			0,
			_centro_costo
			);
		end if
				-- Cuenta del Banco
		let _renglon = _renglon + 1;
		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		0.00,
		_monto,
		_centro_costo
		);
	end foreach	
elif a_origen_cheque = 'I' then -- Bono de Vida Individual(Nuevas)   Cod_Ramo: 019, --ARMANDO: Colocar Prog. igual que rentabilidad2 28/02/2018

	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;
	
	let _cod_origen = "001";	
	let _cod_subramo = "005";
	call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

	foreach
		select cod_ramo,
			   cod_origen,
			   cod_subramo,
			   sum(monto_bono)
		  into _cod_ramo,
			   _cod_origen,
			   _cod_subramo,
			   _monto
		  from chqbono019
		 where no_requis = a_no_requis	 	  
		 group by 1,2,3

		let _dif_monto = _monto - _monto_cheque;
		let _monto = _monto - _dif_monto;
		let _renglon = _renglon + 1 ;
		let _cuenta  = sp_sis15('INSRIE', "04", _cod_origen, _cod_ramo, _cod_subramo);  --SE PONE POR CORREO DE ZULEYKA 19/10/2023

		insert into chqchcta(
				no_requis,
				renglon,
				cuenta,
				debito,
				credito,
				centro_costo)
		VALUES(	a_no_requis,
				_renglon,
				_cuenta,
				_monto,
				0,
				_centro_costo);
				
		let _cod_auxiliar = "05816";		 --Solicitud de Yasmin correo del 07/03/2024
		if _cod_auxiliar is not null then
			insert into	chqctaux(
			no_requis,
			renglon,
			cuenta,
			cod_auxiliar,
			debito,
			credito,
			centro_costo
			)
			values(
			a_no_requis,
			_renglon,
			_cuenta,
			_cod_auxiliar,
			_monto,
			0,
			_centro_costo
			);
		end if				

		-- Cuenta del Banco 

		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		0.00,
		_monto,
		_centro_costo
		);
		
	end foreach
elif a_origen_cheque = 'L' then -- Bonificacion prima nueva cobrada, proyecto CCP
	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;
	let _cod_origen = "001";
	call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;
	foreach
		select comision,
		       no_poliza
		  into _monto,
		       _no_poliza
		  from chqboccp
		 where no_requis = a_no_requis
		 
		select cod_ramo,
		       cod_subramo
		  into _cod_ramo,
               _cod_subramo
   	      from emipomae
		 where no_poliza = _no_poliza;

		let _renglon = _renglon + 1 ;
		let _cuenta  = sp_sis15('INSRIE', "04", _cod_origen, _cod_ramo, _cod_subramo);
		insert into chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_monto,
		0,
		_centro_costo
		);
		
		let _cod_auxiliar = "05820";		 --Solicitud de Yasmin correo del 07/03/2024
		if _cod_auxiliar is not null then
			insert into	chqctaux(
			no_requis,
			renglon,
			cuenta,
			cod_auxiliar,
			debito,
			credito,
			centro_costo
			)
			values(
			a_no_requis,
			_renglon,
			_cuenta,
			_cod_auxiliar,
			_monto,
			0,
			_centro_costo
			);
		end if
		-- Cuenta del Banco 
		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		0.00,
		_monto,
		_centro_costo
		);
		
	end foreach
elif a_origen_cheque = 'H' then -- Bonificacion por Produccion RAMOS GENERALES 
	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;
	let _cod_origen = "001";
	call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

	foreach
		select no_poliza,
		       comision
		  into _no_poliza,
		       _monto
		  from chqborege
		 where no_requis = a_no_requis
		
		select cod_ramo,
		       cod_subramo
		  into _cod_ramo,
               _cod_subramo
   	      from emipomae
		 where no_poliza = _no_poliza; 

		let _renglon = _renglon + 1 ;
		let _cuenta  = sp_sis15('INSRIE', "04", _cod_origen, _cod_ramo, _cod_subramo);

		insert into chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_monto,
		0,
		_centro_costo
		);
		
		let _cod_auxiliar = "05819";		 --Solicitud de Yasmin correo del 07/03/2024
		if _cod_auxiliar is not null then
			insert into	chqctaux(
			no_requis,
			renglon,
			cuenta,
			cod_auxiliar,
			debito,
			credito,
			centro_costo
			)
			values(
			a_no_requis,
			_renglon,
			_cuenta,
			_cod_auxiliar,
			_monto,
			0,
			_centro_costo
			);
		end if	
		
		-- Cuenta del Banco 
		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		0.00,
		_monto,
		_centro_costo
		);
		
	end foreach	

elif a_origen_cheque = 'R' then -- Bono Persistencia Anual SD#5742 cuenta # 266200171 Zuleyka
	delete from chqctaux where no_requis = a_no_requis;
	delete from chqchcta where no_requis = a_no_requis;
	
	let _cod_origen = "001";
	call sp_sac93("000", 99) returning _error, _error_desc, _centro_costo;

	foreach
		select monto_bono
		  into _monto
		  from chqbopersis
		 where no_requis = a_no_requis		

		let _renglon = _renglon + 1 ;
		let _cuenta  = "266200171";	 -- cuenta enviada por team  # 266200171 Zuleyka
	
		insert into chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta,
		_monto,
		0,
		_centro_costo
		);
		-- Cuenta del Banco 
		let _renglon = _renglon + 1;

		INSERT INTO chqchcta(
		no_requis,
		renglon,
		cuenta,
		debito,
		credito,
		centro_costo
		)
		VALUES(
		a_no_requis,
		_renglon,
		_cuenta_banco,
		0.00,
		_monto,
		_centro_costo
		);
		
	end foreach		

else -- Otros Cheques

	-- Cuenta del Banco

	select max(renglon)
	  into _renglon
	  from chqchcta
	 where no_requis = a_no_requis;

	let _renglon = _renglon + 1;

	INSERT INTO chqchcta(
	no_requis,
	renglon,
	cuenta,
	debito,
	credito,
	centro_costo
	)
	VALUES(
	a_no_requis,
	_renglon,
	_cuenta_banco,
	0.00,
	_monto_cheque,
	_centro_costo2
	);
end if
end 
return 0, "Actualizacion Exitosa ...";
end procedure