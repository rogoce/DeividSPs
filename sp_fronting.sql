-- Procedimiento que carga la tabla para el presupuesto de ventas 2010

-- Creado    : 04/06/2010 - Autor: Itzis Nunez 

drop procedure sp_fronting;

create procedure "informix".sp_fronting()
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

{foreach

 select no_documento
   into _no_documento
   from b

 let _no_poliza = sp_sis21(_no_documento);

 select count(*)
   into _cantidad
   from emipouni
  where no_poliza = _no_poliza;

 if _cantidad = 1 then

	 select no_unidad
	   into _no_unidad
	   from emipouni
	  where no_poliza = _no_poliza;
 else
	continue foreach;
	
 end if

	select count(*)
	  into _cantidad
	  from emifacon f, reacomae c
	 where f.no_poliza         = _no_poliza
	   and f.no_endoso         = '00000'
	   and f.no_unidad         = _no_unidad
	   and f.cod_contrato      = c.cod_contrato
	   and c.tipo_contrato     = 3
	   and f.porc_partic_prima <> 0;

	if _cantidad > 0 then

	   foreach

		select f.cod_contrato,
		       c.serie
		  into _cod_contrato,
		       _serie
		  from emifacon f, reacomae c
		 where f.no_poliza         = _no_poliza
		   and f.no_endoso         = '00000'
		   and f.no_unidad         = _no_unidad
		   and f.cod_contrato      = c.cod_contrato
		   and c.tipo_contrato     = 3
		   and f.porc_partic_prima <> 0

	   	exit foreach;
	   end foreach

	   foreach

		select cod_contrato
		  into _cod_contrato_nvo
		  from reacomae
		 where fronting = 1
  		   and tipo_contrato = 3
		   and serie         = _serie

		exit foreach;
	   end foreach

		 update b
		    set contrato_vjo = _cod_contrato,
			    contrato_nvo = _cod_contrato_nvo,
				no_poliza    = _no_poliza
		  where no_documento = _no_documento;

	 end if

end foreach}

foreach

 select no_poliza,
		contrato_vjo,
        contrato_nvo
   into _no_poliza,
		_cod_contrato,
        _cod_contrato_nvo
   from b
  where contrato_vjo <> contrato_nvo
    and cambiado     = 0

 select no_unidad
   into _no_unidad
   from emipouni
  where no_poliza = _no_poliza;

 select count(*)
   into _cantidad
   from emifacon
  where no_poliza = _no_poliza
    and no_endoso = '00000'
	and no_unidad = _no_unidad;

 if _cantidad = 1 then
	
	select count(*)
	  into _cantidad
	  from emifafac
	 where no_poliza    = _no_poliza
       and no_endoso    = '00000'
	   and no_unidad    = _no_unidad
	   and cod_contrato = _cod_contrato;

	 if _cantidad = 1 then

		update emifacon
		   set cod_contrato = _cod_contrato_nvo
		 where no_poliza    = _no_poliza
	       and no_endoso    = '00000'
		   and no_unidad    = _no_unidad;

		update emifafac
		   set cod_contrato = _cod_contrato_nvo
		 where no_poliza    = _no_poliza
	       and no_endoso    = '00000'
		   and no_unidad    = _no_unidad
		   and cod_contrato = _cod_contrato;

		update emipomae
		   set fronting = 1
		 where no_poliza = _no_poliza;

		update b
		   set cambiado = 1
		 where no_poliza = _no_poliza;

	 end if

 end if

end foreach

end 

return 0, "Actualizacion Exitosa";

end procedure
