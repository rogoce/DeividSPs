-- Procedimiento que carga los registros iniciales de toda la distribucion de coaseguro
-- para el Cambio de Coaseguro

-- Creado    : 23/10/2007 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/10/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis103;

create procedure sp_sis103(
a_no_poliza	char(10),
a_no_endoso	char(5)
) returning smallint,
            char(50);

define _suma				dec(16,2);
define _prima				dec(16,2);
define _prima_fac			dec(16,2);
define _prima_ret			dec(16,2);
define _suma_fac			dec(16,2);
define _cod_coasegur		char(3);

define _cod_cober_reas		char(3);
define _orden				smallint;
define _cod_contrato		char(5);
define _tipo_contrato		smallint;

define _no_unidad			char(5);
define _no_cambio			smallint;

define _null				char(1);
define _cantidad			smallint;

define _error				smallint;
define _error_isam			smallint;
define _error_desc			char(50);

BEGIN

ON EXCEPTION SET _error, _error_isam, _error_desc 
 	RETURN _error, _error_desc;         
END EXCEPTION           

--set debug file to "sp_sis29.trc";
--trace on;

set isolation to dirty read;

-- Eliminacion de la registros existentes

delete from emifafac
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from emifacon
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

select par_ase_lider
  into _cod_coasegur
  from parparam;

select suma,
       prima
  into _suma,
       _prima
  from endcamco
 where no_poliza    = a_no_poliza
   and no_endoso    = a_no_endoso
   and cod_coasegur = _cod_coasegur;

 select count(*)
   into _cantidad
   from endeduni
  where no_poliza = a_no_poliza
    and no_endoso = a_no_endoso;

let _prima = _prima / _cantidad;
let _suma  = _suma  / _cantidad;
let _null  = null;

foreach
 select no_unidad
   into _no_unidad
   from endeduni
  where no_poliza = a_no_poliza
    and no_endoso = a_no_endoso

	select max(no_cambio)
	  into _no_cambio
	  from emireama
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	insert into emifacon(
	no_poliza,
	no_endoso,
	no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	cod_ruta,
	porc_partic_suma,
	porc_partic_prima,
	suma_asegurada,
	prima,
	ajustar,
	subir_bo
	)
	select
	a_no_poliza,
	a_no_endoso,
	_no_unidad,
	cod_cober_reas,
	orden,
	cod_contrato,
	_null,
	porc_partic_suma,
	porc_partic_prima,
	porc_partic_prima / 100 * _suma,
	porc_partic_prima / 100 * _prima,
	0,
	0
	from emireaco
   where no_poliza = a_no_poliza
     and no_unidad = _no_unidad
     and no_cambio = _no_cambio;
	  	
	let _prima_ret = 0.00;

	foreach
	 select cod_cober_reas,
	        orden,
			cod_contrato,
			suma_asegurada,
			prima
	   into _cod_cober_reas,
	        _orden,
			_cod_contrato,
			_suma_fac,
			_prima_fac
	   from emifacon
	  where no_poliza = a_no_poliza
	    and no_endoso = a_no_endoso
	    and no_unidad = _no_unidad

		select tipo_contrato
		  into _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _tipo_contrato = 3 then

			insert into emifafac(
			no_poliza,
			no_endoso,
			no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			cod_coasegur,
			porc_partic_reas,
			porc_comis_fac,
			porc_impuesto,
			suma_asegurada,
			prima,
			impreso,
			fecha_impresion,
			no_cesion,
			subir_bo
			)
			select
			a_no_poliza,
			a_no_endoso,
			_no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			cod_coasegur,
			porc_partic_reas,
			porc_comis_fac,
			porc_impuesto,
			porc_partic_reas / 100 * _suma_fac,
			porc_partic_reas / 100 * _prima_fac,
			0,
			today,
			_null,
			0
			from emireafa
		   where no_poliza      = a_no_poliza
		     and no_unidad      = _no_unidad
		     and no_cambio      = _no_cambio
		     and cod_cober_reas = _cod_cober_reas
		     and orden          = _orden;

		elif _tipo_contrato = 1 then 

			let _prima_ret = _prima_ret + _prima_fac;

		end if

	end foreach

	update endeduni
	   set prima_suscrita = _prima,
	       prima_retenida = _prima_ret
     where no_poliza      = a_no_poliza
	   and no_endoso      = a_no_endoso
	   and no_unidad      = _no_unidad;

end foreach

select sum(prima_suscrita),
       sum(prima_retenida)
  into _prima,
       _prima_ret
  from endeduni
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

update endedmae
   set prima_suscrita = _prima,
       prima_retenida = _prima_ret
 where no_poliza      = a_no_poliza
   and no_endoso      = a_no_endoso;

end

return 0, "Actualizacion Exitosa";

end procedure;

