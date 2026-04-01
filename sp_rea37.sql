--------------------------------------------
--Reporte de Verificación de Distribución de Reaseguro de Primas Suscritas
--execute procedure sp_rea37()
--22/07/2016 - Autor: Román Gordón.
--------------------------------------------
drop procedure sp_rea37;
create procedure sp_rea37()
returning	integer			as v_error,
			char(10)		as poliza,
			char(5)			as unidad,
			char(5)			as contrato,
			dec(9,4)		as porc_partic_prima,
			dec(9,4)		as porc_partic_reas,
			varchar(150)	as error_desc;

define _error_desc			varchar(150);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _no_endoso			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _porc_partic_prima	dec(9,4);
define _porc_partic_suma	dec(9,4);
define _porc_partic_reas	dec(9,4);
define _no_cambio			smallint;
define _error_isam			integer;
define _res_notrx			integer;
define _error				integer;
define _res_fechatrx		date;
define _vigencia_inic		date;
define _vigencia_final		date;
define _endoso				char(10);
define _orden				smallint;

--set debug file to 'sp_rea37.trc';
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _no_poliza,'','',0.00,0.00,trim(_error_desc);
end exception

drop table if exists tmp_err_soda;

select e.no_poliza,no_unidad,max(e.no_endoso) as endoso,0 as error
  from emipomae p, endedmae e,endeduni u
 where e.no_poliza = p.no_poliza
   and e.no_poliza = u.no_poliza
   and e.no_endoso = u.no_endoso
   and p.cod_ramo = '020'
   and p.estatus_poliza = 1
   and e.cod_endomov in ('004','011','017')
   and p.actualizado = 1
   and e.actualizado = 1
 group by 1,2,4
 into temp tmp_err_soda;

create index idx_tmp_err_soda on tmp_err_soda(no_poliza,endoso,no_unidad);

foreach
	select no_poliza,
		   endoso,
		   no_unidad
	  into _no_poliza,
		   _no_endoso,
		   _no_unidad
	  from tmp_err_soda
	 order by 1,2

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;

	if _no_cambio is null then
		update tmp_err_soda
		   set error = 1
		 where no_poliza = _no_poliza
		   and endoso = _no_endoso
		   and no_unidad = _no_unidad;

		return 1,_no_poliza,_no_unidad,_cod_contrato, 0.00,0.00,'' with resume;
		continue foreach;
	end if

	foreach
		select cod_contrato,
			   cod_cober_reas,
			   porc_partic_prima
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad

		select porc_partic_prima
		  into _porc_partic_reas
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio = _no_cambio
		   and cod_cober_reas = _cod_cober_reas
		   and cod_contrato = _cod_contrato;

		if _porc_partic_reas is null then
			let _porc_partic_reas = 0.00;
		end if

		if _porc_partic_reas <> _porc_partic_prima then
			update tmp_err_soda
			   set error = 2
			 where no_poliza = _no_poliza
			   and endoso = _no_endoso
			   and no_unidad = _no_unidad;

			return 2, _no_poliza,_no_unidad,_cod_contrato,_porc_partic_prima,_porc_partic_reas,'' with resume;
		end if
	end foreach
end foreach

--Cambio de Emireaco segun registros de emifacon., Armando 22/12/2016
{foreach
	select no_poliza,
		   no_unidad,
		   endoso
	  into _no_poliza,
           _no_unidad,
		   _endoso
      from tmp_err_soda
	where error = 2

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad;	

	delete from emireaco
	where no_poliza = _no_poliza
	  and no_unidad = _no_unidad;
	  
	foreach
		select cod_cober_reas,orden,cod_contrato,porc_partic_suma,porc_partic_prima
		  into _cod_cober_reas,_orden,_cod_contrato,_porc_partic_suma,_porc_partic_prima
		 from emifacon
		where no_poliza = _no_poliza
		  and no_endoso = _endoso
		  and no_unidad = _no_unidad
		  
		insert into emireaco(no_poliza,no_unidad,no_cambio,cod_cober_reas,orden,cod_contrato,porc_partic_suma,porc_partic_prima)
		values(_no_poliza,_no_unidad,_no_cambio,_cod_cober_reas,_orden,_cod_contrato,_porc_partic_suma,_porc_partic_prima);
	end foreach	  
	
	
end foreach}

end

end procedure;