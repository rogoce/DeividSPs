-- Procedimiento que Genera la Prima cobrada devengada neta para Bono de Rentabilidad
-- Creado: 03/01/2018 - Autor: Román Gordón
--execute procedure sp_dev06c('001','2017-01','2017-12')


--drop procedure sp_dev06fbk;
create procedure sp_dev06fbk(a_no_documento char(20),a_fecha_corte date, a_fecha_desde date, a_fecha_hasta date)
returning	smallint		as cod_error,
			varchar(100)	as error,
			decimal(16,2)   as prima_neta_cob_dev;

define _mensaje				varchar(100);
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

set isolation to dirty read;

--set debug file to 'sp_dev06e.trc';
--trace on;

begin
	on exception set _error,_error_isam,_mensaje
		let _mensaje = _mensaje || trim(a_no_documento);
		return _error,_mensaje,0;
	end exception

	drop table if exists tmp_consumo_prima;
	let _no_poliza = sp_sis21(a_no_documento);

	select tiene_impuesto
	  into _tiene_impuesto
	  from emipomae
	 where no_poliza = _no_poliza;

	call sp_dev06(a_no_documento,a_fecha_corte) returning _error,_mensaje,_cubierto_hasta,_fecha_suspension;

	if _error <> 0 then
		let _mensaje = _mensaje || ' ' || trim(a_no_documento);
		return _error,_mensaje,0 with resume;
	end if

	select sum(prima_cobrada)
	  into _prim_cobrada_bruta
	  from tmp_consumo_prima
	 where no_documento = a_no_documento
	   and fecha >= a_fecha_desde
	   and fecha <= a_fecha_hasta;

	if _prim_cobrada_bruta is null then
		let _prim_cobrada_bruta = 0.00;
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
--drop table if exists tmp_consumo_prima;
return 0,'Actualización Exitosa',_prima_cob_dev_neta;
end
end procedure;