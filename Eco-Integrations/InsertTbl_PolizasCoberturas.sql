 /****** Script for SelectTopNRows command from SSMS  ******/
INSERT INTO [SWFIntegrationCore].[dbo].[Tbl_PolizasCoberturas](
      [IdPoliza]
      ,[IdItem]
      ,[Cobertura]
      ,[SumaAsegurada]
      ,[Deducible]
      ,[LimitePorPersona]
      ,[LimitePorAccidente]
      ,[PrimaBruta]
      ,[IdCompania]
      ,[IdEndoso]
      ,[NroCertificado]
      ,[CodProducto]
      ,[CodRamo]
      ,[CodCorredor]
      ,[Fecha]
      ,[FechaCreacion]
      ,[CodCobertura])
select *
  from openquery(dataserver,'
select mae.no_poliza as IdPoliza
      ,cob.no_unidad as IdItem
      ,rcob.nombre as Cobertura
      ,u.suma_asegurada as SumaAsegurada
      ,cob.deducible as Deducible
      ,cob.limite_1 as LimitePorPersona
      ,cob.limite_2 as LimitePorAccidente
      ,cob.prima_neta as PrimaBruta
      ,4 as IdCompania
      ,cob.no_endoso as IdEndoso
      ,cob.no_unidad as NroCertificado
      ,u.cod_producto as CodProducto
      ,emi.cod_ramo as CodRamo
      ,pol.cod_agente as CodCorredor
      ,mae.fecha_emision as Fecha
      ,mae.fecha_emision as FechaCreacion
      ,cob.cod_cobertura as CodCobertura
  from endedmae mae
 inner join emipomae emi on (emi.no_poliza = mae.no_poliza and mae.actualizado = 1 and mae.fecha_emision >= ''01/01/2021'' and mae.fecha_emision <= ''15/04/2021'')
 inner join emipoliza pol on (pol.no_poliza = mae.no_poliza and pol.cod_agente in (''02111'',''02569''))
 inner join endeduni u on (mae.no_poliza = u.no_poliza and mae.no_endoso = u.no_endoso)
 inner join endedcob cob on (cob.no_poliza = u.no_poliza and cob.no_endoso = u.no_endoso and cob.no_unidad = u.no_unidad)
 inner join prdcober rcob on (cob.cod_cobertura = rcob.cod_cobertura)')