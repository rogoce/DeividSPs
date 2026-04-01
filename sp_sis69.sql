drop procedure sp_sis69;

create procedure "informix".sp_sis69()
returning char(20),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2),
          dec(16,2);

define _no_documento	char(20);

DEFINE _saldo             DEC(16,2);
DEFINE _por_vencer        DEC(16,2);
DEFINE _exigible          DEC(16,2);
DEFINE _corriente         DEC(16,2);
DEFINE _monto_30          DEC(16,2);
DEFINE _monto_60          DEC(16,2);
DEFINE _monto_90          DEC(16,2);

foreach
 select no_documento
   into _no_documento
   from emipomae
  where incobrable      = 1
    and actualizado     = 1
	and sucursal_origen = "023"
  group by no_documento

	CALL sp_cob33(
		 "001",
		 "001",	
		 _no_documento,
		 "2004-10",
		 "31/10/2004"
		 ) RETURNING _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
    				 _saldo;    

	return _no_documento,
    	   _saldo,
	       _por_vencer,       
    	   _exigible,         
    	   _corriente,        
    	   _monto_30,         
    	   _monto_60,         
    	   _monto_90
		   with resume;

end foreach

end procedure
