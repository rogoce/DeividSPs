-- Procedimiento que Genera la Prima cobrada devengada neta para un rango de periodos
-- Creado: 03/01/2018 - Autor: Román Gordón
--execute procedure sp_dev06c('001','2017-01','2017-12')


drop procedure sp_dev07;
create procedure sp_dev07()
returning	char(5)		as cod_agente,
			varchar(50)	as agente,
			char(20) as no_documento,
			dec(16,2) as prima_dev_2018,
			dec(16,2) as prima_dev_2017,
			dec(16,2) as diferencia;

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

define _pridev2018          dec(16,2);
define _pridev2017          dec(16,2);
define _agente              varchar(50);

set isolation to dirty read;

--set debug file to 'sp_dev06e.trc';
--trace on;

create temp table tmp_cobpridev(
  cod_agente char(5),
  anio char(4),
  no_documento char(20),
  pridev2018 dec(16,2),
  pridev2017 dec(16,2))  WITH NO LOG;
  

{begin
on exception set _error,_error_isam,_mensaje
	let _mensaje = _mensaje || trim(_no_documento);
	return _error,_mensaje;
end exception
}
foreach with hold
	select distinct no_documento,
	       cod_agente,
		   anio,
		   prima_cob_dev_neta
	  into _no_documento,
	       _cod_agente,
		   _anio,
		   _prima_cob_dev_neta
	  from deivid_bo:cobpridev

	--********  Unificacion de Agente *******
	call sp_che168(_cod_agente) returning _error,_cod_agente;	
	
	let _pridev2018 = 0.00;
	let _pridev2017 = 0.00;
	
	if _anio = '2017' then
		let _pridev2017 = _prima_cob_dev_neta;
	end if
	
	if _anio = '2018' then
		let _pridev2018 = _prima_cob_dev_neta;
	end if
			
	insert into tmp_cobpridev
	values (_cod_agente, 
	        _anio,
			_no_documento,
			_pridev2018,
			_pridev2017
			);
	  
end foreach

foreach with hold
	select cod_agente,
	       no_documento,
	       sum(pridev2017),
	       sum(pridev2018)
	  into _cod_agente,
	       _no_documento,
		   _pridev2017,
		   _pridev2018
	  from tmp_cobpridev
	 group by cod_agente, no_documento
	 
	 select nombre 
	   into _agente
	   from agtagent
	  where cod_agente = _cod_agente;
	  
	  return _cod_agente,
	         _agente,
			 _no_documento,
			 _pridev2018,
			 _pridev2017,
			 _pridev2018 - _pridev2017 with resume;
		   
end foreach

DROP TABLE tmp_cobpridev;
--return 0,'Actualización Exitosa';
--end
end procedure;