   --Reporte E - Canal de Distribucion
   --Estadistico para la superintendencia
   --  Armando Moreno M. 11/03/2017
   
   DROP procedure sp_super02;
   CREATE procedure sp_super02(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING smallint,char(50),integer,integer,integer,integer,decimal(16,2),char(10);

    DEFINE v_cod_ramo,v_cod_subramo,_cod_ramo,_cod_subramo  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE _no_poliza,_no_reclamo,_no_licencia   CHAR(10);
    DEFINE v_cant_polizas,_cnt_reclamo,_cnt_cerra,_cantidad          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,_prima_suscrita,_prima_retenida,v_suma_asegurada,_total_pri_sus,v_incurrido_bruto,
	       _salv_y_recup,_pago_y_ded,_var_reserva  DECIMAL(16,2);
    DEFINE _tipo,_nueva_renov              CHAR(01);
    DEFINE v_filtros          			   CHAR(255);
	DEFINE _mes2,_mes,_ano2,_orden,unidades2,li_dia,li_mes,li_anio   SMALLINT;
	define _cod_tipoprod,_cod_origen	  	   					char(3);
	DEFINE _vigencia_inic, _vig_fin_vida, _vig_ini_end,_fecha2  DATE;
	define _no_endoso         									char(5);
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados  INTEGER;
	define _cnt_pol integer;
	define _cod_contratante char(10);
	define _cliente_pep 	smallint;
	define _tipo_persona 	char(1);
	define _cod_asegurado,_cod_pagador char(10);
	define _n_origen 					char(11);
	define _porc_partic_ben, _beneficio, _suma_asegurada,_prima_agt dec(16,2);
	define _cnt integer;
	define _no_unidad,_cod_agente char(5);
	define _cod_cliente  char(10);
	define _tipo_per_cte,_tipo_agente char(1);
	define _n_agente     char(50);
	define _top5         smallint;
	define _cantidad_j, _cnt_j integer;
	define _cod_formapag  char(3);

    CREATE TEMP TABLE temp_agente(
              no_poliza     CHAR(10),
              cod_agente    CHAR(5),
              prima_suscrita   decimal(16,2),
			  tipo_persona     char(1),
			  cod_contratante  char(10),
			  tipo_per_cte     char(1)
              ) WITH NO LOG;
			  CREATE INDEX i_agente1 ON temp_agente(cod_agente);
			  CREATE INDEX i_agente2 ON temp_agente(tipo_persona);

    CREATE TEMP TABLE temp_agente2(
              no_poliza     CHAR(10),
              cod_agente    CHAR(5),
              prima_suscrita   decimal(16,2),
			  tipo_persona     char(1),
			  cod_contratante  char(10),
			  tipo_per_cte     char(1)
              ) WITH NO LOG;
			  CREATE INDEX ii_agente11 ON temp_agente2(cod_agente);
			  CREATE INDEX ii_agente22 ON temp_agente2(tipo_persona);
			  

LET v_cod_ramo       = NULL;
LET v_cod_subramo    = NULL;
LET v_desc_subramo   = NULL;
LET v_cant_polizas   = 0;
LET v_prima_suscrita = 0;
LET _prima_suscrita  = 0;
LET _tipo            = NULL;
let _salv_y_recup    = 0;
let _pago_y_ded      = 0;
let _var_reserva     = 0;
let _cnt_cerra       = 0;
LET v_cant_polizas_ma  = 0;
LET _cnt_prima_nva   = 0;
LET _cnt_prima_ren   = 0;
LET _cnt_prima_can   = 0;
let _prima_agt       = 0;
let _cantidad_j      = 0;
let _cnt_j           = 0;
let _cantidad        = 0;
let _cnt             = 0;

SET ISOLATION TO DIRTY READ;
LET descr_cia = sp_sis01(a_cia);
-- Descomponer los periodos en fechas
LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];
LET _mes = _mes2;

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;
--trae cant. de polizas vig. temp_perfil
CALL sp_pro95a(
a_cia,
a_agencia,
_fecha2,
'*',
'4;Ex',
a_origen) RETURNING v_filtros;

--CORREDORES
foreach
	select no_poliza,
	       prima_suscrita,
		   cod_contratante
	  into _no_poliza,
	       _prima_suscrita,
		   _cod_contratante
	  from temp_perfil
	 where seleccionado = 1
	 
	select cod_formapag
	  into _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;

    if _cod_formapag = '008' then	--Excluir corredor remesa, cambio solicitado por Amilcar 22/01/2018
		continue foreach;
	end if	 
	
	foreach
		select cod_agente,
		       porc_partic_agt
		  into _cod_agente,
			   _porc_partic_ben
		  from emipoagt
         where no_poliza = _no_poliza
		 
		let _prima_agt = 0;
		let _prima_agt = _prima_suscrita * _porc_partic_ben / 100;
		
		select tipo_persona,tipo_agente
		  into _tipo_persona,_tipo_agente
		  from agtagent
		 where cod_agente = _cod_agente;
		
		if _tipo_agente = 'A' then
		else
			continue foreach;
		end if
		 
		 select tipo_persona
		  into _tipo_per_cte
		  from cliclien
		 where cod_cliente = _cod_contratante;
		
		insert into temp_agente(no_poliza,cod_agente,prima_suscrita,tipo_persona,cod_contratante,tipo_per_cte)
		values(_no_poliza,_cod_agente,_prima_agt,_tipo_persona,_cod_contratante,_tipo_per_cte);
		
	end foreach
end foreach

--CORREDORES REMESA
foreach
	select no_poliza,
	       prima_suscrita,
		   cod_contratante
	  into _no_poliza,
	       _prima_suscrita,
		   _cod_contratante
	  from temp_perfil
	 where seleccionado = 1 
	  
	select cod_formapag
	  into _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;

    if _cod_formapag = '008' then	--corredor remesa
    else
		continue foreach;
	end if	
	
	foreach
		select cod_agente,
		       porc_partic_agt
		  into _cod_agente,
			   _porc_partic_ben
		  from emipoagt
         where no_poliza = _no_poliza
		 
		let _prima_agt = 0;
		let _prima_agt = _prima_suscrita * _porc_partic_ben / 100;
		
		select tipo_persona,tipo_agente
		  into _tipo_persona,_tipo_agente
		  from agtagent
		 where cod_agente = _cod_agente;
		
		if _tipo_agente = 'A' then
		else
			continue foreach;
		end if
		 
		 select tipo_persona
		  into _tipo_per_cte
		  from cliclien
		 where cod_cliente = _cod_contratante;
		
		insert into temp_agente2(no_poliza,cod_agente,prima_suscrita,tipo_persona,cod_contratante,tipo_per_cte)
		values(_no_poliza,_cod_agente,_prima_agt,_tipo_persona,_cod_contratante,_tipo_per_cte);
		
	end foreach
end foreach

let _top5 = 1;
foreach
	select cod_agente, sum(prima_suscrita),count(no_poliza)
	  into _cod_agente, _prima_suscrita, _cnt_pol
      from temp_agente
     where tipo_persona = 'N'
     group by 1
     order by sum(prima_suscrita) desc
	 
	select count(distinct cod_contratante)
	  into _cnt
	  from temp_agente
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'N';
	   
	select count(distinct no_poliza)
	  into _cantidad
	  from temp_agente
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'N';
	   
	select count( distinct cod_contratante)
	  into _cnt_j
	  from temp_agente
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'J';

	   select count( distinct no_poliza)
	  into _cantidad_j
	  from temp_agente
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'J';
	   
	let _n_agente = "";
	
	select nombre,no_licencia
	  into _n_agente,_no_licencia
	  from agtagent
	 where cod_agente = _cod_agente; 
	 if _top5 = 11 then
		exit foreach;
	 end if	
	 return 1,_n_agente,_cnt,_cantidad,_cnt_j,_cantidad_j,_prima_suscrita,_no_licencia with resume;
	 let _top5 = _top5 + 1;
end foreach

let _top5 = 1;
foreach
	select cod_agente, sum(prima_suscrita),count(no_poliza)
	  into _cod_agente, _prima_suscrita, _cnt_pol
      from temp_agente
     where tipo_persona = 'J'
     group by 1
     order by sum(prima_suscrita) desc
	 
	select count(distinct cod_contratante)
	  into _cnt
	  from temp_agente
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'N';
	   
	select count(distinct no_poliza)
	  into _cantidad
	  from temp_agente
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'N';
	   
	select count( distinct cod_contratante)
	  into _cnt_j
	  from temp_agente
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'J';

	   select count( distinct no_poliza)
	  into _cantidad_j
	  from temp_agente
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'J';
	   
	let _n_agente = "";
	
	select nombre,no_licencia
	  into _n_agente,_no_licencia
	  from agtagent
	 where cod_agente = _cod_agente; 
	 if _top5 = 11 then
		exit foreach;
	 end if	
	 return 2,_n_agente,_cnt,_cantidad,_cnt_j,_cantidad_j,_prima_suscrita,_no_licencia with resume;
	 let _top5 = _top5 + 1;
end foreach

let _top5 = 1;
foreach
	select cod_agente, sum(prima_suscrita),count(no_poliza)
	  into _cod_agente, _prima_suscrita, _cnt_pol
      from temp_agente2
     where tipo_persona = 'N'
     group by 1
     order by sum(prima_suscrita) desc
	 
	select count(distinct cod_contratante)
	  into _cnt
	  from temp_agente2
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'N';
	   
	select count(distinct no_poliza)
	  into _cantidad
	  from temp_agente2
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'N';
	   
	select count( distinct cod_contratante)
	  into _cnt_j
	  from temp_agente2
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'J';

	   select count( distinct no_poliza)
	  into _cantidad_j
	  from temp_agente2
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'J';
	   
	let _n_agente = "";
	
	select nombre,no_licencia
	  into _n_agente,_no_licencia
	  from agtagent
	 where cod_agente = _cod_agente; 
	 if _top5 = 11 then
		exit foreach;
	 end if	
	 return 3,_n_agente,_cnt,_cantidad,_cnt_j,_cantidad_j,_prima_suscrita,_no_licencia with resume;
	 let _top5 = _top5 + 1;
end foreach

let _top5 = 1;
foreach
	select cod_agente, sum(prima_suscrita),count(no_poliza)
	  into _cod_agente, _prima_suscrita, _cnt_pol
      from temp_agente2
     where tipo_persona = 'J'
     group by 1
     order by sum(prima_suscrita) desc
	 
	select count(distinct cod_contratante)
	  into _cnt
	  from temp_agente2
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'N';
	   
	select count(distinct no_poliza)
	  into _cantidad
	  from temp_agente2
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'N';
	   
	select count( distinct cod_contratante)
	  into _cnt_j
	  from temp_agente2
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'J';

	   select count( distinct no_poliza)
	  into _cantidad_j
	  from temp_agente2
     where cod_agente = _cod_agente
	   and tipo_per_cte = 'J';
	   
	let _n_agente = "";
	
	select nombre,no_licencia
	  into _n_agente,_no_licencia
	  from agtagent
	 where cod_agente = _cod_agente; 
	 if _top5 = 11 then
		exit foreach;
	 end if	
	 return 4,_n_agente,_cnt,_cantidad,_cnt_j,_cantidad_j,_prima_suscrita,_no_licencia with resume;
	 let _top5 = _top5 + 1;
end foreach

drop table temp_agente;
drop table temp_agente2;
drop table temp_perfil;
END PROCEDURE;