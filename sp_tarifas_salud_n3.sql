--Reporte usado para generar la información para las cartas de salud
-- Creado: 13/06/2025 - Autor: Armando Moreno M.

drop procedure sp_tarifas_salud_n3;
create procedure sp_tarifas_salud_n3(a_periodo char(7))
returning char(20)     as poliza,
          char(20)     as estaus,
	      varchar(50)  as subramo,
	      varchar(50)  as producto,
	      date         as vigencia_inicial,
		  date         as vigencia_final,
		  date         as fecha_ren,
		  char(3)      as tipo,
	      varchar(50)  as asegurado,
	      varchar(50)  as email_ase,
	      varchar(50)  as contratante,
	      varchar(50)  as email_contr,
	      varchar(250) as corredor,
	      varchar(200) as email_corr,
		  smallint     as mes_vigencia,	  
          dec(16,2)    as prima,
		  dec(5,2)     as porc_rec_tec,
		  dec(16,2)    as monto_aumento_tec,
		  dec(5,2)     as aumento1,
		  dec(16,2)    as mto_primer_ajuste,
		  dec(16,2)    as mto_prima_resul1,
		  dec(16,2)    as prima_bruta,
		  dec(5,2)     as aumento2,
		  dec(16,2)    as mto_segundo_ajuste,
		  dec(16,2)    as mto_sdo_ajus_imp,
		  dec(16,2)    as mto_prima_resul2,
		  dec(16,2)    as prima_bruta_ren,
		  varchar(40)  as periodo_pago,
		  varchar(50)  as pagador,
		  varchar(50)  as email_pagador,
		  date         as fecha_efec;

define _email_ase,_email_cont,_n_pagador,_e_mail_pag	varchar(50);
define _asegurado,_n_subramo,_n_producto  varchar(50);
define _dependiente		varchar(50);
define _recargo_uni,_email_personas,_email_agtmail		varchar(50);
define _email_todos_agt      varchar(200);
define _recargo_dep,_contratante,_n_corredor		varchar(50);
define _n_todos_agt 								varchar(250);
define v_desc_nombre		char(35);
define _periodo_pago		char(20);
define _estatus				char(20);
define _no_documento		char(20);
define _cod_dependiente		char(10);
define _no_poliza,_cod_cliente			char(10);
define _cod_asegurado		char(10);
define v_nopoliza,_cod_pagador			char(10);
define _periodo_hasta		char(7);
define _periodo_desde		char(7);
define _cod_producto		char(5);
define _no_unidad,_cod_agente			char(5);
define _cod_recargo		char(3);
define _prima_dependiente,_mto_ajus_tec_d_s,_mto_ajus_tec_sal,_mto_seg_aju_d_imp	dec(16,2);
define _prima_bruta,_mto_segundo_ajuste_d	dec(16,2);
define _mto_segundo_ajuste,_mto_prima_resul2	dec(16,2);
define _mto_prima_resul2_d,_prima_acum_depen	dec(16,2);
define _mto_primer_ajuste,_prima_bruta2		dec(16,2);
define _mto_prima_resul1,_mto_primer_ajuste_d,_prima_neta		dec(16,2);
define _porc_recarg_uni			dec(16,2);
define _prima,_mto_ajuste_tec,_mto_ajuste_tec_d					dec(16,2);
define _porc_rec_tec,_porc_recargo_aum,_porc_aumento2,_porc_recargo_ase		dec(5,2);
define _porc_rec_tec_dep,_porc_rec_aum_dep,_porc_partic_agt,_porc_recargo_dep         dec(5,2);
define _fecha_aniv_dep			date;
define _fecha_aniv_uni			date;
define _fecha_ren_pol,_fecha_efe_ase,_fecha_efe_dep		date;
define _vigencia_final		date;
define _vigencia_inic,_fecha_desde		date;
define _mes_vigencia		smallint;
define _mes_periodo,_ano		smallint;
define _meses				smallint;
define _error_isam,_error   integer;
define _fecha_actual        date;
define _cod_no_renov char(3);
define _n_dep        varchar(50);
define _cod_perpago char(3);
define _n_perpago  varchar(40);

set isolation to dirty read;

--set debug file to "sp_tarifas_salud_n3.trc";
--trace on;

begin

let _mes_periodo = a_periodo[6,7];
let _fecha_desde = mdy(_mes_periodo,1,a_periodo[1,4]);
let _fecha_desde = _fecha_desde - 2 units month;

let _fecha_actual = current;
let _ano = year(_fecha_actual);
let _porc_aumento2 = 31.5;

foreach                                           
	select mae.no_documento,
	       decode(mae.estatus_poliza,1,"VIGENTE",2,"CANCELADA",3,"VENCIDA",4,"ANULADA"),
	       sub.nombre as subramo,
		   prd.nombre as producto,
		   mae.vigencia_inic,
		   mae.vigencia_final,
           cli.nombre as asegurado,
		   cli.e_mail,
		   con.nombre as contratante,
		   con.e_mail,
		   uni.prima_asegurado,
		   uni.prima_neta,
		   mae.cod_no_renov,
		   mae.no_poliza,
		   uni.no_unidad,
		   mae.prima_bruta,
		   mae.cod_perpago,
		   mae.cod_pagador,
		   uni.vigencia_inic
	  into _no_documento,
           _estatus,
           _n_subramo,
           _n_producto,
           _vigencia_inic,
           _vigencia_final,
           _asegurado,
           _email_ase,
           _contratante,
		   _email_cont,
           _prima,
           _prima_neta,
           _cod_no_renov,
		   _no_poliza,
		   _no_unidad,
		   _prima_bruta,
		   _cod_perpago,
		   _cod_pagador,
		   _fecha_efe_ase
      from emipomae mae
		   inner join emipouni uni on uni.no_poliza = mae.no_poliza --and uni.no_endoso = mae.no_endoso
		   inner join prdsubra sub on sub.cod_ramo = mae.cod_ramo and sub.cod_subramo = mae.cod_subramo
		   inner join prdprod prd on prd.cod_producto = uni.cod_producto
		   inner join cliclien cli on cli.cod_cliente = uni.cod_asegurado
		   inner join cliclien con on con.cod_cliente = mae.cod_contratante
     where mae.cod_ramo = '018'
       and (mae.estatus_poliza = 1 or (mae.estatus_poliza = 3 and mae.vigencia_final >= _fecha_desde) or (mae.estatus_poliza = 3 and mae.cod_no_renov = '027'))
       and month(mae.vigencia_inic) = _mes_periodo
       and mae.cod_subramo not in ('010','012')
       and mae.actualizado = 1
	   and uni.activo = 1

	let _mes_vigencia = month(_vigencia_inic);
	let _fecha_ren_pol = mdy(_mes_vigencia,1,_ano);
	
	--sacar agente de mayor % de participacion
	let _n_todos_agt = "";
	foreach
		select porc_partic_agt,
		       cod_agente
		  into _porc_partic_agt,
		       _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		select email_personas,
			   nombre
		  into _email_personas,
			   _n_corredor
		  from agtagent
		 where cod_agente = _cod_agente;
		 
		let _n_todos_agt = _n_todos_agt || trim(_n_corredor) || "/";
		 
	end foreach

	let _n_todos_agt = trim(_n_todos_agt);
	
	select nombre
	  into _n_perpago
	  from cobperpa
	 where cod_perpago = _cod_perpago;
	 
	select nombre,e_mail
	  into _n_pagador,_e_mail_pag
	  from cliclien
	 where cod_cliente = _cod_pagador; 
	
	--sacar email de campo de personas y concatenar los que tienen tipo PER en agtmail.
	let _email_todos_agt = "";
	
	let _email_todos_agt = trim(_email_personas);
	let _email_agtmail = "";
	foreach
		select email
		  into _email_agtmail
		  from agtmail
		 where cod_agente = _cod_agente
		   and tipo_correo = 'PER'
		
		let _email_todos_agt = _email_todos_agt || ";" || trim(_email_agtmail);
	end foreach
	
	let _porc_recargo_ase = 0.00;
	let _porc_rec_tec     = 0.00;
	foreach
		select porc_recargo
		  into _porc_recargo_ase
		  from emiunire
		 where no_poliza = _no_poliza
           and no_unidad = _no_unidad
           and cod_recargo <> '003'

		let _porc_rec_tec = _porc_rec_tec + _porc_recargo_ase;
	end foreach

	let _prima_acum_depen = 0;
	select sum(prima)
	  into _prima_acum_depen
      from emidepen
     where no_poliza = _no_poliza
       and no_unidad = _no_unidad
       and activo = 1;
	if _prima_acum_depen is null then
		let _prima_acum_depen = 0;
    end if
	
	let _prima = _prima - _prima_acum_depen;
	let _mto_ajuste_tec   = 0;
	let _mto_ajus_tec_sal = 0;
	let _mto_ajuste_tec = _prima * _porc_rec_tec /100;
	let _mto_ajuste_tec = _mto_ajuste_tec + _prima;
	let _mto_ajus_tec_sal = _mto_ajuste_tec;
	if _porc_rec_tec = 0 then
		let _mto_ajus_tec_sal = 0;
	end if
	
	--RECARGO POR UNIDAD
	let _porc_recargo_aum = 0;
	
	select porc_recargo
	  into _porc_recargo_aum
	  from emiunire
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_recargo = '003';

	if _porc_recargo_aum is null then
		let _porc_recargo_aum = 0;
	end if	
	
	let _mto_primer_ajuste = 0;
	let _mto_primer_ajuste = _mto_ajuste_tec * _porc_recargo_aum /100;
	
	let _mto_prima_resul1 = 0;
	if _mto_ajus_tec_sal = 0 then
		let _mto_prima_resul1 = _prima + _mto_primer_ajuste;
	else
		let _mto_prima_resul1 = _mto_ajus_tec_sal + _mto_primer_ajuste;
	end if
	
	let _mto_segundo_ajuste = 0;
	let _mto_ajuste_tec = 0;
	let _mto_ajuste_tec = _prima * _porc_rec_tec /100;
	let _mto_ajuste_tec = _mto_ajuste_tec + _prima;
	let _mto_segundo_ajuste = _mto_ajuste_tec * _porc_aumento2 /100;
	
	let _mto_prima_resul2 = 0;
	let _mto_prima_resul2 = _mto_prima_resul1 + _mto_segundo_ajuste;
	let _prima_bruta2 = 0;
	let _prima_bruta2 = _mto_prima_resul2 * 1.05;
	let _mto_seg_aju_d_imp = 0.00;
	let _mto_seg_aju_d_imp = _mto_segundo_ajuste *1.05;
	
	return _no_documento,_estatus,_n_subramo,_n_producto,_vigencia_inic,_vigencia_final,
	       _fecha_ren_pol,'ASE',_asegurado,_email_ase,_contratante,_email_cont,
           _n_todos_agt, _email_todos_agt,_mes_vigencia,_prima,_porc_rec_tec,_mto_ajus_tec_sal,
		   _porc_recargo_aum,_mto_primer_ajuste,_mto_prima_resul1,_prima_bruta,_porc_aumento2,_mto_segundo_ajuste,
		   _mto_seg_aju_d_imp,_mto_prima_resul2,_prima_bruta2,_n_perpago,_n_pagador,_e_mail_pag,_fecha_efe_ase with resume;
	
	--RECARGO DEPENDIENTES
	foreach
		select cod_cliente,
		       prima,
			   fecha_efectiva
		  into _cod_cliente,
               _prima_dependiente,
			   _fecha_efe_dep
          from emidepen
         where no_poliza = _no_poliza
           and no_unidad = _no_unidad
		   and activo = 1
		   
		select nombre into _n_dep from cliclien
		where cod_cliente = _cod_cliente;
		   
		let _porc_recargo_dep = 0.00;
		let _porc_rec_tec_dep = 0.00;
		foreach
			select por_recargo
			  into _porc_recargo_dep
			  from emiderec
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and cod_cliente = _cod_cliente
			   and cod_recargo <> '003'

			let _porc_rec_tec_dep = _porc_rec_tec_dep + _porc_recargo_dep;
		end foreach
		
		let _mto_ajuste_tec_d = 0;
		let _mto_ajuste_tec_d = _prima_dependiente * _porc_rec_tec_dep /100;
		let _mto_ajuste_tec_d = _mto_ajuste_tec_d + _prima_dependiente;
		let _mto_ajus_tec_d_s = _mto_ajuste_tec_d;
		if _porc_rec_tec_dep = 0 then
			let _mto_ajus_tec_d_s = 0;
		end if
		   
		--RECARGO POR DEPENDIENTE
		
		let _porc_rec_aum_dep = 0;
		select por_recargo
		  into _porc_rec_aum_dep
		  from emiderec
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cliente = _cod_cliente
		   and cod_recargo = '003';
		if _porc_rec_aum_dep is null then
			let _porc_rec_aum_dep = 0;
		end if	   
		   
		let _mto_primer_ajuste_d = 0;
		let _mto_primer_ajuste_d = _mto_ajuste_tec_d * _porc_rec_aum_dep /100;
		
		let _mto_prima_resul1 = 0;
		if _mto_ajus_tec_d_s = 0 then
			let _mto_prima_resul1 = _prima_dependiente + _mto_primer_ajuste_d;
		else
			let _mto_prima_resul1 = _mto_ajus_tec_d_s + _mto_primer_ajuste_d;
		end if
		
		let _prima_bruta = _mto_prima_resul1 * 1.05;
		
		let _mto_segundo_ajuste_d = 0;
		let _mto_ajuste_tec_d = 0;
		let _mto_ajuste_tec_d = _prima_dependiente * _porc_rec_tec_dep /100;
		let _mto_ajuste_tec_d = _mto_ajuste_tec_d + _prima_dependiente;
		let _mto_segundo_ajuste_d = _mto_ajuste_tec_d * _porc_aumento2 /100;
		
		let _mto_prima_resul2_d = 0;
		let _mto_prima_resul2_d = _mto_prima_resul1 + _mto_segundo_ajuste_d;
		let _prima_bruta2 = 0;
		let _prima_bruta2 = _mto_prima_resul2_d * 1.05;
		let _mto_seg_aju_d_imp = 0.00;
		let _mto_seg_aju_d_imp = _mto_segundo_ajuste_d * 1.05;
	   
		return _no_documento,_estatus,_n_subramo,_n_producto,_vigencia_inic,_vigencia_final,
		       _fecha_ren_pol,'DEP',_n_dep,_email_ase,_contratante,_email_cont,
			   _n_todos_agt, _email_todos_agt,_mes_vigencia,_prima_dependiente,_porc_rec_tec_dep,_mto_ajus_tec_d_s,
			   _porc_rec_aum_dep,_mto_primer_ajuste_d,_mto_prima_resul1,_prima_bruta,_porc_aumento2,_mto_segundo_ajuste_d,
			   _mto_seg_aju_d_imp,_mto_prima_resul2_d,_prima_bruta2,_n_perpago,_n_pagador,_e_mail_pag,_fecha_efe_dep with resume;
		
	end foreach

end foreach
end
end procedure;   