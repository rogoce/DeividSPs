-- Cumulo del asegurado ramo de vida individual

-- Modificado: 07/02/2011 - Autor: Armando Moreno Montenegro

--drop procedure sp_sis145;

create procedure "informix".sp_sis145(a_cod_contratante char(10))
returning  dec(16,2);


define _no_poliza		  char(10);
define _suma_cumulo		  dec(16,2);
define _suma     		  dec(16,2);
define _no_documento      char(20);

--SET DEBUG FILE TO "sp_sis145.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _suma        = 0;
let _suma_cumulo = 0;

foreach

	select no_documento
	  into _no_documento
	  from emipomae
	 where cod_contratante = a_cod_contratante
	   and cod_ramo        = '019'
	   and actualizado     = 1
	   and estatus_poliza  = 1
	 group by no_documento

	 let _no_poliza = sp_sis21(_no_documento);

	 select sum(suma_asegurada)
	   into _suma
	   from emipomae
	  where no_poliza = _no_poliza;

	 let _suma_cumulo = _suma_cumulo + _suma;	

end foreach

return _suma_cumulo;

end procedure
