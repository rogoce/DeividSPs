SELECT cod_compania,cod_banco,cod_chequera,"04",no_cheque,fecha_impresion,
        a_nombre_de,
        monto,anulado,fecha_captura,no_requis,"CK"
   FROM chqchmae

 WHERE fecha_impresion >= "01/01/2009" 
   AND fecha_impresion <> Today;
   AND tipo_requis <> "A" 
