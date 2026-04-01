-- Procedure Determina las polizas leasing mal creadas

-- Creado    : 24/06/2011 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_par321;

create procedure sp_par321() 
returning char(20),
          char(10),
          char(30),
          char(100),
          char(3),
          char(3),
          char(50),
          char(50);

define _no_poliza		char(10);
define _cod_asegurado	char(10);
define _no_documento	char(20);
define _nombre			char(100);
define _cedula			char(30);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_ramo		char(50);
define _nombre_subra	char(50);

set isolation to dirty read;

create temp table tmp_leasing(
cod_asegurado	char(10)
) with no log;

foreach
 select no_poliza
   into _no_poliza
   from emipomae
  where actualizado  = 1
    and leasing      = 1
--	and no_documento = "0210-10225-20"

	foreach
	 select cod_asegurado
	   into _cod_asegurado
	   from emipouni
	  where no_poliza = _no_poliza

		insert into tmp_leasing values(_cod_asegurado);		

	end foreach

end foreach

foreach
 select cod_asegurado
   into _cod_asegurado
   from tmp_leasing
  group by cod_asegurado

	select nombre,
	       cedula
	  into _nombre,
	       _cedula
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	foreach
	 select no_documento,
	        cod_ramo,
			cod_subramo
	   into _no_documento,
	        _cod_ramo,
			_cod_subramo
	   from emipomae
	  where actualizado    = 1
	    and leasing        = 0
		and estatus_poliza = 1
		and (cod_contratante = _cod_asegurado or
		     cod_pagador     = _cod_asegurado )
   group by 1, 2, 3
   order by 2, 1

		select nombre
		  into _nombre_ramo
		  from prdramo 
		 where cod_ramo = _cod_ramo;

		select nombre
		  into _nombre_subra
		  from prdsubra
		 where cod_ramo    = _cod_ramo
		   and cod_subramo = _cod_subramo;
			
		return _no_documento,
		       _cod_asegurado,
		       _cedula,
			   _nombre,
			   _cod_ramo,
			   _cod_subramo,
			   _nombre_ramo,
			   _nombre_subra
			   with resume;

	end foreach

end foreach

drop table tmp_leasing;

return "0",
       "",
       "",
	   "Proceso Completado",
	   "",
	   "",
	   "",
	   "";

end procedure
