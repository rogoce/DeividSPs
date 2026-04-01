-- Actualizacion de Registros Segun el Tipo de Gestion

-- Creado    : 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/05/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.

drop procedure sp_cob159;	  

create procedure sp_cob159(
a_cod_cliente		char(10),
a_cod_cobrador 		char(3),
a_dia				smallint,
a_fecha				datetime year to fraction(5),
a_fecha_hora		datetime year to fraction(5)
)
returning integer,
          char(50);

define _dia_cobros1			integer;
define _dia_cobros2			integer;
define _dia1				integer;
define _dia2				integer;
define _cod_sucursal		char(3);
define _cod_cobrador		char(3);
define _fec		    		datetime year to fraction(5);
define _no_poliza		    char(10);
define _code_pais		    char(3);
define _code_provincia	    char(2);
define _code_ciudad  	    char(2);
define _code_distrito	    char(2);
define _code_correg  	    char(5);
define _cod_motiv   		char(3);
define _no_documento		char(20);
define _por_vencer          dec(16,2);
define _code_agente  	    char(5);
define _user_added		    CHAR(10);
define _apagar              dec(16,2);
define _saldo				dec(16,2);
define _exigible			dec(16,2);
define _corriente			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90            dec(16,2);
define _descripcion			CHAR(50);
define _cantidad			integer;
define _procedencia			integer;
define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _cnt_ruter			smallint;
define _cnt_cobruter2		smallint;

--set debug file to "sp_cob159.trc";
--trace on;

set isolation to dirty read;

let _por_vencer = 0;

begin

on exception set _error, _error_isam, _error_desc
 	return _error, _error_desc;         
end exception

let a_cod_cliente	= a_cod_cliente;
let a_cod_cobrador	= a_cod_cobrador;
let	a_dia			= a_dia;
let	a_fecha			= a_fecha;
let	a_fecha_hora	= a_fecha_hora;

foreach
	select dia_cobros1,
		   dia_cobros2
	  into _dia1,
	  	   _dia2
	  from cascliente
	 where cod_cliente = a_cod_cliente
	exit foreach;
end foreach

select a_pagar,
	   code_pais,
	   code_provincia,
	   code_ciudad,
	   code_distrito,
	   code_correg,
	   procedencia,
	   dia_cobros1,
	   saldo,
	   por_vencer,
	   exigible,
	   corriente,
	   monto_30,
	   monto_60,
 	   monto_90,
	   descripcion,
	   user_added,
	   dia_cobros2
  into _apagar,
  	   _code_pais,
	   _code_provincia,
	   _code_ciudad,
	   _code_distrito,
	   _code_correg,
	   _procedencia,
	   _dia_cobros1,
	   _saldo,
	   _por_vencer,
	   _exigible,
	   _corriente,
	   _monto_30,
	   _monto_60,
 	   _monto_90,
	   _descripcion,
	   _user_added,
	   _dia_cobros2		 
  from cobruter1
 where cod_cobrador = a_cod_cobrador
   and dia_cobros1  = a_dia
   and fecha        = a_fecha;

if _apagar is null then
	return 0, "";
end if
if _dia1 <> _dia_cobros1 then
	let _dia_cobros1 = _dia1;
end if
if _dia2 <> _dia_cobros2 then
	let _dia_cobros2 = _dia2;
end if

let _cod_cobrador = null;

if _descripcion is null then
	let _descripcion = "";
end if

--** borrar cobruter1 para ser insertado el reg.

delete from cobruter1
 where cod_pagador = a_cod_cliente
   and tipo_labor <> 1;

let _cod_motiv   = null;
let _code_agente = null;


select count(*)
  into _cnt_ruter
  from cobruter1
 where cod_cobrador	= a_cod_cobrador
   and dia_cobros1	= _dia_cobros1
   and fecha		= a_fecha_hora;
 
while _cnt_ruter <> 0
	let a_fecha_hora = a_fecha_hora + 1 units second;
	select count(*)
	  into _cnt_ruter
	  from cobruter1
	 where cod_cobrador	= a_cod_cobrador
	   and dia_cobros1	= _dia_cobros1
	   and fecha		= a_fecha_hora;
end while

	insert into cobruter1(
	cod_cobrador,   	
	cod_motiv,
	a_pagar,      
	saldo,       
	por_vencer,  
	exigible,    
	corriente,   
	monto_30,    
	monto_60,    
	monto_90,
	dia_cobros1,	
	dia_cobros2,
	fecha,
	cod_agente,
	cod_pagador,
	code_pais,     
	code_provincia,
	code_ciudad,	 
	code_distrito,
	code_correg,
	descripcion,
	user_added,
	procedencia
	)
	VALUES(
	a_cod_cobrador,
	_cod_motiv,    
	_apagar,
	_saldo,     
	_por_vencer,
	_exigible,  
	_corriente,	
	_monto_30,	
	_monto_60,	
	_monto_90,	
    _dia_cobros1,
	_dia_cobros2,
	a_fecha_hora,
	_code_agente,
	a_cod_cliente,
	_code_pais,
	_code_provincia,
	_code_ciudad,
	_code_distrito,
	_code_correg,
	_descripcion,
	_user_added,
	_procedencia
    );

	select count(*)
	  into _cnt_ruter
	  from cobruhis
	 where cod_cobrador	= a_cod_cobrador
	   and dia_cobros1	= _dia_cobros1 
	   and fecha		= a_fecha_hora;
	
	if _cnt_ruter > 0 then
		let a_fecha_hora = a_fecha_hora + 5 units second;
	end if

	--historia de rutero(cobruhis)
	BEGIN
		ON EXCEPTION IN(-268)
		let a_fecha_hora = a_fecha_hora + 6 units second;
		
		BEGIN
			ON EXCEPTION IN(-268)
				let a_fecha_hora = a_fecha_hora + 3 units second;
				insert into cobruhis(
					cod_cobrador,   	
					cod_motiv,
					a_pagar,      
					dia_cobros1,	
					fecha,
					cod_agente,
					cod_pagador,
					code_pais,     
					code_provincia,
					code_ciudad,	 
					code_distrito,
					code_correg,
					user_added,
					procedencia
					)
					values(
					a_cod_cobrador,
					_cod_motiv,    
					_apagar,
					_dia_cobros1,
					a_fecha_hora,
					_code_agente,
					a_cod_cliente,
					_code_pais,
					_code_provincia,
					_code_ciudad,
					_code_distrito,
					_code_correg,
					_user_added,
					_procedencia
					);
			End Exception
			
				insert into cobruhis(
					cod_cobrador,   	
					cod_motiv,
					a_pagar,      
					dia_cobros1,	
					fecha,
					cod_agente,
					cod_pagador,
					code_pais,     
					code_provincia,
					code_ciudad,	 
					code_distrito,
					code_correg,
					user_added,
					procedencia
					)
					values(
					a_cod_cobrador,
					_cod_motiv,    
					_apagar,
					_dia_cobros1,
					a_fecha_hora,
					_code_agente,
					a_cod_cliente,
					_code_pais,
					_code_provincia,
					_code_ciudad,
					_code_distrito,
					_code_correg,
					_user_added,
					_procedencia
					);
			end
	END EXCEPTION
			insert into cobruhis(
			cod_cobrador,   	
			cod_motiv,
			a_pagar,      
			dia_cobros1,	
			fecha,
			cod_agente,
			cod_pagador,
			code_pais,     
			code_provincia,
			code_ciudad,	 
			code_distrito,
			code_correg,
			user_added,
			procedencia
			)
			values(
			a_cod_cobrador,
			_cod_motiv,    
			_apagar,
			_dia_cobros1,
			a_fecha_hora,
			_code_agente,
			a_cod_cliente,
			_code_pais,
			_code_provincia,
			_code_ciudad,
			_code_distrito,
			_code_correg,
			_user_added,
			_procedencia
			);
	end

	foreach
		select no_documento,
			   a_pagar,
			   code_pais,
			   code_provincia,
			   code_ciudad,
			   code_distrito,
			   code_correg,
			   dia_cobros1,
			   saldo,
			   por_vencer,
			   exigible,
			   corriente,
			   monto_30,
			   monto_60,
			   monto_90,
			   descripcion,
			   dia_cobros2,
			   cod_cobrador,
			   fecha
		  into _no_documento,
			   _apagar,
			   _code_pais,
			   _code_provincia,
			   _code_ciudad,
			   _code_distrito,
			   _code_correg,
			   _dia_cobros1,
			   _saldo,
			   _por_vencer,
			   _exigible,
			   _corriente,
			   _monto_30,
			   _monto_60,
			   _monto_90,
			   _descripcion,
			   _dia_cobros2,
			   _cod_cobrador,
			   _fec
		  from cobruter2
		 where cod_pagador = a_cod_cliente
		   and tipo_labor  = 0

		--** borrar cobruter2 para ser insertado el reg.
		delete from cobruter2
		 where cod_cobrador = _cod_cobrador
		   and dia_cobros1  = _dia_cobros1
		   and fecha        = _fec;

		let a_fecha_hora = a_fecha_hora + 1 units second;

		select count(*)
		  into _cnt_cobruter2
		  from cobruter2
		 where cod_cobrador = _cod_cobrador
		   and dia_cobros1  = _dia_cobros1
		   and fecha        = a_fecha_hora;

		while _cnt_cobruter2 <> 0
			let a_fecha_hora = a_fecha_hora + 1 units second;
			select count(*)
			  into _cnt_cobruter2
			  from cobruter2
			 where cod_cobrador = _cod_cobrador
			   and dia_cobros1  = _dia_cobros1
			   and fecha        = a_fecha_hora;
		end while

		insert into cobruter2(
		no_documento,
		cod_cobrador,   	
		cod_motiv,
		a_pagar,      
		saldo,       
		por_vencer,  
		exigible,    
		corriente,   
		monto_30,    
		monto_60,    
		monto_90,
		dia_cobros1,	
		dia_cobros2,
		fecha,
		cod_agente,
		cod_pagador,
		code_pais,     
		code_provincia,
		code_ciudad,	 
		code_distrito,
		code_correg
		)
		values(
		_no_documento,
		a_cod_cobrador,
		_cod_motiv,    
		_apagar,
		_saldo,     
		_por_vencer,
		_exigible,  
		_corriente,	
		_monto_30,	
		_monto_60,	
		_monto_90,	
		_dia_cobros1,
		_dia_cobros2,
		a_fecha_hora,
		_code_agente,
		a_cod_cliente,
		_code_pais,
		_code_provincia,
		_code_ciudad,
		_code_distrito,
		_code_correg
		);
		LET a_fecha_hora = a_fecha_hora + 1 UNITS SECOND;			
	end foreach
end

return 0, "Actualizacion Exitosa";

end procedure;