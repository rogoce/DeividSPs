--Reporte Resumido RRC
--Armando Moreno M.    23/07/2025

drop procedure sp_reserva_riesgo2;
create procedure sp_reserva_riesgo2(a_periodo char(7))
returning char(3),varchar(50),decimal(16,2),decimal(16,2),decimal(16,2),decimal(16,2),decimal(16,2),decimal(16,2),decimal(16,2),
          decimal(16,2),decimal(16,2);

BEGIN

define _cod_subramo         		char(3);
define _cod_ramo   					char(3);
define _rrc_cedida,_rrc_100         dec(16,2);
define _n_ramo                      varchar(50);
define _prima_suscrita,_comision_corr,_impuesto,_prima_cedida,_comision_reas,_impuesto_reaseg dec(16,2);
define _gastos_adq                   dec(16,2);

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
	   
	return _cod_ramo,_n_ramo,_prima_suscrita,_comision_corr,_impuesto,_prima_cedida,_comision_reas,_impuesto_reaseg,_gastos_adq,_rrc_100,_rrc_cedida with resume;
	
end foreach
end			
end procedure;