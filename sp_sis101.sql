-- Procedimiento que carga los registros iniciales de toda la distribucion de coaseguro
-- para el Cambio de Coaseguro

-- Creado    : 23/10/2007 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/10/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis101;

create procedure sp_sis101(
a_no_poliza	char(10),
a_no_endoso	char(5)
) returning smallint,
            char(50);

define _suma				dec(16,2);
define _prima				dec(16,2);
define _cod_coasegur		char(3);
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

delete from endmocoa
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;


foreach
 select cod_coasegur,
        suma,
		prima
   into _cod_coasegur,
        _suma,
		_prima
   from endcoama
  where no_poliza = a_no_poliza

	select count(*)
	  into _cantidad
	  from endmocoa
	 where no_poliza    = a_no_poliza
	   and no_endoso    = a_no_endoso
	   and cod_coasegur = _cod_coasegur;

	if _cantidad = 0 then

		insert into endmocoa(
		no_poliza,
		no_endoso,
		cod_coasegur,
		porc_partic_coas,
		suma,
		prima,
		suma_total,
		prima_total
		)
		values (
		a_no_poliza,
		a_no_endoso,
		_cod_coasegur,
		0.0000,
		_suma,
		_prima,
		0.00,
		0.00
		);

	else

		update endmocoa
		   set suma         = suma  + _suma,
		       prima        = prima + _prima
		 where no_poliza    = a_no_poliza
		   and no_endoso    = a_no_endoso
		   and cod_coasegur = _cod_coasegur;

	end if
	
end foreach

select sum(suma),
       sum(prima)
  into _suma,
       _prima
  from endmocoa
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

update endmocoa
   set suma_total  = _suma,
       prima_total = _prima
 where no_poliza   = a_no_poliza
   and no_endoso   = a_no_endoso;


end

return 0, "Actualizacion Exitosa";

end procedure;

