-- Procedimiento que calcula el descuento por: Tipo Auto - Ano - Suma Asegurada - RENOVACION DE POLIZAS
-- Creado:	23/07/2014 - Autor: Amado Perez M
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_yos18; 
create procedure sp_yos18(a_fecha integer)
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


delete from MigrarPolizas;

--solo auto  y soda
Insert into MigrarPolizas (no_poliza)
select   distinct a.no_poliza
from endedmae a inner join endeduni b on (a.no_poliza = b.no_poliza and a.no_endoso = b.no_endoso)
where fecha_emision >= today - a_fecha and a.no_poliza not in (select no_poliza from migrarpolizas) 
		and a.no_documento[1,2] not in ('04','08','16','18','19','02','20','23')
		and a.actualizado = 1;
return 0, "Insercion exitosa";

end procedure;