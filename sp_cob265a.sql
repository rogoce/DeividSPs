-- Proceso Generar el informe de Morosidad por Corredor
-- Creado por :     Roman Gordon	07/02/2011
-- SIS v.2.0 - DEIVID, S.A.


Drop Procedure sp_cob265a;

Create Procedure 'informix'.sp_cob265a(a_cod_agente char(5), a_compania char(3), a_sucursal char(3))
Returning char(100)		as Cliente,	--cliente
		  char(20)		as Poliza,		--no_poliza       
		  char(50)		as Ramo,		--ramo		      	  
		  char(10)		as Estatus_Poliza,		--estatus_poliza  
		  char(50)		as Forma_Pago,		--forma_pago
		  char(50)		as Acreedor,		--acreedor      
		  date			as Vigencia_Inic,			--vigencia_inic   
		  integer		as Dia_Vigencia_Final,		--vig_fin_dia  char(2),	  
		  integer		as Mes_Vigencia_Final,		--vig_fin_mes  char(2),	  
		  integer		as Anio_Vigencia_Final,		--vig_fin_anio char(4),		  
		  date			as Fecha_Ult_Pago,			--fecha_utl_pago	  
		  dec(16,2)		as Monto_Utl_Pago,	--mont_ult_pago		  
		  dec(16,2)		as Prima_Bruta,	--prima_bruta		  
		  dec(16,2)		as Saldo,	--saldo				  
		  dec(16,2)		as Por_Vencer,	--por_vencer		  
		  dec(16,2)		as Exigible,	--exigible			  
		  dec(16,2)		as Corriente,	--corriente			  
		  dec(16,2)		as Monto_30,	--monto30			  
		  dec(16,2)		as Monto_60,	--monto60			  
		  dec(16,2)		as Monto_90,	--monto90			  
		  dec(16,2)		as Monto_120,	--monto120			  
		  dec(16,2)		as Monto_150,	--monto150			  
		  dec(16,2)		as Monto_180,	--monto180			  
		  smallint		as No_pagos,		--no_pagos
		  varchar(30)	as Cedula_Ruc,	--cedula					  
		  char(50)		as Compania,		--compania					  
		  char(100)		as Corredor,	--agente			  
		  smallint		as Ind_Aviso_Canc;		--aviso_canc
		  --char(20)      as tel_casa,    -- telefono1
		  --char(20)      as tel_oficina,	-- telefono2		  
		  --char(20)      as celular;     -- celular char(20);		  
		
		
define _cedula				varchar(30);			
define _nombre_agente		char(100);
define _nombre_cliente		char(100);
define _email_agente		char(50);
define _nom_formapag		char(50);
define _nom_ramo			char(50);
define _nom_acre			char(50);
define v_compania_nombre	char(50);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _status_poliza		char(10);
define _periodo				char(7);
define _cod_acre			char(5);
define _vig_fin_anio		char(4);
define _cod_formapag		char(3);
define _cod_pagos			char(3);
define _cod_ramo			char(3);
define _vig_fin_dia 		char(2);
define _vig_fin_mes 		char(2);
define _prima_bruta_acum	dec(16,2);
define _por_vencer_acum		dec(16,2);
define _monto_ult_pago		dec(16,2);
define _corriente_acum		dec(16,2);
define _monto_180_acum		dec(16,2);
define _monto_150_acum		dec(16,2);
define _monto_120_acum		dec(16,2);
define _monto_90_acum		dec(16,2);
define _monto_60_acum		dec(16,2);
define _monto_30_acum		dec(16,2);
define _exigible_acum		dec(16,2);
define _prima_bruta			dec(16,2);
define _saldo_acum			dec(16,2);
define _por_vencer			dec(16,2);
define _max_saldo			dec(16,2);
define _corriente			dec(16,2);
define _monto_180			dec(16,2);
define _monto_150			dec(16,2);
define _monto_120			dec(16,2);
define _monto_90			dec(16,2);
define _monto_60			dec(16,2);
define _monto_30			dec(16,2);
define _exigible			dec(16,2);
define _saldo				dec(16,2);
define _monto				dec(16,2);
define _carta_aviso_canc	smallint;
define _cod_estatus			smallint;
define _cant_pagos			smallint;
define _leasing             smallint;
define _session_id			integer;
define _vig_fin_anio_int	integer;
define _vig_fin_dia_int		integer;
define _vig_fin_mes_int		integer;
define _fecha_ult_pago		date;
define _vigencia_inic		date;
define _vigencia_fin		date;
define _fecha_hoy			date;
define _telefono1			char(20);
define _telefono2			char(20);
define _celular			    char(20);
let _telefono1		= "";
let _telefono2		= "";
let _celular		= "";

set isolation to dirty read;

--set debug file to 'sp_cob265.trc';
--trace on;
{
select dbinfo('sessionid') 
  into _session_id
  from systables
 where tabname = 'systables';

delete from deivid_tmp:fic_morosidad_corredor
 where sessionid = _session_id;}

let	_no_documento = '';
let _email_agente = '';
let _leasing = 0;
let _max_saldo = 2.5;
let	_por_vencer = 0.00;
let	_corriente = 0.00;
let	_monto_180 = 0.00;
let	_monto_150 = 0.00;
let	_monto_120 = 0.00;
let	_monto_90 = 0.00;
let	_monto_60 = 0.00;
let	_monto_30 = 0.00;
let	_exigible = 0.00;
let	_saldo = 0.00;
let	_no_poliza = '';	
let v_compania_nombre = sp_sis01(a_compania);
let _fecha_hoy = today;
let _periodo = sp_sis39(_fecha_hoy);

select nombre
  into _nombre_agente
  from agtagent
 where cod_agente = a_cod_agente;

foreach
	select a.no_documento,
		   a.cod_status,
		   a.vigencia_inic,
		   a.vigencia_fin,
		   a.cod_ramo,
		   a.por_vencer,
		   a.exigible,
		   a.corriente,
		   a.monto_30,
		   a.monto_60,
		   a.monto_90,
		   a.monto_120,
		   a.monto_150,
		   a.monto_180,
		   a.saldo, a.no_poliza
	  into _no_documento,
		   _cod_estatus,
		   _vigencia_inic,
		   _vigencia_fin,
		   _cod_ramo,
		   _por_vencer,
		   _exigible,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _monto_120,
		   _monto_150,
		   _monto_180,
		   _saldo, _no_poliza
	  from emipoliza  a, emipoagt b
	 where a.cod_agente = a_cod_agente
       and a.no_poliza  = b.no_poliza
       and a.cod_agente = b.cod_agente
	   and saldo >= _max_saldo

	let	_nombre_cliente	= '';
	let	_cod_formapag = '';
	let	_cod_cliente = '';	
--	let	_no_poliza = '';
	let _nom_acre = '';
	let	_fecha_ult_pago	= null;
	let	_cant_pagos = 0;	
	
	--let _no_poliza = sp_sis21(_no_documento);

	select no_documento,
		   cod_formapag,
		   prima_bruta,
		   cod_pagador,
		   carta_aviso_canc,
		   no_pagos,
		   leasing
	  into _no_documento,
		   _cod_formapag,
		   _prima_bruta,
		   _cod_cliente,
		   _carta_aviso_canc,
		   _cant_pagos,
		   _leasing
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _cod_formapag  in ('084','085') then
		continue foreach;
	end if   

	--trace on;
	let _nom_acre = '... SIN ACREEDOR ...';
	let _cod_acre    = '';

	foreach
		select cod_acreedor
		  into _cod_acre
		  from emipoacr
		 where no_poliza = _no_poliza
		 order by no_unidad
		 
		if _cod_acre is not null then
			select nombre
			  into _nom_acre
			  from emiacre
			 where cod_acreedor = _cod_acre;
			exit foreach;
		end if
	end foreach

	if _cod_acre is null then
		let _cod_acre = '';
	end if

	if _leasing = 1 then --Tiene leasing

		foreach
			select u.cod_asegurado,   
				   c.nombre
			  into _cod_acre,
				   _nom_acre      
			  from cliclien c, emipouni u
			 where c.cod_cliente = u.cod_asegurado
			   and u.no_poliza  = _no_poliza
			 group by u.cod_asegurado,c.nombre
			exit foreach;
		end foreach
	end if

	let _vig_fin_dia = day(_vigencia_fin);
	let _vig_fin_mes = month(_vigencia_fin);
	let _vig_fin_anio = year(_vigencia_fin);

	let _vig_fin_dia_int =	cast(_vig_fin_dia as integer);
	let _vig_fin_mes_int =	cast(_vig_fin_mes as integer) ;	
	let _vig_fin_anio_int = cast(_vig_fin_anio as integer);

	--trace off;
	let	_monto_ult_pago	= 0.00;

	{call sp_cob245('001','001',_no_documento,_periodo,_fecha_hoy)
	returning	_por_vencer,
				_exigible,  
				_corriente, 
				_monto_30,  
				_monto_60,  
				_monto_90,
				_monto_120,
				_monto_150,
				_monto_180,
				_saldo;
			 
	if _saldo < 2.50 then
		continue foreach;
	end if
}
	select nombre
	  into _nom_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _cod_estatus = 1 then
		let _status_poliza = 'Vigente';
	elif _cod_estatus = 2 then
		let _status_poliza = 'Cancelada';
	elif _cod_estatus = 3 then
		let _status_poliza = 'Vencida';
	elif _cod_estatus = 4 then
		let _status_poliza = 'Anulada';
	end if  
	 
	foreach
		select fecha,
			   monto
		  into _fecha_ult_pago,
			   _monto_ult_pago
		  from cobredet
		 where doc_remesa   = _no_documento	-- recibos de la poliza
		   and actualizado  = 1			    -- recibo este actualizado
		   and tipo_mov     = 'P'       	-- Pago de Prima(P)
		 order by 1 desc
		exit foreach;
	end foreach

	select nombre
	  into _nom_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;
	 
	select nombre,
		   cedula,
		   telefono1,
		   telefono2,		   
           celular
	  into _nombre_cliente,
		   _cedula,
		   _telefono1,
		   _telefono2,		   
           _celular
	  from cliclien
	 where cod_cliente = _cod_cliente;

	{begin
		on exception in(-239,-268)
			delete from  deivid_tmp:fic_morosidad_corredor
			 where sessionid = _session_id
			   and cod_agente = a_cod_agente
			   and no_documento = _no_documento;

			insert into  deivid_tmp:fic_morosidad_corredor
			values (_no_documento,	
					_nom_ramo,		
					_nombre_cliente,
					_cedula,	
					_status_poliza,	
					_nom_formapag,
					_nom_acre,	
					_vigencia_inic,	
					_vig_fin_dia_int, 	
					_vig_fin_mes_int, 	
					_vig_fin_anio_int,	
					_fecha_ult_pago,	
					_monto_ult_pago,	
					_prima_bruta,	
					_saldo,			
					_por_vencer,		
					_exigible,		
					_corriente,		
					_monto_30,		
					_monto_60,		
					_monto_90,		
					_monto_120,		
					_monto_150,		
					_monto_180,		
					_cant_pagos,		
					_nombre_agente,	
					v_compania_nombre,
					_carta_aviso_canc,
					_session_id;);
		end exception

		insert into  deivid_tmp:fic_morosidad_corredor
		values (_no_documento,	
				_nom_ramo,		
				_nombre_cliente,
				_cedula,	
				_status_poliza,	
				_nom_formapag,
				_nom_acre,	
				_vigencia_inic,	
				_vig_fin_dia_int, 	
				_vig_fin_mes_int, 	
				_vig_fin_anio_int,	
				_fecha_ult_pago,	
				_monto_ult_pago,	
				_prima_bruta,	
				_saldo,			
				_por_vencer,		
				_exigible,		
				_corriente,		
				_monto_30,		
				_monto_60,		
				_monto_90,		
				_monto_120,		
				_monto_150,		
				_monto_180,		
				_cant_pagos,		
				_nombre_agente,	
				v_compania_nombre,
				_carta_aviso_canc,
				_session_id);
	end}
	
	return	_nombre_cliente,
			_no_documento,				
			_nom_ramo,				
			_status_poliza,	
			_nom_formapag,	
			_nom_acre,	
			_vigencia_inic,	
			_vig_fin_dia_int,	
			_vig_fin_mes_int,	
			_vig_fin_anio_int,	
			_fecha_ult_pago,	
			_monto_ult_pago,	
			_prima_bruta,		
			_saldo,			
			_por_vencer,		
			_exigible,			
			_corriente,		
			_monto_30,			
			_monto_60,			
			_monto_90,			
			_monto_120,		
			_monto_150,		
			_monto_180,		
			_cant_pagos,		
			_cedula,				
			v_compania_nombre,
			_nombre_agente,	
			_carta_aviso_canc -- ,_telefono1 , _telefono2, _celular
			with resume;
			let	_no_poliza = '';
end foreach
{
foreach
	select no_poliza,      	 
		   ramo,			 
		   cliente,     	 
		   cedula,			 
		   estatus_poliza,	   
		   forma_pago,  
		   acreedor,  	 
		   vigencia_inic, 	  
		   vig_fin_dia,		 
		   vig_fin_mes,		 
		   vig_fin_anio,	 
		   fecha_utl_pago,	   
		   monto_ult_pago,	  
		   prima_bruta,		 
		   saldo,			   
		   por_vencer,		   
		   exigible,		 
		   corriente,		   
		   monto30,			 
		   monto60,			 
		   monto90,			 
		   monto120,		   
		   monto150,		   
		   monto180,		   
		   no_pagos,		  
		   agente,			  
		   compania,
		   carta_aviso_canc			 	  
	  into _no_documento,			  
		   _nom_ramo,				  
		   _nombre_cliente,
		   _cedula,	
		   _status_poliza,	
		   _nom_formapag,
		   _nom_acre,	
		   _vigencia_inic,	
		   _vig_fin_dia_int, 	
		   _vig_fin_mes_int, 	
		   _vig_fin_anio_int,			  	   	
		   _fecha_ult_pago,	
		   _monto_ult_pago,	
		   _prima_bruta,	
		   _saldo,			
		   _por_vencer,		
		   _exigible,		
		   _corriente,		
		   _monto_30,		
		   _monto_60,		
		   _monto_90,		
		   _monto_120,		
		   _monto_150,		
		   _monto_180,		
		   _cant_pagos,		
		   _nombre_agente,	
		   v_compania_nombre,
		   _carta_aviso_canc
	  from deivid_tmp:fic_morosidad_corredor
	 where sessionid = _session_id

	return	_nombre_cliente,
			_no_documento,				
			_nom_ramo,				
			_status_poliza,	
			_nom_formapag,	
			_nom_acre,	
			_vigencia_inic,	
			_vig_fin_dia_int,	
			_vig_fin_mes_int,	
			_vig_fin_anio_int,	
			_fecha_ult_pago,	
			_monto_ult_pago,	
			_prima_bruta,		
			_saldo,			
			_por_vencer,		
			_exigible,			
			_corriente,		
			_monto_30,			
			_monto_60,			
			_monto_90,			
			_monto_120,		
			_monto_150,		
			_monto_180,		
			_cant_pagos,		
			_cedula,				
			v_compania_nombre,
			_nombre_agente,	
			_carta_aviso_canc	
			with resume;									
end foreach
	
delete from deivid_tmp:fic_morosidad_corredor
 where sessionid = _session_id;;}
end procedure;