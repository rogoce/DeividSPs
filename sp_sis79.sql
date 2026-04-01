
--drop procedure sp_sis79;

create procedure "informix".sp_sis79(_id_transaccion integer)
returning char(10);

define _recibo	char(10);

set isolation to dirty read;

IF _id_transaccion < 10 THEN
	LET _recibo = '0000' || _id_transaccion;
elif _id_transaccion < 100 THEN
	LET _recibo = '000' || _id_transaccion;
elif _id_transaccion < 1000 THEN
	LET _recibo = '00' || _id_transaccion;
elif _id_transaccion < 10000 THEN
	LET _recibo = '0' || _id_transaccion;
else
	let _recibo = _id_transaccion;
END IF

return _recibo;
end procedure;

