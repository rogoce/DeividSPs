--Proceso de verificacion de cdmclientes vs cobruter1 para envio de confirmacion al usuario que agrego el regitro al rutero
-- Creado por :     Roman Gordon	16/05/2011
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob279a;
create procedure "informix".sp_cob279a() 
returning	char(20), 		--_no_documento,
			char(50),		--_nom_cliente,				
			varchar(255),	--_observaciones				
			varchar(200),	--_email				
			char(50),		--_rutero,				
			dec(16,2),		--_por_vencer,
			dec(16,2),		--_corriente,
			dec(16,2),		--_exigible,
			dec(16,2),		--_a_pagar,
			dec(16,2),		--_saldo,
			dec(16,2),		--_monto_30,
			dec(16,2),		--_monto_60,				
			dec(16,2),		--_monto_90,				
			smallint,		--_tipo_cliente 				
			char(50),		--_zona
			char(50),		--_nom_formapag
			char(50);		--_nom_usuario
   
define _observaciones		varchar(255);
define _email				varchar(200);
define _zona				char(50);
define _rutero				char(50);	
define _pagador				char(50);
define _nom_cliente			char(50);
define _asegurado			char(50);
define _email_supervisor	char(50);
define _nom_formapag		char(50);
define _nom_usuario			char(50);
define _no_documento		char(20);
define _cod_pagador			char(10);
define _cod_asegurado		char(10);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _user_supervisor		char(8);
define _user_added			char(8);
define _cod_agente			char(5);
define _cod_zona			char(3);
define _supervisor			char(3);												
define _cod_rutero			char(3);
define _cod_cobrador		char(3);
define _departamento		char(3);
define _cod_formapag		char(3); 															
define _por_vencer			dec(16,2);												
define _corriente			dec(16,2);												
define _exigible			dec(16,2);
define _a_pagar				dec(16,2);
define _saldo				dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90			dec(16,2); 
define _tipo_cliente		smallint;
define _dia_hoy				smallint;
define _cnt_cdmcli			smallint;	

--set debug file to "sp_cob279.trc";
--trace on;


let _dia_hoy = day(today);
foreach
	select cod_pagador,
		   cod_agente,
		   cod_cobrador,
		   descripcion,
		   user_added
	  into _cod_pagador,
	  	   _cod_agente,
		   _cod_cobrador,
		   _observaciones,
		   _user_added
	  from cobruter1
	 where (dia_cobros1 = _dia_hoy or dia_cobros2 = _dia_hoy)
	 order by cod_cobrador

	if _cod_pagador is null then
		if _cod_agente is not null then
			let _cod_pagador = _cod_agente;
		else
			continue foreach;
		end if
	end if

	let _por_vencer 	  	= 0;
	let _corriente		  	= 0;
	let _exigible		  	= 0;
	let _a_pagar		  	= 0;
	let _saldo			  	= 0;
	let _monto_30		  	= 0;
	let _monto_60		  	= 0;
	let _monto_90		  	= 0;
	let	_observaciones	  	= '';	
	let	_email			  	= '';
	let	_rutero			  	= '';
	let	_pagador		  	= '';	
	let	_nom_cliente	  	= '';	
	let	_asegurado		  	= '';
	let	_email_supervisor	= '';
	let	_no_documento	  	= '';
	let	_cod_asegurado	  	= '';
	let	_cod_cliente	  	= '';	
	let	_no_poliza		  	= '';
	let	_user_supervisor  	= '';	
	let	_supervisor		  	= '';
	let	_cod_rutero		  	= '';
	let	_departamento	  	= '';
	let _nom_formapag		= '';
	let _zona				= '';
	let _nom_formapag		= '';
	let	_nom_usuario    	= '';
	
	if _cod_cobrador = '059' or _cod_cobrador = '030' then
		continue foreach;
	end if
		
		select descripcion
		  into _nom_usuario
		  from insuser
		 where usuario = _user_added;

		select count(*)
		  into _cnt_cdmcli
		  from cdmclientes
		 where id_cliente = _cod_pagador;
		 
		if _cnt_cdmcli = 0 then
			continue foreach;
		end if
				
		select id_cliente,
			   id_usuario,											
			   observaciones,
			   tipocliente,											
			   nombre												
		  into _cod_pagador,										
			   _cod_rutero,											
			   _observaciones,										
			   _tipo_cliente,										
			   _nom_cliente											
		  from cdmclientes
		 where prog = 'S'
		   and id_cliente = _cod_pagador;

		if _cod_rutero in(21,29) then
			let _cod_rutero = '0' || _cod_rutero;
        end if

	select nombre
 	  into _rutero
 	  from cobcobra
 	 where cod_cobrador = _cod_rutero;

	let _email = 'cobros@asegurancon.com';		
	
	if _tipo_cliente = 0 then
		foreach	
			select no_documento,
				   por_vencer,
				   corriente,
				   exigible,
				   a_pagar,
				   saldo,
				   monto_30,
				   monto_60,
				   monto_90
			  into _no_documento,
			   	   _por_vencer,
				   _corriente,
		 		   _exigible,
				   _a_pagar,
				   _saldo,
				   _monto_30,
				   _monto_60,
				   _monto_90
			  from cobruter2
			 where cod_pagador = _cod_pagador

			let _no_poliza = sp_sis21(_no_documento);
			
			select cod_formapag
			 into _cod_formapag
			 from emipomae
			where no_poliza = _no_poliza;

			select nombre,
				   cod_cobrador
			  into _nom_formapag,
			  	   _cod_zona
			  from cobforpa
			 where cod_formapag = _cod_formapag;

			if _cod_zona is null then
				foreach
					select cod_agente
					  into _cod_agente
					  from emipoagt
					 where no_poliza = _no_poliza
					 order by porc_partic_agt desc
					exit foreach;
				end foreach

				select cod_cobrador
				  into _cod_zona
				  from agtagent
				 where cod_agente = _cod_agente;
			end if

			select nombre
			  into _zona
			  from cobcobra
			 where cod_cobrador = _cod_zona;			 			

		   return _no_documento,
				  _nom_cliente,
				  _observaciones,
				  _email,
				  _rutero,
				  _por_vencer,
				  _corriente,
				  _exigible,
				  _a_pagar,
				  _saldo,
				  _monto_30,
				  _monto_60,
				  _monto_90,
				  _tipo_cliente,
				  _zona,
				  _nom_formapag,
				  _nom_usuario with resume;
			
		end foreach
	else

		return _no_documento,
			   _nom_cliente,
			   _observaciones,
			   _email,
			   _rutero,
			   _por_vencer,
			   _corriente,
			   _exigible,
			   _a_pagar,
			   _saldo,
			   _monto_30,
			   _monto_60,
			   _monto_90,
			   _tipo_cliente,
			   _zona,
			   _nom_formapag,
			   _nom_usuario with resume;
	end if
end foreach;
end procedure; 


