-- procedimiento que genera la remesa de los pagos externos 

-- creado    : 09/09/2004 - autor: armando moreno
-- modificado: 30/09/2004 - autor: armando moreno

-- sis v.2.0 - deivid, s.a.

drop procedure sp_cob212;
create procedure sp_cob212(
a_compania		char(3),
a_sucursal		char(3),
a_user			char(8),
a_numero		char(10),
a_recibo_susp	char(30)
) returning	smallint,
			char(100),
			char(10);

define _descripcion   		char(100);
define _nombre_cliente 		char(80);
define _nombre_agente 		char(50);
define _recibi_de			char(50);
define _ramo				char(50);
define _error_desc			char(50);
define _doc_remesa	 		char(30);
define _cedula,_cedula_pag  char(30);
define _doc_suspenso 		char(30);
define _cuenta				char(25);
define _no_documento 		char(20);
define _no_recibo_ancon 	char(10);
define _cod_pagador			char(10);
define _cod_agente,_no_poliza2   		char(10);
define a_no_remesa			char(10);
define _no_poliza,_cod_pagador_sus    		char(10);
define _cod_agt		 		char(10);
define _periodo				char(7);
define _cod_auxiliar 		char(5);
define _ano_char        	char(4);
define _caja_comp			char(3);
define _caja_caja			char(3);
define _cod_ramo			char(3);
define _tipo_mov        	char(1);
define _null            	char(1); 
define _tipo_remesa			char(1);
define _porc_partic			dec(5,2);
define _porc_comis			dec(5,2);
define _monto_descontado	dec(16,2);
define _monto_descontado1	dec(16,2);
define _gasto_manejo		dec(16,2);
define _monto_comis			dec(16,2);
define _monto_calc			dec(16,2);
define _total_susp			dec(16,2);
define _comis_dif			dec(16,2);
define _monto_cob			dec(16,2);
define _impuesto			dec(16,2);
define _factor				dec(16,2);
define _prima				dec(16,2);
define _saldo        		dec(16,2);
define _monto        		dec(16,2);
define _tipo_formato		smallint;
define _error_isam			smallint;
define _comis_desc			smallint;
define _cnt_suspe,_valor    smallint;
define _ubic_pago			smallint;
define _error_code      	integer;
define _secuencia			integer;
define _renglon2     		integer;
define _renglon      		integer;
define _cant				integer;
define _error				integer;
define _fecha_recibo		date;
define _fecha				date;
define _msg_banisi   		char(100);
define _cnt                 smallint;
define _obs                 varchar(100);
define _obs2                char(1);

if TRIM(a_numero) = '31331' then --AND a_user = 'LPEREZ' then
 set debug file to "sp_cob212.trc"; 
  trace on;                                                                
end if

set isolation to dirty read;

begin
 
on exception set _error_code,_error_isam,_error_desc
 	drop table temp_gasto; 
 	return _error_code, _error_desc, '';
end exception

create temp table temp_gasto
             (cod_ramo	char(3),
			  cuenta	char(25),
			  monto		dec(16,2))
              with no log;

let _null       = null;
let _tipo_remesa = 'C';
let _cnt = 0;
let _monto_descontado1 = 0;

select no_recibo_ancon,																										
	   cod_agente,
	   fecha_recibo,
	   tipo_formato	
  into _no_recibo_ancon,
	   _cod_agt,
	  _fecha,
	  _tipo_formato
  from cobpaex0
 where numero = a_numero;

if _tipo_formato = 1 then
	select cedula,
	       nombre
	  into _cedula,
	       _recibi_de
	  from agtagent
	 where cod_agente = _cod_agt;

elif _tipo_formato = 2 then
	select cod_auxiliar,
	       nombre
	  into _cedula,
	       _recibi_de
	  from emicoase
	 where cod_coasegur = _cod_agt;

	let _tipo_remesa = 'B';

elif _tipo_formato = 3 then
	select cedula,
	       nombre
	  into _cedula,
	       _recibi_de
	  from cliclien
	 where cod_cliente = _cod_agt;
end if

select ubicacion_pago
  into _ubic_pago
  from cobforpaexm
 where cod_agente = _cod_agt
   and tipo_formato = _tipo_formato;

if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if

let a_no_remesa   = sp_sis13("001", 'COB', '02', 'par_no_remesa');
let _obs = "";
select count(*)
  into _cant
  from cobremae
 where no_remesa = a_no_remesa;

if _cant <> 0 then
	return 1, 'el numero de remesa generado ya existe, por favor actualize nuevamente ...', "";
end if	

call sp_cob224a(_cod_agt,_tipo_formato) returning _caja_caja, _caja_comp;
  
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
values(	a_no_remesa,
		a_compania,
		a_sucursal,
		_caja_caja,
		_null,
		_recibi_de,
		_tipo_remesa,
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

update cobpaex0
   set no_remesa_ancon = a_no_remesa
 where numero = a_numero;

let _comis_dif = 0.00;

select max(renglon)
  into _renglon
  from cobredet
 where no_remesa = a_no_remesa;

if _renglon is null then
	let _renglon = 0;
end if

let _renglon = _renglon + 1;

foreach
	select no_documento,
		   monto_cobrado,
		   cliente,
		   monto_comis, --+ comis_cobro + comis_visa + comis_clave),  -- comis_desc, se elimino la suma de valores por peticion sr. carlos berrocal 03/03/2011
		   renglon,
		   gasto_manejo
	  into _no_documento,
		   _monto,
		   _nombre_cliente,
		   _monto_comis,
		   _renglon2,
		   _gasto_manejo
	  from cobpaex1
	 where numero = a_numero
	 order by renglon
	 
	if  _cod_agt = '00035' then  -- AMORENO: EMAIL 28022019, 25/02/2019.Validacion pago externo Ducruet Banisi
		call sp_cob772(_cod_agt,a_numero,_renglon2) returning _error,_msg_banisi;
		if _error <> 0 then
			continue foreach;
		end if
	end if
	
	if _tipo_formato = 3 and (_cod_agt in ('39141','80831','84057','51385','176896')) then	 
		let _no_documento = sp_sis160(_no_documento);
		let _no_poliza	  = sp_sis21(_no_documento);

		if _no_poliza is not null or _no_poliza <> "" then
			select cod_pagador
			  into _cod_pagador
			  from emipomae
			 where no_poliza = _no_poliza;

			select nombre
			  into _nombre_cliente
			  from cliclien
			 where cod_cliente = _cod_pagador;
		end if
	end if
	LET _obs = "";
	let _obs2 = "";
	let _no_poliza2 = "";
	let _no_poliza = sp_sis250(_no_documento,_periodo,_fecha);
	if _no_poliza is not null or _no_poliza <> "" then
		let _cedula_pag = "";
		select cod_pagador
		  into _cod_pagador_sus
		  from emipomae
		 where no_poliza = _no_poliza;
		select cedula
		  into _cedula_pag
		  from cliclien
		 where cod_cliente = _cod_pagador_sus; 
		let _valor = 0;
		let _valor = sp_sis519a(_no_documento);	--Buscar si la poliza esta cancelada o anulada o vigente y con cod_no_renov = '039'
		if _valor = 1 then --Debe crear suspenso en lugar del pago
		    let _no_poliza2 = _no_poliza;
			let _no_poliza = null;
			let _obs = "BLOQUEO PAGO – CANCELADA";
			let _obs2 = "*";
		end if
		if _valor = 3 then --Debe crear suspenso en lugar del pago
			let _no_poliza2 = _no_poliza;
			let _no_poliza = null;
			let _obs = "BLOQUEO PAGO – ANULADA";
			let _obs2 = "*";
		end if
		if _valor = 2 then --Debe crear suspenso en lugar del pago
			let _no_poliza2 = _no_poliza;
			let _no_poliza = null;
			let _obs = "BLOQUEO PAGO – CESADA";
			let _obs2 = "*";
		end if
	end if
	if _no_poliza is not null or _no_poliza <> "" then

		if _monto >= 0.00 then 
			let _tipo_mov   = 'P';
		else
			let _tipo_mov   = 'N';
		end if

		if _tipo_formato = 2 then --Afectacion de catalogo Coaseguro
			let _cuenta = sp_sis15('PPGHONXPCO', '01',_no_poliza);
			
			select cod_ramo
			  into _cod_ramo
			  from emipomae
			 where no_poliza = _no_poliza;

			insert into temp_gasto(cod_ramo,cuenta,monto) 
			values (_cod_ramo,_cuenta,_gasto_manejo);	   
		end if

		select sum(saldo)
		  into _saldo
		  from emipomae
		 where no_documento = _no_documento
		   and actualizado  = 1;

		if _saldo is null then
			let _saldo = 0;
		end if

		-- impuestos de la poliza
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
		
		-- descripcion de la remesa		
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

		let _descripcion = trim(_nombre_cliente) || "/" || trim(_nombre_agente);
		let _monto_descontado = _monto_comis;

		if _monto_descontado = 0.00 then
			let _comis_desc = 0;
		else
			let _comis_desc = 1;
		end if		  

		-- detalle de la remesa
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
				_renglon,
				a_compania,
				a_sucursal,
				_no_recibo_ancon,
				_no_documento,
				_tipo_mov,
				_monto,
				_prima,
				_impuesto,
				_monto_descontado,
				_comis_desc,
				_descripcion,
				_saldo,
				_periodo,
				_fecha,
				0,
				_no_poliza);
				
		   let _cnt = 0;	 
			select count(*)
			  into _cnt
			  from emipoagt
			 where no_poliza = _no_poliza;
			   
			if _cnt is null then
				let _cnt = 0;
			end if				
        let _monto_descontado1	 = 0;
		foreach
			select cod_agente,
				   porc_partic_agt,
				   porc_comis_agt
			  into _cod_agente,
				   _porc_partic,
				   _porc_comis
			  from emipoagt
			 where no_poliza  = _no_poliza

			if _monto_descontado <> 0 then
				let _monto_calc = _prima * (_porc_partic / 100) * (_porc_comis / 100);
				--let _monto_descontado = _monto_calc;
			else
				let _monto_calc = _monto_descontado;
			end if
			
			if _cnt > 1 then
				let _monto_descontado1	= _monto_descontado * (_porc_partic / 100);
			else
				let _monto_descontado1	= _monto_descontado;
			end if

			insert into cobreagt(
					no_remesa,
					renglon,
					cod_agente,
					monto_calc,
					monto_man,
					porc_comis_agt,
					porc_partic_agt)
			values(	a_no_remesa,
					_renglon,
					_cod_agente,
					_monto_calc,
					_monto_descontado1, --_monto_descontado,
					_porc_comis,
					_porc_partic);		  
		end foreach

		select sum(monto_calc)
		  into _monto_calc
		  from cobreagt
		 where no_remesa = a_no_remesa
		   and renglon   = _renglon;

		if _monto_calc is null then
			let _monto_calc = 0.00;
		end if

		let _comis_dif = _comis_dif + (_monto_calc - _monto_descontado);
	else   --crear prima en suspenso

		let _secuencia = 0;

		select count(*)
		  into _secuencia
		  from cobpaex3
		 where no_recibo = _no_recibo_ancon;

		if _secuencia = 0 then  --no existe
			insert into cobpaex3(
					no_recibo,
					secuencia)
			values(	_no_recibo_ancon,
					0);
		end if

		let _descripcion = trim(_nombre_cliente);

		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agt;

		--tabla que lleva la secuencia por recibo
		select max(secuencia)
		  into _secuencia
		  from cobpaex3
		 where no_recibo = _no_recibo_ancon;

		let _doc_suspenso		= trim(_no_recibo_ancon) || "-" || _secuencia;
		let _no_poliza			= _null;
		let _tipo_mov			= 'E';
		let _monto_descontado	= 0;
		let _secuencia			= _secuencia + 1;
		let _cnt_suspe			= 0;
		let _impuesto			= 0;
		let _prima				= 0;
		let _saldo				= 0.00;
		let _ramo				= sp_sis394(_no_documento);

		select count(*)
		  into _cnt_suspe
		  from cobsuspe
		 where doc_suspenso = _doc_suspenso;

		if _cnt_suspe > 0 then
			return 1,'El Suspenso: ' || trim(_doc_suspenso) || ' ya ha sido creado. Verifique.','';
		end if

		update cobpaex3
		   set secuencia = _secuencia
		 where no_recibo = _no_recibo_ancon;
		 
		if _no_poliza2 <> "" then
			let _no_poliza = _no_poliza2;
		end if

		insert into cobsuspe(
				doc_suspenso,
				cod_compania,
				cod_sucursal,
				monto,
				fecha,
				coaseguro,
				asegurado,
				poliza,
				ramo,
				actualizado,
				user_added,
				date_added,
				corredor,
				cedula,
				observacion)
		values(	_doc_suspenso,
				a_compania,
				a_sucursal,
				_monto,
				_fecha,
				"",
				_nombre_cliente,
				_no_documento,
				_ramo,
				0,
				a_user,
				_fecha,
				_nombre_agente,
				_cedula_pag,
				_obs);

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
				cod_cobertura)
		values(	a_no_remesa,
				_renglon,
				a_compania,
				a_sucursal,
				_no_recibo_ancon,
				_doc_suspenso,--_no_documento,
				_tipo_mov,
				_monto,
				_prima,
				_impuesto,
				_monto_descontado,
				0,
				_descripcion,
				_saldo,
				_periodo,
				_fecha,
				0,
				_no_poliza,
				_obs2);

		-- comision descontada
		if _monto_comis <> 0.00 then

			let _renglon      = _renglon + 1;
			let _tipo_mov     = 'C';
			let _cod_auxiliar = "A" || _cod_agt[2,5]; -- en sac no alcanza para poner los 5 digitos

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
			values(	a_no_remesa,
					_renglon,
					a_compania,
					a_sucursal,
					_no_recibo_ancon,
					_cedula,
					_tipo_mov,
					_monto_comis * -1,
					0.00,
					0.00,
					0.00,
					0,
					"comision descontada ...",
					0.00,
					_periodo,
					_fecha,
					0,
					_null,
					_cod_agt,
					_cod_auxiliar);
		end if
	end if

	let _renglon = _renglon + 1;
end foreach

if _ubic_pago = 1 then
	let a_recibo_susp = trim(a_recibo_susp);
	--let a_recibo_susp = 'GB110112-01';

	if a_recibo_susp = '' or a_recibo_susp is null then
		let a_recibo_susp = _no_recibo_ancon;
	end if

	call sp_sis138b(a_recibo_susp) 
	returning	_nombre_cliente,
				_total_susp,
				_renglon,
				_fecha_recibo,
				_doc_remesa;

	if _renglon = 1 then
		drop table temp_gasto;
		return 1, 'no se encontro la prima en suspenso.', '';
	end if
	
	select max(renglon)
	  into _renglon
	  from cobredet
	 where no_remesa = a_no_remesa;

	let _renglon = _renglon + 1;
	let _tipo_mov = 'A';
   	let _descripcion = trim(_nombre_cliente);

	{select sum(monto),
		   sum(monto_descontado)
	  into _monto_cob,
	  	   _monto_descontado
	  from cobredet
	 where no_remesa = a_no_remesa
	   and tipo_mov = 'P';}

	let _total_susp = -1 * _total_susp;--(_monto_cob - _monto_descontado); 

	-- detalle de la remesa
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
			_renglon,
			a_compania,
			a_sucursal,
			_no_recibo_ancon,
			_doc_remesa,
			_tipo_mov,
			_total_susp,
			0,
			0,
			0,
			0,
			_descripcion,
			0,
			_periodo,
			_fecha,
			0,
			null);
elif _ubic_pago = 2 then
	--select 	
end if

if _tipo_formato = 2 then --Afectacion de catalogo Coaseguro
	
	select max(renglon)
	  into _renglon
	  from cobredet
	 where no_remesa = a_no_remesa;

	let _tipo_mov = 'M';

	foreach
		select distinct cod_ramo
		  into _cod_ramo
		  from temp_gasto

		foreach
			select sum(monto),
				   cuenta
			  into _gasto_manejo,
				   _cuenta
			  from temp_gasto
			 where cod_ramo = _cod_ramo
			 group by cuenta

			select cta_nombre
			  into _descripcion
			  from cglcuentas
			 where cta_cuenta = _cuenta;

			let _renglon = _renglon + 1;

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
					_renglon,
					a_compania,
					a_sucursal,
					_no_recibo_ancon,
					_cuenta,
					_tipo_mov,
					_gasto_manejo,
					0,
					0,
					_gasto_manejo,
					0,
					_descripcion,
					0,
					_periodo,
					_fecha,
					0,
					null);
		end foreach
	end foreach
	drop table temp_gasto; 	  
end if

-- diferencia en el monto de la comision
{
if _comis_dif <> 0.00 then

	let _renglon  = _renglon + 1;
	let _tipo_mov = 'C';

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
	values(
    a_no_remesa,
    _renglon,
    a_compania,
    a_sucursal,
    _no_recibo_ancon,
    _cedula,
    _tipo_mov,
    _comis_dif,
    0.00,
    0.00,
    0.00,
    0,
    "comison descontada ...",
    0.00,
    _periodo,
    _fecha,
    0,
	_null,
	_cod_agt
	);

end if
--}

-- comision de cobro, visa y clave
{
select sum(comis_cobro + comis_visa + comis_clave)
  into _monto_comis
  from cobpaex1
 where numero = a_numero;

if _monto_comis <> 0 then
 
	let _renglon      = _renglon + 1;
	let _tipo_mov     = 'M';
	let _no_documento = "564020103";

	select cta_nombre
	  into _descripcion
	  from cglcuentas
	 where cta_cuenta = _no_documento;

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
	no_poliza
	)
	values(
	a_no_remesa,
	_renglon,
	a_compania,
	a_sucursal,
	_no_recibo_ancon,
	_no_documento,
	_tipo_mov,
	_monto_comis * -1,
	0.00,
	0.00,
	0.00,
	0,
	_descripcion,
	0.00,
	_periodo,
	_fecha,
	0,
	_null					
	);

end if
}

let _saldo = 0.00;

foreach 
	select tipo_mov,
		   monto,
		   monto_descontado
	  into _tipo_mov,
		   _monto,
		   _monto_descontado	 		
	  from cobredet
	 where no_remesa = a_no_remesa
	   and renglon   <> 0

	-- obtiene el monto del banco
	if _tipo_mov = 'M' and _monto_descontado <> 0  then
		let _monto = 0;
	end if

	let _saldo = _saldo + (_monto - _monto_descontado);
end foreach

update cobremae
   set monto_chequeo = _saldo
 where no_remesa = a_no_remesa;

drop table temp_gasto;

return 0, 'actualizacion exitosa, remesa # ' || a_no_remesa, a_no_remesa; 
end
end procedure