--Caso 12283   Generación Datos de Morosidad Anual para Calculo y Monitoreo de Cobros
--Armando Moreno M.

DROP procedure sp_jean18;
CREATE procedure sp_jean18(a_periodo1 char(7),a_periodo2 char(7))
RETURNING char(20),char(7),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),dec(16,2),char(10),dec(16,2),dec(16,2),dec(16,2),
		  dec(16,2),dec(16,2),dec(16,2),dec(16,2),char(10),char(50),char(20),char(3),char(50),char(3),char(50),char(3),char(50),char(3),
		  char(50),char(5),char(50),date,date,smallint,smallint,smallint,char(15),dec(16,2),char(1),char(5),char(50),smallint,
		  char(4),char(2),char(3),char(50);


define _no_documento,_n_division											  char(20);
DEFINE _v_i,_v_f                                                              date;
define _cod_agente,_cod_grupo                                                  char(5);
define _cod_formapag,_cod_cobrador,_cod_ramo,_cod_subramo,_cod_vendedor       char(3);
define _periodo                                                               char(7);
define _n_contratante,_n_f_pago,_n_cobrador,_n_ramo,_n_subramo,_n_agente,_n_grupo,_n_zona char(50);
define _no_poliza,_cod_contratante 											char(10);
define _estatus_poliza 														char(15);
define _nueva_renov,_cobra_poliza,_cod 														char(1);
define _saldo,_por_vencer,_exigible,_corriente,_dias_30,_dias_60,_dias_90,_cobros_por_vencer,_cobros_exigible,_cobros_corriente   dec(16,2);
define _cobros_30,_cobros_60,_cobros_90,_cobros_total,_prima_bruta_end 		dec(16,2);
define _y_vf,_m_vf,_d_vf  													integer;
define _fac 																smallint;
define _ano_contable 														char(4);
define _mes_contable 														char(2); 

foreach
	select no_documento,
		   periodo,
		   saldo,
		   por_vencer,
		   exigible,
		   corriente,
		   dias_30,
		   dias_60,
		   dias_90,
		   no_poliza,
		   cobros_por_vencer,
		   cobros_exigible,
		   cobros_corriente,
		   cobros_30,
		   cobros_60,
		   cobros_90,
		   cobros_total,
		   facultativo
	  into _no_documento,
		   _periodo,
           _saldo,
           _por_vencer,
		   _exigible,
		   _corriente,
		   _dias_30,
		   _dias_60,
		   _dias_90,
		   _no_poliza,
		   _cobros_por_vencer,
		   _cobros_exigible,
		   _cobros_corriente,
		   _cobros_30,
		   _cobros_60,
		   _cobros_90,
		   _cobros_total,
		   _fac
	  from deivid_cob:cobmoros4_202411
	 where periodo >= a_periodo1
       and periodo <= a_periodo2
	   and (cobros_total <> 0 or saldo <> 0)
	   
	select cod_contratante,
	       cod_formapag,
		   cod_ramo,
		   cod_subramo,
		   vigencia_inic,
		   vigencia_final,
		   year(vigencia_final),
		   month(vigencia_final),
		   day(vigencia_final),
		   decode(estatus_poliza,1,"Vigente",2,"Cancelada",3,"Vencida",4,"Anulada"),
		   nueva_renov,
		   cod_grupo,
		   periodo[1,4],
		   periodo[6,7]
	  into _cod_contratante,
	       _cod_formapag,
		   _cod_ramo,
		   _cod_subramo,
		   _v_i,
		   _v_f,
		   _y_vf,
		   _m_vf,
		   _d_vf,
		   _estatus_poliza,
		   _nueva_renov,
		   _cod_grupo,
		   _ano_contable,
		   _mes_contable
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select prima_bruta
      into _prima_bruta_end
      from endedmae
     where no_poliza = _no_poliza
       and no_endoso = '00000';	 
	 
	select nombre
	  into _n_contratante
	  from cliclien
	 where cod_cliente = _cod_contratante;
	 
	select nombre
	  into _n_grupo
	  from cligrupo
	 where cod_grupo = _cod_grupo;
	 
	 select nombre
	  into _n_f_pago
	  from cobforpa
	 where cod_formapag = _cod_formapag;
	
	foreach
		select cobra_poliza
		  into _cobra_poliza
		  from cobdivco
		 where cod_formapag = _cod_formapag

		exit foreach;
	end foreach
	
	select nombre
	  into _n_division
	  from cobdivis
	 where cod_division = _cobra_poliza;
	
	foreach
		select cod_agente into _cod_agente from emipoagt
		where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	select nombre,cod_cobrador,cod_vendedor into _n_agente,_cod_cobrador,_cod_vendedor from agtagent
	where cod_agente = _cod_agente;
	
	select nombre
	  into _n_cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;
	 
    select nombre into _n_ramo from prdramo
	where cod_ramo = _cod_ramo;
	  
    select nombre into _n_subramo from prdsubra
	where cod_ramo = _cod_ramo
	  and cod_subramo = _cod_subramo;
	  
    select nombre into _n_zona from agtvende
	where cod_vendedor = _cod_vendedor;

 
	return _no_documento,_periodo,_saldo,_por_vencer,_exigible,_corriente,_dias_30,_dias_60,_dias_90,_no_poliza,_cobros_por_vencer,_cobros_exigible,_cobros_corriente,
	       _cobros_30,_cobros_60,_cobros_90,_cobros_total,_cod_contratante,_n_contratante,_n_division,_cod_formapag,_n_f_pago,_cod_cobrador,_n_cobrador,_cod_ramo,_n_ramo,_cod_subramo,
		   _n_subramo,_cod_agente,_n_agente,_v_i,_v_f,_y_vf,_m_vf,_d_vf,_estatus_poliza,_prima_bruta_end,_nueva_renov,_cod_grupo,_n_grupo,_fac,_ano_contable,_mes_contable,
		   _cod_vendedor,_n_zona with resume;
	
end foreach
END PROCEDURE;