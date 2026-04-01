-- Creacion de la Transaccion Inicial de Reclamos
-- 
-- Creado    : 04/05/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE apm_wf_cotizacion;
CREATE PROCEDURE "informix".apm_wf_cotizacion()
returning integer;

define v_cod_asignacion	   	char(10);
define _no_reclamo			char(10);
define _cont                integer;

--SET DEBUG FILE TO "sp_cwf3.trc"; 
--trACE ON;

let _cont = 0;
foreach
{  select wf_cotizacion.nrocotizacion
    into v_cod_asignacion 
    FROM wf_cotizacion,   
         wf_db_autos,
         wf_autos,
         emivehic  
   WHERE ( wf_cotizacion.nrocotizacion = wf_db_autos.nrocotizacion and
           wf_db_autos.nrocotizacion = wf_autos.nrocotizacion and
           wf_db_autos.fecha_emision <= '31/05/2010') and  
         ( (wf_cotizacion.actualizado <> '1' And wf_cotizacion.actualizado <> '7') OR  
         ( wf_cotizacion.actualizado is null ) ) group by 1
}

{  select wf_cotizacion.nrocotizacion
    into v_cod_asignacion     
    FROM wf_cotizacion,   
         wf_db_autos
   WHERE ( wf_cotizacion.nrocotizacion = wf_db_autos.nrocotizacion and
           date(wf_db_autos.fecha_emision) <= '31/05/2010') and  
         ( (wf_cotizacion.actualizado <> '1' And wf_cotizacion.actualizado <> '7') OR  
         ( wf_cotizacion.actualizado is null ) ) 
 }
  select wf_cotizacion.nrocotizacion
    into v_cod_asignacion     
    FROM wf_cotizacion,   
         wf_db_autos
   WHERE ( wf_cotizacion.nrocotizacion = wf_db_autos.nrocotizacion and
           wf_db_autos.fecha_emision is null) and  
         ( (wf_cotizacion.actualizado <> '1' And wf_cotizacion.actualizado <> '7') OR  
         ( wf_cotizacion.actualizado is null ) ) 

  update   wf_cotizacion
     set   wf_cotizacion.actualizado = '7'
   where  wf_cotizacion.nrocotizacion = v_cod_asignacion;

let _cont = _cont + 1;
end foreach 
return  _cont;
end procedure