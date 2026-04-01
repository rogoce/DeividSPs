-- Procedimiento que Cambia el periodo de pago de los doctores a diario
-- 
-- Creado     : 04/04/2013 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_cambia_per_pago;

create procedure "informix".sp_cambia_per_pago()

define _no_recibo	char(10);
define _tipo_mov	char(1);
define _desc_remesa	char(100);
define _monto		dec(16,2);
define _fecha		date;
define _desc_mov	char(20);
define _monto_desc	dec(16,2);
define _codigo      char(10);


set isolation to dirty read;

foreach

 select codigo
   into _codigo
   from bb

 update cliclien
    set cod_ocupacion = '004',
	    periodo_pago  = 0
  where cod_cliente   = _codigo;



end foreach

--unload to recibos.txt select no_recibo from tmp_recibos;

end procedure