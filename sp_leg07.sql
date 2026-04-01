-- Reporte Perfiles de Clientes - PEP
-- Creado    : 20/09/2001 - Autor: Henry Giron
-- SIS v.2.0 - d_leg_sp_leg07_dw1 - DEIVID, S.A.
drop procedure sp_leg07;
create procedure sp_leg07()
returning	 CHAR(50)	as	Ramo,
CHAR(20)	as	Poliza,
 CHAR(50)	as	tipo_produccion,
CHAR(10)	as	cod_contratante ,
CHAR(100)	as	Contratante,
CHAR(2)	as	cliente_pep,
 CHAR(5)	as	cod_agente,
CHAR(100)	as	corredor,
CHAR(100)	as	vendedor,
date		as	fecha_suscripcion,
 CHAR(50)	as	sucursal,
 CHAR(50)	as	ponderacion,
CHAR(10)	as	Nueva_Renov,
CHAR(8)	as	usuario,
DEC(16,2)	as	prima_neta	,
DEC(16,2)	as	prima_bruta,
CHAR(3)	as	cod_perpago,
CHAR(20)	as	per_pago,
date		as	vigencia_inic,
date		as	vigencia_final,
CHAR(10)	as	tipo_cliente,
date		as	fecha_perfil_riesgo,
DEC(16,2)	as	prima_neta_Anual,
DEC(16,2)	as	prima_bruta_Anual,
CHAR(8)	as	usuario_added,
date		as	fecha_added,
CHAR(8)	as	usuario_changed,
date		as	fecha_changed,
char(30)    as  ced,
char(50)    as  cte_per,
varchar(100)	as email,
varchar(15)	as telefono1,
varchar(15)	as telefono2,
varchar(15)	as telefono3;

--integer li_imp1, li_imp2, li_envi1, li_envi2, li_envi3, li_envi4		 
--string ls_periodo,ls_poliza
begin

define _contratante			char(100);
define _vendedor				char(100);
define _corredor				char(100);
define _email					varchar(100);
define _tipo_produccion		char(50);
define _ponderacion			char(50);
define _sucursal				char(50);
define _ramo					char(50);
define _per_pago				char(20);
define _poliza					char(20);
define _telefono1				char(15);
define _telefono2				char(15);
define _telefono3				char(15);
define _cod_contratante		char(10);
define _tipo_cliente			char(10);
define _nueva_renov			char(10);
define _no_poliza				char(10);
define _usuario_changed		char(8);
define _usuario_added			char(8);
define _usuario				char(8);
define _cod_agente			char(5);
define _cod_perpago			char(3);
define _cod_ramo				char(3);
define _cliente_pep			char(2);
define _prima_neta_anual		dec(16,2);
define _prima_bruta_anual	dec(16,2);
define _prima_bruta			dec(16,2);
define _prima_neta			dec(16,2);
define _fecha_perfil_riesgo	date;
define _fecha_suscripcion	date;
define _vigencia_final		date;
define _fecha_changed			date;
define _vigencia_inic			date;
define _fecha_added			date;
define _fecha_hoy				date;
define _no_pagos				smallint;

			
--	set debug file to "sp_leg07.trc";
--	trace on;
let _fecha_hoy = sp_sis26() ;
let _usuario_added = '';
let _usuario_changed = '';
let _fecha_added = null;
let _fecha_changed = null;

drop table if exists temp_leg07;		
create temp table temp_leg07
			(ramo					char(50),
			poliza					char(20),
			tipo_produccion		char(50),
			cod_contratante		char(10),
			contratante			char(100),
			cliente_pep			char(2),
			cod_agente				char(5),
			corredor				char(100),
			vendedor				char(100),
			fecha_suscripcion		date,
			sucursal				char(50),
			ponderacion			char(50),
			nueva_renov			char(10),
			usuario				char(8),
			prima_neta				dec(16,2),
			prima_bruta			dec(16,2),
			cod_perpago			char(3),
			per_pago				char(20),
			vigencia_inic			date,
			vigencia_final		date,
			tipo_cliente			char(10),
			fecha_perfil_riesgo	date,
			prima_neta_anual		dec(16,2),
			prima_bruta_anual		dec(16,2),
			usuario_added			char(8),
			fecha_added			date,			
			usuario_changed		char(8),
			fecha_changed			date,
			email					varchar(100),
			telefono1				varchar(15),
			telefono2				varchar(15),
			telefono3				varchar(15)
            ) with no log;										 
	create index idx1_temp_leg07 on temp_leg07(ramo);
	create index idx2_temp_leg07 on temp_leg07(poliza);
	create index idx3_temp_leg07 on temp_leg07(cod_contratante);
	create index idx4_temp_leg07 on temp_leg07(cod_agente);

set isolation to dirty read;		

	
foreach
 select ram.nombre as Ramo,
		emi.no_documento as Poliza,
		pro.nombre as tipo_produccion, 
		emi.cod_contratante, 
		con.nombre as Contratante, 
		CASE con.cliente_pep WHEN 0 then 'NO' WHEN 1 then 'SI' END as cliente_pep,
		cor.cod_agente,
		agt.nombre as corredor,
		zon.nombre as vendedor,
		emi.fecha_suscripcion,
		suc.descripcion as sucursal,
		rie.nombre as ponderacion,
		CASE emi.nueva_renov WHEN 'N' then 'NUEVA' WHEN 'R' THEN 'RENOVACION' END as Nueva_Renov,
		emi.user_added,
		emi.prima_neta,
		emi.prima_bruta,
		emi.cod_perpago,
		per.nombre as per_pago,
		emi.vigencia_inic,
		emi.vigencia_final
    into _Ramo,
		_Poliza,
		_tipo_produccion,
		_cod_contratante,
		_Contratante,
		_cliente_pep,
		_cod_agente,
		_corredor,
		_vendedor,
		_fecha_suscripcion,
		_sucursal,
		_ponderacion,
		_Nueva_Renov,
		_usuario,
		_prima_neta,
		_prima_bruta,
		_cod_perpago,
		_per_pago,
		_vigencia_inic,
		_vigencia_final
  from emipomae emi
 inner join prdramo ram
    on ram.cod_ramo = emi.cod_ramo
     -- and emi.fecha_suscripcion > '01/09/2020'
     -- and emi.cod_sucursal <> '009'
        and emi.actualizado = 1
        and emi.estatus_poliza = 1
     -- and emi.nueva_renov = 'N'
 inner join emipoagt cor
         on cor.no_poliza = emi.no_poliza
 inner join agtagent agt
         on cor.cod_agente = agt.cod_agente
 inner join agtvende zon
         on agt.cod_vendedor = zon.cod_vendedor
 inner join cliclien con
         on con.cod_cliente = emi.cod_contratante
 inner join insagen suc
         on emi.cod_sucursal = suc.codigo_agencia
 inner join emitipro pro
         on pro.cod_tipoprod = emi.cod_tipoprod
 inner join cobperpa per  on per.cod_perpago = emi.cod_perpago
  left join ponderacion pon
         on pon.cod_cliente = con.cod_cliente
  left join cliriesgo rie
         on rie.cod_riesgo = pon.cod_riesgo
 --  order by sucursal asc,  fecha_suscripcion asc
   
   call sp_sis21(_Poliza) returning _no_poliza;

	select CASE tipo_persona WHEN 'N' then 'NATURAL' WHEN 'J' THEN 'JURIDICA' ELSE 'GOBIERNO' END as tipo_cliente,
		    e_mail,
			telefono1,
			telefono2,
			telefono3
	  into _tipo_cliente,
		    _email,
			_telefono1,
			_telefono2,
			_telefono3
	  from cliclien
	 where cod_cliente = _cod_contratante;	
	 
	select user_add,date_add,user_changed,date_changed
	  into _usuario_added, _fecha_added, _usuario_changed, _fecha_changed
	  from ponderacion
	 where cod_cliente = _cod_contratante;		 
	 
	   let _fecha_perfil_riesgo = _fecha_hoy;
	   
	   let _no_pagos = 0;
	   
		SELECT cod_ramo , no_pagos
		  INTO _cod_ramo , _no_pagos
		  FROM emipomae
		 WHERE no_poliza = _no_poliza;
		 
		 if _cod_ramo = '018' then
		 
		 	if _cod_perpago = '001' or _cod_perpago = '006'  or _cod_perpago = '008'  then 
				let _no_pagos = 1;
			elif _cod_perpago = '007' then 
				let _no_pagos = 2;
			elif _cod_perpago = '005'or _cod_perpago = '009'  then 
				let _no_pagos = 3;
			elif _cod_perpago = '004' then  
				let _no_pagos = 4;
			elif _cod_perpago = '003' then 
				let _no_pagos = 6;
			elif _cod_perpago = '002' then 
				let _no_pagos = 12;				
			end if
			
			let _prima_neta_Anual = _prima_neta * _no_pagos;
			let _prima_bruta_Anual = _prima_bruta * _no_pagos;		 
		 else
			let _prima_neta_Anual = _prima_neta ;
			let _prima_bruta_Anual = _prima_bruta ;			 
		 end if		
	   
		   	insert into temp_leg07(Ramo,
								Poliza,
								tipo_produccion,
								cod_contratante,
								Contratante,
								cliente_pep,
								cod_agente,
								corredor,
								vendedor,
								fecha_suscripcion,
								sucursal,
								ponderacion,
								Nueva_Renov,
								usuario,
								prima_neta,
								prima_bruta,
								cod_perpago,
								per_pago,
								vigencia_inic,
								vigencia_final,
								tipo_cliente,
								fecha_perfil_riesgo,
								prima_neta_Anual,
								prima_bruta_Anual,
								usuario_added, 
								fecha_added, 
								usuario_changed, 
								fecha_changed,
								email,
								telefono1,
								telefono2,
								telefono3
									  )  
			    	     values( _Ramo,
								_Poliza,
								_tipo_produccion,
								_cod_contratante,
								_Contratante,
								_cliente_pep,
								_cod_agente,
								_corredor,
								_vendedor,
								_fecha_suscripcion,
								_sucursal,
								_ponderacion,
								_Nueva_Renov,
								_usuario,
								_prima_neta,
								_prima_bruta,
								_cod_perpago,
								_per_pago,
								_vigencia_inic,
								_vigencia_final,
								_tipo_cliente,
								_fecha_perfil_riesgo,
								_prima_neta_Anual,
								_prima_bruta_Anual,
								_usuario_added, 
								_fecha_added, 
								_usuario_changed, 
								_fecha_changed,
								_email,
								_telefono1,
								_telefono2,
								_telefono3
								 );	 
			    
end foreach


foreach
     select Ramo,
			Poliza,
			tipo_produccion,
			cod_contratante,
			Contratante,
			cliente_pep,
			cod_agente,
			corredor,
			vendedor,
			fecha_suscripcion,
			sucursal,
			ponderacion,
			Nueva_Renov,
			usuario,
			prima_neta,
			prima_bruta,
			cod_perpago,
			per_pago,
			vigencia_inic,
			vigencia_final,
			tipo_cliente,
			fecha_perfil_riesgo,
			prima_neta_Anual,
			prima_bruta_Anual,
			usuario_added, 
			fecha_added, 
			usuario_changed, 
			fecha_changed,
			email,
			telefono1,
			telefono2,
			telefono3
       into _Ramo,
			_Poliza,
			_tipo_produccion,
			_cod_contratante,
			_Contratante,
			_cliente_pep,
			_cod_agente,
			_corredor,
			_vendedor,
			_fecha_suscripcion,
			_sucursal,
			_ponderacion,
			_Nueva_Renov,
			_usuario,
			_prima_neta,
			_prima_bruta,
			_cod_perpago,
			_per_pago,
			_vigencia_inic,
			_vigencia_final,
			_tipo_cliente,
			_fecha_perfil_riesgo,
			_prima_neta_Anual,
			_prima_bruta_Anual,
			_usuario_added, 
			_fecha_added, 
			_usuario_changed, 
			_fecha_changed,
			_email,
			_telefono1,
			_telefono2,
			_telefono3
       from temp_leg07	
	  order by ramo asc, poliza asc   

	         return _Ramo,
					_Poliza,
					_tipo_produccion,
					_cod_contratante,
					_Contratante,
					_cliente_pep,
					_cod_agente,
					_corredor,
					_vendedor,
					_fecha_suscripcion,
					_sucursal,
					_ponderacion,
					_Nueva_Renov,
					_usuario,
					_prima_neta,
					_prima_bruta,
					_cod_perpago,
					_per_pago,
					_vigencia_inic,
					_vigencia_final,
					_tipo_cliente,
					_fecha_perfil_riesgo,
					_prima_neta_Anual,
					_prima_bruta_Anual,
					_usuario_added, 
			        _fecha_added, 
			        _usuario_changed, 
			        _fecha_changed,
					"",
					"",
					_email,
					_telefono1,
					_telefono2,
					_telefono3
	                with resume;
end foreach
end
end procedure
		