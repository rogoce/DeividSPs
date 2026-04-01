drop procedure ap_pro49;

create procedure "informix".ap_pro49()

-- Inclusion de Unidades del Endoso
--
-- Creado    : 31/10/2000 - Autor: Victor Molinar
-- Modificado: 09/05/2001 - Autor: Demetrio Hurtado Almanza

RETURNING SMALLINT, CHAR(30);

BEGIN
DEFINE   r_error       SMALLINT;
DEFINE   r_descripcion CHAR(30);
DEFINE   r_cobertura   CHAR(5);
DEFINE   r_orden       SMALLINT;
DEFINE   r_limite1     CHAR(50);
DEFINE   r_limite2     CHAR(50);
DEFINE   r_deducible   CHAR(50);
DEFINE   r_cantidad    SMALLINT;
DEFINE   v_poliza      char(10);
define   v_endoso      char(5); 
define   v_unidad      char(5); 
define   v_producto    char(5);

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = NULL;
LET r_cobertura   = NULL;
LET r_limite1     = 0.00;
LET r_limite2     = 0.00;
LET r_orden       = 0;
LET r_deducible   = NULL;

----------------
-----  Cargar las coberturas
----------------
foreach with hold
   select no_poliza,
          no_endoso,
		  no_unidad,
		  cod_producto
	 into v_poliza,
	      v_endoso,
		  v_unidad,
		  v_producto
	 from endeduni
	where no_poliza = '0001302959'
	  and no_endoso = '00001'

   delete from emifafac
    where no_poliza     = v_poliza
      and no_endoso     = v_endoso
      and no_unidad     = v_unidad;
   
   delete from emifacon
    where no_poliza     = v_poliza
      and no_endoso     = v_endoso
      and no_unidad     = v_unidad;
   
   delete from endedcob
    where no_poliza     = v_poliza
      and no_endoso     = v_endoso
      and no_unidad     = v_unidad;
   
-- Estaba causando problemas en la inclusion de Unidades de Transporte, porque le 
-- insertaba todas las unidades del producto y tenian que estar eliminado, asi que
-- le agregue la condicion de que solo trajera las coberturas Default - Demetrio

   foreach
     select x.cod_cobertura, x.orden, x.desc_limite1, x.desc_limite2, x.deducible
       into r_cobertura, r_orden, r_limite1, r_limite2, r_deducible
       from prdcobpd x
      where x.cod_producto = v_producto
	    and x.cob_default  = 1
   
      Insert Into endedcob(
	  no_poliza,
	  no_endoso,
      no_unidad,
	  cod_cobertura,
	  orden,
	  tarifa,
	  deducible,
	  limite_1,
	  limite_2,
	  prima_anual,
	  prima,
	  descuento,
	  recargo,
	  prima_neta,
	  date_added,
	  date_changed,
	  desc_limite1,
	  desc_limite2,
	  factor_vigencia,
	  opcion)
      Values(
      v_poliza,
      v_endoso,
      v_unidad,
      r_cobertura,
      r_orden,
      0.00,
      r_deducible,
      0.00,
      0.00,
      0.00,
      0.00,
      0.00,
      0.00,
      0.00,
      Current,
      Current,
      r_limite1,
      r_limite2,
      0.00,
	  0);
   end foreach
end foreach
RETURN r_error, r_descripcion  WITH RESUME;
END
end procedure;
