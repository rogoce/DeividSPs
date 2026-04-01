-- Procedure que determina el producto nuevo para los cambios de tarifas 2010
-- Creado    : 29/09/2010 - Autor: Amado Perez M 
-- SIS v.2.0 - sp_pro30g - DEIVID, S.A.

drop procedure sp_pro30g;
create procedure sp_pro30g(
a_no_poliza 	char(10),
a_cod_producto	char(5),
a_periodo       char(7)
) returning char(5);

define _cod_producto, _cod_prod_ori	char(5);
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
  from emicartasal
 where no_documento = _no_documento;

let _cant_dep = 0;

select count(*)
  into _cant_dep
  from emidepen
 where no_poliza = a_no_poliza
   and activo = 1;

if _cant > 0 then
  select cod_producto, fecha_aniv
	into _cod_prod_ori, _fecha_aniv
	from emicartasal
  where no_documento = _no_documento;

  if _vigencia_final <> _fecha_aniv then 
	return _cod_producto;
  end if

  IF _cod_producto IN ('00418','00419','00420','00460','00461','00462','00463','00464','00465')	THEN --> Estos productos no cambian Acta Facturacion Salud
	return _cod_producto;
  END IF

  IF _cod_prod_ori IN ('00466','00567','00568') THEN --Comunidad China
  	  LET _cod_producto = '01500';	
  ELSE
	  IF _cod_grupo = '01007' AND a_periodo = '2011-04' THEN -- Grupo Apavimed
		 IF _cod_prod_ori IN ('00620') THEN
			LET _cod_producto = '01609';
		 ELIF _cod_prod_ori IN ('00621') THEN
			LET _cod_producto = '01610';
		 ELIF _cod_prod_ori IN ('00622') THEN
			LET _cod_producto = '01611';
		 END IF
	  ELIF _cod_grupo = '983' AND a_periodo = '2011-04' THEN -- Grupo Conafar
		 IF _cod_prod_ori IN ('00773') THEN
			LET _cod_producto = '01609';
		 ELIF _cod_prod_ori IN ('00774') THEN
			LET _cod_producto = '01610';
		 ELIF _cod_prod_ori IN ('00775') THEN
			LET _cod_producto = '01611';
		 END IF
	  ELIF _cod_grupo in ('11111', '22222') THEN -- CLIENTES DE KAM Y ASOCIADOS, CLIENTES DE ARCO SEGUROS
	     IF _cod_prod_ori IN ('01096','01133') THEN
			LET _cod_producto = '01655';
		 ELIF _cod_prod_ori IN ('01097','01134') THEN
			LET _cod_producto = '01656';
		 ELIF _cod_prod_ori IN ('01098','01135') THEN
			IF _cant_dep > 2 THEN
				LET _cod_producto = '01658';
			ELSE
				LET _cod_producto = '01657';
			END IF
		 END IF
	  ELSE
	      IF _cod_grupo NOT IN ('01007','983', '11111', '22222') THEN -->Se agrego ya que se estaba cambiando para los siguientes meses el producto Amado 7/06/2011. 
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
			  ELIF _cod_subramo = '008' THEN
			     LET _cod_producto = '01587';
			  ELIF _cod_subramo = '018' THEN
			     LET _cod_producto = '01586';
			  END IF
		  END IF
	  END IF
  END IF
end if

return _cod_producto;

end procedure