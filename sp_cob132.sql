-- Retorna el Resumen Historico de Rutero(cobruhis)
-- Para un Pagador o un Cobrador
-- 
-- Creado    : 08/09/2003 - Autor: Armando Moreno M.
-- Modificado: 08/09/2003 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - d_cobr_sp_cob100_dw1 - DEIVID, S.A.

drop procedure sp_cob132;

create procedure sp_cob132(a_cod_cobrador char(3))
returning char(50),
		  char(50),
          smallint,
          datetime year to fraction(5),
		  decimal(16,2),
		  char(8),
          smallint,
          datetime year to fraction(5),
		  char(8),
		  char(10),
		  char(5);

define _nombre_cobrador	char(50);
define _nombre_motivo	char(50);
define _contacto		char(50);
define v_documento		char(20);
define v_doc			char(20);
define _cod_pagador		char(10);
define _user_posteo		char(8);
define _user_added		char(8);
define _code_correg		char(5);
define _cod_cobrador	char(3);
define _cod_agente		char(5);
define _code_pais		char(3);
define _cod_motiv		char(3);
define _code_provincia	char(2);
define _code_distrito	char(2);
define _code_ciudad		char(2);
define v_apagar			dec(16,2);
define _a_pagar			dec(16,2);
define _procedencia		smallint;
define _dia_cobros1		smallint;
define _fecha_posteo	datetime year to fraction(5);
define _fecha			datetime year to fraction(5);

set isolation to dirty read;

foreach 
	select cod_cobrador,
		   dia_cobros1,
		   fecha,
		   cod_motiv,
		   a_pagar,
		   user_added,
		   procedencia,
		   fecha_posteo,
		   user_posteo,
		   cod_pagador,
		   cod_agente,
		   code_pais,     
		   code_provincia,
		   code_ciudad,	 
		   code_distrito,
		   code_correg
	  into _cod_cobrador,
		   _dia_cobros1,
		   _fecha,
		   _cod_motiv,
		   _a_pagar,
		   _user_added,
		   _procedencia,
		   _fecha_posteo,
		   _user_posteo,
		   _cod_pagador,
		   _cod_agente,
		   _code_pais,     
		   _code_provincia,
		   _code_ciudad,	 
		   _code_distrito,
		   _code_correg
	  from cobruhis
	 where cod_cobrador = a_cod_cobrador
	   and date(fecha_posteo) = "28/11/2003"

	select contacto
	  into _contacto
	  from cliclien
	 where cod_cliente = _cod_pagador;

	if _contacto is null then
		let _contacto = "";
	end if

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
	user_added
	)
	values(
	_cod_cobrador,
	_cod_motiv,    
	_a_pagar,
	0,     
	0,
	0,  
	0,	
	0,	
	0,	
	0,	
	_dia_cobros1,
	_dia_cobros1,
	_fecha,
	_cod_agente,
	_cod_pagador,
	_code_pais,
	_code_provincia,
	_code_ciudad,
	_code_distrito,
	_code_correg,
	_contacto,
	_user_added);
	
	foreach
		select no_documento,
			   a_pagar
		  into v_documento,
			   v_apagar
		  from caspoliza
		 where cod_cliente  = _cod_pagador

		let v_doc = null;

		if v_apagar  <= 0.00 then
			continue foreach;
		end if

		let _fecha = _fecha + 1 units second;

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
		VALUES(
		v_documento,
		_cod_cobrador,
		_cod_motiv,
		v_apagar,
		0,     
		0,
		0,  
		0,	
		0,	
		0,	
		0,	
		_dia_cobros1,
		_dia_cobros1,
		_fecha,
		_cod_agente,
		_cod_pagador,
		_code_pais,
		_code_provincia,
		_code_ciudad,
		_code_distrito,
		_code_correg
		);
	end foreach

	select nombre
	  into _nombre_cobrador
	  from cobcobra
	 where cod_cobrador = a_cod_cobrador;

	select nombre
	  into _nombre_motivo
	  from cobmotiv
	 where cod_motiv = _cod_motiv;

	return _nombre_cobrador,
	       _nombre_motivo,
		   _dia_cobros1,
		   _fecha,
		   _a_pagar,
		   _user_added,
		   _procedencia,
		   _fecha_posteo,
		   _user_posteo,
		   _cod_pagador,
		   _cod_agente
		   with resume;
end foreach
end procedure;