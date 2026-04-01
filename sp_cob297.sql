-- Procedimiento que Genera la Remesa de las Primas en Suspenso con Polizas ya Creadas
-- Creado    : 28/10/2011 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob297;

create procedure "informix".sp_cob297(a_user char(8))
returning	smallint,
            char(100),
            char(10);

define _n_coaseguro		varchar(50);
define _descripcion   	char(100);
define _mensaje         char(100);
define _nombre_cliente 	char(50);
define _nombre_agente 	char(50);
define _error_desc      char(50);
define _poliza			char(50);
define _ramo			char(50);
define _doc_remesa    	char(30);
define a_no_documento	char(20);
define _cod_contratante	char(10);
define a_no_recibo		char(10);
define a_no_remesa      char(10);
define _cod_agente   	char(10);
define _no_poliza    	char(10);
define _periodo			char(7);
define _ano_char        char(4);
define a_compania		char(3);
define a_sucursal		char(3);
define _caja_caja		char(3);
define _caja_comp		char(3);
define _tipo_mov		char(1);
define _null            char(1);
define _porc_partic		dec(5,2);
define _porc_comis		dec(5,2);
define _sum_susp		dec(16,2);
define _impuesto		dec(16,2);
define _factor			dec(16,2);
define _saldo        	dec(16,2);
define _monto        	dec(16,2);
define _prima			dec(16,2);
define _flag_inicio		smallint;
define _cnt_legal		smallint;
define _cantidad		smallint;
define _error_code      integer;
define _error_isam      integer;
define _cant	      	integer;
define _fecha_corte		date;
define _fecha			date;
define _valor           smallint;

--set debug file to "sp_cob297.trc"; 
--trace on;

set isolation to dirty read;

begin
on exception set _error_code, _error_isam, _error_desc
 	return _error_code, trim(_error_desc) || trim(_doc_remesa), _error_isam;         
end exception

let _n_coaseguro = "";  
let a_no_remesa = '1';
let _fecha_corte = current - 1 units year; --Suspensos Agregados de un año en adelante
let _flag_inicio = 0;
let _cantidad = 0;
let _null = null;

foreach
	select ramo,
		   poliza,
		   doc_suspenso,
		   monto,
		   cod_compania,
		   cod_sucursal,
		   coaseguro
	  into _ramo,
		   _poliza,
		   _doc_remesa,
		   _monto,
		   a_compania,
		   a_sucursal,
		   _n_coaseguro
	  from cobsuspe
	 where date_added >= _fecha_corte
	   and actualizado = 1
    
    if trim(_n_coaseguro[1,4]) = 'ASSA' then --No incluir suspensos de coaseguro de ASSA hasta segunda orden. 09/03/2012 instr. Monica Cardenas
		continue foreach;
	end if

	-- Determinar el Numero de Poliza (Poliza Ancon)
	let _no_poliza = sp_sis21(_ramo);
	let a_no_documento = _ramo;

	if _no_poliza is null then
		let _no_poliza     = sp_sis21(_poliza);
		let a_no_documento = _poliza;
	end if

	-- Determinar el Numero de Poliza (Poliza Coaseguro)
	if _no_poliza is null then
		if _ramo is not null and _ramo <> '' then
			call sp_sis162(_ramo) returning _no_poliza, a_no_documento;
		end if
		
		if _no_poliza is null then
			if _poliza is not null and _poliza <> '' then
				call sp_sis162(_poliza) returning _no_poliza, a_no_documento;
			end if

			if _no_poliza is null then
				continue foreach;
			end if		
		end if
	end if

	let _cnt_legal = 0;
	
	select count(*)
	  into _cnt_legal
	  from coboutleg
	 where no_documento = a_no_documento;
	 
	if _cnt_legal > 0 then
		continue foreach;
	end if
	
	--******PROCEDIMIENTO PARA VERIFICAR SI LA POLIZA ESTA CANCELADA O ANULADA O Vigente y Motivo de No Renovación -039 Cese de Coberturas(Ley 12) AL MOMENTO DE GENERAR LA REMESA DE ACH.-- APM 25-08-2025 SD 14715
	let _valor = 0;
	let _valor = sp_sis519a(a_no_documento);
	if _valor in(1,2,3) then
		continue foreach;
	end if	
	
	-- Determinar el Numero de Recibo
    let a_no_recibo = null;	
	foreach
		select no_recibo,
			   sum(monto)
		  into a_no_recibo,
			   _sum_susp
		  from cobredet
		 where doc_remesa	= _doc_remesa
		   and tipo_mov		= "E"
		   and actualizado	= 1
		 group by no_remesa,no_recibo
		 
		if _sum_susp = _monto then
			exit foreach;
		end if
	end foreach	

	if a_no_recibo is null then
		continue foreach;
	end if 

	-- Determinar el Saldo
	let _saldo = sp_cob174(a_no_documento);

	if _saldo = 0 then
		continue foreach;
	end if

	if _flag_inicio = 0 then
		let a_no_remesa = sp_sis13("001", 'COB', '02', 'par_no_remesa');

		select fecha
		  into _fecha
		  from cobremae
		 where no_remesa = a_no_remesa;

		if _fecha is not null then
			return 1, 'El Numero de Remesa Generado Ya Existe, Por Favor Actualice Nuevamente ...', '';
		end if	

		let _fecha = today;
		let _periodo = sp_sis39(_fecha);

		-- Insertar el Maestro de Remesas
		call sp_cob224() returning _caja_caja, _caja_comp;

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
				cod_chequera)
		VALUES(	a_no_remesa,
				"001",
				"001",
				_caja_caja,
				_null,
				"APLICACION DE PRIMAS EN SUSPENSO",
				'C',
				_fecha,
				0,
				2,
				0.00,
				0,
				_periodo,
				a_user,
				_fecha,
				a_user,
				_fecha,
				_caja_comp);

		let _flag_inicio = 1;
	end if

	let _cantidad = _cantidad + 1;
	let _monto    = _monto * -1;

	-- Aplicacion de Prima en Suspenso
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
			actualizado)
	values(	a_no_remesa,
			_cantidad,
			a_compania,
			a_sucursal,
			a_no_recibo,
			_doc_remesa,
			'A',
			_monto,
			0,
			0,
			0,
			0,
			'',
			0,
			_periodo,
			_fecha,
			0);

	-- Pago de Prima
	let _cantidad = _cantidad + 1;
	let _monto    = _monto * -1;

	-- Impuestos de la Poliza
	select sum(i.factor_impuesto)
	  into _factor
	  from prdimpue i, emipolim p
	 where i.cod_impuesto = p.cod_impuesto
	   and p.no_poliza    = _no_poliza;

	if _factor is null then
		let _factor = 0;
	end if

	let _factor   = 1 + _factor / 100;
	let _prima    = _monto / _factor;
	let _impuesto = _monto - _prima;

	-- Descripcion de la Remesa		
	let _nombre_agente = "";

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		exit foreach;
	end foreach

	select cod_contratante
	  into _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;			

	let _descripcion = TRIM(_nombre_cliente) || "/" || TRIM(_nombre_agente);
	let _tipo_mov = "P";

	if _monto < 0 then
		let _tipo_mov = "N";
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
			no_poliza)
	values(	a_no_remesa,
			_cantidad,
			a_compania,
			a_sucursal,
			a_no_recibo,
			a_no_documento,
			_tipo_mov,
			_monto,
			_prima,
			_impuesto,
			0,
			0,
			_descripcion,
			_saldo,
			_periodo,
			_fecha,
			0,
			_no_poliza);

	foreach
		select cod_agente,
			   porc_partic_agt,
			   porc_comis_agt
		  into _cod_agente,
			   _porc_partic,
			   _porc_comis
		  from emipoagt
		 where no_poliza = _no_poliza

		insert into cobreagt(
		no_remesa,
		renglon,
		cod_agente,
		monto_calc,
		monto_man,
		porc_comis_agt,
		porc_partic_agt
		)
		values(
		a_no_remesa,
		_cantidad,
		_cod_agente,
		0,
		0,
		_porc_comis,
		_porc_partic
		);
	end foreach
end foreach

if _cantidad = 0 then
	delete from cobremae 
	 where no_remesa = a_no_remesa;

	return 1, 'No Hay Registros en Suspenso por Procesar ' , "";
end if

--Actualizacion de Remesa
call sp_cob29(a_no_remesa, a_user) returning _error_code, _mensaje;

if _error_code <> 0 then
	return _error_code, _mensaje, a_no_remesa;
end if

foreach
	select no_poliza
	  into _no_poliza
	  from cobredet
	 where no_remesa = a_no_remesa
	   and tipo_mov = 'P'
	   and actualizado = 1
	
	select saldo
	  into _saldo
	  from emipomae
	 where no_poliza = _no_poliza;
	
	call sp_pro863(_no_poliza,_saldo,'informix',a_no_remesa) returning _error_code, _mensaje;
	
	if _error_code not in (1,0) then
		return _error_code, _mensaje, a_no_remesa;
	end if
end foreach

return 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 
--commit work;
end 
end procedure;