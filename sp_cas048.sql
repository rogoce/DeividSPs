-- Call Center Polizas vs Call Center y Call Center Vs Polizas
-- 
-- Creado    : 25/07/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 25/07/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas048;

create procedure sp_cas048()
returning char(20),
          smallint,
          char(1);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cobra_poliza	char(1);
define _cantidad		smallint;
define _estatus_poliza	char(1);
define _cant_pro		smallint;
define _cod_formapag    char(3);

set isolation to dirty read;
 
{
foreach
 select no_documento
   into _no_documento
   from caspoliza

	let _no_poliza = sp_sis21(_no_documento);

	select cobra_poliza,
	       estatus_poliza
	  into _cobra_poliza,
		   _estatus_poliza	
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cobra_poliza = "E" then
		continue foreach;
	end if

	update emipomae
	   set cobra_poliza = "E" 
	 where no_poliza    = _no_poliza;


	return _no_documento,
	       1,
		   _estatus_poliza
	       with resume;
	       	
end foreach
}

let _cant_pro = 0;

--{
foreach
 select no_documento
   into _no_documento
   from emipomae
  where actualizado    = 1
	and cobra_poliza   = "E"
--	and estatus_poliza = 1
	and cod_tipoprod   not in ("002", "004")
  group by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	select cobra_poliza,
		   estatus_poliza,
		   cod_formapag
	  into _cobra_poliza,
		   _estatus_poliza,
		   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cobra_poliza <> "E" then
		continue foreach;
	end if

	if _estatus_poliza <> 2 then
		continue foreach;
	end if

	select count(*)
	  into _cantidad
	  from caspoliza
	 where no_documento = _no_documento;

	if _cantidad <> 0 then
		continue foreach;
	end if

	let _cant_pro = _cant_pro + 1;

	if _cant_pro > 1000 then
		exit foreach;
	end if

{
	if _cod_formapag = "006" then

		update emipomae
		   set cobra_poliza = "C",
		       cod_formapag = "008"
		 where no_poliza    = _no_poliza;

	else

		update emipomae
		   set cobra_poliza = "C"
		 where no_poliza    = _no_poliza;

	end if
--}

	return _no_documento,
	       2,
		   _estatus_poliza
	       with resume;
	       	
end foreach
--}

end procedure