select tmp.numrecla,rec.fecha_siniestro,rec.fecha_reclamo,tmp.reserva_bruto,tmp.reserva_neto,
       tmp.reserva_bruto - tmp.reserva_neto as reserva_cedida,tmp.categoria_contable,2025
  from tmp_sinis tmp
 inner join recrcmae rec on rec.no_reclamo = tmp.no_reclamo
 where seleccionado = 1
