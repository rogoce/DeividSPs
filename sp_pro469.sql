-- **********************************
-- Creado : Henry Giron Fecha : 16/09/2010
-- execute procedure sp_aud18("*","01/01/2010","31/03/2010")
-- *********************************
DROP PROCEDURE sp_pro469;
CREATE PROCEDURE sp_pro469() 
RETURNING   CHAR(20)	as poliza,	--cia_comp,
			char(5)	    as unidad,	--cia_nom,
			dec(16,2)	as suma_asegurada,			--cuenta,
			smallint	as agnos,
			dec(16,2)	as prima_suscrita,
			char(15)    as cood_manzana,
			char(2)     as cod_provincia,
			char(50)    as provincia,
			char(3)     as cod_distrito,
			char(50)    as distrito,
			char(3)     as cod_correg,
			char(50)    as corregimiento,
			char(4)     as cod_barrio,
			char(50)    as barrio;

define v_filtros            varchar(255);
define _no_poliza, _no_poliza_2	char(10);
define _no_unidad           char(5);
define _no_documento        char(20);
define _suma_asegurada, _suma_asegurada2      dec(16,2);
define _cant smallint;
define _prima_suscrita      dec(16,2);
define _cod_manzana   		char(15);
DEFINE _numero      		char(3);
DEFINE _referencia   		char(50);
DEFINE _cod_provincia   	char(2);
DEFINE _provincia   		char(50);
DEFINE _cod_distrito   		char(3);
DEFINE _distrito   	     	char(50);
DEFINE _cod_correg   		char(3);
DEFINE _correg      		char(50);
DEFINE _cod_barrio   		char(4);
DEFINE _barrio   		    char(50);

--trae cant. de polizas vig. temp_perfil
CALL sp_pro95(
'001',
'001',
today,
'001;',
'*',
'%') RETURNING v_filtros;


FOREACH	
 select no_poliza,
        no_documento,
 		suma_asegurada
   into	_no_poliza,
        _no_documento,
		_suma_asegurada
   from temp_perfil
   where cod_subramo <> '002'
   
  foreach
	select no_unidad,
	       suma_asegurada,
		   prima_suscrita,
		   cod_manzana
	  into _no_unidad,
	       _suma_asegurada,
		   _prima_suscrita,
		   _cod_manzana
	  from emipouni
	 where no_poliza = _no_poliza
	   and tipo_incendio = 1
	  
	  let _cant = 0;
		 
	  foreach
		  select no_poliza
			into _no_poliza_2
			from emipomae
		   where no_documento = _no_documento
		     and no_poliza <> _no_poliza
			 order by vigencia_inic desc
	     		 
			select suma_asegurada
			  into _suma_asegurada2
			  from emipouni 
			 where no_poliza = _no_poliza_2
			   and no_unidad = _no_unidad;
			
			 if _suma_asegurada = _suma_asegurada2 then
				let _cant = _cant + 1;
			 else
				exit foreach;
			 end if
	   end foreach		 
		
	   if _cant >= 4 then
		  SELECT emiman05.numero,   
				 emiman05.referencia,   
				 emiman05.cod_provincia,   
				 emiman01.nombre,   
				 emiman05.cod_distrito,   
				 emiman02.nombre,   
				 emiman05.cod_correg,   
				 emiman03.nombre,   
				 emiman05.cod_barrio,   
				 emiman04.nombre
			INTO _numero,      	
				 _referencia,   	
				 _cod_provincia, 
				 _provincia,   	
				 _cod_distrito,  
				 _distrito,   	  
				 _cod_correg,   	
				 _correg,      	
				 _cod_barrio,   	
				 _barrio   		
			FROM emiman05,
				 emiman04,
				 emiman03,
				 emiman02,
				 emiman01
		   WHERE ( emiman05.cod_manzana = _cod_manzana ) and
				 ( emiman05.cod_barrio = emiman04.cod_barrio ) and  
				 ( emiman02.cod_provincia = emiman01.cod_provincia ) and  
				 ( emiman05.cod_provincia = emiman04.cod_provincia ) and  
				 ( emiman05.cod_distrito = emiman04.cod_distrito ) and  
				 ( emiman05.cod_correg = emiman04.cod_correg ) and  
				 ( emiman04.cod_provincia = emiman03.cod_provincia ) and  
				 ( emiman04.cod_distrito = emiman03.cod_distrito ) and  
				 ( emiman04.cod_correg = emiman03.cod_correg ) and  
				 ( emiman03.cod_provincia = emiman02.cod_provincia ) and  
				 ( emiman03.cod_distrito = emiman02.cod_distrito );  
	   
		  RETURN _no_documento,
				 _no_unidad,
				 _suma_asegurada,
				 _cant,
				 _prima_suscrita,
				 _cod_manzana,
				 _cod_provincia,  
				 _provincia,   	 
				 _cod_distrito,   
				 _distrito,   	  
				 _cod_correg,   	 
				 _correg,      	 
				 _cod_barrio,   	 
				 _barrio   
				 WITH RESUME;
       end if
   end foreach
END FOREACH;

drop table  temp_perfil; 

END PROCEDURE
  


	  