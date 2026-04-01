
 
 
SELECT cod_compania,cod_banco,cod_chequera,no_cheque,count(*)
 
 
   FROM chqchmae

 WHERE fecha_impresion >= "01/01/2009"
   AND fecha_impresion <> Today
   AND tipo_requis <> "A"
   AND cod_chequera IS NOT NULL
   AND no_cheque NOT IN (0,2,194039,196216,194901,41261)
GROUP BY cod_compania,cod_banco,cod_chequera,no_cheque
having count(*) > 1
