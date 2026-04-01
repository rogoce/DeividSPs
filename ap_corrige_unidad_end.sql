
drop procedure ap_corrige_unidad_end;
create procedure "informix".ap_corrige_unidad_end()
RETURNING SMALLINT, CHAR(30);

DEFINE _cant          	INTEGER;

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
DEFINE _cod_entrada     integer;
DEFINE _cod_ent_char    char(10);
DEFINE _cod_entrada_vjo CHAR(10);

DEFINE _no_remesa, _recibo_old, _recibo_new   CHAR(10);
  
BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--SET DEBUG FILE TO "sp_seg009.trc"; 
--TRACE ON;



select *
  from endeduni
 where no_poliza = '732856'
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into endeduni
 select * 
   from tmp_ttco;

							
update endedcob				
   set no_unidad = '00001'	
 where no_poliza = '732856'
   and no_unidad = '';

update endmoaut				
   set no_unidad = '00001'	
 where no_poliza = '732856'
   and no_unidad = ''; 		


update endunide				
   set no_unidad = '00001'	
 where no_poliza = '732856'
   and no_unidad = '';		


update endedde2				
   set no_unidad = '00001'	
 where no_poliza = '732856'
   and no_unidad = ''; 		
							

RETURN r_error, r_descripcion ;

drop table tmp_ttco;

END

end procedure;
  
 

  
 
  
 
 
 
 
 

 
  
  
 
 
  












































