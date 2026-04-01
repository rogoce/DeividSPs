-- Procedimiento que Realiza la Renovacion de la Poliza desde programa de opciones de renovacion
-- Es una copia del procedure sp_pro281.

-- Creado    : 07/01/2005 - Autor: Armando Moreno M.
-- mod		 : 03/04/2007 - poner suma aseg decimal y entera cuando es ramo auto.

drop procedure sp_pro283a;
create procedure sp_pro283a(
v_usuario		char(8),
v_poliza		char(10),
v_poliza_nuevo	char(10),
a_opcion		integer default 0)
returning	integer,
			char(100);

define _error_desc			char(100);
define _no_motor			char(30);
define _no_documento		char(20);
define _no_tarjeta			char(19);
define _no_cuenta			char(17);
define _cod_manzana			char(15);
define _cod_asegurado		char(10);
define _cod_pagador			char(10);
define _fecha_exp			char(7);
define _cod_cobertura		char(5); 
define _cod_producto		char(5); 
define _cod_product1		char(5);
define _cod_product2		char(5);
define _no_unidad			char(5); 
define _cod_ruta			char(5);
define _nounidad			char(5);
define _cod_agt				char(5);
define _no_uni				char(5);
define _cod_descuento		char(3);
define ls_cod_perpago		char(3);
define _cod_tipoprod		char(3);
define _cod_formapag		char(3);
define _cod_impuesto		char(3);
define _cod_perpago			char(3);
define ls_impuesto			char(3);
define _cod_origen			char(3); 
define _cod_rammo			char(3);
define _cod_banco			char(3);
define _cod_ramo			char(3);
define _valor_asignar		char(1); 
define _tipo_tarjeta		char(1);
define _cobra_poliza		char(1);
define _tipo_cuenta			char(1);
define _cod_prod			char(5);
define _cod_subramo			char(3);
define _tipo_agente			char(1);
define _porc_depre_uni		dec(5,2);
define _porc_depre_pol		dec(5,2);
define _porc_descuento		dec(5,2);
define _porc_depre			dec(5,2);
define _porc_com			dec(5,2);
define _suma_asegurada		dec(16,2);
define ld_prima_anual		dec(16,2);
define ld_prima_bruta		dec(16,2);
define ld_prima_neta		dec(16,2);
define _suma_decimal		dec(16,2);
define ld_descuento			dec(16,2);
define _prima_bruta			dec(16,2);
define _suma_difer			dec(16,2);
define ld_suscrita			dec(16,2);
define ld_retenida			dec(16,2);
define _monto_visa			dec(16,2);
define _suma_acum			dec(16,2);
define ld_recargo			dec(16,2);
define ld_prima				dec(16,2);
define ld_impuesto			dec(16,4);
define ld_impuesto1			dec(16,4);
define _dia_cobros1			smallint;
define _dia_cobros2			smallint;
define _tipo_forma			smallint;
define _ano_actual			smallint;
define li_no_pagos			smallint;
define _aplica_imp			smallint;
define _saber_agt			smallint;
define _resultado			smallint;
define _ano_auto			smallint;
define li_meses				smallint;
define _r_anos				smallint;
define li_dia				smallint;
define li_mes				smallint;
define li_ano				smallint;
define r_anos				smallint;
define _canti				smallint;
define _nuevo				smallint;
define _anno				smallint;
define _mes					smallint;
define _no_renovar          smallint;
define _cant_unidades		integer;
define _anos_pagador		integer;
define _suma_entera			integer;
define _error_isam			integer;
define _no_pagos  			integer;
define _opc_fin				integer;
define _saber				integer;
define _error				integer;
define _cnt					integer;
define _fecha_primer_pago	date;
define _vigencia_final		date;
define ld_fecha_1_pago		date;
define _fecha_actual		date;
define _vig_fin				date;
define _v_f					date;
define _v_i					date;
define _vf					date;
define _vi					date;
define _uso                 char(1);
define _cod_pro             char(5);
define _cant_p              smallint;
define _tipo_auto         	smallint;
define _no_recibo           char(10);
define _desc_comb           decimal(16,2);
define _desc_modelo         decimal(16,2);
define _desc_sini           decimal(16,2);
define _retorno             smallint;
define _cod_tipo_tar        char(3);

define _incurrido_bruto		dec(16,2);
define _prima_devengada		dec(16,2);
define _siniestralidad		dec(16,2);
define _descuento_sini		dec(16,2);
define _condicion           smallint;
define _descuento_modelo    decimal(16,2);
DEFINE _cod_modelo			CHAR(5);
DEFINE _cod_tipo			CHAR(3);
DEFINE _cod_marca           CHAR(5);

define _no_sinis_ult		smallint;
define _no_sinis_his		smallint;
define _no_vigencias		smallint;
define _no_sinis_pro		dec(16,2);
define _cod_ramo_uni        char(3);

define _desc_vehic          decimal(16,2);
define _desc_edad           decimal(16,2);
define _desc_pr_tipov       decimal(16,2);

define _periodo			char(8);
define _por_vencer		dec(16,2);
define _exigible		dec(16,2);
define _corriente		dec(16,2);
define _monto_180		dec(16,2);
define _monto_150		dec(16,2);
define _monto_120		dec(16,2);
define _monto_90		dec(16,2);
define _monto_60		dec(16,2);
define _monto_30		dec(16,2);
define _saldo			dec(16,2);
define _saldo_mas_60	dec(16,2);	
define _fecha_aviso_canc	date;
define _carta_aviso_canc	smallint;
define _cnt_ren             smallint;

set debug file to "sp_pro283a.trc"; 

begin
on exception set _error, _error_isam, _error_desc
 	return _error, _error_desc;         
end exception

set isolation to dirty read;
--set lock mode to wait;

let _no_renovar = 0;
let _fecha_actual = current;
let _ano_actual   = year(_fecha_actual);
let _anos_pagador = 0;

update emipomae
   set renovada    = 1,
       fecha_renov = _fecha_actual
 where no_poliza   = v_poliza;

select * 
  from emipomae
 where no_poliza = v_poliza
  into temp prueba;
  
  -- CASO:ENILDA renovacion New no trae el check no_Poliza  anterior
select x.no_documento,x.carta_aviso_canc,x.fecha_aviso_canc	   
  Into _no_documento,_carta_aviso_canc,_fecha_aviso_canc
  from prueba x
 where x.no_poliza = v_poliza;
 
 if _no_documento = '0217-00197-09' then
	trace on;
 end if
 
if _carta_aviso_canc = 1 then
--trace on;
	let _periodo = sp_sis39(_fecha_actual);	   
	call sp_cob245a("001","001",_no_documento,_periodo,_fecha_actual)	 
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

	let _saldo_mas_60 = _monto_60 + _monto_90 + _monto_120 + _monto_150 + _monto_180;
   if _saldo_mas_60 > 0 then 
		update emipomae  
	   	   set carta_aviso_canc = 0,fecha_aviso_canc = null
		 where no_documento in (_no_documento) ;		  
	else
		let _carta_aviso_canc = 0;
		let _fecha_aviso_canc = null;		
   end if   
   --trace off;
end if


let _resultado = 0;
let _r_anos = 0;
let r_anos = 0;
let _anno = 0;
let _mes  = 0;

select anos_pagador,
	   vigencia_final,
	   cod_ramo
  Into r_anos,
	   _vigencia_final,
	   _cod_rammo
  from emiporen
 where no_poliza = v_poliza;
 
 let _no_recibo = null;
 
 select no_recibo,no_renovar
   into _no_recibo,_no_renovar
   from emirepol
  where no_poliza = v_poliza;

if _no_renovar = 1 AND _cod_rammo in('002','023')then
	return 1, 'No se puede renovar, poliza Con Cese de Coberturas';
end if

let li_mes = month(_vigencia_final);
let li_dia = day(_vigencia_final);
let li_ano = year(_vigencia_final);
let _prima_bruta = 0;

if li_mes = 2 then
	if li_dia > 28 then
		let li_dia = 28;
	    let _vigencia_final = mdy(li_mes, li_dia, li_ano);
	end if
end if

if _cod_rammo <> "019" then
	if r_anos > 0 then
	   let r_anos = r_anos - 1;
	else
	   let r_anos = 0;
	end if
else
	let r_anos = r_anos + 1;
end if

update prueba
   set no_poliza         = v_poliza_nuevo,
       serie             = year(vigencia_final),
       no_factura        = null,
       fecha_suscripcion = current,
       fecha_impresion   = current,
       fecha_cancelacion = null,
       impreso           = 0,
       nueva_renov       = "R",
       estatus_poliza    = 1,
       actualizado       = 0,
	   posteado          = '0',
       fecha_primer_pago = vigencia_final,
       date_changed      = current,
       date_added        = current,
       carta_aviso_canc  = _carta_aviso_canc,
       carta_prima_gan   = 0,
       carta_vencida_sal = 0,
       carta_recorderis  = 0,
       fecha_aviso_canc  = _fecha_aviso_canc,
       fecha_prima_gan   = null,
       fecha_vencida_sal = null,
       fecha_recorderis  = null,
       user_added        = v_usuario,
       ult_no_endoso     = 0,
       renovada          = 0,
       fecha_renov       = null,
       fecha_no_renov    = null,
       no_renovar        = 0,
       perd_total        = 0,
       anos_pagador      = r_anos,
       incobrable        = 0,
       fecha_ult_pago    = null,
       vigencia_inic     = vigencia_final,
       vigencia_final    = _vigencia_final + 1 units year,
       saldo             = 0,
	   cod_banco         = cod_banco,
	   no_cuenta         = no_cuenta,
	   tiene_gastos      = 0,
	   gastos			 = 0.00,
	   wf_aprob          = 0,
	   wf_firma_aprob    = null,
	   wf_incidente      = null,
	   wf_fecha_entro    = null,
	   wf_fecha_aprob	 = null,
	   no_recibo		 = null
 where no_poliza         = v_poliza;

foreach
	select vigencia_final,
	       cod_tipoprod,
		   vigencia_inic
	  into _vf,
	       _cod_tipoprod,
		   _vi
  	  from emireaut
	 where no_poliza = v_poliza
	exit foreach;
end foreach

let _saber_agt = 0;

{foreach
	select count(*)
	  into _saber_agt
	  from emipoagt
	 where no_poliza  = v_poliza
	   and cod_agente = '00035'

	exit foreach;
end foreach

if _cod_rammo = '020' and _saber_agt = 0 then --SODA

	select no_documento,vigencia_final
	  into _no_documento,_vig_fin
	  from emipomae
	 where no_poliza = v_poliza;

	let _mes = month(_vig_fin);
	let _anno = year(_vig_fin);

	if _mes > 9 and _anno > 2012 then
	else
		update prueba
		   set nueva_renov      = "N",
		       reemplaza_poliza = _no_documento,
			   no_documento     = null
		 where no_poliza = v_poliza_nuevo;

	end if

end if }	 --Se quita 20/09/2012 por instr. sr Carrero.

update emiporen
   set vigencia_final    = _vf,
	   fecha_primer_pago = _vi,
       cod_tipoprod      = _cod_tipoprod
where no_poliza = v_poliza;
	
		update prueba
		   set  (fecha_primer_pago,
				 cod_banco,
				 no_cuenta,
				 cod_formapag,
				 cod_perpago,
				 no_pagos,
				 dia_cobros1,
				 dia_cobros2,
				 tipo_tarjeta,
				 no_tarjeta,
				 fecha_exp,
				 cobra_poliza,
				 tipo_cuenta,
				 factor_vigencia,
				 saldo_por_unidad,
				 vigencia_final,
				 direc_cobros,
				 cod_tipoprod) =
		((select fecha_primer_pago,
				 cod_banco,
				 no_cuenta,
				 cod_formapag,
				 cod_perpago,
				 no_pagos,
				 dia_cobros1,
				 dia_cobros2,
				 tipo_tarjeta,
				 no_tarjeta,
				 fecha_exp,
				 cobra_poliza,
				 tipo_cuenta,
				 factor_vigencia,
				 saldo_por_unidad,
				 vigencia_final,
				 direc_cobros,
				 cod_tipoprod
			from emiporen
		   where no_poliza = v_poliza))
		 where no_poliza = v_poliza_nuevo;

insert into emipomae
select * from prueba
 where no_poliza = v_poliza_nuevo;

select fecha_primer_pago,
       no_pagos,
	   cod_formapag,
	   cod_perpago,
	   cod_ramo,
	   cod_subramo,
	   cod_origen,
	   no_documento
  into ld_fecha_1_pago,
       li_no_pagos,
	   _cod_formapag,
	   ls_cod_perpago,
	   _cod_ramo,
	   _cod_subramo,
	   _cod_origen,
       _no_documento
  from emipomae
 where no_poliza = v_poliza_nuevo;
 
if _no_recibo is not null then
	update emipomae
	   set no_recibo = _no_recibo
	 where no_poliza = v_poliza_nuevo;  
end if

select tipo_forma
  into _tipo_forma
  from cobforpa
 where cod_formapag = _cod_formapag;

{
if li_no_pagos = 1 then

	select meses
	  into li_meses
	  from cobperpa
	 where cod_perpago = ls_cod_perpago;

	let li_mes = month(ld_fecha_1_pago) + li_meses;
	let li_ano = year(ld_fecha_1_pago);
	let li_dia = day(ld_fecha_1_pago);

	if li_mes > 12 then
		let li_mes = li_mes - 12;
		let li_ano = li_ano + 1;
	end if

	if li_mes = 2 then
		if li_dia > 28 then
			let li_dia = 28;
		end if
	elif li_mes in (4, 6, 9, 11) then
		if li_dia > 30 then
			let li_dia = 30;
		end if
	end if

	let ld_fecha_1_pago = mdy(li_mes, li_dia, li_ano);

	update emipomae
	   set fecha_primer_pago = ld_fecha_1_pago
	 where no_poliza = v_poliza_nuevo;

end if
}
drop table prueba;

select * 
  from emiporec
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emiporec	--recargos
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emidirco
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emidirco	--dir de cobro.
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emiagtre
 where no_poliza = v_poliza
  into temp prueba;

select cod_ramo
  into _cod_rammo
  from emipomae
 where no_poliza = v_poliza;

select anos_pagador,
       cod_subramo
  into _r_anos,
       _cod_subramo
  from emipomae
 where no_poliza = v_poliza_nuevo;

foreach
	select cod_producto
	  into _cod_prod
	  from emipouni
	 where no_poliza = v_poliza

	exit foreach;
end foreach

let _porc_com = 0;

foreach
	select cod_agente,
	       porc_comis_agt
	  into _cod_agt,
		   _porc_com
	  from prueba

	select tipo_agente
	  into _tipo_agente
	  from agtagent
	 where cod_agente = _cod_agt;

	if _cod_rammo <> "019" then		
		if _porc_com = 0 then
			call sp_pro305(_cod_agt,_cod_rammo,_cod_subramo) returning _porc_com;
		end if
	else
		foreach
			select porc_comis_agt
			  into _porc_com
			  from prdcoprd
			 where cod_producto = _cod_prod
			   and _r_anos between ano_desde and ano_hasta
			exit foreach;
 	    end foreach
	end if

	if _porc_com is null then
		let _porc_com = 0;
	end if

	if _tipo_agente = 'O' then
		let _porc_com = 0;
	end if

	update prueba 
	   set porc_comis_agt = _porc_com
	 where cod_agente     = _cod_agt
	   and no_poliza      = v_poliza;
end foreach

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipoagt	--corredores
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emipolim
 where no_poliza = v_poliza
  into temp prueba;

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipolim	--impuestos
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

if _no_documento = "0210-01288-01" then --Minsa
	delete from emipolim 
	 where no_poliza = v_poliza_nuevo;
end if

select count(*)
  into _canti 
  from emipolim
 where no_poliza = v_poliza_nuevo;

if _canti = 0 then

	select aplica_impuesto
	  into _aplica_imp
	  from parorig
	 where cod_origen = _cod_origen;

	if _no_documento = "0210-01288-01" then
		let _aplica_imp = 0;
	end if

	if _aplica_imp = 1 then

		let _cnt = sp_sis186(_no_documento,_aplica_imp);

		if _cnt <> 0 then	--hay error
		else
			foreach
				select cod_impuesto
				  into _cod_impuesto
				  from prdimsub
				 where cod_ramo    = _cod_ramo
				   and cod_subramo = _cod_subramo

				insert into emipolim (no_poliza, cod_impuesto, monto)
				values (v_poliza_nuevo,_cod_impuesto, 0.00);
			end foreach
	    end if
	end if
end if

select *
  from emicomar
 where no_poliza = v_poliza
  into temp prueba;

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emicoama	--coaseguro may
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select *
  from emicomir
 where no_poliza = v_poliza
  into temp prueba;

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emicoami	----coaseguro min
select *
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emiciare
 where no_poliza = v_poliza
  into temp prueba;

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiciara	--
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emipolde
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emipolde	--descuentos
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emipouni
 where no_poliza = v_poliza
  into temp prueba;

select * from emipouni
 where no_poliza = v_poliza
   and perd_total = 1
  into temp prueba2;

	foreach
		select no_unidad,
			   cod_producto,
			   cod_asegurado,
			   vigencia_inic,
			   vigencia_final,
			   cod_formapag,
			   cod_perpago,
			   no_pagos,
			   fecha_primer_pago,
			   tipo_tarjeta,
			   no_tarjeta,
			   fecha_exp,
			   cod_banco,
			   cobra_poliza,
			   no_cuenta,
			   tipo_cuenta,
			   cod_pagador,
			   dia_cobros1,
			   dia_cobros2,
			   anos_pagador,
			   monto_visa,
			   cod_manzana
		  into _no_uni,
			   _cod_producto,
			   _cod_asegurado,
			   _v_i,
			   _v_f,
			   _cod_formapag,
			   _cod_perpago,
			   _no_pagos,
			   _fecha_primer_pago,
			   _tipo_tarjeta,
			   _no_tarjeta,
			   _fecha_exp,
			   _cod_banco,
			   _cobra_poliza,
			   _no_cuenta,
			   _tipo_cuenta,
			   _cod_pagador,
			   _dia_cobros1,
			   _dia_cobros2,
			   _anos_pagador,
			   _monto_visa,
			   _cod_manzana
		  from emireaut
		 where no_poliza = v_poliza

		select count(*)
		  into _saber
		  from emipouni
		 where no_poliza = v_poliza
		   and no_unidad = _no_uni;

		if _saber = 0 then	--es unidad nueva
			foreach
				select cod_ruta
				  into _cod_ruta
				  from emirerea
				 where no_poliza = v_poliza

				exit foreach;
			end foreach

			insert into prueba(
				no_poliza,
				no_unidad,
				cod_ruta,
				cod_producto,
				cod_asegurado,
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
				activo,
				prima_asegurado,
				prima_total,
				no_activo_desde,
				facturado,
				user_no_activo,
				perd_total,
				impreso,
				fecha_emision,
				prima_suscrita,
				prima_retenida,
				suma_aseg_adic,
				tipo_incendio,
				gastos,
				cod_formapag,
				cod_perpago,
				no_pagos,
				fecha_primer_pago,
				tipo_tarjeta,
				no_tarjeta,
				fecha_exp,
				cod_banco,
				cobra_poliza,
				no_cuenta,
				tipo_cuenta,
				cod_pagador,
				dia_cobros1,
				dia_cobros2,
				anos_pagador,
				monto_visa,
				cod_manzana,
				subir_bo)
			values(	v_poliza,
					_no_uni,
					_cod_ruta,
					_cod_producto,
					_cod_asegurado,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					_v_i,
					_v_f,
					0.00,
					null,
					1,
					0,
					0,
					null,
					1,
					null,
					0,
					1,
					CURRENT,
					0,
					0,
					0,
					null,
					0.00,
					_cod_formapag,
					_cod_perpago,
					_no_pagos,
					_fecha_primer_pago,
					_tipo_tarjeta,
					_no_tarjeta,
					_fecha_exp,
					_cod_banco,
					_cobra_poliza,
					_no_cuenta,
					_tipo_cuenta,
					_cod_pagador,
					_dia_cobros1,
					_dia_cobros2,
					_anos_pagador,
					_monto_visa,
					_cod_manzana,
					0);
		end if

		update prueba 
		   set no_poliza = v_poliza_nuevo,
			   cod_manzana = _cod_manzana
		 where no_poliza = v_poliza
		   and no_unidad = _no_uni
		   and perd_total = 0;
	end foreach
	
foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

select count(*)
  into _cnt
  from prueba;

if _cnt = 0 then
	return 1, 'No se puede renovar, pÃ³liza marcada como pÃ©rdida total.';
end if

insert into emipouni	--unidades
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

update emipouni
   set impuesto = 0
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * from emiredes	--descripcion
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;
end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipode2
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emireacr
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;
end foreach

delete from prueba
 where no_unidad not in (select no_unidad from emireaut
						  where no_poliza = v_poliza);

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipoacr	--acreedores
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select e.* 
  from emiunire e, emireaut i
 where e.no_poliza = i.no_poliza
   and e.no_unidad = i.no_unidad
   and e.no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;

end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiunire	--recargos
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

if _cod_ramo = '008' then
	select * 
	  from emifian1
	 where no_poliza = v_poliza
	  into temp prueba;

	foreach
		select no_unidad
		  into _nounidad
		  from prueba2
		 where perd_total = 1

		delete from prueba
		 where no_unidad = _nounidad;
	end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emifian1		
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;
end if

select * 
  from emifigar
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;
end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);	}

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emifigar
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;


select * from emiauto
 where no_poliza = v_poliza
   and no_unidad = (select no_unidad 
					  from emipouni 
					 where no_poliza = v_poliza_nuevo
					   and emiauto.no_unidad = emipouni.no_unidad)
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;
end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba2.perd_total = 1);	 }

insert into prueba
select * 
  from emiautor
 where no_poliza = v_poliza;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emiauto
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

update emiauto
   set ano_tarifa = ano_tarifa + 1
 where no_poliza  = v_poliza_nuevo;

update emiauto
   set ano_tarifa = 1
 where no_poliza  = v_poliza_nuevo
   and ano_tarifa = 0;

drop table prueba;

select *
  from emirecum
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;
end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emicupol	--cumulos de incendio
select *
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emireglo
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emigloco	--reaseguro global
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select * 
  from emirerea
 where no_poliza = v_poliza
  into temp prueba;

update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emifacon	--reaseguro individual
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select *                    -- QUITAR COMENTARIO CUANDO CREAN LOS CAMPOS EN EMIFAFAC
  from emirefac
 where no_poliza = v_poliza
  into temp prueba;

{select no_poliza,        -- PONER EN COMENTARIO CUANDO CREAN LOS CAMPOS EN EMIFAFAC
	   no_endoso,
       no_unidad,
       cod_cober_reas,
       orden,
       cod_contrato,
       cod_coasegur,
       porc_partic_reas,
       porc_comis_fac,
       porc_impuesto,
       suma_asegurada,
       prima,
	   impreso,
	   fecha_impresion,
	   no_cesion, 
	   subir_bo,
	   monto_comision,
	   monto_impuesto
  from emirefac
 where no_poliza = v_poliza
  into temp prueba;
}  
update prueba 
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emifafac	--facultativo
select * 
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

select *
  from emirenco		--coberturas(opcion Final)
 where no_poliza = v_poliza
  into temp prueba;

foreach
	select no_unidad
	  into _nounidad
	  from prueba2
	 where perd_total = 1

	delete from prueba
	 where no_unidad = _nounidad;
end foreach

{delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);}

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emipocob
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

foreach
	select no_unidad,
	       cod_cobertura
	  into _no_unidad,
	       _cod_cobertura
	  from emipocob
	 where no_poliza = v_poliza_nuevo
	 
	let _desc_comb = 0.00;
	let _desc_modelo = 0.00;
	let _desc_sini = 0.00;
	let _desc_vehic = 0.00;
	let _desc_edad = 0.00;
	let _desc_pr_tipov = 0.00;
	 
	select desc_comb,
	       desc_modelo,
		   desc_sini,
		   desc_vehic,
		   desc_edad,
		   desc_pr_tipov
	  into _desc_comb,
	       _desc_modelo,
		   _desc_sini,
		   _desc_vehic,
		   _desc_edad,
		   _desc_pr_tipov
	  from emireau1
	 where no_poliza = v_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura = _cod_cobertura;
	
    if 	_desc_comb > 0 then -- Descuento combinado
		let _retorno = sp_proe79(v_poliza_nuevo, _no_unidad, _cod_cobertura, '004', _desc_comb);		
	end if   
    if 	_desc_modelo > 0 then -- Descuento por modelo
		let _retorno = sp_proe79(v_poliza_nuevo, _no_unidad, _cod_cobertura, '005', _desc_modelo);			
	end if   
    if 	_desc_sini > 0 then -- Descuento combinado
		let _retorno = sp_proe79(v_poliza_nuevo, _no_unidad, _cod_cobertura, '006', _desc_sini);			
	end if   
    if 	_desc_vehic > 0 then -- Descuento combinado
		let _retorno = sp_proe79(v_poliza_nuevo, _no_unidad, _cod_cobertura, '007', _desc_vehic);			
	end if   
    if 	_desc_edad > 0 then -- Descuento edad
		let _retorno = sp_proe79(v_poliza_nuevo, _no_unidad, _cod_cobertura, '008', _desc_edad);			
	end if   
    if 	_desc_pr_tipov > 0 then -- Descuento tipo de vehiculo por producto
		let _retorno = sp_proe79(v_poliza_nuevo, _no_unidad, _cod_cobertura, '009', _desc_pr_tipov);			
	end if   
end foreach


{select * from emicobde
 where no_poliza = v_poliza
  into temp prueba;

delete from prueba
 where no_unidad = (select no_unidad from prueba2
   			         where prueba.no_unidad = prueba2.no_unidad
  					   and prueba2.perd_total = 1);

update prueba set no_poliza = v_poliza_nuevo
 where no_poliza   = v_poliza;

insert into emicobde
select * from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;}

select * 
  from emibenef
 where no_poliza = v_poliza
  into temp prueba;

update prueba
   set no_poliza = v_poliza_nuevo
 where no_poliza = v_poliza;

insert into emibenef
select *
  from prueba
 where no_poliza = v_poliza_nuevo;

drop table prueba;

let _suma_acum = 0;

foreach
	select no_unidad,
		   suma_aseg,
		   opcion_final,
		   cod_producto,
		   cod_product1,
		   cod_product2
	  into _no_unidad,
		   _suma_asegurada,
		   _opc_fin,
		   _cod_producto,
		   _cod_product1,
		   _cod_product2
	  from emireaut
	 where no_poliza = v_poliza

	let _cod_pro = _cod_producto;

    if _opc_fin = 1 then
		if _cod_product1 is not null then
			let _cod_pro = _cod_product1;
		end if
	elif _opc_fin = 2 then 
		if _cod_product2 is not null then
			let _cod_pro = _cod_product2;
		end if
	end if

	-- Definir el codigo de tarifa para las unidades
	let _desc_comb = 0.00;
	let _desc_modelo = 0.00;
	let _desc_sini = 0.00;
	let _desc_vehic = 0.00;
	let _desc_edad = 0.00;
	let _cod_tipo_tar = '001'; -- Tarifa normales

	select sum(porc_descuento)
	  into _desc_vehic
	  from emicobde
	 where no_poliza = v_poliza_nuevo
	   and no_unidad = _no_unidad
	   and cod_descuen = '004';
	   
	if _desc_vehic > 0.00 then
		let _cod_tipo_tar = '008'; -- Tarifa autos Vehiculos Clasificados 2017
	else	
		SELECT cod_tipo_tar
		  INTO _cod_tipo_tar
		  FROM emipouni
		 WHERE no_poliza = v_poliza
		   AND no_unidad = _no_unidad;
		 
		let _tipo_auto = sp_proe75(v_poliza, _no_unidad);
		
		call sp_pro550(_no_documento) returning _no_documento, _no_sinis_ult, _no_sinis_his, _no_vigencias, _no_sinis_pro, _incurrido_bruto, _prima_devengada, _siniestralidad,	_descuento_sini, _condicion;
		if _tipo_auto = 1 and _cod_tipo_tar in ('001','006') and _no_sinis_ult = 0 then	--'002'
			let _cod_tipo_tar = '006'; -- 
		else	
			let _cod_tipo_tar = '001'; -- Tarifa normales
		
			select sum(porc_descuento)
			  into _desc_comb
			  from emicobde
			 where no_poliza = v_poliza_nuevo
			   and no_unidad = _no_unidad
			   and cod_descuen = '004';
			   
			if _desc_comb > 0.00 then
				let _cod_tipo_tar = '002'; -- Tarifa autos julio 2014
			end if

			select sum(porc_descuento)
			  into _desc_modelo
			  from emicobde
			 where no_poliza = v_poliza_nuevo
			   and no_unidad = _no_unidad
			   and cod_descuen = '005';

			if _desc_modelo > 0.00 then
				let _cod_tipo_tar = '004'; -- Tarifa por modelo
			end if
			   
			select sum(porc_descuento)
			  into _desc_sini
			  from emicobde
			 where no_poliza = v_poliza_nuevo
			   and no_unidad = _no_unidad
			   and cod_descuen = '006';

			if _desc_sini > 0.00 then
				let _cod_tipo_tar = '005'; -- Tarifa por siniestralidad
			end if
		end if
	end if
	
	update emipouni
	   set cod_tipo_tar	= _cod_tipo_tar
	 where no_poliza = v_poliza_nuevo
	   and no_unidad = _no_unidad;
	
	   
{    let _tipo_auto = sp_proe75(v_poliza_nuevo, _no_unidad);

	if _tipo_auto in (1,2,3) then
		select count(*)
		  into _cnt
		  from prdcobpd p, emipocob e
		 where p.cod_cobertura = e.cod_cobertura
		   and p.cod_producto  = _cod_pro
		   and p.tipo_descuento in (1,2)
		   and e.no_poliza = v_poliza_nuevo
		   and e.no_unidad = _no_unidad;

		if _cnt > 0 then
			SELECT COUNT(*)
			  INTO _cant_p
			  FROM recrcmae
			 WHERE no_poliza = v_poliza
			   AND estatus_audiencia in (0,8)
			   AND cod_evento  in ('016','002','003','004','006','007','011','050','059','138')	      --> esperar la lista de los eventos que debemos contar
			   AND actualizado = 1;

			if (_tipo_auto = 1 and _cant_p = 1) or (_tipo_auto in (2,3) and _cant_p = 0) then 
			    update emipouni
			       set cod_tipo_tar	= '002'
				 where no_poliza = v_poliza_nuevo
				   and no_unidad = _no_unidad;
			end if
			IF _cant_p > 1 THEN --Con mas de un reclamo perdido
				update emipouni
				   set cod_tipo_tar	= '003'
				 where no_poliza = v_poliza_nuevo
				   and no_unidad = _no_unidad;
			END IF
			
		end if    
	end if
}
	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = v_poliza_nuevo;

	if _cod_ramo = "002" or _cod_ramo = "020" or _cod_ramo = "023" then
		let _suma_entera    = _suma_asegurada;
		let _suma_asegurada = _suma_entera;
	end if

	call sp_proe02(v_poliza_nuevo, _no_unidad, "001") returning _error;

	let ld_impuesto = 0.00;

	foreach
		select emipolim.cod_impuesto,
			   (prdimpue.factor_impuesto * sum(emipouni.prima_neta)/100)
		  into ls_impuesto,
			   ld_impuesto1
		  from emipolim, prdimpue, emipouni
		 where emipolim.no_poliza    = v_poliza_nuevo
		   and emipouni.no_poliza    = emipolim.no_poliza
		   and emipouni.no_unidad    = _no_unidad
		   and prdimpue.cod_impuesto = emipolim.cod_impuesto
		 group by emipolim.cod_impuesto, prdimpue.factor_impuesto

		let ld_impuesto = ld_impuesto + ld_impuesto1;

		update emipolim
		   set monto = monto + ld_impuesto1
		 where no_poliza    = v_poliza_nuevo
		   and cod_impuesto = ls_impuesto;
		
		let ld_impuesto1 = 0.00;
	end foreach

	select no_motor
	  into _no_motor
	  from emiauto
	 where no_poliza = v_poliza
	   and no_unidad = _no_unidad;

	select sum(prima_neta)
	  into ld_prima_neta
	  from emipocob
	 where no_poliza = v_poliza_nuevo
	   and no_unidad = _no_unidad;
	   
	if _cod_ramo = '024' then

		select cod_ramo
  		  into _cod_ramo_uni 
		  from emipouni
		 where no_poliza = v_poliza_nuevo
           and no_unidad = _no_unidad;
		   
		if _cod_ramo_uni = '020' then
			select (1 * sum(emipouni.prima_neta)/100)
		      into ld_impuesto1
		      from emipolim, prdimpue, emipouni
		     where emipolim.no_poliza    = v_poliza_nuevo
		       and emipouni.no_poliza    = emipolim.no_poliza
		       and emipouni.no_unidad    = _no_unidad
		       and prdimpue.cod_impuesto = emipolim.cod_impuesto
		     group by emipolim.cod_impuesto, prdimpue.factor_impuesto;
			let ld_impuesto = ld_impuesto + ld_impuesto1;
		end if
	end if

	let ld_prima_bruta = ld_prima_neta + ld_impuesto;

	update emipouni
	   set suma_asegurada = _suma_asegurada,
		   prima_neta 	  = ld_prima_neta,
		   impuesto 	  = ld_impuesto,
		   prima_bruta    = ld_prima_bruta
	 where no_poliza      = v_poliza_nuevo
	   and no_unidad      = _no_unidad;

	select ano_auto
	  into _ano_auto
	  from emivehic
	 where no_motor   = _no_motor;

	let _resultado = _ano_actual - _ano_auto;

	{if _resultado <= 0 then
		let _nuevo = 1;
	else
		let _nuevo = 0;
	end if}

	update emivehic
	   set valor_auto = _suma_asegurada
	 where no_motor   = _no_motor;

	let _suma_acum = _suma_acum + _suma_asegurada;

	if _opc_fin = 0 then
		update emipouni
		   set cod_producto = _cod_producto
		 where no_poliza    = v_poliza_nuevo
		   and no_unidad    = _no_unidad;

		select * from emirede0	--descuento. unidad
		 where no_poliza = v_poliza
		   and no_unidad = _no_unidad
		  into temp prueba;

		foreach
			select no_unidad
			  into _nounidad
			  from prueba2
			 where perd_total = 1

			delete from prueba
			 where no_unidad = _nounidad;
		end foreach

	   {delete from prueba
		 where no_unidad = (select no_unidad from prueba2
							 where prueba.no_unidad = prueba2.no_unidad
							   and prueba2.perd_total = 1);}

		update prueba
		   set no_poliza = v_poliza_nuevo
		 where no_poliza   = v_poliza;

		insert into emiunide
		select * from prueba
		 where no_poliza = v_poliza_nuevo;

		drop table prueba;

	elif _opc_fin = 1 then

		if _cod_product1 is null then
			update emipouni
			   set cod_producto = _cod_producto
			 where no_poliza    = v_poliza_nuevo
			   and no_unidad    = _no_unidad;
		else
			update emipouni
			   set cod_producto = _cod_product1
			 where no_poliza    = v_poliza_nuevo
			   and no_unidad    = _no_unidad;
		end if

		select * from emirede1	--descuentos. opcion1
		 where no_poliza = v_poliza
		   and no_unidad = _no_unidad
		  into temp prueba;

		foreach
			select no_unidad
			  into _nounidad
			  from prueba2
			 where perd_total = 1

			delete from prueba
			 where no_unidad = _nounidad;
		end foreach

	  {	delete from prueba
		 where no_unidad = (select no_unidad from prueba2
							 where prueba.no_unidad = prueba2.no_unidad
							   and prueba2.perd_total = 1);			   }

		update prueba 
		   set no_poliza = v_poliza_nuevo
		 where no_poliza   = v_poliza;

		insert into emiunide
		select * from prueba
		 where no_poliza = v_poliza_nuevo;

		drop table prueba;
	elif _opc_fin = 2 then

		if _cod_product2 is null then
			update emipouni
			   set cod_producto = _cod_producto
			 where no_poliza    = v_poliza_nuevo
			   and no_unidad    = _no_unidad;
		else
			update emipouni
			   set cod_producto = _cod_product2
			 where no_poliza    = v_poliza_nuevo
			   and no_unidad    = _no_unidad;
		end if
		
		select * from emirede2	--descr. unidad
		 where no_poliza = v_poliza
		   and no_unidad = _no_unidad
		  into temp prueba;

		foreach
			select no_unidad
			  into _nounidad
			  from prueba2
			 where perd_total = 1

			delete from prueba
			 where no_unidad = _nounidad;
		end foreach

	  {	delete from prueba
		 where no_unidad = (select no_unidad from prueba2
							 where prueba.no_unidad = prueba2.no_unidad
							   and prueba2.perd_total = 1);}

		update prueba
		   set no_poliza = v_poliza_nuevo
		 where no_poliza   = v_poliza;

		insert into emiunide
		select * from prueba
		 where no_poliza = v_poliza_nuevo;

		drop table prueba;
	end if

	foreach
		select cod_descuen,
			   porc_descuento
		  into _cod_descuento,
			   _porc_descuento
		  from emiunide
		 where no_poliza = v_poliza_nuevo
		   and no_unidad = _no_unidad

		select uso_auto
		  into _uso
		  from emiauto
		 where no_poliza = v_poliza_nuevo
		   and no_unidad = _no_unidad;

		
		if _cod_descuento = '001' and _uso <> 'C' then			
			call sp_sis194(v_poliza_nuevo,_no_unidad,_porc_descuento) returning _error,_error_desc,_porc_descuento;
			
			if _error <> 0 then
				return _error,_error_desc;
			end if
		end if
	end foreach
end foreach

drop table prueba2;

--

call sp_proe03(v_poliza_nuevo, "001") returning _error;

if _tipo_forma = 2 or  _tipo_forma = 4 then -- tarjetas de credito/ach
	select prima_bruta 
	  into _prima_bruta 
	  from emipomae
	 where no_poliza = v_poliza_nuevo;
	 
	let _monto_visa = _prima_bruta / _no_pagos;

	update emipomae
	   set monto_visa = _monto_visa
	 where no_poliza  = v_poliza_nuevo;
end if

update emipomae
   set suma_asegurada = _suma_acum
 where no_poliza      = v_poliza_nuevo;

return 0, 'ActualizaciÃ³n Exitosa';
end
end procedure;