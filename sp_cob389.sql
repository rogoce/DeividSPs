-- sp_cob389   Procedimiento toma valores temporal de aviso pdf
-- creado: 24/11/2016 - Autor: Henry Girón.

DROP PROCEDURE sp_cob389;
CREATE PROCEDURE "informix".sp_cob389(a_aviso CHAR(15), a_poliza CHAR(10), a_usuario CHAR(10))
                  RETURNING integer, varchar(50);  

DEFINE _saldo	          DEC(16,2);
DEFINE _prima	          DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _fecha             DATE;
DEFINE _estatus	          CHAR(1);
DEFINE _error		      INTEGER;
DEFINE _error_mess 	      CHAR(50);

let _estatus = "";
let _saldo = 0.00;
let _prima = 0.00;
let _exigible = 0.00;

set isolation to dirty read;
--set debug file to "sp_cob389.trc";
--trace on;
let _error = 0;
let _error_mess = '';

begin
on exception set _error
	return _error,_error_mess;  
end exception

SELECT  saldo,
		prima,
		exigible,
		fecha_proceso,
        estatus		
   INTO _saldo,
		_prima,
		_exigible,
		_fecha,
		_estatus
   FROM avisocanc
  WHERE no_aviso  = a_aviso
    AND no_poliza = a_poliza
	AND impreso    = 0;
	
let _fecha = sp_sis26() ;	

Insert into tmp_pdf_aviso(no_aviso, no_poliza, estatus, user_added, fecha_add, saldo, prima, exigible)
values (a_aviso, a_poliza, _estatus, a_usuario, _fecha, _saldo, _prima, _exigible); 

end
--trace off;
return 0, "Se inserto tmp_pdf_aviso";

END PROCEDURE