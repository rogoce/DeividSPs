-- Procedimiento que genera el cambio de plan de pagos (proceso de nueva ley de seguros)
-- Creado     : 08/01/2013 - Autor: Amado Perez M.2
define _error_desc		char(50);
define _error_isam		integer;
define _error			integer;
define _actualizado		smallint;

--set debug file to "sp_cob253.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc 
	return _error, _error_desc;
end exception


select actualizado
  into _actualizado
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _actualizado <> 0 then
	return 1,'No se puede eliminar un endoso ya actualizado';
end if

delete from emifafac 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from emifacon 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  
   
delete from endmoase 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from endeddes
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endcamco
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endedrec
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endcoama
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endedcob 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endedde2 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endunide
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  
 
delete from endunire 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endcuend
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from endedacr
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from endbenef
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from endmoaut
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso; 

delete from endmotrd
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from endmotra
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  
 
delete from endeduni 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from endmoage 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endcamre 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endcamrf
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endeddes 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endedde1 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endedimp 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from emipode1 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from emiglofa 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from emigloco 
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;  

delete from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

return 0,'Actualización Exitosa';
end
end procedure 