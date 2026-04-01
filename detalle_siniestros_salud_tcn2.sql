select trx.periodo[1,4] as anio,trx.periodo,trx.transaccion,trx.anular_nt,emi.no_documento,rec.cod_asegurado,rec.cod_reclamante,rec.numrecla,cob.cod_cobertura,cob.nombre as cob,prd.cod_producto,prd.nombre,sub.cod_subramo,sub.nombre as subramo,rec.fecha_siniestro,rec.estatus_reclamo,trx.fecha,icd.cod_icd,icd.nombre as diagnostico,cpt.cod_cpt,cpt.nombre as procedimiento,
       tco.facturado,tco.monto_no_cubierto,tco.elegible,tco.co_pago,tco.coaseguro,tco.a_deducible,tco.ahorro,tco.monto,tco.cod_no_cubierto,cub.nombre as no_cubierto
  from rectrmae trx
 inner join recrcmae rec on rec.no_reclamo = trx.no_reclamo
 inner join emipomae emi on emi.no_poliza = rec.no_poliza
 inner join emipouni uni on uni.no_poliza = rec.no_poliza and uni.no_unidad = rec.no_unidad
 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
 inner join rectipag tip on tip.cod_tipopago = trx.cod_tipopago
 inner join rectrcob tco on tco.no_tranrec = trx.no_tranrec
 inner join prdcober cob on cob.cod_cobertura = tco.cod_cobertura
 inner join prdprod prd on prd.cod_producto = uni.cod_producto
   left join recicd icd on icd.cod_icd = rec.cod_icd
   left join reccpt cpt on cpt.cod_cpt = trx.cod_cpt
   left join recnocub cub on cub.cod_no_cubierto = tco.cod_no_cubierto
 where trx.cod_tipotran = '004'
   and trx.periodo between '2018-01' and '2023-12'
   and trx.actualizado = 1
   and emi.cod_ramo = '018'
   --and emi.cod_subramo not in ('010','012')
   and trx.anular_nt is not null
