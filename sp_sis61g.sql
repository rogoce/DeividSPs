-- Modificado Armando Moreno	21/02/2005

--Procedimiento para determinar anos uso para tarifas deacuerdo al año del vehiculo

drop procedure sp_sis61g;

create procedure "informix".sp_sis61g(a_no_motor char(30), a_poliza CHAR(10))
returning integer;

DEFINE _error     	    SMALLINT; 
define _ano_auto		smallint;
define _resultado		smallint;
define _ano_actual		smallint;
define _nuevo			smallint;

let _ano_actual = year(current);

--let _ano_actual = 2021;

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION           

{Select year(vigencia_inic) 
  Into _ano_actual
  From emipomae
 Where no_poliza = a_poliza;}

Select ano_auto,
       nuevo
  Into _ano_auto,
       _nuevo
  From emivehic
 Where no_motor = a_no_motor;

let _resultado = _ano_actual - _ano_auto;

if _resultado <= 0 then
	let _resultado = 0;
end if
--if _nuevo = 0 then		--El auto no es nuevo
  let _resultado = _resultado + 1;
--end if  

end
return _resultado;
end procedure