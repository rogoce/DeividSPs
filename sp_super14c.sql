-- Informe de Reclamos por Ramo
-- 
-- Creado    : 08/08/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_sp_rec03a_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_super14c;
CREATE PROCEDURE sp_super14c() 
RETURNING CHAR(20),smallint; 

DEFINE _no_poliza        		CHAR(10);
define _no_documento            char(20);
define _renglon                 smallint;

SET ISOLATION TO DIRTY READ;




foreach
	select no_documento,renglon
	  into _no_documento,_renglon
	  from aa
	  where actualizado = 0
	  order by 1
	  
	  let _no_poliza = sp_sis21(_no_documento);
	  update aa
	     set no_poliza    = _no_poliza
	   where no_documento = _no_documento
	     and renglon      = _renglon;	 
	  
	  {if _no_poliza = "" or _no_poliza is null then
		return _no_documento,_renglon with resume;
	  end if	}
	  
end foreach
return "Listo",0;
END PROCEDURE;




