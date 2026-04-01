-- Procedimiento que Determina el Reaseguro para un Cheque de Devolución de Prima
-- 
-- Creado    : 06/09/2013 - Autor: Román Gordon


drop procedure sp_sis188bk;

create procedure "informix".sp_sis188bk(a_no_poliza char(10))--, a_no_unidad char(5))
returning integer, char(250);

define _mensaje				char(250);
define _no_documento		char(21);
define _cod_ramo			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _proporcion			dec(9,6);
define _prima_total			dec(16,9);
define _prima_cober_reas	dec(16,9);
define _porc_cober_reas		dec(9,6);
define _contador_ret		smallint;
define _ramo_sis			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _flag                integer;
define _no_reclamo          char(10);
define _cod_cobertura       char(5);

set isolation to dirty read;

--set debug file to "sp_sis188.trc";
--trace on;

begin

on exception set _error,_error_isam,_mensaje
	--rollback work;
 	return _error,_mensaje;
end exception

create temp table tmp_dist_rea(
	no_poliza		char(10),
	cod_cober_reas	char(3)) with no log;

-- Lectura de la Distribución de Reaseguro de la Póliza

select no_documento,
	   cod_ramo
  into _no_documento,
	   _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;
 
let _flag = 0;
let _prima_total = 0;

if _ramo_sis = 5 then
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = a_no_poliza
--		   and activo = 1

		select sum(prima_neta)
		  into _prima_total
		  from emipocob
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad;

		if _prima_total <> 0 then
			let _flag = 1;
			exit foreach;
		end if

	end foreach

else
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = a_no_poliza

		select sum(prima_neta)
		  into _prima_total
		  from emipocob
		 where no_poliza = a_no_poliza
		   and no_unidad = _no_unidad;

		if _prima_total <> 0 then
			let _flag = 1;
			exit foreach;
		end if

	end foreach
end if

let _cod_cober_reas = null;
   
foreach
	select prdcober.cod_cober_reas,
		   sum(emipocob.prima_neta)
	  into _cod_cober_reas,
		   _prima_cober_reas
	  from emipocob, prdcober  
	 where emipocob.no_poliza = a_no_poliza
	   and emipocob.no_unidad = _no_unidad
	   and prdcober.cod_cobertura = emipocob.cod_cobertura
	 group by prdcober.cod_cober_reas
	
	let _proporcion = 0.00;
	
	insert into tmp_dist_rea(
			no_poliza,
			cod_cober_reas)
	values	(a_no_poliza,
			_cod_cober_reas);
end foreach

if _cod_cober_reas is null then

	foreach
		select prdcober.cod_cober_reas,
			   sum(endedcob.prima_neta)
		  into _cod_cober_reas,
			   _prima_cober_reas
		  from endedcob, prdcober  
		 where endedcob.no_poliza = a_no_poliza
		   and endedcob.no_endoso = '00000'
		   and endedcob.no_unidad = _no_unidad
		   and prdcober.cod_cobertura = endedcob.cod_cobertura
		 group by prdcober.cod_cober_reas
		
		let _proporcion = 0.00;
		
		insert into tmp_dist_rea(
				no_poliza,
				cod_cober_reas)
		values	(a_no_poliza,
				_cod_cober_reas);
	end foreach

  	if _cod_cober_reas is null then
		foreach
			select no_reclamo
			  into _no_reclamo
			  from recrcmae
			 where no_poliza = a_no_poliza

            foreach
				select cod_cobertura
				  into _cod_cobertura
				  from recrccob
				 where no_reclamo = _no_reclamo

				exit foreach;
			end foreach
		exit foreach;
		end foreach

		foreach
		select prdcober.cod_cober_reas
		  into _cod_cober_reas
		  from recrccob, prdcober
		 where recrccob.no_reclamo = _no_reclamo
		   and prdcober.cod_cobertura = recrccob.cod_cobertura
		 group by prdcober.cod_cober_reas


		insert into tmp_dist_rea(
				no_poliza,
				cod_cober_reas)
		values	(a_no_poliza,
				_cod_cober_reas);

		end foreach
	end if

end if

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;

end
end procedure;
