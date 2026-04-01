--drop procedure sp_ag_itz;

create procedure "informix".sp_ag_itz()
returning integer,
          char(100);

define _compania			char(3);
define _sucursal			char(3);
define _fecha_moros			date;
define _periodo_moros		char(7);

define _cod_usuario			char(10);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_contratante		char(10);
define _flag				smallint;
define _cod_agente1			char(5);

define _cod_ramo			char(3);
define _cod_subramo			char(3);
define _nombre_ramo			char(50);
define _nombre_subramo		char(50);
define _vigencia_inic		date;
define _vigencia_final		date;
define _cod_formapag		char(3);
define _nombre_formapag		char(50);
define _cod_agente			char(5);
define _nombre_agente		char(50);
define _fecha_cancelacion	date;
define _prima_bruta			dec(16,2);
define _dia_cobros1			smallint;
define _no_pagos			smallint;
define _nombre_asegurado	char(100);
define _carta_aviso_canc	smallint;
define _fecha_aviso_canc	date;
define _renov_desc			char(20);
define _nueva_renov			char(1);

define _cod_frec_pago		char(3);
define _frec_pago_desc		char(50);

define _estatus_poliza		smallint;
define _estatus_desc		char(10);

define _moro_saldo			dec(16,2);
define _moro_por_vencer		dec(16,2);
define _moro_exigible		dec(16,2);
define _moro_corriente		dec(16,2);
define _moro_30				dec(16,2);
define _moro_60				dec(16,2);
define _moro_90				dec(16,2);

define _no_recibo			char(10);
define _fecha_rec			date;
define _prima_neta			dec(16,2);
define _impuesto			dec(16,2);
define _monto				dec(16,2);
define _transaccion			char(10);
define v_referencia			char(20);
define _no_remesa			char(10);
define _tipo_remesa			char(1);
define _monto_descontado	dec(16,2);
define _cod_cliente			char(10);
define _nombre_cliente		char(100);
define _direccion			char(50);
define _telefono1			char(10);
define _telefono2			char(10);
define _direccion_cob		char(100);
define _email				char(50);
define _apartado			char(20);


define _no_unidad			char(5);
define _orden				smallint;
define _cod_cobertura		char(5);
define _cobertura			char(50);
define _limite1				dec(16,2);
define _limite2				dec(16,2);
define _deducible			char(50);
define _deduc_acum			dec(16,2);
define _cod_ajust_interno	char(3);

define _suma_asegurada		dec(16,2);
define _prima_uni			dec(16,2);
define _desc_uni			dec(16,2);
define _recargo				dec(16,2);
define _prima_neta_uni		dec(16,2);
define _impuesto_uni		dec(16,2);
define _prima_bruta_uni		dec(16,2);

define _no_reclamo			char(10);
define _numreclamo			char(18);
define _estatus_reclamo		char(1);
define _estatus				char(10);
define _fecha_siniestro		date;
define _ajust_interno		char(3);
define _nombre_ajust		char(50);
define _no_tranrec			char(10);


define _fecha_nota			date;
define _desc_nota			char(250);
define _user_added			char(8);


define _cod_tipo_pago		char(3);
define _nom_tip_pago		char(50);
define _no_requis			char(10);
define _fecha_impresion		date;
define _beneficiario		char(100);
define _monto_cheque		dec(16,2);
define _no_cheque			integer;

define _cod_endomov			char(3);
define _tipo_endomov		char(50);
define _no_factura			char(10);
define _no_endoso			char(5);
define _periodo				char(7);
define _fecha_emision		date;

define _fecha_comis			date;
define _monto_comis			dec(16,2);
define _prima_comis			dec(16,2);
define _porc_partic			dec(5,2);
define _porc_comis			dec(5,2);
define _comisiones			dec(16,2);
define _nombre_aseg			char(50);
define _no_documento1		char(20);
define _tipo_requis			char(7);
define _tipo_requis_desc	char(7);

define _cod_parentesco		char(3);
define _cod_cliente1		char(10);
define _nom_cliente1		char(50);
define _nom_parentesco		char(50);

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _cantidad			integer;

begin
on exception set _error, _error_isam, _error_desc
	return _error, trim(_error_desc)||" poliza: "||_no_documento||" no_poliza "||_no_poliza;
end exception

set isolation to dirty read;

--SET DEBUG FILE TO "sp_web01.trc";
--TRACE ON ;

let _compania      = "001";
let _sucursal      = "001";
let _fecha_moros   = today;
let _periodo_moros = sp_sis39(_fecha_moros);
let _deduc_acum	   = 0.00;

-- Eliminar Registros de Tablas Temporales

delete from deivid_web:web_agente;

foreach
	select cod_usuario
	  into _cod_usuario
	  from	web_usuario
	 where	tipo_usuario  = 2
	   and status_usuario = 1
  group by cod_usuario

	let _cod_agente = _cod_usuario;

	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_usuario;

{
   	select count(*)
	  into _cantidad
	  from deivid_web:web_agente
	 where cod_agente = _cod_usuario;

	if _cantidad = 0 then 	   }

		insert into deivid_web:web_agente(
		cod_agente,
		nombre
		)
		values(
		_cod_usuario,
		_nombre_agente
		);
end foreach

end

return 0, "Actualizacion Exitosa";

end procedure

