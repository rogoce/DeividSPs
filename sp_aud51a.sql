-- Procedure para sacar informacion de chqchmae / chqchcta para TTCORP
-- 
-- Creado    :04/04/2014 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud51a;

create procedure "informix".sp_aud51a(a_fecha_desde date, a_fecha_hasta date)
 returning integer,  varchar(100); 

define _error_cod  			integer;
define _error_desc          varchar(50);
define _error_isam	        integer;
define _transaccion			char(50);

set isolation to dirty read;

delete from deivid_ttcorp:tmp_chqchmae;
delete from deivid_ttcorp:tmp_chqchcta;

--SET DEBUG FILE TO "sp_aud51.trc";
--trace on;

select no_requis,cod_cliente,cod_agente,cod_banco,cod_chequera,cuenta,cod_compania,cod_sucursal,origen_cheque,no_cheque,fecha_impresion,fecha_captura,autorizado,pagado,a_nombre_de,cobrado,fecha_cobrado,
       anulado,fecha_anulado,anulado_por,monto,periodo,user_added,autorizado_por,unificado,incidente,wf_firmado,wf_entregado,aut_workflow,cod_ruta,wf_nombre,wf_cedula,wf_fecha,wf_hora,wf_pedir_rec,tipo_requis,
	   marcar,aut_workflow_user,aut_workflow_fecha,user_entrego,periodo_pago,user_firmas,firma1,firma2,fecha_firma1,fecha_firma2,en_firma,fecha_paso_firma,no_cheque_ant,impreso_ok,sac_asientos,sac_anulados,
	   centro_costo,tiene_corres,user_corres,hora_captura,aut_workflow_hora,hora_impresion,hora_anulado,pre_autorizado
  from chqchmae
 where fecha_impresion >= a_fecha_desde
   and fecha_impresion <= a_fecha_hasta
   and autorizado = 1
   and pagado     = 1
  into temp prueba;

insert into deivid_ttcorp:tmp_chqchmae
select * from prueba;

drop table prueba;

select t.*
  from chqchmae c, chqchcta t
 where c.no_requis = t.no_requis
   and c.fecha_impresion >= a_fecha_desde
   and c.fecha_impresion <= a_fecha_hasta
   and c.autorizado = 1
   and c.pagado     = 1
  into temp prueba;

insert into deivid_ttcorp:tmp_chqchcta
select * from prueba;

drop table prueba;

return 0,  "Exitoso";

end procedure








