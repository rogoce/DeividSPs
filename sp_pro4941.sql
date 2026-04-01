-- Procedure que determina el producto nuevo para los cambios de producto
-- Creado    : 29/09/2010 - Autor: Henry Giron
-- SIS v.2.0 - sp_pro30g - DEIVID, S.A.		  copia de sp_pro30g

drop procedure sp_pro4941;
create procedure sp_pro4941(a_no_poliza char(10), a_cod_producto char(5),a_periodo char(7))
returning char(5);

define _cod_producto, _cod_prod_ori,_cod_producto_new	char(5);
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

let _cod_producto = a_cod_producto;

let _fecha_periodo = MDY(a_periodo[6,7], 1, a_periodo[1,4]);

set isolation to dirty read;

--SET DEBUG FILE TO "sp_pro30g.trc";
--TRACE ON;                                                                 

select cod_subramo, no_documento, cod_grupo, vigencia_final
  into _cod_subramo, _no_documento, _cod_grupo, _vigencia_final
  from emipomae
 where no_poliza = a_no_poliza;

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
   and activo    = 1;

if _cant > 0 then
  select cod_producto, fecha_aniv
	into _cod_prod_ori, _fecha_aniv
	from emicartasal2
  where no_documento = _no_documento;

  if _vigencia_final <> _fecha_aniv then 
	return _cod_producto;
  end if

	select producto_nuevo
	  into _cod_producto_new
	  from prdnewpro
	 where cod_producto = _cod_producto
--	   and desde = '01/01/2012'
	   and activo = 1;

  if _cod_producto_new is not null then
   IF _cod_producto_new <> _cod_producto THEN
  	 let _cod_producto = _cod_producto_new;
   end if
  end if
end if

return _cod_producto;

end procedure