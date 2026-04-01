USE [SWFIntegrationCore]
GO

INSERT INTO [dbo].[Tbl_Polizas]
           ([IdPoliza]
           ,[IdCompania]
           ,[IdContratante]
           ,[Nombres]
           ,[Apellidos]
           ,[RazonSocial]
           ,[IdTipoPersona]
           ,[Identificacion]
           ,[Email]
           ,[Telefono]
           ,[Direccion]
           ,[NroPoliza]
           ,[FechaFacturacion]
           ,[FechaDesde]
           ,[FechaHasta]
           ,[CodRamo]
           ,[Ramo]
           ,[CodFormaPago]
           ,[FormaPago]
           ,[CodFrecuenciaPago]
           ,[FrecuenciaPago]
           ,[PorcComision]
           ,[CodigoCorredor]
           ,[PrimaBruta]
           ,[PorcImpuesto]
           ,[Impuesto]
           ,[Descuento]
           ,[PrimaNeta]
           ,[IdTipoPoliza]
           ,[CantidadLetras]
           ,[DocPoliza]
           ,[LinkDescargaDoc]
           ,[FechaCreacion]
           ,[Estatus]
           ,[Pais]
           ,[Provincia]
           ,[Sexo]
           ,[IdEndoso]
           ,[TipoEndoso]
           ,[CodTipoEndoso]
           ,[NroFactura]
           ,[CodPlan]
           ,[RevPlan]
           ,[FechaNacimiento]
           ,[Agente]
           ,[PrimaBrutaConDecRec]
           ,[Recargo]
           ,[PrimaSinRecaDcto])
    
select *
  from openquery(dataserver,'select 
       mae.no_poliza
       ,4 as IdCompania
       ,con.cod_cliente
       ,case con.tipo_persona when ''N'' then trim(nvl(con.aseg_primer_nom,'''')) || '' '' || trim(nvl(con.aseg_segundo_nom,'''')) else '''' end as nombres
       ,trim(nvl(con.aseg_primer_ape,'''')) || '' '' ||  trim(nvl(con.aseg_segundo_ape,'''')) as apellidos
       ,case con.tipo_persona when ''N'' then '''' else con.nombre_razon end razon_social
       ,case con.tipo_persona when ''N'' then 2 when ''J'' then 1 else 3 end IdTipoPersona
       ,con.cedula
       ,con.e_mail
       ,con.telefono1
       ,trim(con.direccion_1) || trim(con.direccion_2) as direccion
       ,mae.no_documento
       ,mae.fecha_emision
       ,mae.vigencia_inic_pol
       ,mae.vigencia_final_pol
       ,emi.cod_ramo
       ,ram.nombre as ramo
       ,emi.cod_formapag
       ,pag.nombre as FormaPago
       ,emi.cod_perpago
       ,per.nombre as FrecuenciaPago
       ,agt.porc_comis_agt as PorcComision
       ,agt.cod_agente as CodigoCorredor
       ,mae.prima_bruta
       ,case mae.prima_neta when 0 then 0 else round(abs(mae.impuesto/mae.prima_neta) *100,0) end as PorcImpuesto
       ,mae.impuesto
       ,mae.descuento
       ,mae.prima_neta
       ,'''' as IdTipoPoliza
       ,emi.no_pagos
       ,'''' as DocPoliza
       ,'''' as LinkDocPoliza
       ,mae.fecha_emision as FechaCreacion
       ,Case emi.estatus_poliza when 1 then ''VIGENTE'' when 2 then ''CANCELADA'' when 3 then ''VENCIDA'' when 4 then ''ANULADA'' end Estatus
       ,con.nacionalidad as pais
       ,'''' as Provincia
       ,con.sexo
       ,case mae.no_endoso when ''00000'' then null else mae.no_endoso end IdEndoso
       ,mov.nombre as TipoEndoso
       ,mae.cod_endomov
	   ,mae.no_factura as NroFactura
       ,sub.nombre as CodPlan
       ,'''' as RevPlan
       ,con.fecha_aniversario
       ,mae.user_added as agente
       ,0 as PrimaBrutaConDecRec --???
       ,mae.recargo
       ,0 as PrimaSinRecaDcto --???
  from endedmae mae
 inner join emipomae emi
         on emi.no_poliza = mae.no_poliza
        and mae.fecha_emision between ''01/01/2021'' and ''15/04/2021''
     --   and mae.no_endoso = ''00000''
 inner join emipoliza pol
         on pol.no_poliza = mae.no_poliza
		and pol.cod_agente in (''02111'',''02569'')
 inner join cliclien con
         on con.cod_cliente = emi.cod_contratante
 inner join prdramo ram
         on ram.cod_ramo = emi.cod_ramo
 inner join cobforpa pag
         on pag.cod_formapag = emi.cod_formapag
 inner join cobperpa per
         on per.cod_perpago = emi.cod_perpago
 inner join endtimov mov
         on mov.cod_endomov = mae.cod_endomov
 inner join prdsubra sub
         on sub.cod_ramo = emi.cod_ramo
        and sub.cod_subramo = emi.cod_subramo
  left join endmoage agt
         on agt.no_poliza = mae.no_poliza
        and agt.no_endoso = mae.no_endoso
		
  left join agtagent cor
         on cor.cod_agente = agt.cod_agente
        and cor.tipo_agente = ''A''
  where mae.actualizado = 1')