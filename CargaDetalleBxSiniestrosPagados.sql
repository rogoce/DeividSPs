 use Stage_AnconBI

select rea.serie,det.poliza,det.NombreAsegurado,det.periodo,det.fecha_siniestro,det.reclamo,det.diagnostico,det.afavorde,det.fecha_factura,det.fecha_pagado,det.cheque,det.FechaImpresion as fecha_cheque,
       det.facturado,det.montonocubierto,det.elegible,det.ahorro,det.adeducible,det.copago,det.coaseguro,det.montopagado
  from DetallePagoReclamosSaludAP det
 inner join Stage_AnconBI..rearumae rea on det.fecha_factura between rea.vig_inic and rea.vig_final and rea.cod_ramo = '018'
 inner join (select sal.CodAsegurado,sal.NombreAsegurado,sum(sal.montopagado) as MontoPagado 
               from DetallePagoReclamosSaludAP sal
			 where periodo <= '2025-06'
			 group by sal.CodAsegurado,sal.NombreAsegurado
			) rec on rec.CodAsegurado = det.CodAsegurado and rec.MontoPagado >= 75000
 --where det.poliza = '1811-01169-01'
 order by det.NombreAsegurado,det.fecha_factura,rea.serie,det.poliza,det.reclamo
 --group by CodAsegurado,NombreAsegurado,rea.serie
 --order by MontoPagado desc  1811-01169-01
 --61024

/*select periodo,count(*),sum(MontoPagado)
  from Stage_AnconBI..DetallePagoReclamosSaludAP
 group by periodo
 order by periodo
*/
insert into Stage_AnconBI..Tbl_DetalleReclamosPersonas
select *,CONCAT(year(Fecha_Factura),'-',right(concat('00',month(Fecha_Factura)),2)),'' from openquery (dataserver, 'execute procedure sp_rec748(''2025-07'',''2025-07'')')


select IdVigPolizas,FechaFactura,FechaReclamo,*
  from Tbl_DetalleReclamosPersonas 
 where  periodo >= '2025-01'
   and Ramo = 'SALUD'
   and IdVigPolizas !=0
 order by Poliza,2

select top 1000 * from Stage_AnconBi..DetallePagoReclamosSaludAP where periodo = '2025-11'
--CONCAT(year(FechaFactura),'-',right(concat('00',month(FechaFactura)),2)) 

select *
/*update det
   set det.IdVigPolizas = vig.IdVigPolizas
*/
  from Tbl_DetalleReclamosPersonas det
 inner join Stage_AnconBI..Tbl_VigenciaPolizas vig on det.No_Poliza = vig.NoPoliza and det.FechaTrx between vig.VigenciaDesde and vig.VigenciaHasta
 where Isnull(det.IdVigPolizas,0) = 0


 select * from Stage_AnconBI..vwEndedmaeBI where periodo >= '2025-01'
