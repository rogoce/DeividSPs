-- Procedimiento para cambiar el uso del auto a comercial con valores suministrados por Jenniffer
--
-- Creado    : 04/04/2016 - Autor: Armanod Moreno M.


--DROP PROCEDURE sp_sis440;

CREATE PROCEDURE "informix".sp_sis440() 
RETURNING integer,char(50);

DEFINE _no_documento CHAR(20);
DEFINE _no_unidad	 CHAR(5);
DEFINE _no_poliza    CHAR(10);


foreach
	select no_documento
	  into _no_documento
	  from uso
	  
	  let _no_poliza = sp_sis21(_no_documento);
	  
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza
		
		update emiauto
		   set uso_auto = 'C'
		 where no_poliza = _no_poliza
           and no_unidad = _no_unidad;
		   
		update endmoaut
           set uso_auto = 'C'	
		 where no_poliza = _no_poliza
           and no_unidad = _no_unidad;
		 
	end foreach
	
end foreach

RETURN 0,'Actualizacion Exitosa';

END PROCEDURE;