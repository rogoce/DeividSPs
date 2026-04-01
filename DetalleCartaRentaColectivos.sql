select rec.numrecla,rec.no_unidad,rec.cod_asegurado,uni.cod_asegurado,cli.nombre,dep.cod_cliente,clp.nombre,rec.cod_reclamante--,trx.transaccion
       ,sum(cob.facturado) fact,sum(cob.elegible) eleg,sum(cob.a_deducible) deduc ,sum(cob.co_pago)copago,sum(cob.monto_no_cubierto) no_cubierto,sum(cob.coaseguro) coas,sum(cob.ahorro) ahorro,sum(cob.monto) pag
  from emipomae emi
 inner join emipouni uni on uni.no_poliza = emi.no_poliza
 inner join emidepen dep on dep.no_poliza = uni.no_poliza and dep.no_unidad = uni.no_unidad
 inner join recrcmae rec on rec.no_poliza = emi.no_poliza  and rec.no_unidad = uni.no_unidad and rec.cod_reclamante = dep.cod_cliente
 inner join rectrmae trx on trx.no_reclamo = rec.no_reclamo and trx.cod_tipotran not in ('001','002','003')
 inner join rectrcob cob on cob.no_tranrec = trx.no_tranrec
 inner join rectitra tip on tip.cod_tipotran = trx.cod_tipotran
 inner join cliclien cli on cli.cod_cliente = uni.cod_asegurado
 inner join cliclien clp on clp.cod_cliente = dep.cod_cliente
-- inner join atcdocde
 where emi.no_documento = '1822-00381-01'
   and emi.actualizado = 1
   and trx.periodo between '2022-01' and '2022-12'
   and trx.actualizado = 1
 group by rec.numrecla,rec.no_unidad,rec.cod_asegurado,uni.cod_asegurado,cli.nombre,dep.cod_cliente,clp.nombre,rec.cod_reclamante
 order by 2,3,rec.cod_reclamante
 
