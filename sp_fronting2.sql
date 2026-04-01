-- Procedimiento que carga la tabla para el presupuesto de ventas 2010

-- Creado    : 04/06/2010 - Autor: Itzis Nunez 

--drop procedure sp_fronting2;

create procedure "informix".sp_fronting2()
returning integer,
          char(50);

define _no_unidad	char(5);

define _cantidad smallint;
define _fronting smallint;
define _no_documento char(20);
define _no_poliza    char(10);

define _error		 integer;
define _error_isam	 integer;
define _error_desc	 char(50);
define _cod_contrato char(5);
define _serie        integer;
define _cod_contrato_nvo char(5);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _fronting = 0;


foreach

 select no_poliza,
		contrato_vjo,
        contrato_nvo
   into _no_poliza,
		_cod_contrato,
        _cod_contrato_nvo
   from b
  where contrato_vjo = contrato_nvo

 select fronting
   into _fronting
   from emipomae
  where no_poliza = _no_poliza;

	return _fronting,_no_poliza with resume;

end foreach

end 

--return 0, "Actualizacion Exitosa";

end procedure
