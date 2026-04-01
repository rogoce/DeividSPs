
DROP procedure sp_che200;
CREATE procedure sp_che200(a_periodo1 char(7),a_periodo2 char(7))
RETURNING char(3), date,char(12),char(50),char(12),dec(16,2), dec(16,2),dec(16,2);

DEFINE _cod_auxiliar    CHAR(10);
define _res_cuenta,_indiv_col      char(12);
DEFINE _res_fechatrx,_fecha1,_fecha2    date;
define _res_origen    char(3);
define _cta_nombre    char(50);
define _db,_cr   dec(16,2);


let _fecha1 = sp_sis40b(a_periodo1);
let _fecha2 = sp_sis36(a_periodo2);

foreach
	select res_origen,res_fechatrx,res_cuenta,cta_nombre,case emi.cod_subramo when '012' then 'COLECTIVO' when null then 'BLANCO' else 'INDIVIDUAL' end as indiv_col,asi.debito,asi.credito
	  into _res_origen,_res_fechatrx,_res_cuenta,_cta_nombre,_indiv_col,_db,_cr
	  from cglcuentas cgl
	 inner join cglresumen res on res_cuenta = cta_cuenta
	  left join recasien asi on asi.sac_notrx = res_notrx and asi.cuenta = res_cuenta and asi.centro_costo = res_ccosto
	  left join rectrmae mae on mae.no_tranrec = asi.no_tranrec
	  left join recrcmae rec on rec.no_reclamo = mae.no_reclamo
	  left join emipomae emi on emi.no_poliza = rec.no_poliza
	where res_fechatrx between _fecha1 and _fecha2
	   and cta_nombre like '%HOSP%'
	   and res_origen = 'REC'
	union all
	select res_origen,res_fechatrx,res_cuenta,cta_nombre,case emi.cod_subramo when '012' then 'COLECTIVO' when null then 'BLANCO' else 'INDIVIDUAL' end as indiv_col,asi.debito,asi.credito
	  from cglcuentas cgl
	inner join cglresumen res on res_cuenta = cta_cuenta
	  left join cobasien asi on asi.sac_notrx = res_notrx and asi.cuenta = res_cuenta and asi.centro_costo = res_ccosto
	  left join cobredet mae on mae.no_remesa = asi.no_remesa and mae.renglon = asi.renglon
	  left join emipomae emi on emi.no_poliza = mae.no_poliza
	where res_fechatrx between _fecha1 and _fecha2
	   and cta_nombre like '%HOSP%'
	   and res_origen = 'COB'
	union all
	select res_origen,res_fechatrx,res_cuenta,cta_nombre,case emi.cod_subramo when '012' then 'COLECTIVO' else 'INDIVIDUAL' end as indiv_col,asi.debito,asi.credito
	  from cglcuentas cgl
	inner join cglresumen res on res_cuenta = cta_cuenta
	  left join endasien asi on asi.sac_notrx = res_notrx and asi.cuenta = res_cuenta and asi.centro_costo = res_ccosto
	  left join endedmae mae on mae.no_poliza = asi.no_poliza and mae.no_endoso = asi.no_endoso
	  left join emipomae emi on emi.no_poliza = mae.no_poliza
	where res_fechatrx between _fecha1 and _fecha2
	   and cta_nombre like '%HOSP%'
	   and res_origen = 'PRO'
	union all
	select res_origen,res_fechatrx,res_cuenta,cta_nombre,'' as indiv_col,res_debito,res_credito
	  from cglcuentas cgl
	inner join cglresumen res on res_cuenta = cta_cuenta
	where res_fechatrx between _fecha1 and _fecha2
	   and cta_nombre like '%HOSP%'
	   and res_origen in ('CGL')

	return _res_origen,_res_fechatrx,_res_cuenta,_cta_nombre,_indiv_col,_db,_cr,_db - abs(_cr) with resume;
end foreach 
 

END PROCEDURE;