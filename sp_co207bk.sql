

create procedure "informix".sp_co207(
a_compania		char(3),
a_sucursal		char(3),
a_user			char(8),
a_no_recibo     char(20),
a_no_documento  char(20)
) returning smallint,
            char(100),
            char(10);
			
define _descripcion		char(100);
define _mensaje			char(100);
define _nombre_cliente	char(50);
define _nombre_agente	char(50);
define _doc_remesa		char(30);
define _recibo_tmp		char(20);
define _cod_contratante	char(10);
define a_no_remesa		char(10);
define _cod_agente		char(10);
define _no_poliza		char(10);
define _periodo			char(7);
define _ano_char		char(4);
define _caja_caja		char(3);
define _caja_comp		char(3);
define _null			char(1);
define _porc_partic		dec(5,2);
define _porc_comis		dec(5,2);
define _impuesto		dec(16,2);
define _factor			dec(16,2);
define _prima			dec(16,2);
define _saldo			dec(16,2);
define _monto			dec(16,2);
define _error_code		integer;
define _cant			integer;
define _fecha			date;

{set debug file to "sp_cob50a.trc"; 
trace on;}

set isolation to dirty read;

--begin work;
begin
on exception set _error_code
--	rollback work;	
 	return _error_code, 'Error al Actualizar la Remesa', '';         
end exception

let _null		= null;
let a_no_remesa	= '1';  
let a_no_recibo	= trim(a_no_recibo);
let _doc_remesa	= _null;

let a_no_remesa	= sp_sis13(a_compania, 'COB', '02', 'par_no_remesa');

Select fecha
  into _fecha
  from cobremae
 where no_remesa = a_no_remesa;

if _fecha is not null then
	return 1, 'el numero de remesa generado ya existe, por favor actualize nuevamente ...', '';
end if	

let _fecha = today;

if month(_fecha) < 10 then
	let _periodo = year(_fecha) || '-0' || month(_fecha);
else
	let _periodo = year(_fecha) || '-' || month(_fecha);
end if

-- insertar el maestro de remesas

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
		cod_chequera
		)
values	(
		a_no_remesa,
		a_compania,
		a_sucursal,
		_caja_caja,
		_null,
		_null,
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
		_caja_comp
		);

select doc_remesa
  into _doc_remesa
  from cobredet
 where no_recibo = a_no_recibo
   and tipo_mov  = "E";

-- Para los casos en que el numero de recibo sea el numero
-- del documento de la prima en suspenso

if _doc_remesa is null then	
	let _recibo_tmp = null;

	select no_recibo
	  into _recibo_tmp
	  from cobredet
	 where doc_remesa = a_no_recibo
	   and tipo_mov   = "E";

	-- Invertir los Valores

	if _recibo_tmp is not null then
		let _doc_remesa = a_no_recibo; 
		let a_no_recibo = _recibo_tmp; 
	end if 
end if

if _doc_remesa is not null then
	
	let _doc_remesa = trim(_doc_remesa);

	select count(*)
	  into _cant
	  from cobsuspe
	 where doc_suspenso = _doc_remesa;

	if _cant = 0 then
--		rollback work;
		RETURN 1, 'No se encontro la prima en suspenso, No se Aplico el pago...', '';
	else

		select actualizado,
		       monto
		  into _cant,
		       _monto
		  from cobsuspe
		 where doc_suspenso = _doc_remesa;

		if _cant = 1 then

			let _monto = _monto * -1;

			--***aplicacion de prima en suspenso***

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
		    actualizado
			)
			values(
		    a_no_remesa,
		    1,
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
		    0
			);

			--***PAGO DE PRIMA***

			let _monto = _monto * -1;

			-- Impuestos de la Poliza

			let _no_poliza = sp_sis21(a_no_documento);

			select sum(saldo)
			  into _saldo
			  from emipomae
			 where no_documento = a_no_documento
			   and actualizado  = 1;

			if _saldo is null then
				let _saldo = 0;
			end if

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

			let _descripcion = trim(_nombre_cliente) || "/" || trim(_nombre_agente);

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
		    2,
		    a_compania,
		    a_sucursal,
		    a_no_recibo,
		    a_no_documento,
		    "P",
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
			_no_poliza
			);

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
						porc_comis_agt
						porc_partic_agt
						)
				values(
						a_no_remesa,
						2,
						_cod_agente,
						0,
						0,
						_porc_comis,
						_porc_partic
						);
			end foreach

			select sum(monto)
			  into _saldo
			  from cobredet
			 where no_remesa = a_no_remesa;

			update cobremae
			   set monto_chequeo = _saldo
			 where no_remesa     = a_no_remesa;
		else
--			rollback work;
			RETURN 1, 'La Remesa que creo la prima en suspenso no esta actualizada, No se puede Aplicar el pago...', '';
		end if
    end if
else
--	rollback work;
	RETURN 1, 'No se encontro el No. de Recibo, No se puede Aplicar el Pago... ', '';
end if

--Actualizacion de Remesa

call sp_cob29(a_no_remesa, a_user) returning _error_code, _mensaje;

if _error_code <> 0 then
	return _error_code, _mensaje, a_no_remesa;
end if
--commit work;

return 0, 'Actualizacion Exitosa, Remesa # ' || a_no_remesa, a_no_remesa; 

end
end procedure
