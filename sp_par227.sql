-- Informacion para SEMM

-- Creado    : 1O/07/2006 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_par227;

create procedure "informix".sp_par227()
returning integer,
          char(50);

define _no_documento	char(20);
define _no_poliza		char(10);

define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _estatus_poliza	smallint;

define _cod_asegurado	char(10);
define _nombre			char(100);
define _cedula			char(30);

define _cantidad		integer;

create temp table tmp_semm(
cedula			char(30),
nombre			char(100),
no_documento	char(20),
estatus			char(1)
) with no log;

set isolation to dirty read;

let _cantidad = 0;

foreach
 select no_documento
   into _no_documento
   from emipomae
  where actualizado = 1
    and	cod_ramo    in ("003", "001")
--    and	cod_ramo    in ("003", "018", "016", "019", "004", "001", "014")
  group by no_documento

	let _no_poliza = sp_sis21(_no_documento);
	
	select cod_ramo,
	       cod_subramo,
		   estatus_poliza
	  into _cod_ramo,
	       _cod_subramo,
		   _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus_poliza <> 1 then 
		continue foreach;
	end if

	if _cod_ramo = "003" then
		
		if _cod_subramo <> "001" then
			continue foreach;
		end if

	elif _cod_ramo = "001" then

		if _cod_subramo <> "001" then
			continue foreach;
		end if

	end if

	let _cantidad = _cantidad + 1;

	foreach
	 select	cod_asegurado
	   into _cod_asegurado
	   from emipouni
	  where no_poliza = _no_poliza
	
		select nombre,
		       cedula
		  into _nombre,
		       _cedula
		  from cliclien
		 where cod_cliente = _cod_asegurado;

		insert into tmp_semm
		values (
		_cedula,
		_nombre,
		_no_documento,
		"N"
		);	

	end foreach

end foreach

return _cantidad, " Registros Procesados ...";

end procedure							
