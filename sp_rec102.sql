-- Verificacion del Incurrido para los Excesos de Perdida

-- Creado    : 11/08/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_rec102;

create procedure "informix".sp_rec102(a_numrecla char(20))
returning char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(7,4),
		  char(1),
		  char(7),
		  char(50),
		  char(50),
		  dec(16,2),
          char(20);

define _porc_retencion	dec(16,2);
define _suma_max_ret	dec(16,2);
define _cod_tipotran	char(3);
define _transaccion		char(10);
define _numrecla		char(20);
define _monto_tr		dec(16,2);
define _variacion_tr	dec(16,2);

define _incurrido_bruto dec(16,2);
define _incurrido_neto  dec(16,2);
define _inc_neto_acum   dec(16,2);
define _inc_bruto_acum  dec(16,2);
define _inc_int1		integer;
define _inc_int2		integer;

define _porc_coas		dec(7,4);
define _porc_reas		dec(7,4);

define _no_tranrec		char(10);
define _no_reclamo		char(10);
define _monto_inc		dec(16,2);
define _fecha			date;
define _ano				smallint;
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _periodo			char(7);
define _nombre_tipo		char(50);
define _cod_recla		char(10);
define _nombre_recla	char(50);
define _asterisco       char(1);

define _inc_reas_acum	dec(16,2);

set isolation to dirty read;

create temp table tmp_exeper(
no_reclamo	char(10),
numrecla	char(20),
cod_recla	char(10),
cod_ramo	char(3)
) with no log;

foreach
 select no_reclamo,
		no_poliza,
		numrecla,
		cod_reclamante
   into _no_reclamo,
        _no_poliza,
		_numrecla,
		_cod_recla
   from	recrcmae
  where actualizado = 1
	and numrecla    = a_numrecla

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	insert into tmp_exeper
	values (_no_reclamo, _numrecla, _cod_recla, _cod_ramo);

{
	select porc_partic_coas
	  into _porc_coas
	  from reccoas
	 where no_reclamo   = _no_reclamo
	   and cod_coasegur = "036";

	if _porc_coas is null then
		let _porc_coas = 0.00;
	end if
 
	let _inc_neto_acum = 0.00;

	foreach
	 select no_tranrec,
			transaccion,
			fecha,
			monto,
			variacion,
			periodo,
			cod_tipotran
	   into	_no_tranrec,
			_transaccion,
			_fecha,
			_monto_tr,
			_variacion_tr,
			_periodo,
			_cod_tipotran
	   from rectrmae
	  where	actualizado = 1
	    and no_reclamo  = _no_reclamo
      order by transaccion

		let _ano = year(_fecha);

		select monto
		  into _suma_max_ret
		  from reaexper
		 where cod_ramo = _cod_ramo
		   and ano      = _ano;

		if _suma_max_ret is null then
			let _suma_max_ret = 0.00;
		end if

		if _suma_max_ret = 0.00 then
			continue foreach;
		end if

		if _cod_tipotran = "004" or
		   _cod_tipotran = "005" or
		   _cod_tipotran = "006" or
		   _cod_tipotran = "007" then

			let _monto_inc = _monto_tr;

		else

			let _monto_inc = 0.00;

		end if

		let _incurrido_bruto = _monto_inc + _variacion_tr;
		let _incurrido_bruto = _incurrido_bruto * _porc_coas / 100;

		select porc_partic_suma
		  into _porc_reas
		  from rectrrea
		 where no_tranrec    = _no_tranrec
		   and tipo_contrato = 1;

		if _porc_reas is null then
			let _porc_reas = 0.00;
		end if		

		let _incurrido_neto = _incurrido_bruto * _porc_reas / 100;
		let _inc_neto_acum  = _inc_neto_acum + _incurrido_neto;

		let _inc_int1 = _inc_neto_acum;
		let _inc_int2 = _suma_max_ret;
		 
		if _inc_int1 > _inc_int2 then
		
			insert into tmp_exeper
			values (_no_reclamo, _numrecla, _cod_recla, _cod_ramo);

			exit foreach;

		end if
		
	end foreach
}	
end foreach

foreach
 select no_reclamo,
		numrecla,
		cod_recla,
		cod_ramo
   into _no_reclamo,
        _numrecla,
		_cod_recla,
		_cod_ramo
   from	tmp_exeper

	select nombre
	  into _nombre_recla
	  from cliclien
	 where cod_cliente = _cod_recla;

	select porc_partic_coas
	  into _porc_coas
	  from reccoas
	 where no_reclamo   = _no_reclamo
	   and cod_coasegur = "036";

	if _porc_coas is null then
		let _porc_coas = 0.00;
	end if
 
	let _inc_neto_acum  = 0.00;
	let _inc_bruto_acum = 0.00;
	let _inc_reas_acum  = 0.00;
	let _asterisco      = "";

	foreach
	 select no_tranrec,
			transaccion,
			fecha,
			monto,
			variacion,
			periodo,
			cod_tipotran
	   into	_no_tranrec,
			_transaccion,
			_fecha,
			_monto_tr,
			_variacion_tr,
			_periodo,
			_cod_tipotran
	   from rectrmae
	  where	actualizado = 1
	    and no_reclamo  = _no_reclamo
      order by transaccion

		let _ano = year(_fecha);

		select monto
		  into _suma_max_ret
		  from reaexper
		 where cod_ramo = _cod_ramo
		   and ano      = _ano;

		if _suma_max_ret is null then
			let _suma_max_ret = 0.00;
		end if

		if _cod_tipotran = "004" or
		   _cod_tipotran = "005" or
		   _cod_tipotran = "006" or
		   _cod_tipotran = "007" then

			let _monto_inc = _monto_tr;

		else

			let _monto_inc = 0.00;

		end if

		let _incurrido_bruto = _monto_inc       + _variacion_tr;
		let _incurrido_bruto = _incurrido_bruto * _porc_coas / 100;
		let _variacion_tr    = _variacion_tr    * _porc_coas / 100;

		select porc_partic_suma
		  into _porc_reas
		  from rectrrea
		 where no_tranrec    = _no_tranrec
		   and tipo_contrato = 1;

		if _porc_reas is null then
			let _porc_reas = 0.00;
		end if		

		let _incurrido_neto  = _incurrido_bruto * _porc_reas / 100;
		let _inc_neto_acum   = _inc_neto_acum   + _incurrido_neto;
		let _inc_bruto_acum  = _inc_bruto_acum  + _incurrido_bruto;
		let _inc_reas_acum   = _inc_reas_acum   + (_incurrido_bruto - _incurrido_neto);

		select nombre
		  into _nombre_tipo
		  from rectitra
		 where cod_tipotran = _cod_tipotran;

		if _inc_neto_acum > _suma_max_ret then
			let _asterisco = "*";
		end if
		
		return _transaccion,
			   _incurrido_bruto,
			   _variacion_tr,
			   _inc_bruto_acum,
			   _inc_neto_acum,
			   _inc_reas_acum,
			   _porc_reas,
			   _asterisco,
			   _periodo,
			   _nombre_tipo,
			   _nombre_recla,
			   _suma_max_ret,
		       _numrecla
			   with resume;

	end foreach

end foreach

drop table tmp_exeper;

end procedure