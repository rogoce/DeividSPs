

DROP PROCEDURE sp_bono10;
CREATE PROCEDURE "informix".sp_bono10()
RETURNING	char(20),
			CHAR(50),
			CHAR(5),
			CHAR(50),
			DATE,
			DEC(16,2),
			DEC(16,2),
			DEC(16,2),
			DATE,
			DATE;

DEFINE _suma_aseg_act  	  DEC(16,2);
DEFINE _suma_inicial      DEC(16,2);
DEFINE _prima_suscrita    DEC(16,2);
DEFINE _vig_ini 		  DATE;     
DEFINE _vig_fin     	  DATE;     
DEFINE _fecha_suscripcion DATE;
DEFINE _no_poliza         CHAR(10);
DEFINE _no_documento	  CHAR(20);
DEFINE _cod_agente		  CHAR(5);
DEFINE _n_corredor        CHAR(50);
DEFINE _cnt               INTEGER;
DEFINE _n_asegurado		  CHAR(50);
DEFINE _cod_contratante   CHAR(10);

--SET DEBUG FILE TO "sp_cob33.trc";
--TRACE ON ;

SET ISOLATION TO DIRTY READ;

LET _suma_inicial   = 0;
LET _prima_suscrita = 0;
let _cnt            = 0;
let _suma_aseg_act  = 0;

foreach

	select no_poliza,
	       cod_contratante,
		   fecha_suscripcion,
		   suma_asegurada,
		   no_documento,
		   vigencia_inic,
		   vigencia_final,
		   prima_suscrita
	  into _no_poliza,
	       _cod_contratante,
		   _fecha_suscripcion,
		   _suma_aseg_act,
		   _no_documento,
		   _vig_ini,
		   _vig_fin,
		   _prima_suscrita
	  from emipomae
	 where actualizado = 1
	   and fecha_suscripcion >= '01/01/2015'
	   and fecha_suscripcion <= '30/11/2015'
	   and nueva_renov = 'R'
	   and cod_ramo    in('002','023')
	   order by no_documento
	   
	select count(*)
      into _cnt
      from emipocob
     where no_poliza = _no_poliza
       and cod_cobertura in('00119','00121','01307')
	   and prima_neta > 0;
	   
	if _cnt is null then
		let _cnt = 0;
    end if	
	
    if _cnt = 0 then
		continue foreach;
	end if

	foreach
		select suma_asegurada
		  into _suma_inicial
		  from emipomae
		 where actualizado = 1
		   and no_documento = _no_documento
		   and nueva_renov  = 'N'
	end foreach
	
	foreach   
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach	

	select nombre
	  into _n_corredor
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	select nombre
	  into _n_asegurado
	  from cliclien
	 where cod_cliente = _cod_contratante;

	return _no_documento,_n_asegurado,_cod_agente,_n_corredor,_fecha_suscripcion,_suma_inicial,_suma_aseg_act,_prima_suscrita,_vig_ini,_vig_fin with resume;
end foreach
		
END PROCEDURE;
