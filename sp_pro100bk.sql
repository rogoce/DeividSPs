-- Procedure que guarda una copia de Endedmae
-- para verificar cuando se cambian los valores
-- de endosos

-- Creado    : 05/06/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 05/06/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro100bk;
create procedure sp_pro100bk(a_no_poliza char(10),a_no_endoso char(5))
RETURNING smallint;

define _cantidad		smallint;
define _vigencia_inic	date;
define _periodo_inic	char(7);
define _periodo2		char(7);

-- Actualiza el Periodo del Endoso de acuerdo a la vigencia
-- Requerimientos NIFF

select vigencia_inic,
       periodo
  into _vigencia_inic,
	   _periodo2
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

let _periodo_inic = sp_sis39(_vigencia_inic);

if _periodo_inic > _periodo2 then

	update endedmae
	   set periodo   = _periodo_inic
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso;

	if a_no_endoso = "00000" then

		update emipomae
		   set periodo   = _periodo_inic
		 where no_poliza = a_no_poliza;

	end if

end if

-- Crea el Historico

select count(*)
  into _cantidad
  from endedhis
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cantidad <> 0 then
	return 1;
end if

insert into endedhis(
no_poliza,		  
no_endoso,		  
cod_compania,	  
cod_sucursal,	  
cod_tipocalc,	  
cod_formapag,	  
cod_tipocan,		  
cod_perpago,		  
cod_endomov,		  
no_documento,	  
vigencia_inic,	  
vigencia_final,	  
prima,			  
descuento,		  
recargo,			  
prima_neta,		  
impuesto,		  
prima_bruta,		  
prima_suscrita,	  
prima_retenida,	  
tiene_impuesto,	  
fecha_emision,	  
fecha_impresion,	  
fecha_primer_pago, 
no_pagos,		  
actualizado,		  
no_factura,		  
fact_reversar,	  
date_added,		  
date_changed,	  
interna,			  
periodo,			  
user_added,		  
factor_vigencia,	  
suma_asegurada,	  
posteado,		  
activa,			  
vigencia_inic_pol, 
vigencia_final_pol,
no_endoso_ext,
cod_tipoprod,
cotizacion,
de_cotizacion,
gastos
)
select
no_poliza,		  
no_endoso,		  
cod_compania,	  
cod_sucursal,	  
cod_tipocalc,	  
cod_formapag,	  
cod_tipocan,		  
cod_perpago,		  
cod_endomov,		  
no_documento,	  
vigencia_inic,	  
vigencia_final,	  
prima,			  
descuento,		  
recargo,			  
prima_neta,		  
impuesto,		  
prima_bruta,		  
prima_suscrita,	  
prima_retenida,	  
tiene_impuesto,	  
fecha_emision,	  
fecha_impresion,	  
fecha_primer_pago, 
no_pagos,		  
actualizado,		  
no_factura,		  
fact_reversar,	  
date_added,		  
date_changed,	  
interna,			  
periodo,			  
user_added,		  
factor_vigencia,	  
suma_asegurada,	  
posteado,		  
activa,			  
vigencia_inic_pol, 
vigencia_final_pol,
no_endoso_ext,
cod_tipoprod,
cotizacion,
de_cotizacion,
gastos
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;	  

return 0;
end procedure
