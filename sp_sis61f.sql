-- Modificado Armando Moreno	21/02/2005

--Procedimiento para determinar anos uso para tarifas deacuerdo al año del vehiculo

--drop procedure sp_sis61e;

create procedure "informix".sp_sis61e(a_no_motor char(30))
returning integer;

DEFINE _error     	    SMALLINT; 
define _ano_auto		smallint;
define _resultado		smallint;
define _ano_actual		smallint;

let _ano_actual = year(current);

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION           

Select ano_auto
  Into _ano_auto
  From emivehic
 Where no_motor = a_no_motor;

let _resultado = _ano_actual - _ano_auto;

let _resultado = _resultado + 1;

end
return _resultado;
end procedure