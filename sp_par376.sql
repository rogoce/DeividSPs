-- Procedure que genera los asientos contables para los ach de reclamos cliente Banisi
-- Creado el: 16/12/2008 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/09/2013 - Autor: Roman Gordon	-- Se Agrego el procedure sp_sis171a para llenar Chqreaco y chqreafa  
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par376;
create procedure sp_par376(
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

 let _cuenta_banco = sp_sis15('BACTAHOCH', '02', _cod_banco, _cod_chequera); -- Chequera Bancos Locales

-- Registros Contables

let _renglon = 0;

if a_origen_cheque = '3' then -- Cheques de Reclamos

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


end if

end 

return 0, "Actualizacion Exitosa ...";

end procedure