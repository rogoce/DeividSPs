-- Actualizacion Masiva polizas vigentes (Codificacion de Manzanas)
-- Creado: 08/10/2008 - Autor: Armando Moreno Montenegro

drop procedure sp_pro845a;
create procedure sp_pro845a(a_cod_manzana char(15))
returning   char(15)	as cod_manzana,
			dec(16,2)	as prima,
			dec(16,2)	as suma_asegurada,
			dec(16,2)	as cumulo,
			dec(16,2)	as disponible,
			integer		as cantidad_polizas,	
			integer		as polizas_tramite,		
			integer		as suma_aseg_tramite;	


define _nombre_manzana		char(50);
define _cod_manzana		  	char(15);
define _cod_coasegur		char(3);
define _suma_aseg_tramite	dec(16,2);
define _suma_asegurada		dec(16,2);
define _disponible			dec(16,2); 
define _cumulo				dec(16,2);
define _prima				dec(16,2);
define _suma_fac_acum       dec(16,2);
define _suma_fac            dec(16,2);
define _no_unidad           char(5);
define _no_poliza           char(10);
define _fecha				date;
define _cantidad_unidades	smallint;
define _polizas_tramite		smallint;

SET ISOLATION TO DIRTY READ;

-- Seleccion del Codigo de La Compania Lider
-- y del Contrato de Retencion

LET _cod_coasegur = sp_sis02('001','001');
--set debug file to "sp_pro845.trc";
--trace on;

let _fecha = CURRENT;
let _cantidad_unidades = 0;
let _polizas_tramite = 0;
let _suma_aseg_tramite = 0.00;
let _suma_asegurada = 0.00;
let _cumulo = 0.00;
let _prima = 0.00;

select man.cod_manzana,
	   man.referencia,
	   nvl(sum(mae.suma_asegurada),0),
	   nvl(sum(cnt_unidad),0)
  into _cod_manzana,
	   _nombre_manzana,
	   _suma_asegurada,
	   _cantidad_unidades
  from emiman05 man
  left join (select uni.cod_manzana,sum(uni.suma_asegurada * (nvl(coa.porc_partic_coas,100)/100)) as suma_asegurada,count(*) as cnt_unidad
               from emipomae emi
              inner join emipouni uni on emi.no_poliza = uni.no_poliza
               left join emicoama coa on coa.no_poliza = emi.no_poliza and coa.cod_coasegur = _cod_coasegur
              where emi.cod_ramo in ('001','003')
                and emi.estatus_poliza = 1
                and emi.actualizado = 1
                and emi.vigencia_inic <= _fecha
				and uni.cod_manzana = a_cod_manzana--uni.cod_manzana_aux = a_cod_manzana
              group by uni.cod_manzana         --uni.cod_manzana_aux
             ) mae on mae.cod_manzana = man.cod_manzana--mae.cod_manzana_aux = man.cod_manzana
 where man.cod_manzana = a_cod_manzana
 group by man.cod_manzana,man.referencia;
 
 
select limite_max
  into _cumulo
  from emiman05 man
 inner join emiman06 ref on ref.cod_categoria = man.cod_categoria
 where man.cod_manzana = a_cod_manzana;

if _cumulo is null then
	let _cumulo = 0.00;
end if

--Ciclo para quitar la suma asegurada de contrato Facultativo
let _suma_fac_acum = 0;
let _suma_fac      = 0;
foreach
	select e.no_unidad,
	       e.no_poliza
	  into _no_unidad,
	       _no_poliza
	  from emipouni e, emipomae w
	 where e.no_poliza = w.no_poliza
	   and e.cod_manzana = a_cod_manzana
	   and w.estatus_poliza = 1
	order by e.no_poliza,e.no_unidad 
	 
	select sum(suma_asegurada)
      into _suma_fac
      from emifacon e, reacomae r
     where e.cod_contrato = r.cod_contrato
	   and e.no_poliza = _no_poliza
       and e.no_unidad = _no_unidad
       and r.tipo_contrato = 3
	   and e.cod_cober_reas in ('001','003');

	if _suma_fac is null then 
		let _suma_fac = 0;
	end if
	   
	let _suma_fac_acum = _suma_fac_acum + _suma_fac;   
	   
end foreach
let _suma_asegurada = _suma_asegurada - _suma_fac_acum;

let _disponible = _cumulo - _suma_asegurada;

return _cod_manzana,
       _prima,
       _suma_asegurada,
       _cumulo,
	   _disponible,
       _cantidad_unidades,
       _polizas_tramite,	
       _suma_aseg_tramite;
--trace off;
end procedure;