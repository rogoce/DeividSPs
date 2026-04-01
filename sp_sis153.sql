-- Modificando el reaseguro de las polizas con contrato allied, solamente debe ser para este contrato

-- Creado    : 25/04/2011 - Autor: Amado Perez M. 

drop procedure sp_sis153;

create procedure "informix".sp_sis153(a_no_poliza char(10), a_no_unidad char(5), a_cod_contrato char(5))
returning integer, char(50);

define _no_cambio      smallint;
define _no_reclamo     char(10);
define _error          integer;
define _error_isam     integer;
define _error_desc     char(50);
define _no_cambio2     smallint;
define _orden          smallint;
define _cod_ramo       char(3);
define _cod_cober_reas char(3);
define _cod_contrato   char(5);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _no_cambio2 = 0;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

{if _cod_ramo = '002' then
	let _cod_cober_reas = '002';
else
	let _cod_cober_reas = '025';
end if}

--if _cod_ramo = '016' then
	let _cod_cober_reas = '015';
--end if


select max(no_cambio)
  into _no_cambio
  from emireama
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

if _no_cambio is null then
	let _no_cambio = 0;
end if

let _no_cambio2 = _no_cambio + 1;

insert into emireama (
     no_poliza,
	 no_unidad,
	 no_cambio,
	 cod_cober_reas,
	 vigencia_inic,
	 vigencia_final
	) select no_poliza,
			 no_unidad,
			 _no_cambio + 1,
			 cod_cober_reas,
			 vigencia_inic,
			 vigencia_final
	    from emireama
	   where no_poliza = a_no_poliza
	     and no_unidad = a_no_unidad
	     and no_cambio = _no_cambio
		 and cod_cober_reas = _cod_cober_reas;

update emireama
   set vigencia_final = vigencia_inic
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad
   and no_cambio = _no_cambio;

insert into	emireaco (
     no_poliza,
	 no_unidad,
	 no_cambio,
	 cod_cober_reas,
	 orden,
	 cod_contrato,
	 porc_partic_suma,
	 porc_partic_prima
	) select no_poliza,
			 no_unidad,
			 _no_cambio + 1,
			 cod_cober_reas,
			 orden,
			 cod_contrato,
			 100,
			 100
		from emireaco
	   where no_poliza = a_no_poliza
		 and no_unidad = a_no_unidad
		 and no_cambio = _no_cambio
		 and cod_contrato <> a_cod_contrato
		 and porc_partic_suma <> 0
		 and porc_partic_prima <> 0
		 and cod_cober_reas = _cod_cober_reas;


{foreach	  
	select no_reclamo
      into _no_reclamo
	  from recrcmae
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad

    delete from recreafa where no_reclamo = _no_reclamo;
    delete from recreaco where no_reclamo = _no_reclamo;

	let _orden = 1;

    foreach
		select cod_contrato
		  into _cod_contrato
		  from emireaco
		 where no_poliza = a_no_poliza
		   and no_unidad = a_no_unidad
		   and no_cambio = _no_cambio2

	    insert into recreaco (
		     no_reclamo,
			 orden,
			 cod_contrato,
			 porc_partic_suma,
			 porc_partic_prima,
			 subir_bo
			) 
		values (
		     _no_reclamo,
		     _orden,
		     _cod_contrato,
		     100,	
			 100,
			 1
			);

		let _orden = _orden + 1;
	end foreach

end foreach	}
end
return 0, "Actualizacion Exitosa"; 
end procedure