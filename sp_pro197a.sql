-- Retorna Maximo Vitalicio

-- Creado    : 29/10/2010 - Autor: Armando Moreno
-- Modificado: 29/10/2010 - Autor: Armando Moreno


DROP PROCEDURE sp_pro197a;

CREATE PROCEDURE sp_pro197a(a_cod_producto char(5))
RETURNING DEC(16,2),char(3);


DEFINE _maximo_vitalicio dec(16,2);
DEFINE _cod_subramo      char(3);

SET ISOLATION TO DIRTY READ;

let _maximo_vitalicio = 0.00;
let _cod_subramo      = null;

select cod_subramo
  into _cod_subramo
  from prdprod
 where cod_producto = a_cod_producto;

foreach

	select maximo_vitalicio
	  into _maximo_vitalicio
	  from prdbemax
	 where cod_producto = a_cod_producto

	exit foreach;

end foreach

if _maximo_vitalicio is null then
	let _maximo_vitalicio = 0.00;
end if
	
RETURN _maximo_vitalicio,_cod_subramo;
	
END PROCEDURE;


