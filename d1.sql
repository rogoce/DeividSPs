INSERT INTO bcocirc (compania,cod_banco,cod_ctabanco,tipo_proceso,nodocmto,
fecha,
                     anombre,monto,estado,fechacap,no_requis,tipo_docu)
SELECT cod_compania,cod_banco,cod_chequera,"04",no_cheque,fecha_impresion,
a_nombre_de,
        monto,anulado,fecha_captura,no_requis,"CK"
   FROM chqchmae
 WHERE no_requis NOT IN (SELECT no_requis FROM  bcocirc)
   AND fecha_impresion >= "01/01/2009"
   AND fecha_impresion <> Today
   AND tipo_requis <> "A"
   AND no_cheque not in (0,194039,196216,194901,41261)

