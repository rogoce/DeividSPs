-- Procedure que determina el producto nuevo para los cambios de tarifas 2012
-- Creado    : 19/12/2011 - Autor: Henry Giron
-- SIS v.2.0 - sp_pro30g - DEIVID, S.A.

drop procedure sp_pro30l;
create procedure sp_pro30l(
a_no_poliza 	char(10),
a_cod_producto	char(5)
) returning char(5);

define _cod_producto	char(5);
define _producto_nuevo  char(5);
define _tipo_suscrip	smallint;
define _cod_subramo		char(3);
define _fecha_creacion  date;
define _no_documento    char(20); 
define _cant            smallint;
define _cod_grupo       char(5);
define _cant_dep        smallint;
define _fecha_periodo   date;
define _vigencia_final, _fecha_aniv   date;
define _periodo         char(7);
define _cod_prod_sav    char(5);

--let _fecha_periodo = MDY(a_periodo[6,7], 1, a_periodo[1,4]);
let _cod_producto = a_cod_producto;

set isolation to dirty read;

--SET DEBUG FILE TO "sp_pro30k.trc";
--TRACE ON;                                                                 

select cod_subramo, no_documento, cod_grupo, vigencia_final
  into _cod_subramo, _no_documento, _cod_grupo, _vigencia_final
  from emipomae
 where no_poliza = a_no_poliza;

    IF _cod_grupo IN ('00984','01010','989') THEN 
	   return _cod_producto;
    END IF

let _cant = 0;

select count(*)
  into _cant
  from emicartasal5
 where no_documento = _no_documento;

if _cant > 0 then

  select fecha_aniv
	into _fecha_aniv
	from emicartasal5
   where no_documento = _no_documento;
   
   let _cant_dep = 0;
   
   select count(*)
     into _cant_dep
	 from prdnewpro
	where cod_producto = a_cod_producto
      and activo = 1;	
	  
	if _cant_dep is null then
		let _cant_dep = 0;
	end if		
   
    if _cant_dep > 0 then
	   select producto_nuevo
		 into _cod_producto
         from prdnewpro
	    where cod_producto = a_cod_producto
          and activo = 1;
	end if	  
		  
   	if _vigencia_final = _fecha_aniv then 
	    return _cod_producto;
	else
		let _cod_producto = a_cod_producto;
	end if

end if

return _cod_producto;

end procedure