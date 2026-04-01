-- Detalle de las facturas para revision contable

-- Creado    : 08/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_sac175;

create procedure "informix".sp_sac175(a_periodo char(7))
returning char(20),
          char(10),
		  char(50),
		  date,
		  dec(16,2),
		  dec(16,2),
		  date,
		  char(3),
		  char(50),
		  dec(5,2);

define _nombre_ramo		char(50);
define _nombre_cliente	char(50);

define _no_documento	char(20);

define _no_factura		char(10);
define _no_poliza		char(10);
define _cod_cliente		char(10);
define _cod_agente		char(10);
define _no_remesa		char(10);


define _periodo			char(7);
define _periodo2		char(7);

define _no_endoso		char(5);

define _cod_ramo		char(3);

define _tipo_agente		char(1);
define _tipo_mov		char(1);

define _fecha			date;
define _fecha_anulado	date;

define _prima_suscrita	dec(16,2);
define _prima_neta		dec(16,2);

define _porc_comis_agt  dec(5,2);
define _porc_partic_agt	dec(5,2);

define _renglon			smallint;

foreach
 select doc_remesa,
        no_recibo,
		fecha,
		periodo,
		monto,
		prima_neta,
		tipo_mov,
		desc_remesa,
		no_poliza,
		no_remesa,
		renglon
   into _no_documento,
        _no_factura,
		_fecha_anulado,
		_periodo,
		_prima_suscrita,
		_prima_neta,
		_tipo_mov,
		_nombre_cliente,
		_no_poliza,
		_no_remesa,
		_renglon
   from cobredet
  where cod_compania = "001"
    and actualizado  = 1 	
	and tipo_mov     matches "*"
    and periodo      = a_periodo

	{
	select cod_ramo,
	       cod_contratante
	  into _cod_ramo,
	       _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;
	}

	let _cod_ramo    = _tipo_mov;

	if _tipo_mov = "P" then
		let _nombre_ramo = "PAGO DE PRIMA";
	elif _tipo_mov = "N" then
		let _nombre_ramo = "NOTA DE CREDITO";
	elif _tipo_mov = "C" then
		let _nombre_ramo = "COMISION DESCONTADA";
	elif _tipo_mov = "D" then
		let _nombre_ramo = "DEDUCIBLE";
	elif _tipo_mov = "S" then
		let _nombre_ramo = "SALVAMENTO";
	elif _tipo_mov = "R" then
		let _nombre_ramo = "RECUPERO";
	elif _tipo_mov = "E" then
		let _nombre_ramo = "CREAR PAGO SUSPENSO";
	elif _tipo_mov = "A" then
		let _nombre_ramo = "APLICAR PAGO SUSPENSO";
	elif _tipo_mov = "B" then
		let _nombre_ramo = "RECIBO ANULADO";
	elif _tipo_mov = "T" then
		let _nombre_ramo = "APLICAR RECLAMO";
	elif _tipo_mov = "O" then
		let _nombre_ramo = "DEUDA AGENTE";
	elif _tipo_mov = "M" then
		let _nombre_ramo = "AFECTACION CATALOGO";
	end if

	-- Periodo y Fecha

	let _periodo2 = sp_sis39(_fecha_anulado);

	if _periodo = _periodo2 then
		let _fecha = _fecha_anulado;
	elif _periodo > _periodo2 then
		let _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);
	elif _periodo < _periodo2 then
		let _fecha = sp_sis36(_periodo);
	end if

	let _porc_comis_agt = 0.00;

	if _tipo_mov in ("P", "N") then

		foreach
		 Select	porc_comis_agt,
				porc_partic_agt,
				cod_agente
		   Into	_porc_comis_agt,
				_porc_partic_agt,
				_cod_agente
		   From cobreagt
		  Where	no_remesa = _no_remesa
		    and renglon   = _renglon

			select tipo_agente
			  into _tipo_agente
			  from agtagent
			 where cod_agente = _cod_agente;

			if _tipo_agente = "O" then
				let _porc_comis_agt = 0.00;
			end if

			exit foreach;

		end foreach

	end if

	return _no_documento,
	       _no_factura,
		   _nombre_cliente,
		   _fecha_anulado,
		   _prima_neta,
		   _prima_suscrita,
		   _fecha,
		   _cod_ramo,
		   _nombre_ramo,
		   _porc_comis_agt
		   with resume;

end foreach	

end procedure
