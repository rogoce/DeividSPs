--Reporte Resumido RRC
--Armando Moreno M.    23/07/2025

drop procedure sp_reserva_riesgo22;
create procedure sp_reserva_riesgo22(a_periodo char(7))
returning char(3),varchar(50),decimal(16,2),decimal(16,2),decimal(16,2),decimal(16,2),decimal(16,2),decimal(16,2),decimal(16,2),
          decimal(16,2),decimal(16,2);

BEGIN

define _cod_subramo         		char(3);
define _cod_ramo   					char(3);
define _rrc_cedida,_rrc_100         dec(16,2);
define _n_ramo                      varchar(50);
define _prima_suscrita,_comision_corr,_impuesto,_prima_cedida,_comision_reas,_impuesto_reaseg dec(16,2);
define _gastos_adq                   dec(16,2);

drop table if exists tmp_ramos_acum;
create temp table tmp_ramos_acum (
cod_ramo		char(3),
n_ramo	    	varchar(50),
prima_suscrita  decimal(16,2),
comision_corr   decimal(16,2),
impuesto        decimal(16,2),
prima_cedida    decimal(16,2),
comision_reas   decimal(16,2),
impuesto_reaseg decimal(16,2),
gastos_adq      decimal(16,2),
rrc_100         decimal(16,2),
rrc_cedida      decimal(16,2))
with no log;
CREATE INDEX tmp_cod_ramos_1 ON tmp_ramos_acum(cod_ramo);
CREATE INDEX tmp_n_ramos_1 ON tmp_ramos_acum(n_ramo);

--set debug file to "sp_reserva_riesgo1.trc";
--trace on;

set isolation to dirty read;

--*******PRIMER CUADRO RRC PARTICIPACION
foreach
	select cod_ramo,
	       n_ramo,
		   sum(prima_suscrita),
		   sum(comision_corr),
		   sum(impuesto),
		   sum(prima_cedida),
		   sum(comision_reas),
		   sum(impuesto_reaseg),
		   sum(gastos_adq)
	  into _cod_ramo,
	       _n_ramo,
	       _prima_suscrita,
		   _comision_corr,
		   _impuesto,
		   _prima_cedida,
		   _comision_reas,
		   _impuesto_reaseg,
		   _gastos_adq
	  from deivid_ttcorp:reserva_riesgo_curso
     where periodo         = a_periodo
	   and periodo_factura = a_periodo
	   and cod_ramo        <> '019'
	 group by cod_ramo,n_ramo
	 order by cod_ramo
	 
	select sum(rrc_100),
		   sum(rrc_cedida)
	  into _rrc_100,
		   _rrc_cedida
	  from deivid_ttcorp:reserva_riesgo_curso
     where periodo         = a_periodo
   	   and cod_ramo        = _cod_ramo;
	   
	if _cod_ramo in('020','023') then
		let _cod_ramo = '002';
		let _n_ramo = 'AUTOMOVIL';
	elif _cod_ramo = '003' then
		let _cod_ramo = '001';
		let _n_ramo = 'INCENDIO';
	elif _cod_ramo in('010','013','012','011','022','007','021') then --ramos tecnicos
		let _cod_ramo = 'RTE';
		let _n_ramo = 'RAMOS TECNICOS';
	elif _cod_ramo = '017' then --Casco
		let _rrc_cedida      = 0.00;
		let _rrc_100         = 0.00;
		let _prima_suscrita  = 0.00;
		let _comision_corr   = 0.00;
		let _impuesto        = 0.00;
		let _prima_cedida    = 0.00;
		let _comision_reas   = 0.00;
		let _impuesto_reaseg = 0.00;
		let _gastos_adq      = 0.00;
		
		foreach
			select cod_subramo,
				   sum(prima_suscrita),
				   sum(comision_corr),
				   sum(impuesto),
				   sum(prima_cedida),
				   sum(comision_reas),
				   sum(impuesto_reaseg),
				   sum(gastos_adq)
			  into _cod_subramo,
				   _prima_suscrita,
				   _comision_corr,
				   _impuesto,
				   _prima_cedida,
				   _comision_reas,
				   _impuesto_reaseg,
				   _gastos_adq
			  from deivid_ttcorp:reserva_riesgo_curso t, emipoliza e
		     where t.id_poliza = e.no_documento
               and t.periodo         = a_periodo
			   and t.periodo_factura = a_periodo
			   and t.cod_ramo        = _cod_ramo
               and e.cod_subramo in('002','001') --aereo,maritimo
          group by e.cod_subramo
		  
			select sum(rrc_cedida),
				   sum(rrc_100)
			  into _rrc_cedida,
				   _rrc_100
			  from deivid_ttcorp:reserva_riesgo_curso t, emipoliza e
		     where t.id_poliza   = e.no_documento
               and t.periodo     = a_periodo
			   and t.cod_ramo    = _cod_ramo
			   and e.cod_subramo = _cod_subramo
          group by e.cod_subramo;		  
		  
		    if _cod_subramo = '001' then
			    let _cod_subramo = 'MAR';
				let _n_ramo = 'CASCO MARITIMO';
			elif _cod_subramo = '002' then
			    let _cod_subramo = 'AER';
				let _n_ramo = 'CASCO AEREO';
			end if
			insert into tmp_ramos_acum
			values(_cod_subramo,_n_ramo,_prima_suscrita,_comision_corr,_impuesto,_prima_cedida,_comision_reas,_impuesto_reaseg,_gastos_adq,_rrc_100,_rrc_cedida);
		end foreach
	end if
	if _cod_ramo <> "017" then
		insert into tmp_ramos_acum
		values(_cod_ramo,_n_ramo,_prima_suscrita,_comision_corr,_impuesto,_prima_cedida,_comision_reas,_impuesto_reaseg,_gastos_adq,_rrc_100,_rrc_cedida);
	end if
END foreach

--****SALIDA****
foreach
	select cod_ramo,
	       n_ramo,	    	
	       sum(prima_suscrita),
	       sum(comision_corr),
	       sum(impuesto),
	       sum(prima_cedida),
	       sum(comision_reas),
	       sum(impuesto_reaseg),
	       sum(gastos_adq),
	       sum(rrc_100),
	       sum(rrc_cedida)
	  into _cod_ramo,
           _n_ramo,
           _prima_suscrita,
	       _comision_corr,
	       _impuesto,
	       _prima_cedida,
	       _comision_reas,
	       _impuesto_reaseg,
	       _gastos_adq,
		   _rrc_100,
		   _rrc_cedida
	  from tmp_ramos_acum
	 group by cod_ramo,n_ramo
     order by cod_ramo
	 
	return _cod_ramo,_n_ramo,_prima_suscrita,_comision_corr,_impuesto,_prima_cedida,_comision_reas,_impuesto_reaseg,_gastos_adq,_rrc_100,_rrc_cedida with resume;
end foreach
end			
end procedure;