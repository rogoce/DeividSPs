-- Validacion del no_requis antes de imprimir, para evitar duplicidad.
--
-- Creado    : 07/09/2007 - Autor: Lic. Armando Moreno 
--
-- SIS v.2.0 d_- DEIVID, S.A.

--DROP PROCEDURE sp_che78a;

CREATE PROCEDURE "informix".sp_che78a(
a_no_requis 	CHAR(10) 
) RETURNING INTEGER;

insert into bitache
select no_requis,no_cheque
from chqchmae
  WHERE cod_compania   = "001"
AND autorizado     = 1
AND pagado         = 1
AND cod_banco      = "001"
AND cod_chequera   = "006"
AND tipo_requis    = "C"
AND en_firma       = 2
and fecha_impresion = "10/09/2007";

 RETURN 0;

END PROCEDURE;
