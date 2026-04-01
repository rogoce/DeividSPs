-- Analisis de la Cartera de Cobros para Determinar la separacion de las Polizas en 
-- Gestores, Cartera, Electronico e Incobrables
-- 
-- Creado    : 31/03/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/03/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob100_dw1 - DEIVID, S.A.

drop procedure sp_cob100;

create procedure sp_cob100(a_compania CHAR(3), a_agencia char(3), a_periodo char(7))
returning char(1),
          char(100),		
	      char(20),			
	      dec(16,2), 		
	      char(50),			
	      char(50),			
	      smallint,			
	      char(30),			
	      char(50),			
	      date,				
	      date,				
	      smallint,			
	      dec(16,2),		  
	      dec(16,2),		  
	      dec(16,2),		  
	      dec(16,2),		  
	      dec(16,2),		  
	      dec(16,2),		
		  char(10),			
	      dec(16,2),		  
	      dec(16,2),		  
	      dec(16,2),		  
	      dec(16,2),		  
	      dec(16,2),		  
	      dec(16,2),		
	      dec(16,2),
	      smallint,
	      smallint,
	      char(5),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),
	      dec(16,2),		  
	      dec(16,2),		  
	      dec(16,2)
	      ;
							  
define _doc_poliza		char(20);		  
define _no_poliza		char(10);
define _incobrable		smallint;
define _cod_formapag	char(3);
define _tipo_forma		smallint;
define a_fecha			date;
define _mes_contable    char(2);
define _ano_contable    char(4);
define _periodo         char(7);
define _saldo           dec(16,2);
define _por_vencer      dec(16,2);
define _exigible        dec(16,2);
define _corriente       dec(16,2);
define _monto_30        dec(16,2);
define _monto_60        dec(16,2);
define _monto_90        dec(16,2);
define _monto_120       dec(16,2);
define _monto_150       dec(16,2);
define _monto_180       dec(16,2);
define _cod_agente		char(5);
define _cobra_poliza	char(1);
define _cobra_poliza2	char(1);
define _cod_grupo		char(5);
define _nombre_grupo	char(50);
define _nombre_corredor	char(50);
define _nombre_cliente	char(100);
define _cod_cliente		char(10);
define _dia_cobros		smallint;
define _cedula			char(30);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);
define _cod_tipoprod	char(3);
define _formapag        char(2);
define _vigencia_inic	date;
define _vigencia_final	date;
define _estatus_poliza	smallint;
define _monto           dec(16,2);
define _monto_pagado    dec(16,2);
define _montoTotal      dec(16,2);
define _montoPagado     dec(16,2);
define _saldo_vencer    dec(16,2);
define _saldo_exigible  dec(16,2);
define _saldo_corriente dec(16,2);
define _saldo_30        dec(16,2);
define _saldo_60        dec(16,2);
define _saldo_90        dec(16,2);
define _saldo_120       dec(16,2);
define _saldo_150       dec(16,2);
define _saldo_180       dec(16,2);
define _dia_cobros1		smallint;
define _dia_cobros2		smallint;
define _cant_saldos		smallint;
define _cant_pagos		smallint;

set isolation to dirty read;

create temp table tmp_seccion(
	cobra_poliza		char(1),
	saldo				dec(16,2),
    saldo_vencer		dec(16,2),       
    saldo_exigible		dec(16,2),         
    saldo_corriente		dec(16,2),        
    saldo_30			dec(16,2),         
    saldo_60			dec(16,2),         
    saldo_90			dec(16,2),
    saldo_120			dec(16,2),         
    saldo_150			dec(16,2),         
    saldo_180			dec(16,2),
	por_vencer			dec(16,2),       
    exigible			dec(16,2),         
    corriente			dec(16,2),        
    monto_30			dec(16,2),         
    monto_60			dec(16,2),         
    monto_90			dec(16,2),
    monto_120			dec(16,2),         
    monto_150			dec(16,2),         
    monto_180			dec(16,2),
	monto_pagado		dec(16,2),
	cant_saldos			integer,
	cant_pagos			integer
) with no log;

let a_fecha = sp_sis36(a_periodo);

foreach 
 select no_documento
   into	_doc_poliza
   from emipomae 
  where cod_compania = a_compania
    and actualizado  = 1
  group by no_documento		

	let _no_poliza = sp_sis21(_doc_poliza);

	select incobrable,
	       cobra_poliza,
		   cod_pagador,
		   cod_grupo,
		   cod_formapag,
		   dia_cobros1,
		   cod_ramo,
		   cod_tipoprod,
		   vigencia_inic,
		   vigencia_final,
		   estatus_poliza,
		   dia_cobros1,
		   dia_cobros2
	  into _incobrable,
	       _cobra_poliza,
		   _cod_cliente,
		   _cod_grupo,
		   _cod_formapag,
		   _dia_cobros,
		   _cod_ramo,
		   _cod_tipoprod,
		   _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,
		   _dia_cobros1,
		   _dia_cobros2
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

	let _monto_pagado = 0.00;

	foreach
	 select monto
	   into _monto
	   from cobredet
	  where doc_remesa   = _doc_poliza
	    and actualizado  = 1	   
	    and tipo_mov     IN ('P', 'N')
	    and periodo      = a_periodo

		let _monto_pagado = _monto_pagado + _monto;
				
	end foreach

	call sp_cob33a(
		 a_compania,
		 a_agencia,	
		 _doc_poliza,
		 a_periodo,
		 a_fecha
		 ) returning _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
    				 _monto_120,         
    				 _monto_150,         
    				 _monto_180,
    				 _saldo;    
   				 
	let _cant_saldos = 0;
	if _saldo <> 0 then
		let _cant_saldos = 1;
	end if

	let _cant_pagos = 0;
	if _monto_pagado <> 0 then
		let _cant_pagos = 1;
	end if

	let _saldo_vencer    = _por_vencer;
	let _saldo_exigible  = _exigible;
	let _saldo_corriente = _corriente;
	let _saldo_30        = _monto_30;
	let _saldo_60        = _monto_60;
	let _saldo_90        = _monto_90;
	let _saldo_120       = _monto_120;
	let _saldo_150       = _monto_150;
	let _saldo_180       = _monto_180;


	LET _montoTotal      = _corriente + _monto_30 + _monto_60 + _monto_90 + _monto_120 + _monto_150 + _monto_180 + _por_vencer;
	LET _montoPagado     = _monto_pagado;

	IF _montoTotal > 0 THEN

		IF _monto_180 <> 0 THEN

			IF _monto_180 >= _montoPagado THEN

				LET _monto_180    = _montoPagado;
				LET _monto_150   = 0;
				LET _monto_120   = 0;
				LET _monto_90    = 0;
				LET _monto_60    = 0;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_180;

			END IF	

		END IF

		IF _monto_150 <> 0 THEN

			IF _monto_150 >= _montoPagado THEN

				LET _monto_150   = _montoPagado;
				LET _monto_120   = 0;
				LET _monto_90    = 0;
				LET _monto_60    = 0;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_150;

			END IF	

		END IF

		IF _monto_120 <> 0 THEN

			IF _monto_120 >= _montoPagado THEN

				LET _monto_120   = _montoPagado;
				LET _monto_90    = 0;
				LET _monto_60    = 0;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_120;

			END IF	

		END IF

		IF _monto_90 <> 0 THEN

			IF _monto_90 >= _montoPagado THEN

				LET _monto_90    = _montoPagado;
				LET _monto_60    = 0;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_90;

			END IF	

		END IF

		IF _monto_60 <> 0 THEN

			IF _monto_60 >= _montoPagado THEN

				LET _monto_60    = _montoPagado;
				LET _monto_30    = 0;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_60;

			END IF	

		END IF

		IF _monto_30 <> 0 THEN

			IF _monto_30 >= _montoPagado THEN

				LET _monto_30    = _montoPagado;
				LET _corriente   = 0;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _monto_30;

			END IF	

		END IF
		
		IF _corriente <> 0 THEN

			IF _corriente >= _montoPagado THEN

				LET _corriente   = _montoPagado;
				LET _por_vencer  = 0;
				LET _montoPagado = 0;

			ELSE

				LET _montoPagado = _montoPagado - _corriente;

			END IF	

		END IF

		IF _por_vencer <> 0 THEN

			LET _por_vencer  = _montoPagado;
			LET _montoPagado = 0;

		END IF

		IF _montoPagado <> 0 THEN
			LET _corriente = _corriente + _montoPagado;
		END IF			

	ELSE
		LET _monto_180  = 0;
		LET _monto_150  = 0;
		LET _monto_120  = 0;
		LET _monto_90   = 0;
		LET _monto_60   = 0;
		LET _monto_30   = 0;
		LET _corriente  = _montoPagado;
		LET _por_vencer = 0;

	END IF

	LET _exigible = _corriente + _monto_30 + _monto_60 + _monto_90 + _monto_120 + _monto_150 + _monto_180;

	insert into tmp_seccion(
	cobra_poliza,
	saldo,
    saldo_vencer,       
    saldo_exigible,         
    saldo_corriente,        
    saldo_30,         
    saldo_60,         
    saldo_90,
    saldo_120,         
    saldo_150,         
    saldo_180,
	por_vencer,       
    exigible,         
    corriente,        
    monto_30,         
    monto_60,
    monto_90,
    monto_120,         
    monto_150,
    monto_180,
	monto_pagado,
	cant_saldos,
	cant_pagos
	)
	values(
	_cobra_poliza,
	_saldo,
    _saldo_vencer,       
    _saldo_exigible,         
    _saldo_corriente,        
    _saldo_30,         
    _saldo_60,         
    _saldo_90,
    _saldo_120,         
    _saldo_150,         
    _saldo_180,
	_por_vencer,       
    _exigible,         
    _corriente,        
    _monto_30,         
    _monto_60,
    _monto_90,
    _monto_120,         
    _monto_150,
    _monto_180,
	_monto_pagado,
	_cant_saldos,
	_cant_pagos
	);

end foreach

let _nombre_ramo     = "";
let _nombre_grupo    = "";
let _nombre_cliente  = "";
let _cedula          = "";
let _tipo_forma      = "";
let _formapag        = "";
let _cod_agente      = "";
let _nombre_corredor = "";

foreach
 select cobra_poliza,
		sum(saldo),
    	sum(saldo_vencer),       
    	sum(saldo_exigible),         
    	sum(saldo_corriente),        
    	sum(saldo_30),         
    	sum(saldo_60),         
    	sum(saldo_90),
    	sum(saldo_120),         
    	sum(saldo_150),         
    	sum(saldo_180),
		sum(por_vencer),       
    	sum(exigible),         
    	sum(corriente),        
    	sum(monto_30),         
    	sum(monto_60),
    	sum(monto_90),
    	sum(monto_120),         
    	sum(monto_150),
    	sum(monto_180),
		sum(monto_pagado),
		sum(cant_saldos),
		sum(cant_pagos)
   into	_cobra_poliza,
		_saldo,
    	_saldo_vencer,       
    	_saldo_exigible,         
    	_saldo_corriente,        
    	_saldo_30,         
   		_saldo_60,         
   		_saldo_90,
    	_saldo_120,         
   		_saldo_150,         
   		_saldo_180,
		_por_vencer,       
   		_exigible,         
   		_corriente,        
   		_monto_30,         
   		_monto_60,
   		_monto_90,
   		_monto_120,         
   		_monto_150,
   		_monto_180,
		_monto_pagado,
		_cant_saldos,
		_cant_pagos
   from tmp_seccion
  group by 1
  order by 1

	return _cobra_poliza,
	       _nombre_cliente,
		   _doc_poliza,
		   _saldo,
		   _nombre_corredor,
		   _nombre_grupo,		  
		   _dia_cobros,			  
		   _cedula,				  
		   _nombre_ramo,		  
		   _vigencia_inic,		  
		   _vigencia_final,		  
		   _estatus_poliza,		  
		   _saldo_vencer,         
    	   _saldo_exigible,         
    	   _saldo_corriente,        
    	   _saldo_30,         	  
    	   _saldo_60,         	  
    	   _saldo_90,			  
		   _cod_cliente,		  
		   _por_vencer,       	  
    	   _exigible,         	  
    	   _corriente,        	  
    	   _monto_30,         	  
    	   _monto_60,         	  
    	   _monto_90,			  
		   _monto_pagado,		  
		   _cant_saldos,		  
		   _cant_pagos,
		   _cod_agente,
    	   _saldo_120,         	  
    	   _saldo_150,         	  
    	   _saldo_180,
    	   _monto_120,         
    	   _monto_150,         
    	   _monto_180
		   with resume;

end foreach

drop table tmp_seccion;

end procedure
