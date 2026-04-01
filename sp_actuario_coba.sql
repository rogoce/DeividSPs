-- Procedimiento para cargar la tabla de problema enn ttcorp
-- Creado     : 03/07/2014
-- Autor 	  : Angel Tello	

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_actuario_coba;		

create procedure "informix".sp_actuario_coba()
	returning integer, char(100);

define _ano_evaluar		smallint;
define _mes_evaluar		smallint;
define _mes_pnd			smallint;
define _ano_pnd			smallint;
define _periodo_pnd1	char(7);
define _periodo_pnd2	char(7);
define _pri_dev_aa		dec(16,2);
define _pri_dev_aa1  	dec(16,2);
define _no_documento	char(20);
define _no_recibo       char(20);
define _no_remesa		char(20);
define _renglon 		integer;

set isolation to dirty read;

--SET DEBUG FILE TO "sp_actuario_coba.trc";
--trace on;

foreach
	 select id_poliza,
	       id_recibo
	   into _no_documento,
	        _no_recibo,
			
	   from deivid_ttcorp:tmp_reaseguro_prob
	  where cod_situacion = 13 
	  order by id_recibo
	  

	 select no_remesa,
			renglon 
	   into _no_remesa,
			_renglon
	   from cobredet
	   where doc_remesa = _no_documento
	     and no_recibo = _no_recibo;
		
		update deivid_ttcorp:tmp_reaseguro_prob
		   set no_remesa = _no_remesa,
		       renglon   = _renglon
		where id_poliza = _no_documento
		  and id_recibo = _no_recibo;
       
end foreach
	return 0, "Actualizacion Exitosa";

end procedure
