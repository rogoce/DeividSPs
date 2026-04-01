-- Insertando 	  
-- Creado    : 15/07/2010 - Autor: Amado Perez M.
-- Modificado: 15/07/2010 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

drop procedure ap_legal3;

create procedure ap_legal3()
returning char(10),
		  date,
		  char(20),
		  char(10),
		  dec(16,2),
		  char(10),
		  char(3),
		  char(10),
		  dec(16,2);

define _no_poliza 		char(10);
define _fecha     		date;
define _no_documento	char(20);
define _no_factura      char(10);
define _saldo			dec(16,2);
define _no_factura_n    char(10);
define _cod_tipocan	   	char(3);
define _no_endoso	   	char(5);
define _prima_bruta		dec(16,2);
define _no_endoso2      char(5);
define _error           integer;

--set debug file to "sp_pro172.trc";


on exception set _error
	--return _error,_error_desc;
end exception


set isolation to dirty read;
begin

--set debug file to "sp_pro348.trc"; 
--trace on; 

foreach
  SELECT no_poliza,
         fecha,
  		 no_documento,   
         no_factura,   
         prima
    INTO _no_poliza,
    	 _fecha,
    	 _no_documento,
		 _no_factura,
		 _saldo
    FROM coboutleg   

 let _no_factura_n = null;

  select no_endoso
    into _no_endoso2
	from endedmae
   where no_factura = _no_factura;

  foreach
	  select no_factura,   
	         cod_tipocan,   
	         no_endoso,
			 prima_bruta
		into _no_factura_n,
		   	 _cod_tipocan,
			 _no_endoso,
			 _prima_bruta
		from endedmae
	   where no_poliza = _no_poliza
		 and no_endoso   > _no_endoso2
		 and no_factura  <> _no_factura
	     and cod_endomov = '002'
	   	 and cod_tipocalc = '004'
	   exit foreach;
  end foreach

-- update coboutleg
--    set no_factura = _no_factura_n
--  where no_documento = _no_documento;

return _no_poliza,_fecha,_no_documento,_no_factura,_saldo,_no_factura_n,_cod_tipocan,_no_endoso,_prima_bruta with resume;

end foreach

end

end procedure