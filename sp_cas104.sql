-- Procedimiento que trae los corredores de la poliza seleccionada.

-- Creado    : 01/09/2010- Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_temp;

create procedure sp_cas104(a_no_poliza  CHAR(10))
returning char(20),
          char(5),      --no_unidad
       	  char(10),     --cod_cliente
       	  varchar(50),  --parentesco
          varchar(100), --nombre
          smallint;     --activo

define _no_poliza			char(10);
define _no_unidad			char(5);
define _cod_cliente			char(10);
define _cod_parentesco		char(3);
define _nombre_dependiente	varchar(100);
define _activo				smallint;
define _parentesco			varchar(50);

set isolation to dirty read;

foreach
	select	cod_cliente,
	    	no_unidad,
	    	cod_parentesco,
	    	activo
	  into	_cod_cliente,
	   		_no_unidad,
	   		_cod_parentesco,
	   		_activo
	   from emidepen
	  where	no_poliza = a_no_poliza

	select nombre
	  into _nombre_dependiente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select nombre
	  into _parentesco
	  from emiparen
	 where cod_parentesco=_cod_parentesco;




	return _no_poliza,
           _no_unidad,
           _cod_cliente,
           _parentesco,
           _nombre_dependiente,
           _activo
		   with resume;

end foreach
end procedure
