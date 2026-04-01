-- Proceso Generar el informe de Morosidad por Corredor
-- Creado por :     Roman Gordon	07/02/2011
-- Modificado por : Federico Coronado 18/01/2023 se agregarón los telefonos y email. copia del sp_cob265_new
--execute procedure sp_cob265_n('01321','001','001')
-- SIS v.2.0 - DEIVID, S.A.


Drop Procedure sp_cob265_new;
Create Procedure sp_cob265_new(a_cod_agente char(5), a_compania char(3), a_sucursal char(3))
Returning char(100)		as asegurado,
		  varchar(30)	as cedula_asegurado,
		  char(100)		as contratante,
		  varchar(30)	as cedula_contratante,
		  char(10)      as celular,
		  char(10)		as telefono1,
		  char(10)		as telefono2,
		  char(50)		as e_mail,
		  char(20)		as poliza,
		  char(50)		as ramo,
		  char(10)		as estatus_poliza,
		  char(50)		as forma_pago,
		  char(50)		as acreedor,
		  date			as vigencia_inic,
		  integer		as vig_fin_dia,
		  integer		as vig_fin_mes,	  
		  integer		as vig_fin_anio,
		  date			as fecha_utl_pago,
		  dec(16,2)		as mont_ult_pago,
		  dec(16,2)		as prima_bruta,
		  dec(16,2)		as saldo,
		  dec(16,2)		as por_vencer,
		  dec(16,2)		as exigible,
		  dec(16,2)		as corriente,
		  dec(16,2)		as monto30,
		  dec(16,2)		as monto60,
		  dec(16,2)		as monto90,		  
		  smallint		as no_pagos,
		  char(50)		as compania,
		  char(100)		as agente,
		  char(50)		as grupo,
		  date			as aviso_canc,
		  date			as fecha_susp_cob,
		  smallint		as facultativo,
		  char(10)      as celular2;


define _cedula_aseg			varchar(30);			
define _cedula				varchar(30);			
define _nombre_agente		char(100);
define _nombre_cliente		char(100);
define _nombre_aseg			char(100);
define _email_agente		char(50);
define _nom_formapag		char(50);
define _nom_grupo			char(50);
define _nom_ramo			char(50);
define _nom_acre			char(50);
define v_compania_nombre	char(50);
define _no_documento		char(20);
define _status_poliza		char(10);
define _cod_asegurado		char(10);
define _cod_cliente			char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_grupo			char(5);
define _no_unidad			char(5);
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
define _facultativo			smallint;
define _cod_estatus			smallint;
define _cant_pagos			smallint;
define _leasing             smallint;
define _session_id			integer;
define _vig_fin_anio_int	integer;
define _vig_fin_dia_int		integer;
define _vig_fin_mes_int		integer;
define _fecha_aviso_canc	date;
define _fecha_ult_pago		date;
define _fecha_susp_cob		date;
define _vigencia_inic		date;
define _vigencia_fin		date;
define _fecha_hoy			date;
define _cnt_agt 			smallint;
define _flag 				smallint;
define _cnt_uni             smallint;
define _celular,_celular2	char(10);
define _telefono1			char(10);
define _telefono2			char(10);
define _e_mail				char(50);

set isolation to dirty read;

--set debug file to 'sp_cob265fc.trc';
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
let _cnt_uni = 0;
	
let v_compania_nombre = sp_sis01(a_compania);
let _fecha_hoy = today;
let _periodo = sp_sis39(_fecha_hoy);
let	_no_poliza = '';
select nombre
  into _nombre_agente
  from agtagent
 where cod_agente = a_cod_agente;

-- RGORDON:Se incluye join con emipoagt HGIRON 11/06/208
 foreach
/*	select a.no_documento, a.no_poliza
	  into _no_documento, _no_poliza
	  from emipoliza a, emipoagt b
	 where a.cod_agente = a_cod_agente
       and a.no_poliza  = b.no_poliza
       and a.cod_agente = b.cod_agente
*/
/**********************************************************************************************************/
--FCORONAD por caso 33420 NSOLIS cuando la póliza tenía más de un corredor solo le aparecía a uno solo 19/12/2019
/**********************************************************************************************************/
	 select p.no_documento
	   into _no_documento
	   from emipoagt a, emipomae p
	  where a.cod_agente   = a_cod_agente
		and a.no_poliza    = p.no_poliza
		and p.actualizado  = 1
      group by p.no_documento
      order by 1
   
	let _no_poliza = sp_sis21(_no_documento);

	foreach
	 select count(*)
	   into _cnt_agt
	   from emipoagt
	  where cod_agente = a_cod_agente
	    and no_poliza = _no_poliza
		
		if _cnt_agt is null then
			let _cnt_agt = 0;
		end if
		
		if _cnt_agt = 0 then
			let _flag = 1;
		else
			let _flag = 0;
		end if
	end foreach

	if _flag = 1 then
		continue foreach;
	end if
/******************************************************************/
--FCORONAD fin
/*****************************************************************/

	let	_nombre_cliente	= '';
	let	_cod_formapag = '';
	let	_cod_cliente = '';	
	--let	_no_poliza = '';
	let _nom_acre = '';
	let	_fecha_ult_pago	= null;
	let	_vigencia_inic = '01/01/1900';
	let	_vigencia_fin = '01/01/1900';
	let	_cod_estatus = 0;
	let	_cant_pagos = 0;	
	
	--let _no_poliza = sp_sis21(_no_documento);

	select no_documento,
		   cod_formapag,
		   prima_bruta,
		   cod_pagador,
		   fecha_aviso_canc,
		   no_pagos,
		   leasing,
		   cod_grupo
	  into _no_documento,
		   _cod_formapag,
		   _prima_bruta,
		   _cod_cliente,
		   _fecha_aviso_canc,
		   _cant_pagos,
		   _leasing,
		   _cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _cod_formapag  = '084' or _cod_formapag = '085' then
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

	select cod_status,
		   vigencia_inic,
		   vigencia_fin,
		   cod_ramo,
		   fecha_suspension
	  into _cod_estatus,
		   _vigencia_inic,
		   _vigencia_fin,
		   _cod_ramo,
		   _fecha_susp_cob
	  from emipoliza
	 where no_documento = _no_documento;

	if _cod_grupo = '77950' then
		select u.desc_unidad
		  into _nombre_aseg
		  from emipouni u 
		 where u.no_poliza  = _no_poliza
		   and cod_asegurado = '660666';

		let _no_unidad = '000001';
		let _cod_asegurado = null;
		let _cedula_aseg = null;		
	else
		select first 1 u.no_unidad,
			   u.cod_asegurado,   
			   c.nombre,
			   c.cedula
		  into _no_unidad,
			   _cod_asegurado,
			   _nombre_aseg,
			   _cedula_aseg
		  from cliclien c
		 inner join emipouni u on u.cod_asegurado = c.cod_cliente
		 where u.no_poliza  = _no_poliza
		 group by u.no_unidad,u.cod_asegurado,c.nombre,c.cedula;
	end if
/*************************************************************************************************************************************/
--FCORONAD por caso 5339 Enilda Fernandez las pólizas con mas de una unidad deben leer en datos de asegurado ver unidades 05/01/2023
/*************************************************************************************************************************************/
	select count(*)
	  into _cnt_uni
	  from emipouni
	 where no_poliza = _no_poliza;
	 
	 if _cnt_uni > 1 then
		let _nombre_aseg = "Ver Unidades";
		let _cedula_aseg = "Ver Unidades";
	 end if
/******************************************************************/
--FCORONAD fin
/*****************************************************************/
	select count(*)
	  into _facultativo
	  from emifacon c, reacomae r
	 where c.no_poliza = _no_poliza
	   and c.no_endoso = '00000'
	   and r.cod_contrato = c.cod_contrato
	   and r.tipo_contrato = 3;

	let _vig_fin_dia = day(_vigencia_fin);
	let _vig_fin_mes = month(_vigencia_fin);
	let _vig_fin_anio = year(_vigencia_fin);

	let _vig_fin_dia_int =	cast(_vig_fin_dia as integer);
	let _vig_fin_mes_int =	cast(_vig_fin_mes as integer) ;	
	let _vig_fin_anio_int = cast(_vig_fin_anio as integer);

	--trace off;
	let	_monto_ult_pago	= 0.00;
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
				
	call sp_cob245('001','001',_no_documento,_periodo,_fecha_hoy)
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
	
	let _monto_90 = _monto_90 + _monto_120 + _monto_150 + _monto_180;

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
		   celular,
		   telefono1,
		   telefono2,
		   e_mail,
		   fax
	  into _nombre_cliente,
		   _cedula,
		   _celular,
		   _telefono1,
		   _telefono2,
		   _e_mail,
		   _celular2
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select nombre
	  into _nom_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;
	
	let _telefono1 = replace(_telefono1,'-','');
	let _telefono2 = replace(_telefono2,'-','');
	let _celular = replace(_celular,'-','');
	
	if _telefono1 is not null and trim(_telefono1) <> '' Then
	   let _telefono1 = trim(_telefono1);
	   let _telefono1 = _telefono1[1,3]||"-"||_telefono1[4,8];
	end if

	if _telefono2 is not null and trim(_telefono2) <> '' Then
	   let _telefono2 = trim(_telefono2);
	   let _telefono2 = _telefono2[1,3]||"-"||_telefono2[4,8];
	end if

	if _celular is not null and trim(_celular) <> '' Then
	   let _celular = trim(_celular);
	   let _celular = _celular[1,4]||"-"||_celular[5,8];
	end if
	if _celular2 is not null and trim(_celular2) <> '' Then
	   let _celular2 = trim(_celular2);
	   let _celular2 = _celular2[1,4]||"-"||_celular2[5,8];
	end if
	 
	if _telefono1 is not null then
		if _telefono1[1] not between "0" and "9" or 
		   _telefono1[2] not between "0" and "9" or
		   _telefono1[3] not between "0" and "9" or
		   _telefono1[4] <> "-" or
		   _telefono1[5] not between "0" and "9" or
		   _telefono1[6] not between "0" and "9" or
		   _telefono1[7] not between "0" and "9" or
		   _telefono1[8] not between "0" and "9" or
		   _telefono1[9] <> " " or
		   _telefono1[10] <> " " then
			let _telefono1 = "";
		end if
	end if 
	
	if _telefono2 is not null then
		if _telefono2[1] not between "0" and "9" or 
		   _telefono2[2] not between "0" and "9" or
		   _telefono2[3] not between "0" and "9" or
		   _telefono2[4] <> "-" or
		   _telefono2[5] not between "0" and "9" or
		   _telefono2[6] not between "0" and "9" or
		   _telefono2[7] not between "0" and "9" or
		   _telefono2[8] not between "0" and "9" or
		   _telefono2[9] <> " " or
		   _telefono2[10] <> " " then
			let _telefono2 = "";
		end if
	end if
	
	if _celular is not null then
		if _celular[1] not between "0" and "9" or 
		   _celular[2] not between "0" and "9" or
		   _celular[3] not between "0" and "9" or
		   _celular[4] not between "0" and "9" or
		   _celular[5] <> "-" or
		   _celular[6] not between "0" and "9" or
		   _celular[7] not between "0" and "9" or
		   _celular[8] not between "0" and "9" or
		   _celular[9] not between "0" and "9" or
		   _celular[10] <> " " then
			let _celular = "";
		end if
	end if
	if _celular2 is not null then
		if _celular2[1] not between "0" and "9" or 
		   _celular2[2] not between "0" and "9" or
		   _celular2[3] not between "0" and "9" or
		   _celular2[4] not between "0" and "9" or
		   _celular2[5] <> "-" or
		   _celular2[6] not between "0" and "9" or
		   _celular2[7] not between "0" and "9" or
		   _celular2[8] not between "0" and "9" or
		   _celular2[9] not between "0" and "9" or
		   _celular2[10] <> " " then
			let _celular2 = "";
		end if
	end if	
	return	_nombre_aseg,
			_cedula_aseg,
			_nombre_cliente,
			_cedula,
			_celular,
		    _telefono1,
		    _telefono2,
		    _e_mail,			
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
			_cant_pagos,		
			v_compania_nombre,
			_nombre_agente,	
			_nom_grupo,
			_fecha_aviso_canc,
			_fecha_susp_cob,
			_facultativo,
			_celular2
			with resume;
			
let	_no_poliza = '';			
end foreach
end procedure;