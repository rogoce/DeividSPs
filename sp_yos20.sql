-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada - RENOVACION DE POLIZAS
-- Creado:	23/07/2014 - Autor: Amado Perez M
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_yos20; 
create procedure sp_yos20()
returning	smallint, varchar(30);


define _no_motor	        char(50);
define _no_documento        char(20); 
define _no_poliza			char(10);
define _cod_modelo			char(5);
define _cod_tipo			char(3);
define _cod_ramo          	char(3);
define _descuento_max		dec(5,2);
define _tipo_descuento      smallint;
define _cant_g              smallint;
define _cant_p              smallint;
define _cant_s 				smallint;
define _tipo_auto			smallint;

set isolation to dirty read;

delete from emimarca_ys;
delete from emimodel_ys;

return 0, "Insercion exitosa";

end procedure;