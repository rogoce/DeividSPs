-- Modificando el reaseguro de las polizas con contrato allied, solamente debe ser para este contrato

-- Creado    : 25/04/2011 - Autor: Amado Perez M. 

drop procedure sp_sis153a;

create procedure "informix".sp_sis153a(a_no_poliza char(10))
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
define _no_unidad      char(5);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception


foreach

	select no_unidad
	  into _no_unidad
	  from emipouni
	 where no_poliza = a_no_poliza
	   and no_unidad between '00013' and '00018'


	insert into emireama (
     no_poliza,
	 no_unidad,
	 no_cambio,
	 cod_cober_reas,
	 vigencia_inic,
	 vigencia_final)
	 values
	 (a_no_poliza,
	  _no_unidad,
	  0,
	  '019',
	  '01/03/2012',
	  '01/03/2013'
	 );

	 insert into emireaco (
     no_poliza,
	 no_unidad,
	 no_cambio,
	 cod_cober_reas,
	 orden,
	 cod_contrato,
	 porc_partic_suma,
	 porc_partic_prima)
	 values
	 (a_no_poliza,
	  _no_unidad,
	  0,
	  '019',
	  1,
	  '00599',
	  100,
	  100
	 );

end foreach

end
return 0, "Actualizacion Exitosa"; 
end procedure