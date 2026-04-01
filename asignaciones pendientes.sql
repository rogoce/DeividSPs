select cod_asignacion, atcdocde.ajustador_asignado , atcdocde.ajustador_asignar , atcdocde.ajustador_fecha , atcdocde.cod_ajustador , atcdocde.cod_asegurado, atcdocde.cod_entrada , atcdocde.cod_icd , atcdocde.cod_reclamante , atcdocde.completado , atcdocde.date_added , atcdocde.fecha_scan , atcdocde.auditado , atcdocde.date_susp_add , atcdocde.date_susp_rem , atcdocde.escaneado , atcdocde.fecha_completado , atcdocde.imcs_asignar , atcdocde.imcs_enviado , atcdocde.imcs_fecha_enviado , atcdocde.imcs_fecha_regreso , atcdocde.imcs_regreso , atcdocde.monto , atcdocde.no_documento , atcdocde.no_unidad , atcdocde.suspenso , atcdocde.titulo , atcdocde.user_added
from atcdocde
where completado = 0
and escaneado = 1
and ajustador_asignar = 1
and suspenso = 0
order by ajustador_asignado desc, date_added
