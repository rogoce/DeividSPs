-- Procedure que determina el producto nuevo para los cambios de tarifas 2010

-- Creado    : 29/09/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - sp_pro30g - DEIVID, S.A.

drop procedure sp_pro30g;

create procedure sp_pro30g(
a_no_poliza 	char(10),
a_cod_producto	char(5)
) returning char(5);

define _cod_producto, _cod_prod_ori	char(5);
define _producto_nuevo  char(5);
define _tipo_suscrip	smallint;
define _cod_subramo		char(3);
define _fecha_creacion  date;
define _no_documento    char(20); 
define _cant            smallint;

let _cod_producto = a_cod_producto;

select cod_subramo, no_documento
  into _cod_subramo, _no_documento
  from emipomae
 where no_poliza = a_no_poliza;

let _cant = 0;

select count(*)
  into _cant
  from emicartasal
 where no_documento = _no_documento;

if _cant > 0 then
  select cod_producto
	into _cod_prod_ori
	from emicartasal
  where no_documento = _no_documento;

  IF _cod_subramo = '007' THEN	 -- Panama plus
     LET _cod_producto = '01500';
  ELIF _cod_subramo = '009' THEN -- Global
     LET _cod_producto = '01501';
  ELIF _cod_subramo = '013' THEN -- Complementario
     IF _cod_prod_ori IN ('00382','00383','00384','00398','00399','00400') THEN -- Sin deducible  
     	LET _cod_producto = '01503';
     ELIF _cod_prod_ori IN ('00385','00401','00403') THEN -- Deducible 5000 
     	LET _cod_producto = '01525';
     ELIF _cod_prod_ori IN ('00406','00407','00408','00409','00411') THEN -- Deducible 10000 
     	LET _cod_producto = '01526';
	 END IF
  ELIF _cod_subramo = '016' THEN -- Hosp plus
     LET _cod_producto = '01502';
  END IF
end if

return _cod_producto;

end procedure