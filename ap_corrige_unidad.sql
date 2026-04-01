
drop procedure ap_corrige_unidad;
create procedure "informix".ap_corrige_unidad(a_poliza CHAR(10))
RETURNING SMALLINT, CHAR(30);

DEFINE _cant          	INTEGER;

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
DEFINE _cod_entrada     integer;
DEFINE _cod_ent_char    char(10);
DEFINE _cod_entrada_vjo CHAR(10);
DEFINE _no_poliza       CHAR(10);

DEFINE _no_remesa, _recibo_old, _recibo_new   CHAR(10);
  
BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
    ROLLBACK WORK;
 	RETURN r_error, r_descripcion;
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--SET DEBUG FILE TO "sp_seg009.trc"; 
--TRACE ON;

--caso 1. no_poliza '786899'
--caso 2. no_poliza '732856'

let _no_poliza = a_poliza;

BEGIN WORK;

select *
  from emipouni
 where no_poliza = _no_poliza
   and no_unidad = ''
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into emipouni
 select * 
   from tmp_ttco;

drop table tmp_ttco;

----
update blobuni
   set no_unidad = '00001'
 where no_poliza = _no_poliza
   and no_unidad = '';

update cobredet
   set no_unidad = '00001'
 where no_poliza = _no_poliza
   and no_unidad = '';

update emiacrebi
   set no_unidad = '00001'
 where no_poliza = _no_poliza
   and no_unidad = '';

update emiauto
   set no_unidad = '00001'
 where no_poliza = _no_poliza
   and no_unidad = '';

update emiautor
   set no_unidad = '00001'
 where no_poliza = _no_poliza
   and no_unidad = '';


--emifian1-----------------
select *
  from emifian1
 where no_poliza = _no_poliza
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into emifian1
 select * 
   from tmp_ttco;

 drop table tmp_ttco;


update emiavan
   set no_unidad = '00001'
 where no_poliza = _no_poliza
   and no_unidad = '';

update emifigar
   set no_unidad = '00001'
 where no_poliza = _no_poliza
   and no_unidad = '';

delete from emifian1
 where no_poliza = _no_poliza
   and no_unidad = '';

----------------
											    
update emibenef								    
   set no_unidad = '00001'					    
 where no_poliza = _no_poliza
   and no_unidad = ''; 						    
											    
update emiblobu								    
   set no_unidad = '00001'					    
 where no_poliza = _no_poliza
   and no_unidad = '';						   
											   
											   
-----Cobertura
select *
  from emipocob
 where no_poliza = _no_poliza
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into emipocob
 select * 
   from tmp_ttco;

 drop table tmp_ttco;

update emicobre								   
   set no_unidad = '00001'					   
 where no_poliza = _no_poliza
   and no_unidad = '';						   
											   
update emicobde								   
   set no_unidad = '00001'					   
 where no_poliza = _no_poliza
   and no_unidad = '';

delete from emipocob
 where no_poliza = _no_poliza
   and no_unidad = '';
---------------------------
											   
update emiducc								   
   set no_unidad = '00001'					   
 where no_poliza = _no_poliza
   and no_unidad = '';						   
											   
update emiducu								   
   set no_unidad = '00001'					   
 where no_poliza = _no_poliza
   and no_unidad = '';						   
											   
-----emifacon
select *
  from emifacon
 where no_poliza = _no_poliza
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into emifacon
 select * 
   from tmp_ttco;

 drop table tmp_ttco;

update emifafac
   set no_unidad = '00001'
 where no_poliza = _no_poliza
   and no_unidad = '';

delete from emifacon
 where no_poliza = _no_poliza
   and no_unidad = '';

-----------------------------
							
update emipoacr				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = '';		
							
update emipode2				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = ''; 		

update emipreas
   set no_unidad = '00001'
 where no_poliza = _no_poliza
   and no_unidad = '';

-----emidepen
select *
  from emidepen
 where no_poliza = _no_poliza
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into emidepen
 select * 
   from tmp_ttco;

 drop table tmp_ttco;

update emiprede				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = ''; 		

delete from emidepen
 where no_poliza = _no_poliza
   and no_unidad = '';

------emireama--------------
select *
  from emireama
 where no_poliza = _no_poliza
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into emireama
 select * 
   from tmp_ttco;

 drop table tmp_ttco;

------emireaco--------------
select *
  from emireaco
 where no_poliza = _no_poliza
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into emireaco
 select * 
   from tmp_ttco;

 drop table tmp_ttco;

update emireafa
   set no_unidad = '00001'
 where no_poliza = _no_poliza
   and no_unidad = '';						   

delete from emireaco
 where no_poliza = _no_poliza
   and no_unidad = '';

delete from emireama
 where no_poliza = _no_poliza
   and no_unidad = '';

-----------------------------

update emivesoda				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = ''; 		

											   
update emiunire								   
   set no_unidad = '00001'					   
 where no_poliza = _no_poliza
   and no_unidad = '';						   
											   
update emiunide								   
   set no_unidad = '00001'					   
 where no_poliza = _no_poliza
   and no_unidad = ''; 						   
											   
-----emitrans
select *
  from emitrans
 where no_poliza = _no_poliza
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into emitrans
 select * 
   from tmp_ttco;

 drop table tmp_ttco;

update emitrand								   
   set no_unidad = '00001'					   
 where no_poliza = _no_poliza
   and no_unidad = ''; 						   
											   
delete from emitrans
 where no_poliza = _no_poliza
   and no_unidad = '';

---------------------------

update emisalmo								   
   set no_unidad = '00001'					   
 where no_poliza = _no_poliza
   and no_unidad = '';						   

-----------Endosos
-----endeduni
select *
  from endeduni
 where no_poliza = _no_poliza
   and no_unidad = ''
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into endeduni
 select * 
   from tmp_ttco;

 drop table tmp_ttco;

update endbenef				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = '';
   
update endmoaut				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = ''; 		

update endunide				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = '';		

update endedacr				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = '';					   

update endunire							   
   set no_unidad = '00001'				   
 where no_poliza = _no_poliza
   and no_unidad = '';					   

update endcuend				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = '';		

update endedde2				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = ''; 		
							
update endcamre				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = '';		
							
update endcamrf				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = ''; 		
							
-----endmotra
select *
  from endmotra
 where no_poliza = _no_poliza
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into endmotra
 select * 
   from tmp_ttco;

 drop table tmp_ttco;
							
update endmotrd				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = ''; 		

delete from endmotra
 where no_poliza = _no_poliza
   and no_unidad = '';

-------------------------------							
-----endedcob
select *
  from endedcob
 where no_poliza = _no_poliza
  into temp tmp_ttco;

 update tmp_ttco
    set no_unidad = '00001';

 insert into endedcob
 select * 
   from tmp_ttco;

 drop table tmp_ttco;

update endcobre				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = ''; 												  

update endcobde				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = '';		
							
-----------------------------		
-- Reclamos

update recrcmae				
   set no_unidad = '00001'	
 where no_poliza = _no_poliza
   and no_unidad = '';		
					

delete from endedcob
 where no_poliza = _no_poliza
   and no_unidad = '';

delete from endeduni
 where no_poliza = _no_poliza
   and no_unidad = '';


delete from emipouni
 where no_poliza = _no_poliza
   and no_unidad = '';
   

COMMIT WORK;

RETURN r_error, r_descripcion;



END

end procedure;
  
 

  
 
  
 
 
 
 
 

 
  
  
 
 
  












































