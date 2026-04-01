-- Procedimiento que Genera la Prima cobrada devengada neta para un rango de periodos
-- Creado: 03/01/2018 - Autor: Román Gordón
--execute procedure sp_dev06c('001','2017-01','2017-12')


drop procedure sp_dev06e;
create procedure sp_dev06e()
returning	smallint		as cod_error,
			varchar(100)	as error;

define _mensaje				varchar(100);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_agente			char(5);
define _anio				char(4);
define _porc_partic_agt		dec(5,2);
define _prima_cob_dev_neta	dec(16,2);
define _prim_cobrada_bruta	dec(16,2);
define _prima_cob_dev_agt	dec(16,2);
define _factor_impuesto		smallint;
define _tiene_impuesto		smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_suspension	date;
define _cubierto_hasta		date;
define _fecha_corte			date;
define _fecha_hasta			date;
define _fecha_desde			date;

set isolation to dirty read;

--set debug file to 'sp_dev06e.trc';
--trace on;

begin
on exception set _error,_error_isam,_mensaje
	let _mensaje = _mensaje || trim(_no_documento);
	rollback work;
	return _error,_mensaje;
end exception

let _anio = '2016';
let _fecha_corte = '01/01/2017';
let _fecha_desde = '01/01/2017';
let _fecha_hasta = '31/12/2017';

foreach with hold
	select distinct no_documento
	  into _no_documento
	  from deivid_bo:cobpridev
	 where anio = 2017
	   
	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	let _no_poliza = sp_sis21(_no_documento);

	select tiene_impuesto
	  into _tiene_impuesto
	  from emipomae
	 where no_poliza = _no_poliza;

	call sp_dev06(_no_documento,_fecha_corte) returning _error,_mensaje,_cubierto_hasta,_fecha_suspension;

	if _error <> 0 then
		let _mensaje = _mensaje || ' ' || trim(_no_documento);
		return _error,_mensaje with resume;
		continue foreach;
	end if

	select sum(prima_cobrada)
	  into _prim_cobrada_bruta
	  from tmp_consumo_prima
	 where no_documento = _no_documento
	   and fecha >= _fecha_desde
	   and fecha <= _fecha_hasta;

	if _prim_cobrada_bruta is null then
		let _prim_cobrada_bruta = 0.00;
	end if
	
	if _prim_cobrada_bruta = 0.00 then
		--commit work;
		--continue foreach;
	end if

	if _tiene_impuesto = 1 then
		let _factor_impuesto = 0;

		select sum(factor_impuesto)
		  into _factor_impuesto
		  from emipolim e, prdimpue i
		 where e.cod_impuesto = i.cod_impuesto
		   and e.no_poliza = _no_poliza;

		if _factor_impuesto is null then
			let _factor_impuesto = 0;
		end if

		let _prima_cob_dev_neta = _prim_cobrada_bruta / (1 + (_factor_impuesto/100));
	else
		let _prima_cob_dev_neta = _prim_cobrada_bruta;
	end if

	foreach
		select cod_agente,
			   porc_partic_agt
		  into _cod_agente,
			   _porc_partic_agt
		  from emipoagt
		 where no_poliza = _no_poliza

		let _prima_cob_dev_agt = _prima_cob_dev_neta * (_porc_partic_agt/100);

		insert into deivid_bo:cobpridev(
				anio,
				cod_agente,
				no_documento,
				prima_cob_dev_neta)
		values(	_anio,
				_cod_agente,
				_no_documento,
				_prima_cob_dev_agt);
	end foreach

	commit work;
end foreach

return 0,'Actualización Exitosa';
end
end procedure;