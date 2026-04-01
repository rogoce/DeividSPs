SELECT a.no_poliza,b.no_unidad,a.no_documento, TO_CHAR(a.vigencia_inic, '%Y-%m-%d') AS vigencia_inic,
    TO_CHAR(a.vigencia_final, '%Y-%m-%d') AS vigencia_final, descripcion, estatus_poliza FROM emipomae a inner join emipode2 b on a.no_poliza = b.no_poliza
WHERE cod_ramo <> '002' and descripcion is not null and vigencia_inic >= '01/01/2023'
