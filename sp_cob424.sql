-- Procedimiento para polizas con 15 dias en suspension - Emipoliza (Correo al Corredor)
-- Creado: 21/11/2017 - Autor: Henry Giron
-- execute procedure sp_cob424('00522',today,15)
drop procedure sp_cob424;
-- 23/09/2019 15:56
create procedure sp_cob424(a_cod_avican char (10), a_fecha_desde date default today, a_dias_cese smallint)
returning	integer			as cod_error,
			varchar(100)	as mensaje;

define _mensaje				varchar(100);
define _no_poliza			char(10);
define _cod_tipo			char(5);
define _excepcion			smallint;
define _ramo_sis			smallint;
define _pagada				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suspension	date;
define _desc_vip			varchar(50);
define _cliente_vip			smallint;
define _cod_cliente			char(10);
define _dias_cese		    smallint;
define _fecha_hoy			date;
define _fecha_suscripcion	date;
define _fecha_primer_pago	date;
define _no_documento		char(20);
define _cod_ramo			char(3);
define _cod_formapag		char(3);
define _cod_area			char(5);
define _cod_grupo			char(5);
define _cod_pagador			char(10);
define _cod_pagos			char(3);
define _cod_suc				char(3);
define _dia_cob1			smallint;
define _dia_cob2			smallint;
define _dias_vencido		smallint;
define _cod_status			char(1);
define _vigencia_inic		date;
define _vigencia_fin		date;
define _prima_bruta			dec(16,2);
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
define _cod_acreencia		smallint;
define _cod_zona			char(3);
define _cod_agente			char(5);
define _cod_tipoprod		char(3);
define _fecha_desde			date;
define _fecha_hasta			date;

set isolation to dirty read;

--set debug file to "sp_cob424.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
return _error,_mensaje;
end exception
let _fecha_hoy = a_fecha_desde;
if a_dias_cese = 0 then

	select valor_parametro
	  into _dias_cese
	  from inspaag
	 where codigo_parametro = 'par_cese';  -- parametro de cese a 15 dias 
else 
	let _dias_cese = a_dias_cese; 
end if	

let _fecha_desde = _fecha_hoy + _dias_cese units day;
let _fecha_hasta = _fecha_hoy + _dias_cese units day + 7 units day; -- en al semana

foreach
	Select no_documento,
		   cod_ramo,
		   cod_formapag, 
		   cod_area, 
		   cod_grupo,
		   cod_pagos,
		   cod_pagador,
		   cod_sucursal,
		   dia_cobros1,
		   dia_cobros2,
		   cod_status,
		   vigencia_inic,
		   vigencia_fin,
		   exigible,
		   por_vencer,
		   corriente,
		   monto_30,
		   monto_60,
		   monto_90,
		   monto_120,
		   monto_150,
		   monto_180,
		   saldo,
		   cod_acreencia,
		   cod_zona,
		   cod_agente,
		   prima_bruta,
		   fecha_suspension
	  into _no_documento, 
		   _cod_ramo, 
		   _cod_formapag, 
		   _cod_area, 
		   _cod_grupo, 
		   _cod_pagos, 
		   _cod_pagador, 
		   _cod_suc, 
		   _dia_cob1, 
		   _dia_cob2, 
		   _cod_status, 
		   _vigencia_inic, 
		   _vigencia_fin, 
		   _exigible, 
		   _por_vencer, 
		   _corriente, 
		   _monto_30, 
		   _monto_60, 
		   _monto_90, 
		   _monto_120, 
		   _monto_150, 
		   _monto_180, 
		   _saldo, 
		   _cod_acreencia, 
		   _cod_zona, 
		   _cod_agente, 
		   _prima_bruta,
           _fecha_suspension		   
	  from emipoliza 
	 where (fecha_suspension >= _fecha_desde and fecha_suspension <= _fecha_hasta )	   
	   and exigible > 1 
	   and cod_ramo in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 1)
	 {  and (cod_corriente  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '001')
			or cod_monto_30   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '002')
			or cod_monto_60   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '003')
			or cod_monto_90   = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '004')
			or cod_monto_120  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '005')
			or cod_monto_150  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '006')
			or cod_monto_180  = (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 2 and cod_filtro = '007') ) 	}
		and cod_formapag in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 3)
		--and cod_zona in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 4)
		and cod_status in (Select cod_filtro from avicanfil where cod_avican = a_cod_avican and tipo_filtro = 8)				
		and (no_documento not in ( select distinct no_documento from avisocanc Where estatus in ('G','I','M','X') and desmarca = 1 )
			or no_documento not in ( select distinct no_documento from avisocanc Where estatus in ('G','I') and desmarca = 0 and abs(date(_fecha_hoy) - fecha_desmarca) <= 15)
			or no_documento not in ( select distinct no_documento from avisocanc Where estatus in ('G','I') and desmarca = 0 and abs(date(_fecha_hoy) - fecha_desmarca) <= 15)
			or cod_status = 1 and no_documento not in ( select distinct no_documento from emipomae where carta_aviso_canc = 1 and estatus_poliza = 1 )
			or cod_status = 3 and no_documento not in ( select distinct no_documento from emipomae where carta_vencida_sal = 1 and estatus_poliza = 3 )
			or cod_status = 1 and no_documento not in ( select distinct no_documento from emipomae where carta_aviso_canc = 1 and vigencia_final = date(_fecha_hoy)))
 
	call sp_ley003(_no_documento,2) returning _error,_mensaje;

	if _error < 0 then
		let _mensaje = _mensaje || ' Poliza: ' || trim(_no_documento);
		return _error,_mensaje;
	elif _error = 1 then
		continue foreach;
	end if


	call sp_sis21(_no_documento) returning _no_poliza;

	if _no_poliza is null then
		continue foreach;
	end if
	
	select fecha_primer_pago,
		   fecha_suscripcion,
		   cod_tipoprod
	  into _fecha_primer_pago,
		   _fecha_suscripcion,
		   _cod_tipoprod		   
	  from emipomae
	 where no_poliza = _no_poliza;	 

	let _cliente_vip = 0; 
	call sp_sis233(_cod_pagador) returning _cliente_vip,_desc_vip; -- HG[JBRITO]14052019 Incumplimiento de Pago 1916-00044-01 si es VIP no lleva notificacion
	if _cliente_vip = 1 then
		continue foreach;
	end if 

	if _fecha_suscripcion > _fecha_primer_pago then
		let _dias_vencido = _fecha_hoy - _fecha_suscripcion;
	else
		let _dias_vencido = _fecha_hoy - _fecha_primer_pago;
	end if	

	-- No Incluye Coaseguro Minoritario ni Reaseguro Asumido
	if _cod_tipoprod = '002' then
	   continue foreach;
	end if
	
	if _dias_vencido < _dias_cese then
		continue foreach;
	end if	
	
	if _vigencia_inic >= a_fecha_desde then
		continue foreach;
	end if
	
	{call sp_cob116(_no_poliza)
	returning	_cod_agente,  
				_nom_agente,      
				_cod_cobrador,
				_nom_cobrador,
				_leasing,
				_cod_div_cob,
				_nom_div_cob;}	

	insert into avicanpoliza(
		   no_documento,
		   cod_ramo,
		   cod_formapag,
		   cod_area,   
		   cod_grupo,
		   cod_pagos,
		   cod_pagador,
		   cod_sucursal,
		   dia_cobros1,
		   dia_cobros2,
		   cod_status,
		   vigencia_inic,
		   vigencia_fin,
		   exigible,
		   por_vencer,
		   corriente,
		   monto_30,
		   monto_60,
		   monto_90,
		   monto_120,
		   monto_150,
		   monto_180,
		   saldo,
		   cod_agente,
		   cod_zona,
		   cod_acreencia,
		   cod_avican,
		   prima_bruta)
	values(
		   _no_documento,
		   _cod_ramo,
		   _cod_formapag,
		   _cod_area,
		   _cod_grupo,
		   _cod_pagos,
		   _cod_pagador,
		   _cod_suc,
		   _dia_cob1,
		   _dia_cob2,
		   _cod_status,
		   _vigencia_inic,
		   _vigencia_fin,
		   _exigible,
		   _por_vencer,
		   _corriente,
		   _monto_30,
		   _monto_60,
		   _monto_90,
		   _monto_120,
		   _monto_150,
		   _monto_180,
		   _saldo,
		   _cod_agente,
		   _cod_zona,
		   _cod_acreencia,
		   a_cod_avican,
		   _prima_bruta);	


end foreach

return 0,'Exito';
end 

end procedure