-- Procedimiento que verifica todos los asegurados y contratantes en leasing

-- Creado    : 07/12/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro509;

create procedure sp_pro509()
returning char(10),
          char(20),
          char(10),
		  char(30),
          char(100);

define _cod_contratante	char(10);
define _cod_pagador		char(10);
define _cod_asegurado	char(10);

define _tipo			char(20);
define _no_poliza		char(10);
define _nombre			char(100);
define _cedula			char(30);

create temp table tmp_leasing(
tipo		char(20),
cod_cliente	char(10),
poliza		char(10)
) with no log;

foreach
 select cod_contratante,
        cod_pagador,
		no_poliza
   into _cod_contratante,
        _cod_pagador,
		_no_poliza
   from emipomae
  where actualizado = 1
    and leasing     = 1

	let _tipo = "Cliente";

	insert into tmp_leasing
	values (_tipo, _cod_contratante, _cod_contratante);

	insert into tmp_leasing
	values (_tipo, _cod_pagador, _cod_contratante);

	let _tipo = "Leasing";

	foreach
	 select cod_asegurado
	   into _cod_asegurado
	   from emipouni
	  where no_poliza = _no_poliza

		insert into tmp_leasing
		values (_tipo, _cod_asegurado, _cod_contratante);

	end foreach

end foreach

foreach
 select poliza,
        tipo,
       	cod_cliente
   into _no_poliza,
        _tipo,
		_cod_asegurado
   from tmp_leasing
  group by 1, 2, 3
  order by 1, 2, 3

	select nombre,
	       cedula
	  into _nombre,
	       _cedula
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	return _no_poliza,
	       _tipo,
	       _cod_asegurado,
		   _nombre,
		   _cedula
		   with resume;

end foreach

drop table tmp_leasing;

end procedure