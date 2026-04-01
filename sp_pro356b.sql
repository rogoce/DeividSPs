-- Procedimiento que Actualiza campos de garantia de pago de la ultima Distribucion de Reaseguro individual--
-- Creado  11/04/2016 -- Henry se adicino columnas de garantia(3)
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro356b;
create procedure "informix".sp_pro356b(a_no_poliza char(10), a_no_unidad char(5),a_cod_cober_reas char(3), a_cod_contrato char(5), a_cant_garantia_pago integer, a_cod_perfac char(3), a_fecha_primer_pago date)
RETURNING   INTEGER ;              --1_muestra estado de error
			

define _no_cesion			char(10);
define _cod_coasegur		char(3);
define _prima		   		dec(16,2);
define _suma_asegurada		dec(16,2);
define _porc_partic_reas	dec(9,6);
define _porc_comis_fac		dec(9,6);
define _porc_impuesto		dec(5,2);
define _orden				smallint;
define _no_cambio			smallint;
define _impreso				smallint;
define _fecha_impresion		date;
define _error,_cant_garantia_pago  integer;
--define _cod_perfac          char(3);
--define _fecha_primer_pago   date;

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error;         
END EXCEPTION

SET ISOLATION TO DIRTY READ;

select max(no_cambio)
  into _no_cambio
  from emireama
 where no_poliza		= a_no_poliza
   and no_unidad		= a_no_unidad
   and cod_cober_reas	= a_cod_cober_reas;

foreach
	select cod_coasegur,
		   orden,
		   porc_partic_reas,			   
		   porc_comis_fac,  
		   porc_impuesto
	  into _cod_coasegur,
		   _orden,
		   _porc_partic_reas,
		   _porc_comis_fac,
		   _porc_impuesto
	  from emireafa
	 where no_poliza		= a_no_poliza
	   and no_unidad		= a_no_unidad
	   and no_cambio		= _no_cambio
	   and cod_cober_reas	= a_cod_cober_reas
	   and cod_contrato		= a_cod_contrato
	

	update emifafac
	   set cant_garantia_pago = a_cant_garantia_pago,
		   cod_perfac = a_cod_perfac,
		   fecha_primer_pago = a_fecha_primer_pago
	 where no_poliza		= a_no_poliza
	   and no_endoso		= '00000'
	   and no_unidad		= a_no_unidad
	   and cod_cober_reas	= a_cod_cober_reas
	   and orden			= _orden
	   and cod_contrato		= a_cod_contrato
	   and cod_coasegur		= _cod_coasegur;		   

end foreach
RETURN 0;
END
end procedure;