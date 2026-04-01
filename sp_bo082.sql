-- Renovaciones SODA de Octubre anteriores a la implementacion de las renovaciones
-- 
-- Creado     : 17/10/2012 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo082;

create procedure "informix".sp_bo082()
returning char(20),
          date,
          char(30),
          char(1),
          smallint;

define _no_documento	char(20);
define _reemplaza_pol	char(30);
define _no_poliza		char(10);
define _no_poliza2		char(10);
define _estatus_poliza	smallint;
define _nueva_renov		char(1);
define _nueva_renov2	char(1);
define _renovada		smallint;
define _vigencia_inic	date;

foreach
 select no_documento
   into _no_documento
   from deivid_tmp:tmp_soda_no_renov

	let _no_poliza = sp_sis21(_no_documento);

	select estatus_poliza,
	       reemplaza_poliza,
		   nueva_renov,
		   renovada,
		   vigencia_inic
	  into _estatus_poliza,
	       _reemplaza_pol,
		   _nueva_renov,
		   _renovada,
		   _vigencia_inic
	  from emipomae
	 where no_poliza = _no_poliza;

	{
	let _no_poliza2 = sp_sis21(_reemplaza_pol);

	select nueva_renov
	  into _nueva_renov2
	  from emipomae
	 where no_poliza = _no_poliza2;

	if _nueva_renov2 = "R" then
		continue foreach;
	end if

	update emipomae
	   set nueva_renov = "R"
	 where no_poliza   = _no_poliza2;
	}

--	if _renovada = 1 then
--		continue foreach;
--	end if

--	if _estatus_poliza <> 2 then
--		continue foreach;
--	end if

--	if _reemplaza_pol is not null then
--		continue foreach;
--	end if

--	delete from deivid_tmp:tmp_soda_no_renov
--	 where no_documento = _no_documento;

	return _no_documento,
		   _vigencia_inic,	
	       _reemplaza_pol,
		   _nueva_renov,
		   _renovada
	        with resume;

end foreach

return "", "", "", "", 0;

end procedure