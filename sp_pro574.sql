-- Procedimiento que genera el endoso de disminución/eliminación de Coberturas para la aplicación de la ley 68 (Sobat)
-- 
-- Creado     : 11/01/2018 - Autor: Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro574('','DEIVID',0.00,'001')

drop procedure sp_pro574;
create procedure sp_pro574(
a_no_poliza		char(10),
a_usuario		char(8),
a_saldo			dec(16,2),
a_suscursal     char(3)
) returning integer,
            varchar(200),
            char(5);


define _descripcion				varchar(200);
define _email_send				varchar(200);
define _desc_limite1			varchar(50);
define _desc_limite2			varchar(50);
define _error_desc				varchar(50);
define _no_documento			char(20);
define _cod_cliente				char(10);
define _no_factura				char(10);
define _periodo					char(7);
define _no_endoso_ext			char(5);
define _cod_cobertura			char(5);
define _no_endoso				char(5);
define _no_unidad				char(5);
define _cod_tipo				char(5);
define _cod_endomov				char(3);
define _cod_no_renov			char(3);
define _cod_tipocalc			char(3);
define _cod_impuesto			char(3);
define _cod_ramo				char(3);
define _null					char(1);
define _porct_imp_i				dec(5,2);
define _prima_pronto_pago		dec(16,2);
define _factor_impuesto			dec(16,2);
define _prima_suscrita			dec(16,2);
define _prima_retenida			dec(16,2);
define _suma_asegurada			dec(16,2);
define _suma_impuesto			dec(16,2);
define _prima_bruta_e			dec(16,2);
define _prima_bruta				dec(16,2);
define _prima_anual				dec(16,2);
define _max_limite1				dec(16,2);
define _max_limite2				dec(16,2);
define _prima_neta				dec(16,2);
define _por_vencer				dec(16,2);
define _corriente				dec(16,2);
define _descuento				dec(16,2);
define _impuesto				dec(16,2);
define _exigible				dec(16,2);
define _limite1					dec(16,2);
define _limite2					dec(16,2);
define _recargo					dec(16,2);
define _dias_90					dec(16,2);
define _dias_30					dec(16,2);
define _dias_60					dec(16,2);
define _saldo					dec(16,2);
define _prima					dec(16,2);
define _factor_vigencia			dec(16,9);
define _tiene_impuesto			smallint;
define _cnt_pronto_pago			smallint;
define _dias_cubiertos			smallint;
define _no_endoso_int			smallint;
define _dias_vigencia			smallint;
define _orden					smallint;
define _cantidad				smallint;
define _signo					smallint;
define _dias2					smallint;
define _error_isam				integer;
define _error					integer;
define _fecha_cubierto_hasta	date;
define _vigencia_final			date;
define _vigencia_inic			date;
define _fecha_actual			date;
define _estatus_poliza          smallint;
define _existe_rev              smallint;

define _no_poliza2		char(10);
define _no_poliza		char(10);
DEFINE _cod_agente      CHAR(5);
DEFINE _cod_grupo       CHAR(5);

if a_no_poliza = '2482791' then
	set debug file to 'sp_pro574.trc';
	trace on;
end if

begin 
on exception set _error, _error_isam, _error_desc 
	call sp_par27(a_no_poliza,_no_endoso);
	return _error, _error_desc, '';
end exception

set isolation to dirty read;

{ let _no_poliza = a_no_poliza;  -- JBRITO: Tomar ultima no_poliza. 18/10/2018 en  CESE

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = a_no_poliza;			   
 
let _no_poliza2 = sp_sis21(_no_documento);

if _no_poliza2 <> _no_poliza then
	let _no_poliza = _no_poliza2;
end if

let a_no_poliza = _no_poliza;
}
--Si la poliza ya esta cancelada, NO debe realizar Cese de Coberturas. Armando.
select estatus_poliza
  into _estatus_poliza
  from emipomae
 where no_poliza = a_no_poliza;
 
 if _estatus_poliza in(2,4) then
	 select count(*)
	   into _cnt_pronto_pago
	   from endedmae
	  where no_poliza = a_no_poliza
	    and cod_tipocan = '012';		--POR VENTA DEL AUTO
	if _cnt_pronto_pago is null then
		let _cnt_pronto_pago = 0;
	end if
	if _cnt_pronto_pago > 0 then
		return 2, 'Poliza ya fue Cancelada', '';
	end if	
 end if

let _prima_pronto_pago = 0.00;
let _existe_rev = 0;

select count(*)
  into _cnt_pronto_pago
  from endedmae
 where no_poliza = a_no_poliza
   and cod_endomov = '024'
   and actualizado = 1;

if _cnt_pronto_pago is null then
	let _cnt_pronto_pago = 0;
end if

select count(*)
  into _existe_rev
  from endedmae
 where no_poliza   = a_no_poliza
   and cod_endomov = '025'		 --endoso de reversion de descuento de pronto pago
   and actualizado = 1;

if (_cnt_pronto_pago - _existe_rev) > 0 then
else
	let _cnt_pronto_pago = 0;
end if

if _cnt_pronto_pago > 0 then

	foreach
		select prima_bruta
		  into _prima_pronto_pago
		  from endedmae
		 where no_poliza = a_no_poliza
		   and cod_endomov = '024'
		   and actualizado = 1
		 order by fecha_emision desc
		exit foreach;
	end foreach

	let _prima_pronto_pago = _prima_pronto_pago * -1;
	call sp_pro578(a_no_poliza,'DEIVID',_prima_pronto_pago) returning _error,_error_desc;

	if _error < 0 then
		return _error, _error_desc, '';
	end if
end if

let _periodo      = sp_sis39(today);
let _fecha_actual = current;
let _cod_endomov  = '032'; -- Cese de Coberturas
let _cod_tipocalc = '004'; -- Saldo
let _cod_no_renov = '039'; -- FALTA DE PAGO
let _cod_tipo	  = '00041'; -- Notificación de Cese de Coberturas
let _null         = null;  -- Para campos null
let _signo        = -1;

select max(no_endoso)
  into _no_endoso_int
  from endedmae
 where no_poliza = a_no_poliza;

let _no_endoso      = sp_set_codigo(5, _no_endoso_int + 1);
let _no_endoso_ext  = sp_sis30(a_no_poliza, _no_endoso);
let _max_limite1 = 5000;
let _max_limite1 = 10000;

select e.no_documento,
	   p.fecha_cubierto,
	   e.vigencia_inic,
	   e.vigencia_final,
	   e.cod_ramo,
	   e.prima_bruta,
	   e.cod_pagador,
	   e.cod_grupo
  into _no_documento,
	   _fecha_cubierto_hasta,
	   _vigencia_inic,
	   _vigencia_final,
	   _cod_ramo,
	   _prima_bruta_e,
	   _cod_cliente,
	   _cod_grupo
  from emipomae e
  join emipoliza p on e.no_documento = p.no_documento
 where e.no_poliza = a_no_poliza;

let _dias_vigencia = _vigencia_final - _vigencia_inic;

call sp_cob174(_no_documento) returning	_saldo;

if _prima_bruta_e = 0 then
	let _prima_bruta_e = 1;
	let _dias_vigencia = 1;
end if
let _dias_cubiertos = (_saldo/_prima_bruta_e) * _dias_vigencia;	
let _factor_vigencia = (_saldo/_prima_bruta_e);
let _fecha_cubierto_hasta = _vigencia_final - _dias_cubiertos units day;

if _fecha_cubierto_hasta < _vigencia_inic then
	let _fecha_cubierto_hasta = _vigencia_inic;
end if

let _dias2  = _fecha_cubierto_hasta - _vigencia_final;

if _dias2 = 0 then
   let _dias2 = -1;
end if

let _factor_vigencia = round(_dias2 / _dias_vigencia,3);

let _factor_vigencia = (_saldo/_prima_bruta_e);

if 	_factor_vigencia > 0 then
	let _factor_vigencia = _factor_vigencia * -1 ;
end if

select emi_periodo
  into _periodo
  from parparam
 where cod_compania = '001';

insert into endedmae(
no_poliza,
no_endoso,
cod_compania,
cod_sucursal,
cod_tipocalc,
cod_formapag,
cod_tipocan,
cod_perpago,
cod_endomov,
no_documento,
vigencia_inic,
vigencia_final,
prima,
descuento,
recargo,
prima_neta,
impuesto,
prima_bruta,
prima_suscrita,
prima_retenida,
tiene_impuesto,
fecha_emision,
fecha_impresion,
fecha_primer_pago,
no_pagos,
actualizado,
no_factura,
fact_reversar,
date_added,
date_changed,
interna,
periodo,
user_added,
factor_vigencia,
suma_asegurada,
posteado,
activa,
vigencia_inic_pol,
vigencia_final_pol,
no_endoso_ext,
cod_tipoprod,
cotizacion,
de_cotizacion,
gastos
)
select 
no_poliza,
_no_endoso,
cod_compania,
a_suscursal,
_cod_tipocalc,
cod_formapag,
_null, 
cod_perpago,
_cod_endomov,
no_documento,
_fecha_cubierto_hasta,
vigencia_final,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
tiene_impuesto,
today,
today,
today,
1,
0,
_null,
_null,
today,
today,
1,
_periodo,
a_usuario,
_factor_vigencia,
0.00,
0,
1,
vigencia_inic,
vigencia_final,
_no_endoso_ext,
cod_tipoprod,
_null,
0,
0.00
  from emipomae
 where no_poliza = a_no_poliza;

select tiene_impuesto
  into _tiene_impuesto
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;

if _tiene_impuesto = 1 then

	insert into endedimp(
			no_poliza,
			no_endoso,
			cod_impuesto,
			monto)
	select no_poliza,
		   _no_endoso,
		   cod_impuesto,
		   0.00
	  from emipolim
	 where no_poliza = a_no_poliza;
end if

select count(*)
  into _cantidad
  from endedimp
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;

if _cantidad = 0 then	
	update endedmae
	   set tiene_impuesto = 0
     where no_poliza      = a_no_poliza
       and no_endoso      = _no_endoso;

	let _tiene_impuesto = 0;
end if

let _prima_bruta = a_saldo * -1;

if _tiene_impuesto = 1 then

	let _suma_impuesto = 0.00;

	foreach	
		select cod_impuesto
		  into _cod_impuesto
		  from emipolim
		 where no_poliza = a_no_poliza

		select factor_impuesto
		  into _factor_impuesto
		  from prdimpue
		 where cod_impuesto = _cod_impuesto;

		let _suma_impuesto = _suma_impuesto  + (_factor_impuesto / 100);
	end foreach

	let _prima_neta = _prima_bruta / (1 + _suma_impuesto);
else
	let _prima_neta = _prima_bruta;
end if

let _impuesto = _prima_bruta - _prima_neta;

update endedmae
   set prima_neta  = _prima_neta,
	   impuesto    = _impuesto,
	   prima_bruta = _prima_bruta
 where no_poliza   = a_no_poliza
   and no_endoso   = _no_endoso;
   
insert into endeduni(
	   no_poliza, 
	   no_endoso, 
	   no_unidad, 
	   cod_ruta, 
	   cod_producto, 
	   cod_cliente, 
	   suma_asegurada,
	   prima, 
	   descuento, 
	   recargo, 
	   prima_neta, 
	   impuesto, 
	   prima_bruta, 
	   reasegurada, 
	   vigencia_inic,
	   vigencia_final, 
	   beneficio_max, 
	   desc_unidad, 
	   prima_suscrita, 
	   prima_retenida, 
	   suma_aseg_adic,
	   gastos, 
	   tipo_incendio)	
select a_no_poliza,
	   _no_endoso,
	   no_unidad,
	   cod_ruta,
	   cod_producto,
	   cod_asegurado,
	   suma_asegurada * _signo,
	   0.00,
	   0.00,
	   0.00,
	   0.00,
	   0.00,
	   0.00,
	   reasegurada,
	   vigencia_inic,
	   vigencia_final,
	   beneficio_max,
	   desc_unidad,
	   0.00,
	   0.00,
	   0,
	   gastos,
	   _null
  from emipouni
 where no_poliza = a_no_poliza;
{
delete from endedcob
 where no_poliza   = a_no_poliza
   and no_endoso   = _no_endoso;

Insert Into endedcob(
		no_poliza,
		no_endoso,
		no_unidad,
		cod_cobertura,
		orden,
		tarifa,
		deducible,
		limite_1,
		limite_2,
		prima_anual,
		prima,
		descuento,
		recargo,
		prima_neta,
		date_added,
		date_changed,
		desc_limite1,
		desc_limite2,
		factor_vigencia,
		opcion)
select a_no_poliza,
	   _no_endoso,
	   no_unidad,
	   cod_cobertura,
	   orden,
	   0.00,
	   deducible,
	   limite_1 * _signo,
	   limite_2 * _signo,
	   prima_anual * _signo,
	   prima * _factor_vigencia,-- * _signo,
	   descuento * _factor_vigencia,-- * _signo,
	   recargo * _factor_vigencia,-- * _signo,
	   prima_neta * _factor_vigencia,-- * _signo,
	   current,
	   current,
	   desc_limite1,
	   desc_limite2,
	   _factor_vigencia,
	   3
  from emipocob
 where no_poliza = a_no_poliza;}
 
call sp_pro493(a_no_poliza, _no_endoso, -1) returning _error, _descripcion;

update endedcob
   set opcion = 3
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;

foreach
	select no_unidad,
		   suma_asegurada
	  into _no_unidad,
		   _suma_asegurada
	  from endeduni
	 where no_poliza = a_no_poliza
	   and no_endoso = _no_endoso

	let _orden = 0;
	foreach
		select c.cod_cobertura
		  into _cod_cobertura
		  from prdcober c
		  join prdramo r on c.cod_ramo = r.cod_ramo
		 where r.cod_ramo = _cod_ramo
		   and c.nombre like '%SOBAT%'
		 order by c.nombre desc

		let _orden = _orden + 1;

		select rango_monto1,
			   rango_monto2
		  into _limite1,
			   _limite2
		  from prdtasec
		 where cod_producto = '03997'
		   and cod_cobertura = _cod_cobertura;

		select desc_limite1,
			   desc_limite2
		  into _desc_limite1,
			   _desc_limite2
		  from prdcobpd
		 where cod_producto = '03997'
		   and cod_cobertura = _cod_cobertura;

		insert Into endedcob(
				no_poliza,
				no_endoso,
				no_unidad,
				cod_cobertura,
				orden,
				tarifa,
				deducible,
				limite_1,
				limite_2,
				prima_anual,
				prima,
				descuento,
				recargo,
				prima_neta,
				date_added,
				date_changed,
				desc_limite1,
				desc_limite2,
				factor_vigencia,
				opcion)
		values( a_no_poliza,
				_no_endoso,
				_no_unidad,
				_cod_cobertura,
				_orden,
				0.00,
				0,
				_limite1,
				_limite2,
				0,
				0,
				0,
				0,
				0,
				current,
				current,
				_desc_limite1,
				_desc_limite2,
				1,
				1);
	end foreach
end foreach
   
select sum(prima_suscrita), 
	   sum(prima_retenida), 
	   sum(prima), 
	   sum(descuento),
       sum(recargo), 
       sum(prima_neta), 
       sum(impuesto), 
       sum(prima_bruta), 
       sum(suma_asegurada)
  into _prima_suscrita, 
  	   _prima_retenida, 
  	   _prima, 
  	   _descuento, 
       _recargo, 
       _prima_neta, 
       _impuesto, 
       _prima_bruta, 
       _suma_asegurada
  from endeduni					 
 where no_poliza  = a_no_poliza
   and no_endoso  = _no_endoso;

update endedmae
   set prima_suscrita = _prima_suscrita,
	   prima_retenida = _prima_retenida,
       prima          = _prima,
       descuento      = _descuento,
	   recargo        = _recargo,
	   suma_asegurada = _suma_asegurada,
	   prima_neta     = _prima_neta,
	   prima_bruta    = _prima_bruta
 where no_poliza      = a_no_poliza
   and no_endoso      = _no_endoso;

call sp_pro43(a_no_poliza, _no_endoso) returning _error, _descripcion;

if _error <> 0 then
	return _error, _descripcion, _no_endoso;
end if

update emipomae  
   set carta_aviso_canc	  = 0,
	   fecha_aviso_canc	  = null,
	   fecha_vencida_sal  = null,
	   carta_prima_gan	  = 0,
	   carta_recorderis	  = 0,
	   carta_vencida_sal  = 0,
	   cod_no_renov       = _cod_no_renov,
	   no_renovar         = 1
 where no_poliza		  = a_no_poliza;
 
--Actualizar tabla Emirepol (pool manual), Emirepo (pool automatico) para que no se pueda renovar la poliza.
update emirepol
   set no_renovar = 1
 where no_documento = _no_documento;

update emirepo
   set no_renovar = 1
 where no_documento = _no_documento;

select no_factura
  into _no_factura
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso;

update avisocanc
   set estatus         = 'Z',
	   cancela         = 1,
	   fecha_cancela   = today,
	   motivo          = 'Disminución de Coberturas/ Ley Sobat',
	   user_cancela    = a_usuario,
	   no_endoso       = _no_endoso,
	   no_factura      = _no_factura,
	   saldo_cancelado = _saldo
 where no_poliza       = a_no_poliza;

update emipouni
   set cod_producto = '03997'
 where no_poliza = a_no_poliza;


call sp_sis163(_cod_cliente) returning _email_send;

{foreach
select cod_agente
  into _cod_agente
  from endmoage
 where no_poliza = a_no_poliza
   and no_endoso = _no_endoso
  exit foreach;
   end foreach}
   
   if _cod_grupo = '1122' or _cod_grupo = '77960'  then      --  F9:30295 ASTANCIO para  reporte Banisi-Ducruet      -- SD#3010 77960  11/04/2022 10:00
	
		  let _cod_agente = '02618'; -- Ducruet - Directo
	  
	 call sp_par318(_cod_agente) returning _email_send;   --  5.	El endoso por cese de cobertura se debe enviar a U.D. EMAIL:ASTANZIO 26/12/2018	 
  end if

--Generar Notificación de Cese de Coberturas
call sp_sis455a(_cod_tipo,_email_send,'','',a_no_poliza,0,'','',0.00,0.00,0.00,null,1) returning _error,_descripcion;
if _error <> 0 then
	return _error, _descripcion, _no_endoso;
end if

--Generar Notificación de Cese de Coberturas en App Movil
{call sp_sis458(_cod_cliente,_no_documento,_tipo_notif) returning _error,_descripcion;
if _error <> 0 then
	return _error, _descripcion, _no_endoso;
end if}

return 0, 'Actualizacion Exitosa', _no_endoso;
end
end procedure;