select ram.nombre as Ramo,emi.no_documento as Poliza,pro.nombre as tipo_produccion, emi.cod_contratante, con.nombre as Contratante, CASE con.cliente_pep WHEN 0 then 'NO' WHEN 1 then 'SI' END as cliente_pep,
       cor.cod_agente,agt.nombre as corredor,zon.nombre as vendedor,emi.fecha_suscripcion,suc.descripcion as sucursal,rie.nombre as ponderacion,CASE emi.nueva_renov WHEN 'N' then 'NUEVA' WHEN 'R' THEN 'RENOVACION' END as Nueva_Renov,emi.user_added,
       emi.prima_neta,emi.prima_bruta,per.cod_perpago,per.nombre as perpago
  from emipomae emi
 inner join prdramo ram
         on ram.cod_ramo = emi.cod_ramo
        --and emi.fecha_suscripcion > '01/09/2020'
     -- and emi.cod_sucursal <> '009'
        and emi.actualizado = 1
        and emi.estatus_poliza = 1
     -- and emi.nueva_renov = 'N'
 inner join emipoagt cor
         on cor.no_poliza = emi.no_poliza
 inner join agtagent agt
         on cor.cod_agente = agt.cod_agente
 inner join agtvende zon
         on agt.cod_vendedor = zon.cod_vendedor
 inner join cliclien con
         on con.cod_cliente = emi.cod_contratante
 inner join insagen suc
         on emi.cod_sucursal = suc.codigo_agencia
 inner join emitipro pro
         on pro.cod_tipoprod = emi.cod_tipoprod
 inner join cobperpa per
         on per.cod_perpago = emi.cod_perpago
  left join ponderacion pon
         on pon.cod_cliente = con.cod_cliente
  left join cliriesgo rie
         on rie.cod_riesgo = pon.cod_riesgo
--  order by sucursal,fecha_suscripcion
