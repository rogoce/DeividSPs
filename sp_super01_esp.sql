   --Hoja C - Factor Cliente
   --Estadistico para la superintendencia
   --  Armando Moreno M. 09/03/2017
   
   DROP procedure sp_super01_esp;
   CREATE procedure sp_super01_esp(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
   RETURNING char(50) as nombre,
             integer  as contratante,
			 integer  as asegurado,
			 integer  as pagador,
			 integer  as beneficiario;
   
    DEFINE v_cod_ramo,v_cod_subramo,_cod_ramo,_cod_subramo  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE unidades2          SMALLINT;
    DEFINE _no_poliza,_no_reclamo         CHAR(10);
    DEFINE v_cant_polizas,_cnt_reclamo          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           _prima_suscrita,_prima_retenida,v_suma_asegurada,
		   _total_pri_sus,v_incurrido_bruto,
           _salv_y_recup,_pago_y_ded,_var_reserva		   DECIMAL(16,2);
    DEFINE _tipo,_nueva_renov              CHAR(01);
    DEFINE v_filtros          CHAR(255);
	DEFINE _mes2,_mes,_ano2,_orden   SMALLINT;
	DEFINE _fecha2     	      DATE;
	define _cod_tipoprod	  char(3);
	DEFINE _vigencia_inic, _vig_fin_vida, _vig_ini_end     DATE;
	define _no_endoso         char(5);
	define li_dia,li_mes,li_anio smallint;
	DEFINE _cnt_cerra,_cantidad            INTEGER;
	define _cod_origen        CHAR(3);
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados  INTEGER;
	define _cnt_pol integer;
	define _cod_contratante char(10);
	define _cliente_pep smallint;
	define _tipo_persona char(1);
	define _cod_asegurado,_cod_pagador char(10);
	define _n_origen char(11);
	define _porc_partic_ben, _beneficio, _suma_asegurada dec(16,2);
	define _cnt integer;
	define _no_unidad char(5);
	define _cod_cliente  char(10);
	define _cte_c,_cte_a,_cte_p,_cte_b smallint;
	
define _n_ramo char(50);
define _cnt_contratante,_cnt_asegurado,_cnt_pagador,_cnt_beneficiario integer;
	
drop table if exists temp_contratantep;

CREATE TEMP TABLE temp_contratantep(
		  no_poliza        CHAR(10),
		  cod_ramo         CHAR(3),
		  c     		   smallint default 0,
		  a				   smallint default 0,
		  p                smallint default 0,
		  b                smallint default 0  
		  ) WITH NO LOG;
			  

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

--trae polizas en periodo
LET v_filtros = sp_pr26bk(a_cia,a_agencia,a_periodo,a_periodo2,'*','*','*','*','*','*','*','*');

--CONTRATANTES PEP
foreach
	select no_poliza,
	       cod_ramo
	  into _no_poliza,
	       _cod_ramo
	  from tmp_prod
	 where seleccionado = 1 
	 group by no_poliza,cod_ramo
	 
	select cod_contratante,
		   cod_pagador
	  into _cod_contratante,
           _cod_pagador
	  from emipomae
     where no_poliza = _no_poliza;
	
	select cliente_pep
	  into _cliente_pep
	  from cliclien
     where cod_cliente = _cod_contratante;

	if _cliente_pep is null then
		let _cliente_pep = 0;
	end if
	let _cte_c = 0;
	if _cliente_pep = 1 then
		let _cte_c = 1;
	end if
	select cliente_pep
	  into _cliente_pep
	  from cliclien
     where cod_cliente = _cod_pagador;
	if _cliente_pep is null then
		let _cliente_pep = 0;
	end if
	let _cte_p = 0;
	if _cliente_pep = 1 then
		let _cte_p = 1;
	end if
	foreach
		select cod_asegurado
		  into _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza
		 
		 select cliente_pep
		   into _cliente_pep
	       from cliclien
          where cod_cliente = _cod_asegurado;

		if _cliente_pep is null then
			let _cliente_pep = 0;
		end if
		let _cte_a = 0;
		if _cliente_pep = 1 then
			let _cte_a = 1;
			exit foreach;
		end if
	end foreach
	
	--BENEFICIARIOS
	let _cte_b = 0;
	if _cod_ramo in('016','019') then	--solo polizas de vida
		foreach
			select no_unidad,
			       cod_asegurado
			  into _no_unidad,
			       _cod_asegurado
			  from emipouni
			 where no_poliza = _no_poliza
			 
			select count(*)
			  into _cnt
			  from emibenef
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt > 0 then	
					foreach
						select cod_cliente
						  into _cod_cliente
						  from emibenef
						 where no_poliza = _no_poliza
						   and no_unidad = _no_unidad
						   
						select cliente_pep
						  into _cliente_pep
						  from cliclien
						 where cod_cliente = _cod_cliente;

						if _cliente_pep is null then
							let _cliente_pep = 0;
						end if
						let _cte_b = 0;
						if _cliente_pep = 1 then
							let _cte_b = 1;
							exit foreach;
						end if
					end foreach
			else
				continue foreach;
			end if
		end foreach
	end if
	insert into temp_contratantep(no_poliza,cod_ramo,c,a,p,b)
	values(_no_poliza,_cod_ramo,_cte_c,_cte_a,_cte_p,_cte_b);
end foreach
--Este es el query que hay que ejecutar para el excell
foreach
	select p.nombre,
	       sum(c),
		   sum(a),
		   sum(p),
		   sum(b)
	  into _n_ramo,
           _cnt_contratante,
           _cnt_asegurado,
		   _cnt_pagador,
		   _cnt_beneficiario
	  from temp_contratantep t, prdramo p
	 where t.cod_ramo = p.cod_ramo
	 group by p.nombre
	 order by p.nombre
	
	return _n_ramo,_cnt_contratante,_cnt_asegurado,_cnt_pagador,_cnt_beneficiario with resume;
end foreach
END PROCEDURE;