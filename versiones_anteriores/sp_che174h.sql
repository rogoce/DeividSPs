  -- Reporte de las Bono de Vida Individual(Nuevas) por Corredor - Detallado Recupero
-- Creado    : 08/02/2008 - Autor: Henry Giron
-- SIS v.2.0 - d_cheq_sp_che174_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che174;
CREATE PROCEDURE sp_che174(a_compania CHAR(3), a_cod_agente CHAR(255) default '*', a_periodo char(7),a_tipo_pago smallint, a_periodo2 char(7))
  RETURNING char(5)   as cod_agente,
			dec(16,2) as prima_sus_agt,
			smallint  as cantidad,
			dec(16,2) as bono_queda,
			dec(16,2) as bono_recupero,
			char(100) as nombre,
			char(3)   as cod_ramo,
			char(50)  as nombre_ramo,
			char(10)  as licencia,
			char(3)   as cod_bono,
			char(50)  as nombre_cia,
			dec(16,2) as bono,
			char(20)  as poliza,
			dec(16,2) as prima_sus_nva,
			dec(16,2) as monto_bono,
			dec(9,4)  as porc_bono,
			char(100) as nombre_clte,
			char(7)   as periodo,
			date      as fecha_recupero,
			dec(16,2) as monto_cancela,
			date      as fecha_cancela,
			char(10)  as factura,
			char(50)   as formapag,
			date      as vig_inic,
			date      as vig_final;



DEFINE _tipo            char(1);
define _tipo_pago       smallint;
define _cod_agente   	char(5);
define _prima_sus_agt   dec(16,2);
define _cantidad        smallint;
define _bono_queda      dec(16,2);
define _bono_recupero   dec(16,2);
define _bono            dec(16,2);
define _nombre          char(100);
define _cod_ramo        char(3);
define _nombre_ramo     char(50);
define _licencia        char(10);
define _cod_bono        char(3);
define _nombre_cia      char(50);
define _no_documento    char(20);
define _prima_sus_nva   dec(16,2);
define _monto_bono		dec(16,2);
define _porc_bono		dec(9,4);
define _nombre_clte	    char(100);
define _periodo			char(7);
define _ult_fecha_recupero date;
define _pri_sus_canc       dec(16,2);
define _cnt_recupero       smallint;
define _factura         char(10);
define _fecha_cancela    date;
define _cod_formapag    char(3);
DEFINE _vigencia_inic,_vigencia_final		DATE;
DEFINE _desc_formapag 		 CHAR(50);
define _no_poliza       char(10);
define _no_factura		char(10);

--SET DEBUG FILE TO "sp_che1741.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

LET  _nombre_cia = sp_sis01(a_compania);
let _ult_fecha_recupero = null;
let a_periodo = a_periodo;
SET ISOLATION TO DIRTY READ;

let	_cod_bono = '001';
let	_prima_sus_agt = 0;
let	_bono = 0;
let	_monto_bono = 0;
let	_porc_bono = 0;
let _pri_sus_canc = 0;
let _cnt_recupero = 0;

if a_cod_agente = "*" then

FOREACH
 SELECT	periodo,
		cod_agente,
		pri_sus_act,
		cantidad,
		bono_queda,
		bono_recupero,
		n_agente,
		cod_ramo,
		nombre_ramo,
		licencia,
		tipo_pago,
		bono,
		ult_fecha_recupero
   INTO	_periodo,
	   _cod_agente,
	   _prima_sus_agt,
	   _cantidad,
	   _bono_queda,
	   _bono_recupero,
	   _nombre,
	   _cod_ramo,
	   _nombre_ramo,
	   _licencia,
	   _tipo_pago,
	   _bono,
		_ult_fecha_recupero
   FROM	chqbono019e
  WHERE cod_agente matches a_cod_agente
	AND ((month(ult_fecha_recupero) >= a_periodo[6,7] AND year(ult_fecha_recupero)  >= a_periodo[1,4])
	AND (month(ult_fecha_recupero) <= (cast(a_periodo2[6,7] as integer) + 1) AND year(ult_fecha_recupero)  <= a_periodo2[1,4]))
	and cia = a_compania
	and aplica = 1

		if a_tipo_pago = 0 then
		elif a_tipo_pago = 1 then
			if _tipo_pago <> 1 then
				continue foreach;
			end if
		else
			if _tipo_pago <> 2 then
				continue foreach;
			end if
		end if

	  select sum(prima_sus_nva),count(*)
		into _pri_sus_canc,_cnt_recupero
		from chqbono019
	   where cod_agente = _cod_agente
		 and date_recupero = _ult_fecha_recupero
		 and recupero = 1 ;

		if _pri_sus_canc is null then
			 Let _pri_sus_canc = 0.00;
		end if

			FOREACH
			SELECT no_documento,
			       prima_sus_nva,
				   monto_bono,
				   porc_bono,
				   nombre_cte,
				   no_poliza
			  INTO _no_documento,
			       _prima_sus_nva,
				   _monto_bono,
				   _porc_bono,
				   _nombre_clte,
				   _no_poliza
			   from chqbono019
			  where periodo = _periodo
			    and cod_agente = _cod_agente
				and aplica = 1
				and recupero = 1

				select cod_formapag,
				       vigencia_inic,
				       vigencia_final
		         into _cod_formapag,
				      _vigencia_inic,
					  _vigencia_final
				 from emipomae
				 where no_poliza = _no_poliza;

				SELECT nombre
				  INTO _desc_formapag
				  FROM cobforpa
				 WHERE cod_formapag = _cod_formapag;

			 foreach
			 select e.no_factura,e.fecha_emision
			   into _no_factura,_fecha_cancela
			   from endedmae e, emipomae p, chqbono019 r
			  where e.no_poliza = p.no_poliza
				and e.no_poliza = r.no_poliza
				and p.cod_ramo = '019'
				and e.cod_endomov = '002'
				and r.periodo = _periodo
				and r.no_poliza = _no_poliza
				and e.actualizado = 1
				and p.estatus_poliza = 2 and r.recupero = 1
				exit foreach;

				end foreach
				--	and r.aplica = 1;


				 RETURN _cod_agente,
						_prima_sus_agt,
						_cnt_recupero,
						_bono_queda,
						_bono_recupero,
						_nombre,
						_cod_ramo,
						_nombre_ramo,
						_licencia,
						_cod_bono,
						_nombre_cia,
						_bono,
						_no_documento,
						_prima_sus_nva,
						_monto_bono,
						_porc_bono,
						_nombre_clte,
						_periodo,
						_ult_fecha_recupero,
						_prima_sus_nva,
						_fecha_cancela,
						_no_factura,
                        _desc_formapag,
				        _vigencia_inic,
					    _vigencia_final
						WITH RESUME;


			END FOREACH

END FOREACH

else

	LET _tipo = sp_sis04(a_cod_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		FOREACH
		SELECT	periodo,
				cod_agente,
				pri_sus_act,
				cantidad,
				bono_queda,
				bono_recupero,
				n_agente,
				cod_ramo,
				nombre_ramo,
				licencia,
				tipo_pago,
				bono
		   INTO _periodo,
			   _cod_agente,
			   _prima_sus_agt,
			   _cantidad,
			   _bono_queda,
			   _bono_recupero,
			   _nombre,
			   _cod_ramo,
			   _nombre_ramo,
			   _licencia,
			   _tipo_pago,
			   _bono
		   FROM	chqbono019e
		  WHERE cod_agente IN (SELECT codigo FROM tmp_codigos)
	AND ((month(ult_fecha_recupero) >= a_periodo[6,7] AND year(ult_fecha_recupero)  >= a_periodo[1,4])
	AND (month(ult_fecha_recupero) <= (cast(a_periodo2[6,7] as integer) + 1) AND year(ult_fecha_recupero)  <= a_periodo2[1,4]))
	and cia = a_compania
	and aplica = 1

			if a_tipo_pago = 0 then
			elif a_tipo_pago = 1 then
				if _tipo_pago <> 1 then
					continue foreach;
				end if
			else
				if _tipo_pago <> 2 then
					continue foreach;
				end if
			end if

	  select sum(prima_sus_nva),count(*)
		into _pri_sus_canc,_cnt_recupero
		from chqbono019
	   where cod_agente = _cod_agente
		 and date_recupero = _ult_fecha_recupero
		 and recupero = 1 ;

		if _pri_sus_canc is null then
			 Let _pri_sus_canc = 0.00;
		end if

			FOREACH
			SELECT no_documento,
			       prima_sus_nva,
				   monto_bono,
				   porc_bono,
				   nombre_cte,
				   no_poliza
			  INTO _no_documento,
			       _prima_sus_nva,
				   _monto_bono,
				   _porc_bono,
				   _nombre_clte,
                   _no_poliza
			   from chqbono019
			  where periodo = _periodo
			    and cod_agente = _cod_agente
				and aplica = 1
                and recupero = 1

				select cod_formapag,
				       vigencia_inic,
				       vigencia_final
		         into _cod_formapag,
				      _vigencia_inic,
					  _vigencia_final
				 from emipomae
				 where no_poliza = _no_poliza;

				SELECT nombre
				  INTO _desc_formapag
				  FROM cobforpa
				 WHERE cod_formapag = _cod_formapag;

			 foreach
			 select e.no_factura,e.fecha_emision
			   into _no_factura,_fecha_cancela
			   from endedmae e, emipomae p, chqbono019 r
			  where e.no_poliza = p.no_poliza
				and e.no_poliza = r.no_poliza
				and p.cod_ramo = '019'
				and e.cod_endomov = '002'
				and r.periodo = _periodo
				and r.no_poliza = _no_poliza
				and e.actualizado = 1
				and p.estatus_poliza = 2 and r.recupero = 1
				exit foreach;

				end foreach

				 RETURN _cod_agente,
						_prima_sus_agt,
						_cnt_recupero,
						_bono_queda,
						_bono_recupero,
						_nombre,
						_cod_ramo,
						_nombre_ramo,
						_licencia,
						_cod_bono,
						_nombre_cia,
						_bono,
						_no_documento,
						_prima_sus_nva,
						_monto_bono,
						_porc_bono,
						_nombre_clte,
						_periodo,
						_ult_fecha_recupero,
						_prima_sus_nva,
						_fecha_cancela,
						_no_factura,
                        _desc_formapag,
				        _vigencia_inic,
					    _vigencia_final
						WITH RESUME;
			END FOREACH

		END FOREACH

	ELSE		        -- Excluir estos Registros

		FOREACH
		SELECT	periodo,
				cod_agente,
				pri_sus_act,
				cantidad,
				bono_queda,
				bono_recupero,
				n_agente,
				cod_ramo,
				nombre_ramo,
				licencia,
				tipo_pago,
				bono,
		        ult_fecha_recupero
		   INTO _periodo,
			   _cod_agente,
			   _prima_sus_agt,
			   _cantidad,
			   _bono_queda,
			   _bono_recupero,
			   _nombre,
			   _cod_ramo,
			   _nombre_ramo,
			   _licencia,
			   _tipo_pago,
			   _bono,
		       _ult_fecha_recupero
		   FROM	chqbono019e
		  WHERE cod_agente IN (SELECT codigo FROM tmp_codigos)
			AND ((month(ult_fecha_recupero) >= a_periodo[6,7] AND year(ult_fecha_recupero)  >= a_periodo[1,4])
			AND (month(ult_fecha_recupero) <= (cast(a_periodo2[6,7] as integer) + 1) AND year(ult_fecha_recupero)  <= a_periodo2[1,4]))
			and cia = a_compania
			and aplica = 1

			if a_tipo_pago = 0 then
			elif a_tipo_pago = 1 then
				if _tipo_pago <> 1 then
					continue foreach;
				end if
			else
				if _tipo_pago <> 2 then
					continue foreach;
				end if
			end if

	  select sum(prima_sus_nva),count(*)
		into _pri_sus_canc,_cnt_recupero
		from chqbono019
	   where cod_agente = _cod_agente
		 and date_recupero = _ult_fecha_recupero
		 and recupero = 1 ;

		if _pri_sus_canc is null then
			 Let _pri_sus_canc = 0.00;
		end if

			FOREACH
			SELECT no_documento,
			       prima_sus_nva,
				   monto_bono,
				   porc_bono,
				   nombre_cte,
				   no_poliza
			  INTO _no_documento,
			       _prima_sus_nva,
				   _monto_bono,
				   _porc_bono,
				   _nombre_clte,
                   _no_poliza
			   from chqbono019
			  where periodo = _periodo
			    and cod_agente = _cod_agente
				and aplica = 1
                and recupero = 1

				select cod_formapag,
				       vigencia_inic,
				       vigencia_final
		         into _cod_formapag,
				      _vigencia_inic,
					  _vigencia_final
				 from emipomae
				 where no_poliza = _no_poliza;

				SELECT nombre
				  INTO _desc_formapag
				  FROM cobforpa
				 WHERE cod_formapag = _cod_formapag;

			 foreach
			 select e.no_factura,e.fecha_emision
			   into _no_factura,_fecha_cancela
			   from endedmae e, emipomae p, chqbono019 r
			  where e.no_poliza = p.no_poliza
				and e.no_poliza = r.no_poliza
				and p.cod_ramo = '019'
				and e.cod_endomov = '002'
				and r.periodo = _periodo
				and r.no_poliza = _no_poliza
				and e.actualizado = 1
				and p.estatus_poliza = 2 and r.recupero = 1
				exit foreach;

				end foreach

				 RETURN _cod_agente,
						_prima_sus_agt,
						_cnt_recupero,
						_bono_queda,
						_bono_recupero,
						_nombre,
						_cod_ramo,
						_nombre_ramo,
						_licencia,
						_cod_bono,
						_nombre_cia,
						_bono,
						_no_documento,
						_prima_sus_nva,
						_monto_bono,
						_porc_bono,
						_nombre_clte,
						_periodo,
						_ult_fecha_recupero,
						_prima_sus_nva,
						_fecha_cancela,
						_no_factura,
                        _desc_formapag,
				        _vigencia_inic,
					    _vigencia_final
						WITH RESUME;
			END FOREACH

		END FOREACH

	END IF
	DROP TABLE tmp_codigos;
end if

END PROCEDURE
