-- Comision del 1% por el uso de la Web para emitir poliza

-- Creado    : 13/02/2015 - Autor: Jaime Chevalier.

--DROP PROCEDURE sp_che214_avila;
CREATE PROCEDURE "informix".sp_che214_avila(
a_compania          char(3),
a_sucursal          char(3),
a_periodo		    char(7),
a_usuario           char(8))

RETURNING  char(5),char(10),dec(16,2),dec(16,2),dec(16,2),varchar(50),char(20),varchar(50);

DEFINE _cod_agente           CHAR(5);
DEFINE _cod_agente_web       CHAR(5);
DEFINE _no_poliza            CHAR(10);
DEFINE _nombre_corredor      CHAR(50);

DEFINE _no_remesa			 CHAR(10);
DEFINE _renglon				 SMALLINT;
DEFINE _no_recibo			 CHAR(10);
DEFINE _fecha				 DATE;
DEFINE _monto				 DEC(16,2);
DEFINE _prima				 DEC(16,2);
DEFINE _tipo_mov			 CHAR(1);  
DEFINE _cod_banco			 CHAR(3);
DEFINE _cod_chequera		 CHAR(3);
DEFINE _periodo              CHAR(7);
DEFINE _porc_partic			 DEC(5,2); 
DEFINE _monto_m				 DEC(16,2);
DEFINE _monto_p				 DEC(16,2);
DEFINE _periodo_pag          CHAR(7);

DEFINE _no_documento		 char(20); 
DEFINE _tipo_prod			 smallint;
DEFINE _cod_ramo			 char(3); 
DEFINE _incobrable			 smallint;
DEFINE _cod_formapag		 char(3);
DEFINE _cod_subramo			 char(3); 
DEFINE _cod_origen			 char(3);
DEFINE _cod_contr			 char(10);
DEFINE _fecha_hoy			 date;
DEFINE _nombre				 char(50);
DEFINE _no_licencia			 char(10); 
DEFINE _porc_coas_ancon		dec(5,2);
DEFINE _tipo_forma			smallint;
DEFINE _forma_pag			smallint;
DEFINE _prima_r				dec(16,2);
DEFINE _prima_rr			dec(16,2);
DEFINE _formula_a			dec(16,2);
DEFINE _porc_comis			dec(5,2);
DEFINE _porc_comis2			dec(5,2);
DEFINE _prima_90			dec(16,2);
DEFINE _prima_45			dec(16,2);
DEFINE _formula_b			dec(16,2);
DEFINE v_corriente			dec(16,2);
DEFINE v_monto_30			dec(16,2);
DEFINE v_monto_60			dec(16,2);
DEFINE v_corr				dec(16,2);
DEFINE v_monto_30bk			dec(16,2);
DEFINE v_nombre_clte		char(100);
DEFINE _contado				smallint;
DEFINE _pago				integer;
DEFINE _cod_tipoprod		char(3);
DEFINE v_por_vencer			dec(16,2);
DEFINE v_exigible			dec(16,2);
DEFINE v_saldo				dec(16,2);
DEFINE _comis				decimal(5,2);
DEFINE _adicional           smallint;
define _error				smallint;
define _ult_per_web         char(7);
define _ultmes              char(2);
define _monto_dev           dec(16,2);
define _no_requis           char(10);
define _pagado              smallint;
define _fecha_anulado       date;
define _fecha_ini			date;
define _fecha_fin			date;
define _porc_partic_prima   dec(16,2);
define _porc_proporcion     dec(16,2);
define _monto_fac_ac        dec(16,2);
define _monto_fac	        dec(16,2);


select ult_per_web
  into _ult_per_web
  from parparam;

create temp table tmp_corredor(
cod_agente	     CHAR(5),
no_poliza	     CHAR(10),
monto		     DEC(16,2),
prima		     DEC(16,2),
fecha		     DATE,
primary key	(cod_agente, no_poliza)) with no log;

create index i_corredor on tmp_corredor(cod_agente);
create index i_corredor2 on tmp_corredor(no_poliza);
let _error = 0;
let _fecha_fin = sp_sis36(a_periodo);	--31/01/2015
let _fecha_ini = sp_sis40b(a_periodo);  --01/01/2015
FOREACH
	   SELECT emipoagt.cod_agente,
			  emipomae.no_poliza
		 INTO _cod_agente,
			  _no_poliza
		 FROM emipoagt inner join agtagent on emipoagt.cod_agente = agtagent.cod_agente inner join emipomae on emipoagt.no_poliza = emipomae.no_poliza
		WHERE emipomae.cod_sucursal = '009'
		  AND emipomae.actualizado = 1
		  AND emipomae.nueva_renov = 'N'
		  AND emipoagt.cod_agente <> '00180'    --No incluye a Tecnica de seguros.
		  AND emipomae.no_poliza <> ""
		  and emipomae.periodo >= '2019-01'
		  and emipomae.periodo <= '2019-12'			  
		  AND agtagent.tipo_agente <> 'O'	  --No incluye a Corredores de oficina.
			  
		if _cod_agente not in('02569') then	--Javier Avila
			continue foreach;
		end if
		FOREACH	 
				SELECT d.no_remesa,
					   d.renglon,
					   d.no_recibo,
					   d.fecha,
					   d.monto,
					   d.prima_neta,
					   d.tipo_mov,
					   m.cod_banco,
			           m.cod_chequera,
					   c.porc_partic_agt
				  INTO _no_remesa,
					   _renglon,
					   _no_recibo,
					   _fecha,
					   _monto,
					   _prima,
					   _tipo_mov,
					   _cod_banco,
			           _cod_chequera,
					   _porc_partic
				  FROM cobredet d, cobremae m, cobreagt c
				 WHERE d.no_remesa    = m.no_remesa 
				   AND d.no_remesa    = c.no_remesa
				   AND d.renglon      = c.renglon
				   AND d.cod_compania = a_compania
				   AND d.actualizado  = 1
				   AND d.tipo_mov     in ('P','N')
				   AND month(d.fecha) = a_periodo[6,7]
				   AND year(d.fecha)  = a_periodo[1,4]
				   AND m.tipo_remesa  in ('A', 'M', 'C')
				   AND c.cod_agente   = _cod_agente
				   AND d.no_poliza    = _no_poliza
				 ORDER BY d.fecha,d.no_recibo,d.no_poliza
				 
				-- devoluciones de prima
						foreach
							SELECT monto,
								   no_requis
							  into _monto_dev, 
								   _no_requis
							  FROM chqchpol
							 WHERE no_poliza = _no_poliza
							 
							SELECT pagado,
								   fecha_anulado
							  INTO _pagado,
								   _fecha_anulado
							  FROM chqchmae
							 WHERE no_requis = _no_requis
							   and fecha_impresion between _fecha_ini and _fecha_fin;
							IF _pagado = 1 THEN
								IF _fecha_anulado IS NOT NULL THEN
									IF _fecha_anulado >= _fecha_ini and _fecha_anulado <= _fecha_fin THEN
										LET _monto_dev = 0;
									END IF
								END IF			
							ELSE
								LET _monto_dev = 0;
							END IF	
					
							IF _monto_dev IS NULL THEN
								LET _monto_dev = 0;
							END IF
							let _prima = _prima - _monto_dev;
						end foreach	
						--fin de devoluciones de primas

						let _monto_fac_ac = 0.00;
							--Quitar facultativo cedido
							foreach
								select porc_partic_prima,
									   porc_proporcion
								  into _porc_partic_prima,
									   _porc_proporcion
								  from cobreaco c, reacomae r
								 where c.no_remesa = _no_remesa
								   and c.renglon = _renglon
								   and r.cod_contrato = c.cod_contrato
								   and r.tipo_contrato = 3

								if _porc_partic_prima is null then
									let _porc_partic_prima = 0.00;
								end if
								
								let _monto_fac = _prima * (_porc_partic_prima/100) * (_porc_proporcion/100);
								let _monto_fac_ac = _monto_fac_ac + _monto_fac;
							end foreach
							
							let _prima = _prima - _monto_fac_ac;						
				 
				 
				 let _monto_m = _monto * (_porc_partic / 100);
		         let _monto_p = _prima * (_porc_partic / 100);

				BEGIN
					on exception in(-239)
						update tmp_corredor
						   set monto      = monto + _monto_m,
							   prima      = prima + _monto_p
						 where cod_agente = _cod_agente
						   and no_poliza  = _no_poliza;
					end exception
				 
				 INSERT INTO tmp_corredor (cod_agente,no_poliza,monto,prima,fecha)
				      VALUES(_cod_agente,_no_poliza,_monto_m,_monto_p,_fecha); 
				END
		END FOREACH  
END FOREACH
	--Termina de buscar los Corredores de la web. 
FOREACH 
	    SELECT cod_agente,
			   no_poliza,
			   sum(monto),
			   sum(prima)
		  INTO _cod_agente,
			   _no_poliza,
			   _monto_m,
			   _monto_p
		  FROM tmp_corredor
		 GROUP BY 1,2
		 ORDER BY 1,2
		 
		 SELECT no_documento,
			    cod_tipoprod,
			    cod_ramo,
			    incobrable,
			    cod_formapag,
			    cod_subramo,
			    cod_origen,
			    cod_contratante
		   INTO _no_documento,
			    _cod_tipoprod,
			    _cod_ramo,	
			    _incobrable,
			    _cod_formapag,
			    _cod_subramo,
			    _cod_origen,
			    _cod_contr
		   FROM emipomae
		  WHERE no_poliza = _no_poliza;
		    
		  SELECT nombre,
		         no_licencia
	        INTO _nombre,
		         _no_licencia
	        FROM agtagent
	       WHERE cod_agente = _cod_agente;
		   
		   SELECT tipo_produccion
			 INTO _tipo_prod
			 FROM emitipro
			WHERE cod_tipoprod = _cod_tipoprod;
			
			IF _tipo_prod = 2 THEN  --coas mayoritario
				SELECT porc_partic_coas
				  INTO _porc_coas_ancon
				  FROM emicoama
				 WHERE no_poliza    = _no_poliza
				   AND cod_coasegur = "036";    --ancon
			ELSE
				let _porc_coas_ancon = 100;
			END IF
			
			let _prima_r     = 0;
			let _prima_rr    = 0;
			let _formula_a   = 0;
			let _porc_comis  = 0;
			let _porc_comis2 = 0;
			let _prima_45    = 0;
			let _prima_90    = 0;
			let _formula_b   = 0;
			let v_corriente  = 0;
			let v_monto_30   = 0;
			let v_monto_60   = 0;
			let v_corr       = 0;
			let v_monto_30bk = 0;
			
			if _monto_p <= 0 then	
                continue foreach;
            end if	
			let _prima_r = _monto_p;
			let _prima_r = (_porc_coas_ancon * _prima_r) / 100;
			let _porc_comis2 = 1;
			
			let _formula_a = _prima_r * (_porc_comis2 / 100);
			
			SELECT nombre
			  INTO v_nombre_clte
			  FROM cliclien
			 WHERE cod_cliente = _cod_contr;
			 
			 let v_corriente = v_corr;
			
			return _cod_agente, _no_poliza, _monto_m, _monto_p, _formula_a, _nombre, _no_documento, v_nombre_clte with resume;
END FOREACH

DROP TABLE tmp_corredor;
END PROCEDURE;