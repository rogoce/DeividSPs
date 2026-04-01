-- Procedimiento que verifica si la poliza que esta en el proceso de pago anticipado de comision se le desconto comision, de ser asi crea una remesa
-- descontando la cantidad de la comision que se desconto el corredor.
--
-- creado    : 18/10/2012 - Autor: Roman Gordon--
-- sis v.2.0 - deivid, s.a.

drop procedure sp_cob313;
create procedure "informix".sp_cob313(a_no_remesa char(10), a_user char(8))
returning   integer,
			char(100);   -- _error

define _error_desc			char(100);
define _descripcion			char(50);
define _recibi_de			char(50);
define _nom_corredor		char(50);
define _no_documento		char(20);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _no_remesa			char(10);
define _periodo				char(7);
define _cod_cobertura		char(5);
define _cod_agente			char(5);
define _cod_sucursal		char(3);
define _cod_compania		char(3);
define _cod_subramo			char(3);
define _caja_caja			char(3);
define _caja_comp			char(3);
define _cod_ramo			char(3);
define _null				char(1);
define _comision_adelanto	dec(16,2);			
define _monto_descontado	dec(16,2);
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

--set debug file to "sp_cob313.trc";      
--trace on;

let _nom_corredor		= '';
let _cod_sucursal		= '001';
let _cod_compania		= '001';
let _descripcion		= 'Descuento de Comision del Pago Anticipado de Comisiones.';
let _recibi_de			= '';
let _fecha				= current;
let _null				= null;
let _renglon			= 0;
let _comision_adelanto	= 0.00;

foreach
	select no_recibo,
		   renglon,
		   no_poliza,
		   monto_descontado,
		   periodo
	  into _no_recibo,
		   _renglon,
	  	   _no_poliza,
		   _monto_descontado,
		   _periodo
	  from cobredet
	 where no_remesa	= a_no_remesa
	   and tipo_mov		= 'P'

	select no_documento
	  into _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

	let _cnt_aplica = 0;

	select count(*)
	  into _cnt_aplica
	  from cobadeco
	 where no_documento = _no_documento;

	if _cnt_aplica = 0 then
		continue foreach;
	end if

	if _monto_descontado = 0.00 then
		continue foreach;
	end if

	--Actualizar el monto descontado a 0 para que se muestre en el estado de cuenta.
	update cobredet
	   set monto_descontado = 0
	 where no_remesa		= a_no_remesa
	   and renglon			= _renglon;

	let _monto_descontado = _monto_descontado * -1;

	foreach
		select cod_agente,
			   porc_partic_agt,
			   porc_comis_agt	
		  into _cod_agente,
			   _porc_partic_agt,	
			   _porc_comis_agt	
		  from cobadeco
		 where no_documento = _no_documento	

		select nombre
		  into _nom_corredor
		  from agtagent
		 where cod_agente = _cod_agente;

		select max(renglon)
		  into _renglon
		  from cobredet
		 where no_remesa = a_no_remesa;

		let _renglon	= _renglon + 1;
		let _recibi_de	= trim(_nom_corredor) || '/Pago Anticipado de Comisiones.';
		let _comision_adelanto = _monto_descontado * (_porc_partic_agt / 100);

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
				a_no_remesa,			--_no_remesa,
				_renglon,			--_renglon,
				_cod_compania,		--_cod_compania,
				_cod_sucursal,		--_cod_sucursal,
				_no_recibo,			--_no_recqibo_ancon,
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
				_no_poliza,			--_no_poliza
				_cod_agente
				);
	end foreach 

	{let _no_remesa   = sp_sis13("001", 'COB', '02', 'par_no_remesa');

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
	_monto_descontado,	--monto_chequeo, 
	0,					--actualizado,   
	_periodo,			--periodo,   
	a_user,				--user_added,   
	_fecha,				--date_added,   
	a_user,				--user_posteo,   
	_fecha,				--date_posteo,
	_caja_comp			--cod_chequera
	);

	update cobremae
	   set recibi_de = _recibi_de
	 where no_remesa = _no_remesa;	}

	

	{call sp_cob29(_no_remesa,a_user) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if}
end foreach

return 0,'Verificacion Exitosa.';
end
end procedure