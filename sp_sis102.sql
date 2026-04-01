-- Procedimiento que Verifica que exista el registro de coaseguro
-- para el Cambio de Coaseguro

-- Creado    : 23/10/2007 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/10/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis102;

create procedure sp_sis102(
a_no_poliza		char(10),
a_no_endoso		char(5),
a_cod_coasegur	char(3)
) returning smallint,
            char(50);

define _suma				dec(16,2);
define _prima				dec(16,2);
define _cantidad			smallint;
define _coas_lider			char(3);

define _error				smallint;
define _error_isam			smallint;
define _error_desc			char(50);

BEGIN

ON EXCEPTION SET _error, _error_isam, _error_desc 
 	RETURN _error, _error_desc;         
END EXCEPTION           

set isolation to dirty read;

select count(*)
  into _cantidad
  from endmocoa
 where no_poliza    = a_no_poliza
   and no_endoso    = a_no_endoso
   and cod_coasegur = a_cod_coasegur;

if _cantidad = 0 then

	select par_ase_lider
	  into _coas_lider
	  from parparam;

	select suma_total,
	       prima_total
	  into _suma,
	       _prima
	  from endmocoa
	 where cod_coasegur = _coas_lider;

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
	a_cod_coasegur,
	0.0000,
	0.00,
	0.00,
	_suma,
	_prima
	);

end if
	
end

return 0, "Actualizacion Exitosa";

end procedure;

