-- Polizas Vigentes de Incendio y Multiriesgo ubicados en Ave. B.

-- Creado    : 14/11/2003 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - d_recl_tra_ayuda_requis2 - DEIVID, S.A.


--drop procedure sp_pro134;

create procedure sp_pro134(
a_cia 			CHAR(3),
a_agencia 		CHAR(3),
a_periodo 		DATE
);

DEFINE v_filtros                        CHAR(100);

LET v_filtros = sp_pro03(a_cia, a_agencia, a_periodo, "001,003;"); --trae las polizas vigentes.

FOREACH
 SELECT no_poliza,
		no_documento,
		cod_grupo,
		cod_ramo,
        cod_contratante,
        vigencia_inic,
        vigencia_final,
        prima_suscrita,
        cod_agente
   INTO v_nopoliza,
 	    v_documento,
 	    v_codgrupo,
 	    v_codramo,
        v_contratante,
        v_vigencia_inic,
        v_vigencia_final,
        v_prima_suscrita,
        v_codagente
   FROM temp_perfil
  WHERE seleccionado = 1
  ORDER BY cod_ramo,vigencia_final,no_documento


	

end procedure;