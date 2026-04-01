-- Creacion de Remesa de Comision de Descontada cuando la poliza esta en Pago adelantado de comision y fue cancelada
-- 
-- Creado     : 11/10/2012 - Autor: Roman Gordon

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob310a;

create procedure "informix".sp_cob310a()
returning smallint,
          char(100);

define _descripcion			char(100);
define _error_desc			char(100);
define _nom_agente			char(50);
define _nom_cuenta			char(50);
define _recibi_de			char(50);
define _cuenta				char(25);													 
define _no_documento		char(20);
define _no_factura			char(10);
define _no_remesa			char(10);													 
define _no_recibo			char(10);										 
define a_no_poliza			char(10);
define _user				char(8);
define _periodo				char(7);
define _cod_auxiliar		char(5);
define _cod_agente			char(5);
define _cod_sucursal		char(3);
define _cod_compania		char(3);
define _caja_caja			char(3);
define _caja_comp			char(3);
define _cta_aux				char(1);
define _null				char(1);
define _comision_cancelada	dec(16,2);
define _comision_adelanto	dec(16,2);
define _monto_descontado	dec(16,2);
define _comision_ganada		dec(16,2);
define _comision_saldo		dec(16,2);
define _prima_suscrita		dec(16,2);
define _monto_recibo		dec(16,2);
define _prima_neta			dec(16,2);
define _impuesto			dec(16,2);
define _factor				dec(16,2);
define _prima				dec(16,2);			
define _porc_partic_agt		dec(5,2);			
define _porc_comis_agt		dec(5,2);			
define _poliza_cancelada	smallint;
define _adelanto_comis		smallint;			
define _pago_comis_ade		smallint;			
define _adelante_comis		smallint;			
define _status_poliza		smallint;			
define _cnt_existe			smallint;
define _no_pagos			smallint;
define _renglon				smallint;
define _aplica				smallint;
define _cant				smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_proceso		date;
define _fecha				date;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

set isolation to dirty read;

let _cod_compania		= '001';
let _cod_sucursal		= '001';
let _no_documento		= '';
let _cod_agente			= '';
let _recibi_de			= '';
let _no_recibo			= '';
let _comision_cancelada	= 0.00;
let	_comision_adelanto	= 0.00;
let _monto_descontado	= 0.00;
let	_porc_partic_agt	= 0.00;
let	_comision_ganada	= 0.00;
let	_comision_saldo		= 0.00;
let	_prima_suscrita		= 0.00;
let	_porc_comis_agt		= 0.00;
let	_monto_recibo		= 0.00;
let	_prima_neta			= 0.00;
let _impuesto			= 0.00;
let _poliza_cancelada	= 0;
let _pago_comis_ade		= 0;
let	_adelanto_comis		= 0;
let	_status_poliza		= 0;
let	_cnt_existe			= 0;
let	_no_pagos			= 0;
let _renglon			= 0;
let	_aplica				= 0;
let _fecha				= '30/09/2014'; --current;
let _null				= null;

--set debug file to "sp_cob310a.trc";
--trace on;

{select user_added,
	   no_factura	
  into _user,
	   _no_factura	
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = a_no_poliza;

select count(*)
  into _cnt_existe
  from cobadeco
 where no_documento = _no_documento;

if _cnt_existe = 0 or _cnt_existe is null then
	return 0,'No forma parte del Pago Adelantado de Comisiones.';
end if}

let _no_remesa   = sp_sis13("001", 'COB', '02', 'par_no_remesa');
let _user = 'informix';

select count(*)
  into _cant
  from cobremae
 where no_remesa = _no_remesa;

if _cant <> 0 then
	return 1, 'el numero de remesa generado ya existe, por favor actualize nuevamente ...';
end if	

call sp_cob224() returning _caja_caja, _caja_comp;

if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if

{select sum(comision_saldo)
  into _monto_recibo
  from cobadeco
 where no_documento = _no_documento;

let _monto_recibo = _monto_recibo * -1;}

insert into cobremae(
no_remesa,   
cod_compania,   
cod_sucursal,   
cod_banco,   
cod_cobrador,   
recibi_de,   
tipo_remesa,   
fecha,   
comis_desc,   
contar_recibos,   
monto_chequeo,   
actualizado,   
periodo,   
user_added,   
date_added,   
user_posteo,   
date_posteo,
cod_chequera
)
values(
_no_remesa,			--no_remesa,   
_cod_compania,		--cod_compania,  
_cod_sucursal,		--cod_sucursal,  
_caja_caja,			--cod_banco,   
_null,				--cod_cobrador,  
_recibi_de,			--recibi_de,   
'C',				--tipo_remesa,   
_fecha,				--fecha,   
0,					--comis_desc,   
2,					--contar_recibos,
0,		--monto_chequeo, 
0,					--actualizado,   
_periodo,			--periodo,   
_user,				--user_added,   
_fecha,				--date_added,   
_user,				--user_posteo,   
_fecha,				--date_posteo,
_caja_comp			--cod_chequera
);

let _cod_agente = '00226';

select nombre
  into _nom_agente
  from agtagent
 where cod_agente = _cod_agente;

let _recibi_de = _nom_agente;

foreach
	select no_documento,
		   no_recibo,
		   comis_pagada
	  into _no_documento,
		   _no_factura,
		   _comision_saldo
	  from tmp_det
	 where tipo_mov = 'P' --no_documento = _no_documento	
	
	select no_poliza 
	  into a_no_poliza
	  from endedmae
	 where no_factura = _no_factura;
	
	let _renglon		= _renglon + 1;
	let _comision_saldo	= _comision_saldo * -1;
	let _descripcion	= 'Devolucion de Comision Descontada por Cancelación de Póliza. Pago adelantado de Comisión.';

	insert into cobredet(
		    no_remesa,
		    renglon,
		    cod_compania,
		    cod_sucursal,
		    no_recibo,
		    doc_remesa,
		    tipo_mov,
		    monto,
		    prima_neta,
		    impuesto,
		    monto_descontado,
		    comis_desc,
		    desc_remesa,
		    saldo,
		    periodo,
		    fecha,
		    actualizado,
			no_poliza,
			cod_agente
			)
	values	(
			_no_remesa,			--_no_remesa,
			_renglon,			--_renglon,
			_cod_compania,		--_cod_compania,
			_cod_sucursal,		--_cod_sucursal,
			_no_factura,		--_no_recqibo_ancon,
			_no_documento,		--_no_documento,
			'C',					--_tipo_mov,
			_comision_saldo,	--_monto,
			0,					--_prima,
			0,					--_impuesto,
			0,					--_monto_descontado,
			0,					--_comis_desc,
			_descripcion,		--_descripcion,
			0,					--_saldo,
			_periodo,			--_periodo,
			_fecha,				--_fecha,
			0,					--0,
			a_no_poliza,		--_no_poliza
			_cod_agente
			);

	-- Afectacion de la catalago a la cuenta de adelanto de comision
	let _cuenta			= sp_sis15('CPCADECOM', '01', a_no_poliza);
	let _renglon		= _renglon + 1;

	select cta_nombre,
		   cta_auxiliar	
	  into _nom_cuenta,
		   _cta_aux	
	  from cglcuentas
	 where cta_cuenta = _cuenta;										   

	let _cod_auxiliar = null;												 	   

	if _cta_aux = 'S' then											 	   
		let _cod_auxiliar = "A" || _cod_agente[2,5]; -- En SAC no alcanza para poner los 5 digitos
	end if

	let _descripcion	= 'AFECTACION DE CATALOGO:' || trim(_nom_cuenta);
	
	if _comision_saldo >= 0.00 then
		let _monto_descontado = 0.00;
	else
		let _monto_descontado = _comision_saldo;
	end if
	
	insert into cobredet(
			no_remesa,
			renglon,
			cod_compania,
			cod_sucursal,
			no_recibo,
			doc_remesa,
			tipo_mov,
			monto,
			prima_neta,
			impuesto,
			monto_descontado,
			comis_desc,
			desc_remesa,
			saldo,
			periodo,
			fecha,
			actualizado,
			no_poliza,
			cod_agente,
			cod_auxiliar)
	values	(_no_remesa,
			_renglon,
			_cod_compania,
			_cod_sucursal,
			_no_factura,
			_cuenta,
			'M',
			abs(_comision_saldo),
			0,
			0,
			0,
			0,
			_descripcion,
			0,
			_periodo,
			_fecha,
			0,
			a_no_poliza,
			_cod_agente,
			_cod_auxiliar);

	{Insert into cobadecoh
			(no_documento,
			cod_agente,
			no_recibo,
			fecha,
			monto_recibo,
			prima_suscrita,
			prima_neta,
			comision_adelanto,
			comision_ganada,
			comision_saldo,
			poliza_cancelada,
			comision_cancelada,
			porc_comis_agt,
			porc_partic_agt,
			cant_pagos)
	 select	no_documento,
			cod_agente,
			no_recibo,
			current,
			monto_recibo,
			prima_suscrita,
			prima_neta,
			abs(comision_adelanto),
			comision_ganada,
			comision_saldo,
			1,
			_comision_saldo,
			porc_comis_agt,
			porc_partic_agt,
			cant_pagos
	   from cobadeco
	  where no_documento = _no_documento;

   	delete from cobadeco 
	 where cod_agente	= _cod_agente
	   and no_documento	= _no_documento;}
end foreach

select sum(monto)
  into _monto_recibo
  from cobredet
 where no_remesa = _no_remesa;
 
update cobremae
   set recibi_de = _recibi_de
 where no_remesa = _no_remesa;

{call sp_cob29(_no_remesa,_user) returning _error, _error_desc;

if _error <> 0 then
	return _error, _error_desc;
end if}

return 0,'Creación exitosa de la remesa.';

end
end procedure