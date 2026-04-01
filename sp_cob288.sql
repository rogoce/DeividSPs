-- Procedimiento que valida la informacion de coaseguro minoritario
 
-- Creado     :	22/08/2011 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob288;		

create procedure sp_cob288()
returning char(10),
          char(20),
          char(50),
          dec(16,2);

define _no_poliza		char(10);
define _no_documento	char(20);
define _saldo			dec(16,2);

define _cantidad		smallint;
define _cantidad_coas	smallint;
define _cod_coasegur	char(3);
define _no_poliza_2		char(10);


set isolation to dirty read;

foreach
 select no_documento,
	     no_poliza
   into	_no_documento,
		_no_poliza
   from emipomae
  where actualizado  = 1
    and cod_tipoprod = "002"  
--  group by no_documento

--	let _no_poliza = sp_sis21(_no_documento);

	select count(*)
	  into _cantidad
	  from emicoami
	 where no_poliza = _no_poliza;

	{
	if _cantidad = 1 then

		select cod_coasegur
		  into _cod_coasegur
		  from emicoami
		 where no_poliza = _no_poliza;

		foreach
		 select	no_poliza
		   into _no_poliza_2
		   from emipomae
		  where no_documento = _no_documento
		    and no_poliza    <> _no_poliza
		    and actualizado  = 1
		    
			select count(*)
			  into _cantidad_coas
			  from emicoami
			 where no_poliza = _no_poliza_2;

			if _cantidad_coas = 0 then

				insert into emicoami
				values (_no_poliza_2, _cod_coasegur, 1);

			end if

		end foreach		     

	end if
	}

	select saldo
	  into _saldo
	  from cobmoros
	 where no_documento = _no_documento;

	if _cantidad = 0 then

		return _no_poliza,
		       _no_documento,
			   "No Tiene Companias",
			   _saldo
			   with resume;

	end if

end foreach

return "0",
       "0",
	   "Proceso Completado",
	   0;

end procedure