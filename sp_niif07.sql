-- Llamado de las Remesas y Endoso que afectan a las pólizas en emiletra de manera cronologica.
-- Creado    : 01/12/2014 - Autor: Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_niif07;

create procedure sp_niif07(a_periodo_desde char(7), a_periodo_hasta char(7))
returning	char(10)	 as no_poliza,
			char(20)	as no_documento,
			date		as vigencia_inic,
			date		as vigencia_final,
			char(3)		as cod_ramo,
			smallint	as estatus_poliza,
			smallint	as no_pagos,
			dec(16,2)	as prima_neta,
			dec(16,2)	as prima_suscrita,
			dec(16,2)	as prima_cedida,
			dec(16,2)	as prima_bruta,
			dec(16,2)	as prima_neta_cob,
			dec(16,2)	as monto_cob,
			smallint	as no_vigencias,
			smallint	as clasificacion;
			
			
define _error_desc		char(50);
define _documento		char(10);
define _no_documento	char(20);
define _no_remesa		char(10);
define _no_poliza		char(10);
define _cod_agente			char(5);
define _no_endoso			char(5);
define _cod_ramo			char(3);
define _tipo_doc			char(1);
define _estatus_poliza		smallint;
define _valor		smallint;
define _no_vigencias		smallint;
define _clasificacion		smallint;
define _no_pagos			smallint;
define _cnt_cob			smallint;
define _vigencia_inic	date;
define _vigencia_final	date;
define _error_isam		integer;
define my_sessionid		integer;
define _error			integer;
define _porc_partic_agt		dec(9,6);
define _porc_comis_agt		dec(9,6);
define _prima_neta_cob		dec(16,2);
define _mto_comision		dec(16,2);
define _monto_cob		dec(16,2);
define _prima_neta		dec(16,2);
define _prima_suscrita		dec(16,2);
define _prima_cedida		dec(16,2);
define _prima_bruta		dec(16,2);
define _monto2		dec(16,2);



set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	
	--let _error_desc = 'poliza: ' || trim(_no_poliza) || trim(_documento) || trim(_error_desc);
	return null,
		   _error_desc,
		   null,
		   null,
		   null,
		   _error,
		   0,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0.00,
		   0;
end exception


--set debug file to "sp_pro545.trc";
--trace on;

drop table if exists fichero_auto;
create temp table fichero_auto(
no_documento			char(20),--
vigencia_inic			date,--
vigencia_final			date,--
clasificacion_niif		char(10),
clasificacion_adic		char(10),
prima_bruta				dec(16,2),--
prima_neta				dec(16,2),--
prima_suscrita			dec(16,2),--
prima_cedida			dec(16,2),--
prima_cobrada			dec(16,2),--??
provision_prima			dec(16,2),
provision_siniestro		dec(16,2),
siniestros_pagados		dec(16,2),
siniestros_pendientes	dec(16,2),
monto_comision			dec(16,2),--
gastos_admin			dec(16,2),
otros_gastos_adq		dec(16,2),
pagos_reas_cedido		dec(16,2),
comis_reas_cedido		dec(16,2),
ingresos_gastos_coa		dec(16,2),
ingresos_financiero		dec(16,2),
gastos_financiero		dec(16,2),
cod_ramo				char(3),--
no_poliza				char(10),--
estatus_poliza			smallint,--
no_pagos				smallint,--
comision				dec(9,2),
nueva_renov				char(1),
tipo					smallint,
primary key (no_poliza)) with no log;


{foreach with hold
	select distinct no_documento
	  into a_no_documento
	  from emipomae
	 where no_documento in (select distinct no_documento from endedmae where no_endoso = '00000' and activa = 0)
	begin work;}

let my_sessionid = DBINFO('sessionid');

foreach with hold
	select first 100 emi.no_poliza,
		   emi.no_documento,
		   mae.vigencia_inic,
		   mae.vigencia_final,
		   mae.cod_ramo,
		   mae.estatus_poliza,
		   mae.no_pagos,
		   sum(emi.prima_neta),
		   sum(emi.prima_suscrita),
		   sum(emi.prima_suscrita - emi.prima_retenida),
		   sum(emi.prima_bruta)		   
	  into _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza,
		   _no_pagos,
		   _prima_neta,
		   _prima_suscrita,
		   _prima_cedida,
		   _prima_bruta
	  from endedmae emi
	 inner join emipomae mae on mae.no_poliza = emi.no_poliza
	 where emi.periodo >= a_periodo_desde
	   and emi.periodo <= a_periodo_hasta 
	   and emi.actualizado = 1
	   --and mae.cod_ramo in ('002','020','023')
	 group by emi.no_poliza,emi.no_documento,mae.vigencia_inic,mae.vigencia_final,mae.cod_ramo,	mae.estatus_poliza,mae.no_pagos
	   
	let _valor = sp_sis101a(_no_documento,'01/01/2021','31/12/2021', my_sessionid);
	let _mto_comision = 0;

	foreach
		select cod_agente,
		       porcentaje,
			   porc_comis_agt
		  into _cod_agente,
               _porc_partic_agt,
			   _porc_comis_agt
		  from con_corr
		 where sessionid = my_sessionid		
		
		let _monto2 = 0.00;
		let _monto2 = _prima_neta * (_porc_partic_agt /100) * (_porc_comis_agt /100);
		let _mto_comision = _mto_comision + _monto2;
	end foreach
	
	select sum(prima_neta),
		   sum(monto)
	  into _prima_neta_cob,
		   _monto_cob
	  from cobredet
	 where no_poliza = _no_poliza
	   and tipo_mov in ('P','N','X')
	   and actualizado = 1;

	select count(*)
	  into _no_vigencias
	  from emipomae
	 where no_documento = _no_documento
	   and actualizado = 1;

	if _cod_ramo = '020' then
		let _clasificacion = 2;
	elif _cod_ramo in ('002','023') then
		select count(*)
		  into _cnt_cob
		  from emipocob
		 where no_poliza = _no_poliza
		   and cod_cobertura in ('00119','00118','00120','00103','00121','00901','00606','01745','01794','00902','00903','00900','01746','01747','01222');

		if _cnt_cob is null then
			let _cnt_cob = 0;
		end if
		
		if _cnt_cob = 0 then
			if _cod_ramo = '002' then
				let _clasificacion = 2;
			else
				let _clasificacion = 4;
			end if
		else
			if _cod_ramo = '002' then
				let _clasificacion = 1;
			else
				let _clasificacion = 3;
			end if
		end if
	else --PENDIENTE
		
	end if

return _no_poliza,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _cod_ramo,
		   _estatus_poliza,
		   _no_pagos,
		   _prima_neta,
		   _prima_suscrita,
		   _prima_cedida,
		   _prima_bruta,
		   _prima_neta_cob,
		   _monto_cob,
		   _no_vigencias,
		   _clasificacion with resume;
		   

end foreach


end
end procedure;