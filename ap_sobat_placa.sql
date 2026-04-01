-- Lista de Cambios de Usuarios
-- Creado    : 01/02/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.  
 drop procedure ap_sobat_placa;

create procedure ap_sobat_placa() 
returning CHAR(30),CHAR(30);
																					 
define _no_motor   		CHAR(30)  ;	
define _chasis          CHAR(30) ;	
define _placa           CHAR(10)	 ;	
define _cupo   	        CHAR(60)  ;	
define _cnt             integer;
define _cod_modelo      CHAR(5);
define _cod_tipoauto    CHAR(3);
											   	
set isolation to dirty read;

foreach
  select no_motor,
         chasis,
         placa,
         cupo		 
    into _no_motor,
         _chasis,
         _placa,
         _cupo		 
    from tmp_sobat_placa  
 
   select cod_modelo
     into _cod_modelo
     from emivehic
    where no_motor = _no_motor
      and no_chasis = _chasis;

   select cod_tipoauto
     into _cod_tipoauto   
     from emimodel
	where cod_modelo = _cod_modelo;
	
   if _cod_tipoauto = '151' then
		continue foreach;
   end if
   
   let _cnt = 0;
 
   select count(*)
    into _cnt
	from emivehic
   where no_motor = _no_motor
     and no_chasis = _chasis;
 
   if _cnt > 0 then
	   update emivehic
		  set placa = _placa,
			  cupo = _cupo
	   where no_motor = _no_motor
		 and no_chasis = _chasis;
		-- and (placa is null or trim(placa) = "");
		 
	  update tmp_sobat_placa
	     set procesado = 1
	   where no_motor = _no_motor
		 and chasis = _chasis;
    
	  return _no_motor,   
			 _chasis
			 with resume;
    end if
end foreach
end procedure


  