INSERT INTO bcocirc (compania,cod_banco,cod_ctabanco,nodocmto,
fecha,anombre,monto,estado,fechacap,no_requis,tipo_docu,tipo_proceso)
SELECT cod_compania,cod_banco,cod_chequera,no_cheque,fecha_impresion,
a_nombre_de,monto,anulado,fecha_captura,no_requis,"CK","04"
   FROM chqchmae
 WHERE fecha_impresion >= "01/01/2009"
   AND fecha_impresion <> Today
   AND tipo_requis <> "A"
   AND cod_chequera IS NOT NULL
   AND no_cheque NOT IN (0,194039,196216,194901,41261,41262)
  -- AND no_requis NOT IN (SELECT no_requis FROM  bcocirc)