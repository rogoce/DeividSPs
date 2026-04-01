--  PROCEDIMIENTO PARA CORREGIR LAS REQUISICIONES DE CHEQUE
--  POR MAL IMPRESION
--  11/11/2009 HENRY

DROP PROCEDURE arregla3;

CREATE PROCEDURE arregla3()
--}
RETURNING CHAR(255);

DEFINE _mensaje CHAR(255);
DEFINE _no_req	CHAR(6);
DEFINE _no_chk	CHAR(5);
DEFINE _no_reg  smallint;
define _trx     char(10);

LET _no_reg = 0;
LET _mensaje = "REALIZADO ";


SET ISOLATION TO DIRTY READ;

BEGIN

foreach
	select req,chk
	  into _no_req,_no_chk
	  from tmp_chk

  	update chqchmae
	set pagado = 1,
	no_cheque = _no_chk
	where no_requis = _no_req;

	LET _no_reg = _no_reg + 1 ;

	foreach
		select transaccion
		  into _trx
		  from chqchrec
		 where no_requis = _no_req

		update rectrmae
		   set pagado = 1
		 where transaccion = _trx;

	end foreach

end foreach

LET _mensaje = _mensaje || _no_reg ;

return _mensaje;


END

END PROCEDURE;