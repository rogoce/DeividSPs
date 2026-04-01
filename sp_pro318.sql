drop procedure sp_pro318;

create procedure sp_pro318(a_no_poliza char(10))
returning integer;

begin
3
INSERT INTO emirepol(
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
4
FROM emirepo
WHERE no_poliza = a_no_poliza;

end 
return 0;

end procedure;
