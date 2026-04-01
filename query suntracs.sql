select e.no_documento,count(*),sum(e.prima_bruta)
  from emipomae p,endedmae e
 where p.no_poliza = e.no_poliza
   and p.vigencia_inic > '01/06/2018'
   and p.cod_grupo = '01016'
   and e.actualizado = 1
   --and e.periodo >= '2018-06'
   and p.cod_ramo = '016'
   --and e.cod_endomov = '006'
   group by 1
