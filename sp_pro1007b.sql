-- Endoso especial, sacar los dependientes

-- Creado    : 13/01/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro1007b;

CREATE PROCEDURE "informix".sp_pro1007b(a_no_poliza char(10))
returning varchar(100),varchar(100),date;

define _n_aseg		  varchar(100);
define _cod_asegurado char(10);
define _cod_depen	  char(10);
define _no_unidad	  char(5);
define _n_proc        varchar(100);
define _cod_proc      char(5);
define _fecha         date;
define _cod_pre_depen char(10);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro1007b.trc";
--trace on;

BEGIN


let _n_proc = "";

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

	select cod_procedimiento,
		   fecha
	  into _cod_proc,
		   _fecha
	  from emipreas
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad


	select nombre
	  into _n_proc
	  from emiproce
	 where cod_procedimiento = _cod_proc;


	return _n_aseg,_n_proc,_fecha with resume;

end foreach

foreach

	select cod_procedimiento,
		   fecha,
		   cod_cliente
	  into _cod_proc,
		   _fecha,
		   _cod_pre_depen
	  from emiprede
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad


	select nombre
	  into _n_proc
	  from emiproce
	 where cod_procedimiento = _cod_proc;

	select nombre
	  into _n_aseg
	  from cliclien
	 where cod_cliente = _cod_pre_depen;


	return _n_aseg,_n_proc,_fecha with resume;

end foreach

END
END PROCEDURE
