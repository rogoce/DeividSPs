select replace(ase.cedula,'-','') as _id ,ase.aseg_primer_ape,trim(nvl(ase.aseg_primer_nom,'')) || ' ' || trim(nvl(ase.aseg_segundo_nom,'')),trim(nvl(ase.aseg_primer_ape,'')),
       '-1' as  relacion,decode(ase.sexo,'F',0,'M',1) as genero,ase.fecha_aniversario,trim(replace(ase.cedula,'-','')) as di,min(uni.vigencia_inic) as fecha_inicio,max(uni.vigencia_final),ram.nombre as ramo,ase.e_mail,trim(replace(ase.celular,'-','')) as celular,1 as operacion
       ,ase.cod_cliente,emi.no_documento,1 as const
  from emipomae emi
 inner join emipouni uni on uni.no_poliza = emi.no_poliza and uni.activo = 1
 inner join cliclien ase on ase.cod_cliente = uni.cod_asegurado
 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
 where emi.cod_ramo = '018'
   and emi.actualizado = 1
   and emi.estatus_poliza = 1
   and ase.tipo_persona = 'N'
 group by 1,2,3,4,5,6,7,8,11,12,13,ase.cod_cliente,emi.no_documento

union

select replace(ase.cedula,'-','') as _id ,ase.aseg_primer_ape,trim(nvl(ase.aseg_primer_nom,'')) || ' ' || trim(nvl(ase.aseg_segundo_nom,'')),trim(nvl(ase.aseg_primer_ape,'')),
       '-1' as  relacion,decode(ase.sexo,'F',0,'M',1) as genero,ase.fecha_aniversario,trim(replace(ase.cedula,'-','')) as di,min(uni.vigencia_inic) as fecha_inicio,max(uni.vigencia_final),ram.nombre as ramo,ase.e_mail,trim(replace(ase.celular,'-','')) as celular,1 as operacion
       ,ase.cod_cliente,emi.no_documento,1 as const
  from emipomae emi
 inner join emipouni uni on uni.no_poliza = emi.no_poliza
 inner join prdramo ram on ram.cod_ramo = emi.cod_ramo
 inner join emidepen dep on dep.no_poliza = uni.no_poliza and dep.no_unidad = uni.no_unidad and dep.activo = 1
 inner join cliclien ase on ase.cod_cliente = dep.cod_cliente
 where emi.cod_ramo = '018'
   and emi.actualizado = 1
   and emi.estatus_poliza = 1
   and ase.tipo_persona = 'N'
 group by 1,2,3,4,5,6,7,8,11,12,13,ase.cod_cliente,emi.no_documento
 order by fecha_aniversario
