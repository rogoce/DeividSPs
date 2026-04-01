/* Query para la extracción de la información de Vida Individual*/
select *
  from openquery(dataserver,
  '
		  
		  select sub.nombre as subramo,prd.cod_producto,prd.nombre as producto,emi.no_poliza,emi.no_documento,ori.vigencia_inic,emi.vigencia_final,
			   emi.vigencia_fin_pol,ori.fecha_suscripcion,per.nombre as periodo_pago,ase.fecha_aniversario,0 as edad,ase.sexo,ase.fumador,emi.suma_asegurada,
			  case when agt.tipo_agente = ''O'' then ''SIN CORREDOR'' else ''CON CORREDOR'' end as corredor,
			  round(((emi.prima_suscrita - emi.prima_retenida)/emi.prima_suscrita),2) as cesion,emi.prima_suscrita,
			  (emi.prima_suscrita/emi.no_pagos) as prima_pagos,emi.no_pagos,
			  sum(bon.monto_bono) as bono_vida
		  from emipomae emi
		 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
		 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
		 inner join emipouni uni on uni.no_poliza = emi.no_poliza
		 inner join prdprod prd on prd.cod_producto = uni.cod_producto
		 inner join cliclien ase on ase.cod_cliente = uni.cod_asegurado
		 inner join cobperpa per on per.cod_perpago = emi.cod_perpago
		 inner join emipomae ori on ori.no_documento = emi.no_documento and ori.nueva_renov = ''N''
		 inner join emipoliza pol on pol.no_documento = emi.no_documento
		 inner join agtagent agt on agt.cod_agente = pol.cod_agente
		  left join chqbono019 bon on bon.no_poliza = emi.no_poliza
		 where emi.cod_ramo in (''019'')
		   and emi.vigencia_inic <= ''31/03/2026''
		   and emi.vigencia_final >= ''01/03/2026''
		   and emi.actualizado = 1
		   and (emi.estatus_poliza in (1,3) or (emi.estatus_poliza in (2,4) and emi.fecha_cancelacion >= ''31/03/2026'')
		       )
		   --and emi.fecha_suscripcion <= ''31/03/2026''
		 group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 
		 order by 5,7
  '  
  )

  /* Generar el archivo del Pasivo por Cobertura Restante. */ -- Pendiente la integración los Gastos de Adquisición y los Gastos Generales
  select *
    from openquery(dataserver,'execute procedure sp_niif12b(''2026-03'',''2026-03'',''001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023,026;'')' )

/* Generar el detalle de transacciones de reclamo. */
  select *
    from openquery(dataserver,'execute procedure sp_niif09e(''2026-03'',''2026-03'',''001,002,003,004,005,006,007,008,009,010,011,012,013,014,015,016,017,018,019,020,021,022,023;'')' )

/* Detalle de Pólizas del Ramo Fianzas*/
select *
    from openquery(dataserver,
'
select emi.no_documento,emi.vigencia_inic,emi.vigencia_final,emi.prima_suscrita,emi.prima_retenida,emi.suma_asegurada,sub.nombre as subramo,con.tipo_contrato,nif.clave_ramo||''-''||nif.clave_subramo||''-''||nif.cat1_n||''-''||nif.cat2_n as enlace_contable
       ,rea.prima as prima_Contrato,rea.suma_asegurada as suma_asegurada_contrato,2026-03 as anio
  from emipomae emi
 inner join prdsubra sub on sub.cod_ramo = emi.cod_ramo and sub.cod_subramo = emi.cod_subramo
 inner join emifacon rea on rea.no_poliza = emi.no_poliza
 inner join reacomae con on con.cod_contrato = rea.cod_contrato
 inner join deivid_tmp:sc_niif17 nif on nif.codramo = emi.cod_ramo and nif.codsubramo = emi.cod_subramo
 where emi.cod_ramo = ''008''
   and (emi.estatus_poliza in (1,3) or (emi.estatus_poliza in (2,4) and emi.fecha_cancelacion > ''31/03/2026''))
   and emi.vigencia_inic between ''01/03/2026'' and  ''31/03/2026'' 
   and emi.actualizado = 1
'
)

 select *
    from openquery(dataserver,'execute procedure DetalleContableGastosAdq(''2026-03'',''2026-03'')')
-- execute procedure DetalleContableGastos('2026-01','2026-01')


/* Detalle de Consolidado de Reservas*/
execute procedure sp_rec02('001','001','2026-03',"*","*","*","*","*")

select tmp.numrecla,rec.fecha_siniestro,tmp.reserva_bruto,tmp.reserva_neto,
       tmp.reserva_bruto - tmp.reserva_neto as res_cedida,tmp.categoria_contable,'2026-03' as corte
       ,'ReservaRegular' as tipo_res,rec.fecha_reclamo
  from tmp_sinis tmp
 inner join recrcmae rec on rec.no_reclamo = tmp.no_reclamo
 where seleccionado = 1
 order by 1
 
 /* Balance de Prueba en formato de Equivalencia de Cuentas NIIF17*/
 --execute procedure sp_sacniif17_1('2026',3,2,'sac')