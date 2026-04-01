drop procedure sp_pro333;

create procedure "informix".sp_pro333(a_periodo char(7),a_fecha date)
returning integer;

begin

INSERT INTO hemirepo(
no_poliza,
user_added,
cod_no_renov,
no_documento,
renovar,
no_renovar,
fecha_selec,
vigencia_inic,
vigencia_final,
saldo,
cant_reclamos,
no_factura,
incurrido,
pagos,
porc_depreciacion,
cod_agente,
estatus,
cod_sucursal,
user_cobros
)
SELECT
no_poliza,
user_added,
cod_no_renov,
no_documento,
renovar,
no_renovar,
fecha_selec,
vigencia_inic,
vigencia_final,
saldo,
cant_reclamos,
no_factura,
incurrido,
pagos,
porc_depreciacion,
cod_agente,
estatus,
cod_sucursal,
user_cobros
FROM emirepo
WHERE fecha_selec = a_fecha;

INSERT INTO hemirepo(
no_poliza,
user_added,
cod_no_renov,
no_documento,
renovar,
no_renovar,
fecha_selec,
vigencia_inic,
vigencia_final,
saldo,
cant_reclamos,
no_factura,
incurrido,
pagos,
porc_depreciacion,
cod_agente,
estatus
)
SELECT
no_poliza,
user_added,
cod_no_renov,
no_documento,
renovar,
no_renovar,
fecha_selec,
vigencia_inic,
vigencia_final,
saldo,
cant_reclamos,
no_factura,
incurrido,
pagos,
porc_depreciacion,
cod_agente,
estatus
FROM emirepol
WHERE fecha_selec = a_fecha
AND   estatus     = 4;

update hemirepo
   set periodo_renovar = a_periodo
 where fecha_selec     = a_fecha;

end 
return 0;

end procedure;
