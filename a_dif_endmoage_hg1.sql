DROP PROCEDURE a0;

CREATE PROCEDURE a0(
		a_compania    CHAR(03),
		a_periodo1    CHAR(07),
		a_periodo2    CHAR(07),
		a_codramo     CHAR(255) DEFAULT "*"
		)
RETURNING CHAR(3),CHAR(10),CHAR(5),CHAR(10),DEC(16,2),DEC(16,2),DEC(16,2),CHAR(8),DATE,CHAR(20),CHAR(5),DEC(16,2),DEC(16,2),DEC(16,2),char(255);

BEGIN
	  DEFINE v_cod_ramo         CHAR(3);
	  DEFINE v_no_poliza        CHAR(10);
	  DEFINE v_no_endoso        CHAR(5);
	  DEFINE v_no_factura       CHAR(10);
	  DEFINE v_prima_suscrita   DEC(16,2);
	  DEFINE v_prima_neta       DEC(16,2);
	  DEFINE v_suma_asegurada   DEC(16,2);
	  DEFINE v_user_added       CHAR(8);
	  DEFINE v_vigencia_inic    DATE;
	  DEFINE v_no_documento     CHAR(20);
	  DEFINE v_cod_agente       CHAR(5);
	  DEFINE v_porc_partic_agt  DEC(16,2);
	  DEFINE v_p_emifacon		DEC(16,2);
	  DEFINE v_diferencia		DEC(16,2);
      DEFINE v_filtros          CHAR(255);

	  DEFINE f_no_poliza        CHAR(10);
	  DEFINE f_no_endoso        CHAR(5);
	  DEFINE f_prima_suscrita   DEC(16,2);


SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_dif
               (cod_ramo         CHAR(3),
				no_poliza        CHAR(10),
				no_endoso        CHAR(5),	
				no_factura       CHAR(10),	
				prima_suscrita   DEC(16,2),
				prima_neta       DEC(16,2),
				suma_asegurada   DEC(16,2),	
				user_added       CHAR(8),	
				vigencia_inic    DATE,	
				no_documento     CHAR(20),	
				cod_agente       CHAR(5),	
				porc_partic_agt  DEC(16,2),	
				p_emifacon		 DEC(16,2),
				diferencia		 DEC(16,2),
                seleccionado     SMALLINT DEFAULT 1) WITH NO LOG;

      CREATE INDEX id1_tmp_dif ON tmp_dif(cod_ramo,no_poliza,no_endoso,no_factura,cod_agente,porc_partic_agt);

CREATE TEMP TABLE tmp_fac
               (cod_ramo         CHAR(3),
				no_poliza        CHAR(10),
				no_endoso        CHAR(5), 
				prima_suscrita   DEC(16,2),
                seleccionado     SMALLINT DEFAULT 1) WITH NO LOG;

      CREATE INDEX id1_tmp_fac ON tmp_fac(cod_ramo,no_poliza,no_endoso);


      LET v_prima_suscrita  = 0;
      LET v_suma_asegurada  = 0;
      LET v_cod_agente      = NULL;


FOREACH
     SELECT cod_ramo
	 into  v_cod_ramo
     FROM prdramo

-- Busca en endedmae los totales
      FOREACH WITH HOLD
			SELECT e.no_poliza,
				e.no_endoso,
				e.no_factura,
				e.prima_suscrita,
				e.prima_neta,
				e.suma_asegurada,
				e.user_added,
				e.vigencia_inic,
			    y.no_documento ,
			    g.cod_agente, 
			    g.porc_partic_agt
			INTO  v_no_poliza,
				v_no_endoso,
				v_no_factura,
				v_prima_suscrita,
				v_prima_neta,
				v_suma_asegurada,
				v_user_added,
				v_vigencia_inic,
			    v_no_documento ,
			    v_cod_agente, 
			    v_porc_partic_agt
			FROM endedmae  e ,emipomae y, endmoage g
			WHERE (e.periodo    >= a_periodo1
				AND e.periodo     <= a_periodo2)
				AND e.actualizado  = 1
				AND e.cod_compania = a_compania
			           AND y.no_poliza    = e.no_poliza
			            AND y.cod_compania = e.cod_compania
			            AND y.actualizado  = 1
			            and y.cod_ramo = v_cod_ramo
			            and g.no_poliza = e.no_poliza
			           and e.no_endoso = g.no_endoso
			           and e.no_poliza||e.no_endoso in (
			           
			SELECT distinct e.no_poliza||e.no_endoso
			FROM endedmae  e  ,emipomae y
			WHERE (e.periodo    >= a_periodo1
				AND e.periodo     <= a_periodo2)
				AND e.actualizado  = 1
				AND e.cod_compania = a_compania
			           AND y.no_poliza    = e.no_poliza
			            AND y.cod_compania = e.cod_compania
			            AND y.actualizado  = 1
			            and y.cod_ramo = v_cod_ramo
			            and e.prima_suscrita > 0
			              and e.no_poliza||e.no_endoso||e.prima_suscrita   not in (
			SELECT  e.no_poliza||e.no_endoso||sum(f.prima)
			FROM endedmae  e  ,emipomae y,   emifacon f
			WHERE (e.periodo    >= a_periodo1
				AND e.periodo     <= a_periodo2)
				AND e.actualizado  = 1
				AND e.cod_compania = a_compania
			           AND y.no_poliza    = e.no_poliza
			            AND y.cod_compania = e.cod_compania
			            AND y.actualizado  = 1
			            and y.cod_ramo = v_cod_ramo
			           AND e.no_poliza    = f.no_poliza
			           AND e.no_endoso    = f.no_endoso
			           AND f.prima <> 0
			           group by  e.no_poliza,e.no_endoso
			)
			           )


           INSERT INTO tmp_dif
                VALUES(v_cod_ramo,
				v_no_poliza,
				v_no_endoso,
				v_no_factura,
				v_prima_suscrita,
				v_prima_neta,
				v_suma_asegurada,
				v_user_added,
				v_vigencia_inic,
				v_no_documento,
				v_cod_agente,
				v_porc_partic_agt,
				0,
				0,
                1);

	END FOREACH

-- Busca en emifacon los totales
      FOREACH WITH HOLD
			select z.no_poliza,
				z.no_endoso,
				sum(prima) 
			INTO  f_no_poliza,
				f_no_endoso,
				f_prima_suscrita
			from emifacon z
			where z.no_poliza||z.no_endoso in (

			SELECT distinct e.no_poliza||e.no_endoso
			FROM endedmae  e  ,emipomae y
			WHERE (e.periodo    >= a_periodo1
				AND e.periodo     <= a_periodo2)
				AND e.actualizado  = 1
				AND e.cod_compania = a_compania
			           AND y.no_poliza    = e.no_poliza
			            AND y.cod_compania = e.cod_compania
			            AND y.actualizado  = 1
			            and y.cod_ramo = v_cod_ramo
			            and e.prima_suscrita > 0
			              and e.no_poliza||e.no_endoso||e.prima_suscrita   not in (
			SELECT  e.no_poliza||e.no_endoso||sum(f.prima)
			FROM endedmae  e  ,emipomae y,   emifacon f
			WHERE (e.periodo    >= a_periodo1
				AND e.periodo     <= a_periodo2)
				AND e.actualizado  = 1
				AND e.cod_compania = a_compania
			           AND y.no_poliza    = e.no_poliza
			            AND y.cod_compania = e.cod_compania
			            AND y.actualizado  = 1
			            and y.cod_ramo = v_cod_ramo
			           AND e.no_poliza    = f.no_poliza
			           AND e.no_endoso    = f.no_endoso
			           AND f.prima <> 0
			           group by  e.no_poliza,e.no_endoso
			)
			 )
			group by  z.no_poliza,z.no_endoso
			order by  z.no_poliza,z.no_endoso

           INSERT INTO tmp_fac
                VALUES(v_cod_ramo,
				v_no_poliza,
				v_no_endoso,
				v_prima_suscrita,
                1);

	END FOREACH

END FOREACH

--Filtro por Ramo
IF a_codramo <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
	LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros

	UPDATE tmp_dif
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
	UPDATE tmp_dif
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
	END IF
	DROP TABLE tmp_codigos;
END IF


FOREACH
	SELECT 	cod_ramo,
			no_poliza,
			no_endoso,
			no_factura,
			prima_suscrita,
			prima_neta,
			suma_asegurada,
			user_added,
			vigencia_inic,
			no_documento,
			cod_agente,
			porc_partic_agt
		INTO  v_cod_ramo,
		    v_no_poliza,
			v_no_endoso,
			v_no_factura,
			v_prima_suscrita,
			v_prima_neta,
			v_suma_asegurada,
			v_user_added,
			v_vigencia_inic,
		    v_no_documento ,
		    v_cod_agente, 
		    v_porc_partic_agt 
         FROM tmp_dif
	   where seleccionado = 1


            SELECT nombre
              INTO v_desc_ramo
              FROM prdramo
             WHERE cod_ramo = v_cod_ramo;

            SELECT prima_suscrita
              INTO f_prima_suscrita
              FROM tmp_fac
             WHERE cod_ramo = v_cod_ramo
             AND no_poliza = v_no_poliza
             AND no_endoso = v_no_endoso;

			if 	v_porc_partic_agt <> 100 then
				LET v_f_calc = 	f_prima_suscrita * v_porc_partic_agt ;
			else
				LET v_f_calc = 	f_prima_suscrita ;
			end if

			LET v_d_calc = 	v_prima_suscrita -  v_f_calc ;


	         RETURN v_cod_ramo,
		    v_no_poliza,
			v_no_endoso,
			v_no_factura,
			v_prima_suscrita,
			v_prima_neta,
			v_suma_asegurada,
			v_user_added,
			v_vigencia_inic,
		    v_no_documento ,
		    v_cod_agente, 
		    v_porc_partic_agt,
		    v_f_calc,
		    v_d_calc,
		    v_filtros 
	        WITH RESUME;


END FOREACH
