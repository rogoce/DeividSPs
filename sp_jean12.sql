-- POLIZAS VIGENTES 
--

DROP procedure sp_jean12;
CREATE procedure sp_jean12(a_fecha date)
RETURNING date,char(20),char(5),dec(16,2),char(50),char(50),dec(16,2),dec(16,2),char(5),char(50),date,date;

DEFINE _no_poliza	 							CHAR(10);
DEFINE _no_documento    						CHAR(20);
DEFINE _n_ramo,_n_subramo,_n_agente  			CHAR(50);
define v_filtros        						varchar(255);
define _no_unidad,_cod_agente       			char(5);
define _fecha_sus,_vigencia_inic,_vigencia_final date;
define _prima_neta,_factor_tar,_suma_aseg_uni	dec(16,2);
define _cod_ramo,_cod_subramo                   char(3);


CALL sp_pro03("001","001",a_fecha,"007,009,012,017,021,001,003,006,011,022,005,010,015,014,013;") RETURNING v_filtros;

let _prima_neta = 0.00;

foreach
	select no_poliza,
	       no_documento,
		   cod_ramo,
		   cod_subramo
	  into _no_poliza,
	       _no_documento,
		   _cod_ramo,
		   _cod_subramo
	  from temp_perfil
	 where seleccionado = 1
	   
	select Fecha_suscripcion,
	       vigencia_inic,
		   vigencia_final
	  into _fecha_sus,
	       _vigencia_inic,
		   _vigencia_final
	  from emipomae
     where no_poliza = _no_poliza;

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		order by porc_partic_agt desc 
		 
		exit foreach;
	end foreach
	
	select nombre
  	  into _n_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _n_ramo
	  from prdramo
 	 where cod_ramo = _cod_ramo;

	select nombre
	  into _n_subramo
	  from prdsubra
 	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	foreach
		select no_unidad,
		       prima_neta,
			   suma_asegurada
	      into _no_unidad,
		       _prima_neta,
			   _suma_aseg_uni
 	      from emipouni 
		 where no_poliza = _no_poliza
		
		let _factor_tar = 0.00;
		if _suma_aseg_uni <> 0.00 then
			let _factor_tar = (_prima_neta / _suma_aseg_uni) * 100;
		end if
		
		return _fecha_sus,_no_documento,_no_unidad,_prima_neta,_n_ramo,_n_subramo,_suma_aseg_uni,_factor_tar,_cod_agente,_n_agente,_vigencia_inic,_vigencia_final with resume;
		
	end foreach	
end foreach
END PROCEDURE;
