-- Procedure que determina el producto nuevo para los cambios de tarifas 2012
-- Creado    : 19/12/2011 - Autor: Henry Giron
-- SIS v.2.0 - sp_pro30g - DEIVID, S.A.

drop procedure sp_pro30k;
create procedure sp_pro30k(
a_no_poliza 	char(10),
a_cod_producto	char(5),
a_periodo       char(7)
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

let _fecha_periodo = MDY(a_periodo[6,7], 1, a_periodo[1,4]);
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
  from emicartasal2
 where no_documento = _no_documento;

let _cant_dep = 0;

select count(*)
  into _cant_dep
  from emidepen
 where no_poliza = a_no_poliza
   and activo = 1;

if _cant > 0 then

  select cod_producto, 
         fecha_aniv,
		 periodo,
		 cod_prod_sav
	into _cod_producto, 
	     _fecha_aniv,
		 _periodo,
		 _cod_prod_sav
	from emicartasal2
   where no_documento = _no_documento;
   
--	-- Opcion de coberturas Asistencia de Viaje para julio y agosto 2018 Panamá Plus y Global
--	if _periodo >= '2018-07' and _periodo <= '2018-08' and _cod_subramo in ('007','009') then
--		let _cod_producto = _cod_prod_sav;
--	end if 

   	if _vigencia_final = _fecha_aniv then 
	    return _cod_producto;
	else
		let _cod_producto = a_cod_producto;
	end if

end if

return _cod_producto;

end procedure