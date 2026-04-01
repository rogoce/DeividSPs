-- Procedimiento que elimina un Endoso de la estructura de endosos
-- 
-- Creado     : 18/09/2013 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis119a;

create procedure sp_sis119a(a_no_poliza char(10),a_no_endoso char(10))
 returning integer,
           char(200),
           char(5);

define _cod_endomov		char(3);
define _cod_tipocan		char(3);
define _cod_tipocalc	char(3);

define _null			char(1);
define _periodo			char(7);
define _no_endoso_int	smallint;
define _no_endoso		char(5);
define _no_endoso_ext	char(5);
define _tiene_impuesto	smallint;
define _cantidad		smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _descripcion		char(200);

define _prima_suscrita	dec(16,2);
define _prima_retenida 	dec(16,2);
define _prima 			dec(16,2);
define _descuento		dec(16,2);
define _recargo			dec(16,2);
define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _prima_bruta		dec(16,2);
define _suma_asegurada	dec(16,2);
define _suma_impuesto	dec(16,2);
define _factor_impuesto	dec(16,2);
define _cod_impuesto	char(3);
define _no_documento    char(20);
define _no_factura      char(10);
define li_return        integer;
define _no_poliza		char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _no_unidad       char(5);
define _cnt             smallint;

--set debug file to "sp_pro518.trc";
--trace on;
begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc, "";
end exception

set isolation to dirty read;

DELETE FROM endeddes where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endedrec where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endedimp where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endunide where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endunire where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endedde2 where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endedacr where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endmoaut where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endmotrd where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endmotra where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endcuend where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endcobre where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endcobde where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endedcob where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endcoama where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;

DELETE FROM endmoage where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endmoase where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endcamco where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endedde1 where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;

DELETE FROM endeduni where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endedmae where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endedhis where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;
DELETE FROM endedmae where no_poliza = a_no_poliza and no_endoso  = a_no_endoso;

end

return 0, "Actualizacion Exitosa", "";

end procedure