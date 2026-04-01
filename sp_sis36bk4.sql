-- Procedimiento que devuelve el ultimo dia del mes dado el periodo
--
-- Creado    : 13/02/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 13/02/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sis36bk4;

CREATE PROCEDURE "informix".sp_sis36bk4(a_no_aviso char(10)) 
RETURNING varchar(50),char(20);

DEFINE _cod_asegurado char(10);
DEFINE _no_poliza char(10);
DEFINE _nombre_acreedor varchar(50);
define _leasing         smallint;
define _no_documento    char(20);
define _cod_acreedor    char(10);


foreach

	select no_poliza,no_documento
	  into _no_poliza,_no_documento
	  from avisocanc
	 where no_aviso = a_no_aviso
   --and nombre_acreedor[1,7] = '... SIN'

   let _cod_acreedor = null;
   
   foreach
   
    select cod_acreedor
	  into _cod_acreedor
	  from emipoacr
	 where no_poliza = _no_poliza
	 
	 let _nombre_acreedor = null;
	 
		if _cod_acreedor is not null then
		
			foreach
			
				select nombre
				  into _nombre_acreedor
				  from emiacre
				 where cod_acreedor = _cod_acreedor
				 
				exit foreach;
				
			end foreach
			
			update avisocanc
			   set nombre_acreedor = _nombre_acreedor
			 where no_aviso   = a_no_aviso
			   and no_poliza = _no_poliza;
			
		end if
		exit foreach;
	end foreach
end foreach
return '','';

END PROCEDURE;