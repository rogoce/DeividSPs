-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_rec282;
CREATE PROCEDURE sp_rec282(a_poliza CHAR(10), a_unidad CHAR(5), a_fecha_sinies DATE)
returning varchar(5);

define _no_endoso	   	char(5);
define _cod_producto    varchar(5);

set isolation to dirty read;
--if a_poliza = '267512' then
--	SET DEBUG FILE TO "sp_cwf3.trc"; 
--	trACE ON;
--end if
let _cod_producto = null;	
FOREACH WITH HOLD
	select no_endoso
	  into _no_endoso
	  from endedmae
	 where no_poliza = a_poliza
	   and vigencia_inic <= a_fecha_sinies
	   and vigencia_final > a_fecha_sinies
	   and cod_endomov in ('014','029') 
	   order by no_endoso
	   
	select cod_producto
	  into _cod_producto
	  from endeduni
	 where no_poliza = a_poliza
	   and no_endoso = _no_endoso
	   and no_unidad = a_unidad;

END FOREACH
{	FOREACH
		SELECT a.no_endoso,
               b.cod_producto		
		  INTO _no_endoso,
		       _cod_producto
		  FROM endedmae a, endeduni b  
		 WHERE a.no_poliza = b.no_poliza
		   AND a.no_endoso = b.no_endoso
		   AND a.no_poliza = a_poliza
		   AND a.cod_endomov in ('014','029')
		   AND a.vigencia_inic <= a_fecha_sinies
		   AND a.vigencia_final > a_fecha_sinies
		   AND a.actualizado = 1
		   AND b.no_unidad = a_unidad
		ORDER BY a.no_endoso --DESC
		EXIT FOREACH;
	END FOREACH
	}
{   SELECT cod_producto
     INTO _cod_producto
	 FROM endeduni
	WHERE no_poliza = a_poliza
	  AND no_unidad = a_unidad
	  AND no_endoso = _no_endoso;
}	
	IF _cod_producto is null THEN
		LET _cod_producto = "";
	END IF
		 
	RETURN _cod_producto;
  
end procedure