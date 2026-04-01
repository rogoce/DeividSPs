-- Procedimiento que Realiza la Renovacion de la Poliza desde programa de opciones de renovacion
-- Es una copia del procedure sp_pro281.

-- Creado    : 07/01/2005 - Autor: Armando Moreno M.
-- mod		 : 03/04/2007 - poner suma aseg decimal y entera cuando es ramo auto.

drop procedure sp_pro283abk;

create procedure "informix".sp_pro283abk(
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
trace on;

begin
on exception set _error, _error_isam, _error_desc
 	return _error, _error_desc;         
end exception

set isolation to dirty read;
--set lock mode to wait;

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
 
 {if _no_documento = '0218-20112-83' then
	trace on;
 end if	}
 
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
 
 select no_recibo
   into _no_recibo
   from emirepol
  where no_poliza = v_poliza; 

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

end
end procedure
