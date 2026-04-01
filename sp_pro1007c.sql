-- Endoso especial extra prima, sacar los dependientes con recargo

-- Creado    : 04/10/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro1007c;

CREATE PROCEDURE "informix".sp_pro1007c(a_no_poliza char(10))
returning varchar(100),varchar(10),decimal(5,2);

define _n_aseg		  varchar(100);
define _cod_asegurado char(10);
define _no_unidad	  char(5);
define _n_proc        varchar(100);
define _porc_recargo  decimal(5,2);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro1007c.trc";
--trace on;

BEGIN


let _n_proc = "";
let _porc_recargo = 0;

foreach
	select no_unidad,
	       cod_asegurado
	  into _no_unidad,
	       _cod_asegurado
	  from emipouni
	 where no_poliza = a_no_poliza

	 exit foreach;

end foreach

let _n_aseg = "";

select nombre
  into _n_aseg
  from cliclien
 where cod_cliente = _cod_asegurado;

foreach

	select porc_recargo
	  into _porc_recargo
	  from emiunire
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad


	return _n_aseg,'RECARGO',_porc_recargo with resume;

end foreach

let _cod_asegurado = "";

foreach

	select por_recargo,
	       cod_cliente
	  into _porc_recargo,
	       _cod_asegurado
	  from emiderec
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad


	select nombre
	  into _n_aseg
	  from cliclien
	 where cod_cliente = _cod_asegurado;


	return _n_aseg,'RECARGO',_porc_recargo with resume;

end foreach

END
END PROCEDURE
