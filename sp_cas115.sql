-- Reporte de Polizas de Nulidad
-- Creado : 10/07/2017 - Autor: Henry Giron
-- Modificado: 10/07/2017 - Autor: Henry Giron
-- SIS v.2.0 - d_cob_sp_cas115_dw1 - DEIVID, S.A. 
-- execute procedure sp_cas115(1)

drop procedure sp_cas115;
create procedure sp_cas115(a_dias_cobros smallint default 0)
returning	char(20) 		as Poliza,
			char(10) 		as Cod_pagador,
			varchar(50) 	as Contratante,
			date 			as Fecha_Primer_Pago,
			date 			as Vigencia_Inicial,
			date 			as Vigencia_Final,
			char(5) 		as cod_formapag,
			varchar(50) 	as Forma_de_Pago,
			char(5) 		as cod_grupo,
			varchar(50) 	as Grupo,
			char(5) 		as cod_agente,
			varchar(50) 	as Corredor,
			char(3) 		as cod_cobrador,
			varchar(50)		as Zona_Cobros,
			char(5)			as cod_ramo,
			varchar(50)		as Ramo,
			dec(16,2)		as Prima_Bruta,
			varchar(20)		as Tipo_Poliza,	
			date			as Fecha_Anulacion,
			char(10)		as cod_campana,
			varchar(50)		as campana,
			smallint		as Dias_resta,
			varchar(50)		as cia,
			smallint		as cliente_vip,
			date			as fecha_actual,
			date			as fecha_hasta,
			char(10)        as celular, 
			dec(16,2)       as exigible,
			varchar(6) 		as Cod_Producto,
			varchar(50)		as Producto;

define _mensaje				varchar(250);
define _nombre_formapag		varchar(50);
define _nom_campana			varchar(50);
define _nombre_ramo			varchar(50); 
define _nom_agente			varchar(50); 
define _nombre_cli			varchar(50);
define _cia_nombre			varchar(50); 
define _nom_grupo			varchar(50);
define _nom_zona			varchar(50);
define _desc_n_r			varchar(10);
define _no_documento		char(20);
define _cod_cliente			char(10);
define _cod_campana			char(10);
define _no_poliza			char(10);
define _cod_formapag		char(5);
define _cod_agente			char(5);
define _cod_grupo			char(5);
define _cod_cobrador		char(3); 
define _cod_subramo			char(3); 
define _cod_ramo			char(3); 
define _nueva_renov			char(1);
define _prima_bruta			dec(16,2);
define _estatus_poliza		smallint;
define _susp_anulacion		smallint;
define _holgura_nueva		smallint;
define _holgura_renov		smallint;
define _dias_nulidad		smallint;
define _cnt_cliente			smallint;
define _cliente_vip			smallint;
define _dias_resta      	smallint;
define _fronting	      	smallint;
define _cnt_holgura         integer;
define _error_isam			integer;
define _error				integer;
define _fecha_suscripcion	date;
define _fecha_primer_pago	date;
define _vigencia_final		date;
define _vigencia_inic		date;
define _fecha_inicio		date;
define _fecha_actual		date;
define _fecha_hasta		    date;
define _fecha_anulacion     date;
define _celular             char(10);
define _a_pagar       		dec(16,2);
define _cnt_unidad          integer;
define _cod_producto        char(5);
define _producto            varchar(50);


set isolation to dirty read;
 --set debug file to "sp_cas115.trc";
 --trace on;
begin
on exception set _error,_error_isam,_mensaje	
 	return	'',
			'',
			'',
			null,
			null,
			null,
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			0.00,
			'',
			null,
			'',
			'',
			_error,
			_mensaje,
			0,
			null,
			null,
			null,
			0,
			null,
			null;
end exception


let  _cia_nombre = sp_sis01('001'); 
let _fecha_actual = today;
let _desc_n_r = '';
let _cnt_holgura = 0;
let _error = 0;
let _holgura_nueva = 60;
let _holgura_renov = 60;

if a_dias_cobros = 0 then
	select valor_parametro
	  into _dias_nulidad
	  from inspaag
	 where codigo_parametro = 'par_nulidad';  -- parametro de nulidad, a 10 dias
	 
	let _dias_nulidad = 40; --Se cambia a 40 segun SD 12740, para dar mas tiempo.
else 
	let _dias_nulidad = a_dias_cobros; 
end if	

if _dias_nulidad is null or _dias_nulidad = 0 then 
	let _mensaje = "Valor de parametro de dias_nulidad invalido.";
	return '','','',null,null,null,'','','','','','','','','','',0.00,'',null,'','',_error,_mensaje,0,null,null,null,0,null,null;
end if

let _fecha_hasta  = _fecha_actual + _dias_nulidad units day; 
let _fecha_inicio = '18/07/2017';
let _fecha_inicio = _fecha_hasta - 2 units year;

call sp_cob356(_fecha_inicio,10) returning _error, _mensaje;

if _error <> 0 then
	return '','','',null,null,null,'','','','','','','','','','',0.00,'',null,'','',_error,_mensaje,0,null,null,null,0,null,null;
end if

--set debug file to "sp_cas115.trc";
--trace on;

foreach
	select b.cod_campana,
		   b.no_documento,
		   b.a_pagar,
		   a.nombre
	  into _cod_campana,
		   _no_documento,
		   _a_pagar,
		   _nom_campana
	  from cascampana a, tmp_caspoliza b
	 where a.cod_campana = b.cod_campana
	   and a.tipo_campana = 3 -- Campaña Nulidad
	   and a.estatus = 2      -- Activo
	   
	 if _no_documento in ( '0116-00595-01') then  ---SD#05043:NSOLIS 17/11/2022 HGIRON
		continue foreach;
	end if	   
	   
	call sp_sis21(_no_documento) returning _no_poliza;
	
	select trim(no_documento),
	       cod_ramo,
		   cod_subramo,
		   cod_contratante,
	       vigencia_inic,
		   vigencia_final,
		   estatus_poliza,
		   nueva_renov,
		   (case when nueva_renov = 'N' then "NUEVA" else "RENOVADA" end) desc_n_r,
		   fecha_primer_pago,
		   fecha_suscripcion,
		   cod_grupo,
		   prima_bruta,
		   cod_formapag,
		   fronting,
		   _fecha_actual - fecha_primer_pago
	  into _no_documento,
	       _cod_ramo,
		   _cod_subramo,
		   _cod_cliente,
	       _vigencia_inic,
		   _vigencia_final,
		   _estatus_poliza,
		   _nueva_renov,
		   _desc_n_r,
		   _fecha_primer_pago,
		   _fecha_suscripcion,
		   _cod_grupo,
		   _prima_bruta,
		   _cod_formapag,
		   _fronting,
		   _dias_resta
	  from emipomae
	 where no_poliza = _no_poliza
	   and vigencia_inic > _fecha_inicio;

	--SE PUSO EN COMENTARIO PORQUE TODAS VALIDACIONES DE EXCEPIONES DE NULIDAD Y SUSPENSION DE COBERTURAS SON MANEJADAS POR EL SP_LEY003 --Román 30/10/2017
	if _estatus_poliza is null then
		continue foreach;
	end if	   

	{if _estatus_poliza <> 1 then
		continue foreach;
	end if
	
	if _fronting = 1 then
		continue foreach;
	end if

	if _cod_ramo in ('008','014') then --'004','016','018','019') Se elimina ramos personales de la exclusión 19/01/2016
		continue foreach;
	elif _cod_ramo in ('016') and _cod_subramo in ('007') then --Colectivo de Vida, Subramo Desgravamen
		continue foreach;
	end if

	if _cod_grupo in ('00000','1000','1090','1009','01016') then --grupos del Estado, SCOTIA BANK, BAGATRAC y Suntracs
		continue foreach;
	end if}
	
	call sp_ley003(_no_documento,1) returning _error,_mensaje;
	
	if _error < 0 then
		return '','','',null,null,null,'','','','','','','','','','',0.00,'',null,'','',_error,_mensaje,0,null,null,null,0,null,null;
	elif _error = 1 then
		continue foreach;
	end if
	
	
	-- 18/07/2017 REQUERIMIENTO: RGORDON 07/08/2017 Vigencia INICIAL
	
	--Let =SI(N2 = "Nueva",SI(HOY()-D2 >=40,FECHA(2017,7,6),D2 + 40),SI(HOY()-D2 >=60,FECHA(2017,7,6),D2 + 60)) 
	if _nueva_renov = 'N' then
		let _cnt_holgura = _holgura_nueva; 		
	else
		let _cnt_holgura = _holgura_renov; 
	end if
	
	if _fecha_suscripcion > _fecha_primer_pago then
		let _fecha_anulacion = _fecha_suscripcion + _cnt_holgura units day;
		let _dias_resta = _fecha_actual - _fecha_suscripcion;
	else
		let _fecha_anulacion = _fecha_primer_pago + _cnt_holgura units day;
	end if

	if _dias_resta >= _cnt_holgura then
		let _fecha_anulacion = current;
	end if

	if _fecha_anulacion > _fecha_hasta then 
	    continue foreach;
	end if

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		 order by porc_partic_agt desc

		exit foreach;
	end foreach

	select nombre,
		   cod_cobrador
	  into _nom_agente,
		   _cod_cobrador
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _nom_zona
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;

	select trim(nombre)
	  into _nom_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;

	select trim(nombre)
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;	 

	select trim(nombre),
	       celular
	  into _nombre_cli,
	       _celular
	  from cliclien
	 where cod_cliente = _cod_cliente; 
	 
    select trim(nombre)
      into _nombre_formapag
      from cobforpa 
     where cod_formapag = _cod_formapag;
	 
	CALL sp_sis233 (_cod_cliente) returning _cliente_vip, _mensaje; 
	
	select count(*)
	  into _cnt_unidad
	  from emipouni 
	 where no_poliza = _no_poliza;
	 
	if _cnt_unidad = 1 then
		select cod_producto
		  into _cod_producto
		  from emipouni
		 where no_poliza = _no_poliza;
		 
		select nombre
		  into _producto
		  from prdprod
		 where cod_producto = _cod_producto;
	else
		let _cod_producto = null;
		let _producto     = 'Ver Detalles por Unidad';
	end if
		
	 
    return _no_documento,
	       _cod_cliente,
		   _nombre_cli,
	       _fecha_primer_pago,
           _vigencia_inic,
		   _vigencia_final,
		   _cod_formapag,
		   _nombre_formapag,
		   _cod_grupo,
		   _nom_grupo,
		   _cod_agente,
		   _nom_agente,
		   _cod_cobrador,
		   _nom_zona,
		   _cod_ramo,
		   _nombre_ramo,
		   _prima_bruta,
		   _desc_n_r,	
		   _fecha_anulacion,
		   _cod_campana,
           _nom_campana,
		   _dias_resta,
		   _cia_nombre,
		   _cliente_vip,
		   _fecha_actual,
		   _fecha_hasta,
		   _celular,
		   _a_pagar,
		   trim((case when _cod_producto is null then "Varios" else _cod_producto end)),
		   _producto
		   with resume;	 
	
end foreach
end
end procedure;