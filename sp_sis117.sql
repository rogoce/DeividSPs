-- Creado    : 28/12/2010 - Autor: Armando Moreno.

--DROP PROCEDURE sp_sis117;

CREATE PROCEDURE "informix".sp_sis117(a_no_poliza char(10))
returning char(5);


define _cod_producto	char(5);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro202a.trc";
--trace on;

let	_cod_producto = "";


BEGIN

foreach

	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = a_no_poliza

    
	if _cod_producto = '00318' then
		exit foreach;
	end if

end foreach

if _cod_producto is null then
	let _cod_producto = "";
end if

return _cod_producto;

END
END PROCEDURE
