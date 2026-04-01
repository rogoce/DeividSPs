-- Procedimiento que genera el reporte de los recaudos diarios mayores a 10,000.00
-- 
-- Creado     : 17/06/2013 - Autor: Federico V. Coronado T.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro534;

create procedure "informix".sp_pro534(a_periodo char(7))
returning integer,
          varchar(50),
          char(13),
          char(50),
          date,
          varchar(10),
		  dec(16,2);
		  
define _no_documento	 char(13);
define _error			 integer;
define _error_isam		 integer;
define _error_desc		 varchar(100);
define _no_poliza		 varchar(10);
define _fecha            date;
define _monto            dec(16,2);
define _tipo_mov         char(1);
define _cod_contratante  varchar(10);
define _cod_ramo         char(3);
define _nombre           varchar(50);
define _nombre_ramo      varchar(50);
define _no_recibo        varchar(10);

--set debug file to "sp_par184.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam, "", _error_desc, "", "", "";
end exception

foreach
	select no_poliza, 
	       fecha, 
	       no_recibo, 
		   monto, 
		   tipo_mov
	  into _no_poliza,
		   _fecha,
		   _no_recibo,
		   _monto,
		   _tipo_mov
	  from cobredet
	 where periodo     = a_periodo
	   and tipo_mov    in ("P","N")
	   and monto       >= '10,000.00'
	   and actualizado = 1
	   
	select cod_contratante, 
	       no_documento, 
	       cod_ramo
	  into _cod_contratante,
		   _no_documento,
		   _cod_ramo
      from emipomae
     where no_poliza = _no_poliza;
	 
	 select nombre 
	   into _nombre_ramo
	   from prdramo 
	  where cod_ramo = _cod_ramo;
	  
	 select nombre
	   into _nombre
	   from cliclien 
	  where cod_cliente = _cod_contratante;
	  
	 RETURN     0, 
			   _nombre,
			   _no_documento,
			   _nombre_ramo,
			   _fecha,
			   _no_recibo,
			   _monto
			   WITH RESUME; 
	   
end foreach 
end 
end procedure