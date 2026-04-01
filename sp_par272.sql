-- Procedure que arregla los contratos de reaseguro mal capturados

drop procedure sp_par272;

create procedure sp_par272()
returning char(10),
          char(10),
		  char(5),
		  char(5),
		  char(5),
		  char(50),
		  char(5),
		  char(50);

define _no_factura		char(10);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _cod_contrato	char(5);
define _cod_contrato2	char(5);
define _nombre			char(50);
define _nombre2			char(50);
define _tipo_contrato	smallint;
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

--begin work;

begin
on exception set _error, _error_isam, _error_desc
--	rollback work;
	return _error,
	       _error_isam,
		   "",
		   "",
		   "",
		   _error_desc,
		   "",
		   ""
		   with resume;
end exception

FOREACH 
 SELECT no_poliza,
        no_endoso,
		no_factura
   INTO _no_poliza,
        _no_endoso,
		_no_factura
   FROM endedmae
  WHERE actualizado = 1
	and no_factura  in ("01-616542", "01-616560", "01-615416", "01-616376", "02-30417")

	call sp_par59(_no_poliza, _no_endoso) returning _error, _error_desc;

	return _no_factura,
	       _error,
		   "",
		   "",
		   "",
		   _error_desc,
		   "",
		   ""
		   with resume;

	{
	foreach
	 select	no_unidad,
	        cod_contrato
	   into	_no_unidad,
	        _cod_contrato
	   from emifacon
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		select nombre,
		       tipo_contrato
		  into _nombre,
		       _tipo_contrato
		  from reacomae
		 where cod_contrato = _cod_contrato;

		select count(*)
		  into _cantidad
		  from reacomae
		 where tipo_contrato = _tipo_contrato
		   and serie         = 2008
		   and fronting      = 0;

		if _cantidad = 1 then

			select nombre,
			       cod_contrato
			  into _nombre2,
			       _cod_contrato2
			  from reacomae
			 where tipo_contrato = _tipo_contrato
			   and serie         = 2008
			   and fronting      = 0;

		else

			let _cod_contrato2 = "";
			let _nombre2       = "";

		end if

		update emifacon
		   set cod_contrato = _cod_contrato2
		 where no_poliza    = _no_poliza
		   and no_endoso	= _no_endoso
		   and cod_contrato = _cod_contrato;

		update emifafac
		   set cod_contrato = _cod_contrato2
		 where no_poliza    = _no_poliza
		   and no_endoso	= _no_endoso
		   and cod_contrato = _cod_contrato;

		update emireaco
		   set cod_contrato = _cod_contrato2
		 where no_poliza    = _no_poliza
		   and cod_contrato = _cod_contrato;
		
		update emireafa
		   set cod_contrato = _cod_contrato2
		 where no_poliza    = _no_poliza
		   and cod_contrato = _cod_contrato;

		return _no_factura,
		       _no_poliza,
			   _no_endoso,
			   _no_unidad,
			   _cod_contrato,
			   _nombre,
			   _cod_contrato2,
			   _nombre2
			   with resume;

	end foreach
	}

end foreach

end 

--rollback work;
--commit work;

end procedure