-- Numero Interno de Reclamo para Workflow

-- Creado    : 10/03/2004 - Autor: Demetrio Hurtado Almanza 

--drop procedure sp_sis54;

create procedure "informix".sp_sis54()
returning char(20),
          char(10),
          char(30);

define _no_poliza    char(10);
define _cantidad	 integer;
define _error		 integer;
define _porcentaje	 dec(16,2);
define _no_documento char(20);

set isolation to dirty read;

let _error = 0;

foreach 
 select no_poliza,
        no_documento
   into _no_poliza,
        _no_documento
   from emipomae
  where actualizado = 1

	select count(*)
	  into _cantidad
	  from emipoagt
	 where no_poliza = _no_poliza;

	if _cantidad = 0 then

		insert into emipoagt
		values ("00099", _no_poliza, 100, 0, 100);

		return _no_documento,
		       _no_poliza,
			   "No Hay Corredor"
			   with resume;

	end if

	select sum(porc_partic_agt)
	  into _porcentaje
	  from emipoagt
	 where no_poliza = _no_poliza;

	if _porcentaje <> 100 then

		return _no_documento,
		       _no_poliza,
			   "No Suma 100%"
			   with resume;

	end if


end foreach

end procedure