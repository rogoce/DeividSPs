-- Procedimiento que calcula el nuevo monto de comision si la poliza recibe un cambio en su prima neta.
-- Proceso de Pago Anticipado de Comisiones
-- creado    : 22/10/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure sp_cob314;
create procedure "informix".sp_cob314(a_no_poliza char(10),a_no_endoso char(5))
returning   integer,
			char(100);   -- _error

define _error_desc			char(100);
define _descripcion			char(50);
define _nom_cuenta			char(50);
define _recibi_de			char(50);
define _nom_corredor		char(50);
define _cuenta				char(25);
define _no_documento		char(20);
define _no_factura			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);				
define _no_remesa			char(10);				
define _user				char(8);				
define _periodo				char(7);				
define _cod_cobertura		char(5);
define _cod_auxiliar		char(5);
define _cod_agente			char(5);
define _cod_sucursal		char(3);
define _cod_compania		char(3);
define _cod_subramo			char(3);
define _cod_endomov			char(3);
define _caja_caja			char(3);
define _caja_comp			char(3);
define _cod_ramo			char(3);
define _cta_aux				char(1);
define _null				char(1);
define _prima_suscrita_end	dec(16,2);
define _comision_adelanto	dec(16,2);
define _monto_descontado	dec(16,2);
define _comis_adel_acum		dec(16,2);
define _comis_adel_sum		dec(16,2);
define _dif_prima_neta		dec(16,2);
define _prima_neta_end		dec(16,2);
define _prima_suscrita		dec(16,2);
define _comision_saldo		dec(16,2);
define _catalago_afect		dec(16,2);
define _prima_neta			dec(16,2);
define _deducible			dec(16,2);
define _prima		   		dec(16,2);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _comis_desc			smallint;
define _tipo_cober			smallint;
define _error_isam			smallint;
define _cnt_aplica			smallint;
define _renglon				smallint;
define _error				smallint;
define _cant				smallint;
define _fecha				date;

begin

on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

set isolation to dirty read;

--set debug file to "sp_cob314.trc";      
--trace on;

let _nom_corredor		= '';
let _cod_sucursal		= '001';
let _cod_compania		= '001';
let _recibi_de			= '';
let _cnt_aplica			= 0;
let _renglon			= 0;
let _prima_suscrita_end	= 0.00;
let _comision_adelanto	= 0.00;
let _comis_adel_acum	= 0.00;
let _comis_adel_sum		= 0.00;
let _prima_neta_end		= 0.00;
let _dif_prima_neta		= 0.00;
let _comision_saldo		= 0.00;
let _catalago_afect		= 0.00;
let _fecha				= current;
let _null				= null;

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = a_no_poliza;

select count(*)
  into _cnt_aplica
  from cobadeco
 where no_documento = _no_documento;

if _cnt_aplica = 0 then
	return 0,'No Aplica.';
end if

select prima_neta,
	   prima_suscrita,
	   user_added,
	   no_factura,
	   cod_endomov
  into _prima_neta_end,
	   _prima_suscrita_end,
	   _user,
	   _no_factura,
	   _cod_endomov
  from endedmae
 where no_poliza	= a_no_poliza
   and no_endoso	= a_no_endoso;

if _cod_endomov not in ('004','005','006','024','025') then
	return 0,'El Movimiento de Endoso no Aplica';
end if

if _prima_neta_end <> 0.00 then
	if _prima_neta_end > 0 then
		let _descripcion = 'Aumento de Comision del Pago Anticipado de Comisiones.';
	else
		let _descripcion = 'Descuento de Comision del Pago Anticipado de Comisiones.';
	end if
	let _no_remesa   = sp_sis13("001", 'COB', '02', 'par_no_remesa');

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
	0,					--monto_chequeo, 
	0,					--actualizado,   
	_periodo,			--periodo,   
	_user,				--user_added,   
	_fecha,				--date_added,   
	_user,				--user_posteo,   
	_fecha,				--date_posteo,
	_caja_comp			--cod_chequera
	);

	foreach
		select cod_agente,
			   comision_saldo,
			   prima_neta,
			   prima_suscrita,
			   comision_adelanto			   
		  into _cod_agente,
		  	   _comision_saldo,
			   _prima_neta,
			   _prima_suscrita,
			   _comis_adel_sum			   
		  from cobadeco
		 where no_documento = _no_documento

		select porc_partic_agt,
			   porc_comis_agt
		  into _porc_partic_agt,
		  	   _porc_comis_agt
		  from emipoagt
		 where no_poliza	= a_no_poliza
		   and cod_agente	= _cod_agente;

		select nombre
		  into _nom_corredor
		  from agtagent
		 where cod_agente = _cod_agente;

		let _comision_adelanto	= _prima_neta_end * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
		let _comision_saldo		= _comision_saldo + _comision_adelanto;
		let _prima_suscrita		= _prima_suscrita + _prima_suscrita_end;
		let _comis_adel_sum		= _comis_adel_sum + _comision_adelanto;
		let _prima_neta			= _prima_neta + _prima_neta_end;
		let _renglon			= _renglon + 1;
		let _recibi_de			= trim(_nom_corredor) || '/Pago Anticipado de Comisiones.';
		let _catalago_afect		= _comision_adelanto * -1; 

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
				'C',				--_tipo_mov,
				_comision_adelanto,	--_monto,
				0,					--_prima,
				0,					--_impuesto,
				0,					--_monto_descontado,
				0,					--_comis_desc,
				_descripcion,		--_descripcion,
				0,					--_saldo,
				_periodo,			--_periodo,
				_fecha,				--_fecha,
				0,					--0,
				a_no_poliza,			--_no_poliza
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
				cod_auxiliar
				)
		values(
				_no_remesa,
				_renglon,
				_cod_compania,
				_cod_sucursal,
				_no_factura,
				_cuenta,
				'M',
				_catalago_afect,
				0,
				0,
				_catalago_afect,
				0,
				_descripcion,
				0,
				_periodo,
				_fecha,
				0,
				a_no_poliza,
				_cod_agente,
				_cod_auxiliar
				);

		update cobadeco
		   set prima_neta			= _prima_neta,
			   prima_suscrita		= _prima_suscrita,
			   --comision_adelanto	= _comis_adel_sum,
			   comision_saldo		= _comision_saldo
		 where no_documento			= _no_documento
		   and cod_agente			= _cod_agente;
	end foreach

	update cobremae
	   set recibi_de = _recibi_de
	 where no_remesa = _no_remesa;

	call sp_cob29(_no_remesa,_user) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if
	
	let _comision_saldo = 0.00;
			
	select comision_saldo
	  into _comision_saldo
	  from cobadeco
	 where no_documento = _no_documento;

	{if abs(_comision_saldo) <= 0.10 then
		delete from cobadeco
		 where no_documento = _no_documento;
	end if	}
end if

return 0,'Actualización Exitosa.';
end
end procedure