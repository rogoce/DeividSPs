---reporte para vielka de rovira para sacar las polizas vigentes de incendio subramo zona libre
---para ver la comision
--Armando Moreno
--21/01/2010

--   DROP procedure verifica1;
   CREATE procedure "informix".verifica1(a_cia CHAR(03),a_agencia CHAR(3),a_periodo DATE,a_codsucursal CHAR(255) DEFAULT "*",a_codramo CHAR(255) DEFAULT "*")

   RETURNING char(10),char(60),CHAR(20),CHAR(5),CHAR(50),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),date,date;


 BEGIN

    DEFINE v_cod_ramo,v_cod_subramo,v_cod_sucursal  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
    DEFINE unidades2          SMALLINT;
    DEFINE _no_poliza          CHAR(10);
    DEFINE v_cant_polizas          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           w_prima_suscrita,w_prima_retenida   DECIMAL(16,2);
    DEFINE v_filtros          CHAR(255);
    DEFINE _tipo              CHAR(01);
	define _cod_agente        char(5);
	define _no_documento      char(20);
	define _porc_comis_agt,_monto,_prima_bruta,_saldo    DECIMAL(16,2);
	define _n_agente          char(50);
	define _cod_tipoprod,_cod_subramo,_cod_ramo  char(3);
	define _n_asegurado   char(60);
	define _cod_contratante char(10);
	define _vigencia_inic  date;
	define _vigencia_final date;

    LET v_cod_ramo  = NULL;
    LET v_cod_sucursal = NULL;
    LET v_cod_subramo  = NULL;
    LET v_desc_subramo = NULL;
    LET _saldo = 0;
    LET _monto = 0;
    LET _prima_bruta = 0;
    LET _porc_comis_agt = 0;
    LET v_filtros = NULL;
    LET _tipo     = NULL;

    SET ISOLATION TO DIRTY READ;

	let v_filtros = sp_pro03("001","001","31/12/2009","001;");


   -- Filtro para Ramos
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE temp_perfil
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

--  Seleccion Final

    FOREACH
       SELECT cod_ramo,
       		  no_poliza,
			  cod_agente,
			  no_documento,
			  prima_suscrita,
			  cod_subramo,
			  cod_contratante,
			  vigencia_inic,
			  vigencia_final
         INTO _cod_ramo,
              _no_poliza,
			  _cod_agente,
			  _no_documento,
			  _prima_bruta,
			  _cod_subramo,
			  _cod_contratante,
			  _vigencia_inic, 
			  _vigencia_final
         FROM temp_perfil
        WHERE seleccionado = 1
        ORDER BY cod_ramo

	   if _cod_ramo = '001' then
	   else
	   		continue foreach;
	   end if

	   if _cod_subramo = '006' then
	   else
			continue foreach;
	   end if

       SELECT cod_tipoprod
         INTO _cod_tipoprod
         FROM emipomae
        WHERE no_poliza = _no_poliza;

	   if _cod_tipoprod = '002' then
			continue foreach;
	   end if

       SELECT porc_comis_agt
         INTO _porc_comis_agt
         FROM emipoagt
        WHERE cod_agente = _cod_agente
          AND no_poliza  = _no_poliza;

	   select nombre
	     into _n_agente
	     from agtagent
	    where cod_agente = _cod_agente;

	   select nombre
	     into _n_asegurado
	     from cliclien
	    where cod_cliente = _cod_contratante;

		select sum(prima_neta)
		  into _monto
		  from cobredet
		 where doc_remesa  = _no_documento
		   and actualizado = 1
		   and periodo     between '2009-01' and '2009-12'
		   and tipo_mov    in ("P", "N");

		if _monto is null then
			let _monto = 0;
		end if

		let _saldo = 0;
		let _saldo = sp_cob115b('001','001',_no_documento,'');

       RETURN  _cod_contratante,_n_asegurado,_no_documento,_cod_agente,_n_agente,_porc_comis_agt,_monto,_prima_bruta,_saldo,_vigencia_inic,_vigencia_final WITH RESUME;
																														   
    END FOREACH

DROP TABLE temp_perfil;
END
END PROCEDURE;
