-- Procedimiento que Genera la Prima cobrada devengada neta para un rango de periodos
-- Creado: 03/01/2018 - Autor: Román Gordón
--execute procedure sp_dev06c('001','2017-01','2017-12')


drop procedure sp_dev06c;
create procedure sp_dev06c(a_cod_compania char(3), a_periodo_desde char(7), a_periodo_hasta char(7))
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
define _cnt_agt				smallint;
define _valor				smallint;
define my_sessionid			integer;
define _error_isam			integer;
define _error				integer;
define _fecha_suspension	date;
define _cubierto_hasta		date;
define _fecha_hasta			date;
define _fecha_desde			date;

set isolation to dirty read;

--set debug file to 'sp_dev06c.trc';
--trace on;

begin
on exception set _error,_error_isam,_mensaje
	let _mensaje = _mensaje || trim(_no_documento);
	rollback work;
	return _error,_mensaje;
end exception

let _fecha_desde = mdy(a_periodo_desde[6,7],1,a_periodo_desde[1,4]);
let _fecha_hasta = sp_sis36(a_periodo_hasta);
let _anio = '2019'; --2017
let my_sessionid = DBINFO('sessionid');
--let a_periodo_desde = '2018-01'; --2017-01
--let a_periodo_hasta = '2018-12'; --2017-12

foreach with hold
	select distinct no_poliza--,periodo[1,4]
	  into _no_poliza--,_anio
	  from cobredet
	 where cod_compania = a_cod_compania
	   and actualizado = 1
	   and tipo_mov in ('P','N')
	   and periodo >= a_periodo_desde
	   and periodo <= a_periodo_hasta
	   
	begin
		on exception in(-535)

		end exception 	
		begin work;
	end

	select no_documento,
		   tiene_impuesto
	  into _no_documento,
		   _tiene_impuesto
	  from emipomae
	 where no_poliza = _no_poliza;

	let _valor = sp_sis101a(_no_documento,'01/10/2018','30/09/2019',my_sessionid);
	
	select count(*)
	  into _cnt_agt
	  from con_corr
	 where sessionid = my_sessionid
	   and cod_agente in ('00692','00259','02547','01459','01058','01562','01727','02111','02569','02587','02603');

	if _cnt_agt is null then
		let _cnt_agt = 0;
	end if 

	if _cnt_agt = 0 then
		continue foreach;
	end if
	
	call sp_dev06(_no_documento,_fecha_hasta) returning _error,_mensaje,_cubierto_hasta,_fecha_suspension;
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
			   porcentaje
		  into _cod_agente,
			   _porc_partic_agt
		  from con_corr
		 where sessionid = my_sessionid

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