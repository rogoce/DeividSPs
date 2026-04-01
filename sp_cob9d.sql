-- Procedimiento para verificar si la poliza es del producto tcr 10602
-- Creado: 04/09/2024	- Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob9d;
create procedure sp_cob9d(a_no_poliza char(10), a_perido_expira char(7))
returning smallint;

define _error        	smallint;
define _cod_producto 	char(5);
define _vigencia_inic 	date;
define _fecha_expira 	date;
define _ano          	char(4);
define _mes          	char(2);
define _vigencia_inicN	date;
define _cod_formapag    char(3);
define _periodo_poliza  char(7);

begin
--set debug file to "sp_cob9c.trc";
--trace on;

on exception set _error 
 	return _error;         
end exception 

LET _mes = a_perido_expira[1,2];
LET _ano = a_perido_expira[4,7]; 
LET a_perido_expira = _ano ||"-"||_mes;
-- Verifica si el producto es 10602 creado para los corredores con la forma de pago tcr 003 no deben aplicar el descuento 5% ya que tienen un 20% de descuento en la cotizacion #Fcoronado 03/09/2024
foreach
	select trim(cod_producto)
	  into _cod_producto
	  from emipouni
	 where no_poliza = a_no_poliza
		exit foreach;
end foreach
if _cod_producto = '10602' then

	select vigencia_inic, cod_formapag
      into _vigencia_inic, _cod_formapag
      from emipomae 
     where no_poliza = a_no_poliza;
	 
		if _cod_formapag = '003' then
			call sp_cob9h(_vigencia_inic,6) RETURNING _vigencia_inicN;  -- Le Sumamos 6 meses a la vigencia inicial de la póliza
			call sp_sis39(_vigencia_inicN) RETURNING _periodo_poliza;   -- Sacamos el periodo de la fecha para sacar el primer dia
			CALL sp_sis36bk(_periodo_poliza) RETURNING _vigencia_inicN; -- sacamos el primer dia de la vigencia inicial.
			
			CALL sp_sis36bk(a_perido_expira) RETURNING _fecha_expira;	
			if _fecha_expira < _vigencia_inicN then
				return 1;
			end if
		end if
end if

return 0;
end
end procedure;