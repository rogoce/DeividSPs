DROP procedure sp_pro4960;
CREATE procedure sp_pro4960(a_cia CHAR(03),a_agencia CHAR(3),a_periodo CHAR(7), a_periodo2 CHAR(7), a_origen CHAR(3) DEFAULT '%')
RETURNING  CHAR(20),CHAR(100),INTEGER,INTEGER,INTEGER,INTEGER,DECIMAL(16,2);

--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---  Armando Moreno M. 21/02/2002
---  Modificado: Amado Perez M. 12/03/2013 -- Se agrega el ramo 022 de equipo pesado a Ramos Tecnicos
---  Ref. Power Builder - d_sp_pro03b
-- execute procedure sp_pro4960('001','001','2016-06', '2016-06', '%')
--------------------------------------------
	define _no_poliza           CHAR(10);	
	define _fecha2     	        DATE;
	define _mes2,_ano2          SMALLINT;
	define _cod_ramo            CHAR(3);	
	define _no_documento        CHAR(20);
	define _total_pri_sus		DECIMAL(16,2);		
	define _suma_asegurada		DECIMAL(16,2);		
	define _orden               CHAR(3);	
	define _tipo_persona        CHAR(1);
    define _cod_contratante,_cod_cliente     CHAR(10);		
	define _descripcion         CHAR(100);	
	define _pn_cant_cli	        INTEGER;
	define _pn_cant_pol	        INTEGER;
	define _pj_cant_cli	        INTEGER;
	define _pj_cant_pol	        INTEGER;		
	define _prima_anual	        DECIMAL(16,2);
	define _prima_devuelta	    DECIMAL(16,2);		
	define _prima_cedida,_monto DECIMAL(16,2);
	define _cod_subramo         CHAR(3);	
	define _tiene_acreedor      SMALLINT;		
	define _cnt_polizas         INTEGER;
	define _cnt_contratante     INTEGER;	
    define _cod_subra_015       CHAR(3);	
    define _codigo              CHAR(3);	
	define _nombre              CHAR(100);	
    define _filtros             CHAR(255);	
	define _descr_cia	        CHAR(45);	
	define _renglon             SMALLINT;	
	define _linea               CHAR(8); 
	define _fronting            smallint;
	
--SET DEBUG FILE TO "sp_pro4960.trc"; 
--trace on;

DROP TABLE  if exists temp_perfil;
DROP TABLE  if exists tmp_poliza;
DROP TABLE  if exists tmp_rpt;

    CREATE TEMP TABLE tmp_poliza(
			  no_documento       CHAR(20),
              cod_ramo           CHAR(3),                            
			  cod_subramo        CHAR(3),                            
			  prima_suscrita     DECIMAL(16,2),
			  sa_poliza          DECIMAL(16,2),
			  tipo_persona       CHAR(1),
			  cod_contratante    CHAR(10),
			  tiene_acreedor     SMALLINT,
			  prima_devuelta 	 DECIMAL(16,2),
			  prima_cedida 	     DECIMAL(16,2),
			  fronting           smallint,
              PRIMARY KEY(no_documento,cod_ramo)) WITH NO LOG;
	CREATE INDEX iii_tmp_poliza1 ON tmp_poliza(cod_ramo);
	CREATE INDEX iii_tmp_poliza2 ON tmp_poliza(no_documento);

	CREATE TEMP TABLE tmp_rpt(
			orden		    CHAR(20),
			descripcion     CHAR(100),
			pn_cant_cli  	INTEGER,
			pn_cant_pol 	INTEGER,
			pj_cant_cli  	INTEGER,
			pj_cant_pol 	INTEGER,			
			prima_anual 	DECIMAL(16,2),
			PRIMARY KEY(orden, descripcion)) WITH NO LOG;  		  

			
SET ISOLATION TO DIRTY READ;
LET _cod_ramo        = NULL;
LET _descr_cia       = NULL;
LET _descr_cia = sp_sis01(a_cia);
LET _suma_asegurada = 0.00;
LET _prima_devuelta = 0.00;
LET _total_pri_sus = 0.00;
LET _prima_cedida = 0.00;
LET _cnt_contratante = 0;
LET _tiene_acreedor = 0;
LET _cnt_polizas = 0;
let _monto  = 0;
let _fronting = 0;

LET _ano2 = a_periodo2[1,4];
LET _mes2 = a_periodo2[6,7];

IF _mes2 = 12 THEN
   LET _mes2 = 1;
   LET _ano2 = _ano2 + 1;
ELSE
   LET _mes2 = _mes2 + 1;
END IF
LET _fecha2 = MDY(_mes2,1,_ano2);
LET _fecha2 = _fecha2 - 1;

CALL sp_pro95a(a_cia,a_agencia,_fecha2,'019,002,020,023,018,008,006,015;','4;Ex',a_origen) RETURNING _filtros;

FOREACH                   
	SELECT cod_ramo, prima_suscrita, no_poliza, no_documento, suma_asegurada , cod_contratante, cod_subramo
	  INTO _cod_ramo, _total_pri_sus, _no_poliza, _no_documento , _suma_asegurada, _cod_contratante, _cod_subramo
	  FROM temp_perfil  
	 WHERE	seleccionado = 1
			 
	IF _suma_asegurada IS NULL THEN
		LET _suma_asegurada = 0;
	END IF 			 	
	  
  	SELECT tipo_persona
	  INTO _tipo_persona
	  FROM cliclien 
	 WHERE cod_cliente = _cod_contratante;

	SELECT fronting
	  INTO _fronting
	  FROM emipomae 
	 WHERE no_poliza = _no_poliza;
	 
	if _fronting is null then
		let _fronting = 0;
	end if	
  
	IF _total_pri_sus IS NULL THEN
		LET _total_pri_sus = 0;
	END IF  	  	     	  

	select count(cod_acreedor)
	  into _tiene_acreedor
	  from emipoacr
	 where no_poliza = _no_poliza;
	 
	  IF _tiene_acreedor IS NULL THEN
		LET _tiene_acreedor = 0;
	  END IF 
	
	select sum(d.monto)
	  into _prima_devuelta
	  from chqchpol d, chqchmae c
	 where d.no_documento = _no_documento
       and d.no_requis = c.no_requis
	   and c.origen_cheque = '6'
	   and c.pagado     = 1
	   and c.autorizado = 1
	   and c.anulado    = 0		   
	   and c.periodo     >= a_periodo
	   and c.periodo     <= a_periodo2;			   
	   
	IF _prima_devuelta IS NULL THEN
	  LET _prima_devuelta = 0;
	END IF  		   	  
	  
	if _cod_ramo = '006' then 	  
	 SELECT	sum( c.prima)
	   INTO	_prima_cedida
	   FROM emifacon c, endedmae e, reacomae x
	  WHERE	c.no_poliza  = _no_poliza
		AND c.cod_contrato = x.cod_contrato
		AND c.no_poliza   = e.no_poliza
		AND c.no_endoso   = e.no_endoso
		and x.tipo_contrato <> '1'
		AND e.actualizado = 1
		AND (c.prima <> 0 OR c.suma_asegurada <> 0)
		AND e.periodo     >= a_periodo
		AND e.periodo     <= a_periodo2;
	end if
		
	IF _prima_cedida IS NULL THEN
		LET _prima_cedida = 0;
	END IF  		
  
	   BEGIN
		  ON EXCEPTION IN(-239)
			 UPDATE tmp_poliza
				SET prima_suscrita = prima_suscrita + _total_pri_sus				    
			   WHERE cod_ramo      = _cod_ramo
				 and no_documento  = _no_documento ;

		  END EXCEPTION
		  INSERT INTO tmp_poliza
			  VALUES(_no_documento,
					 _cod_ramo,
					 _cod_subramo,
					 _total_pri_sus,
					 _suma_asegurada,
					 _tipo_persona,
					 _cod_contratante,
					 _tiene_acreedor,
					 _prima_devuelta,
					 _prima_cedida,
					 _fronting
					 );
	   END	     
END FOREACH
--********PAGO DE SINIESTROS MAYORES A 100,000
-- Polizas de vida Pura
INSERT INTO tmp_rpt
VALUES('001','3.1.1. Pago de siniestros mayores a B/.100,000 (019)',0,0,0,0,0);

FOREACH WITH HOLD
	SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_suscrita)
	  INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _total_pri_sus
	  FROM tmp_poliza	 	 
	 where cod_ramo = '019'
	   and sa_poliza > 100000
  group by 1
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 				
			 WHERE orden = '001' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 					
			 WHERE orden = '001' ;				
		end if					   
END FOREACH	

-- Polizas de vida Pura
INSERT INTO tmp_rpt
VALUES('000','3.1. Polizas de vida pura (019)',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_suscrita)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _total_pri_sus
     FROM tmp_poliza	 	 
	 where cod_ramo = '019'
     group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 				
			 WHERE orden = '000' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 					
			 WHERE orden = '000' ;				
		end if					   
END FOREACH	
{-- Devolucion de Prima
INSERT INTO tmp_rpt
VALUES('002','2.1.1 Devolucion de Prima',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_devuelta)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _prima_devuelta
     FROM tmp_poliza	 	 
	 where cod_ramo = '019' and prima_devuelta > 0
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_devuelta 				
			 WHERE orden = '002' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_devuelta 					
			 WHERE orden = '002' ;				
		end if					   
END FOREACH}
-- Cesion (Garantia)
{INSERT INTO tmp_rpt
VALUES('003','2.1.2 Cesion (Garantia)',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_suscrita)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _total_pri_sus
     FROM tmp_poliza	 	 
	 where cod_ramo = '019' and tiene_acreedor > 0
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 				
			 WHERE orden = '003' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 					
			 WHERE orden = '003' ;				
		end if					   
END FOREACH}
-- Otros beneficiarios con suma asegurada mayor de $ 100.000
{INSERT INTO tmp_rpt
VALUES('004','2.1.5 Otros beneficiarios con suma asegurada mayor de $ 100.000',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_suscrita)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _total_pri_sus
     FROM tmp_poliza	 	 
	 where cod_ramo = '019' and sa_poliza > 100000
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 				
			 WHERE orden = '004' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 					
			 WHERE orden = '004' ;				
		end if
END FOREACH}
-- Polizas de auto (002,023,020)
{INSERT INTO tmp_rpt
VALUES('005','2.3 Polizas de auto (002,023,020)',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_suscrita)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _total_pri_sus
     FROM tmp_poliza	 	 
	 where cod_ramo in ('002','023','020')
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 				
			 WHERE orden = '005' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 					
			 WHERE orden = '005' ;				
		end if
END FOREACH}

-- Devolucion de Prima (002,023,020)
{INSERT INTO tmp_rpt
VALUES('006','2.3.1 Devolucion de Prima',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_devuelta)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _prima_devuelta
     FROM tmp_poliza	 	 
	 where cod_ramo in ('002','023','020') and prima_devuelta > 0
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_devuelta 				
			 WHERE orden = '006' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_devuelta 					
			 WHERE orden = '006' ;				
		end if
END FOREACH}
-- Polizas de salud (018)
{INSERT INTO tmp_rpt
VALUES('007','2.4 Polizas de salud (018)',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_suscrita)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _total_pri_sus
     FROM tmp_poliza	 	 
	 where cod_ramo in ('018')
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 				
			 WHERE orden = '007' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 					
			 WHERE orden = '007' ;				
		end if					   
	 
END FOREACH}
-- Devolucion de Prima (018)
{INSERT INTO tmp_rpt
VALUES('008','2.4.1 Devolucion de Prima',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_devuelta)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _prima_devuelta
     FROM tmp_poliza	 	 
	 where cod_ramo in ('018') and prima_devuelta > 0
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_devuelta 				
			 WHERE orden = '008' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_devuelta 					
			 WHERE orden = '008' ;				
		end if
END FOREACH}

-- Devolucion de Prima Fianza(008)
INSERT INTO tmp_rpt
VALUES('009','3.3.1 Fianzas Devolucion de Prima',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_devuelta)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _prima_devuelta
     FROM tmp_poliza	 	 
	 where cod_ramo in ('008') and prima_devuelta > 0
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_devuelta 				
			 WHERE orden = '009' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_devuelta 					
			 WHERE orden = '009' ;				
		end if					   
	 
END FOREACH	

-- Productos clasificados en cuadros estadisticos como OTROS
INSERT INTO tmp_rpt
VALUES('100','3.4. Productos clasificados en cuadros estadisticos como OTROS',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_suscrita)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _total_pri_sus
     FROM tmp_poliza	 	 
	 where cod_ramo = '015'
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 				
			 WHERE orden = '100' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 					
			 WHERE orden = '100' ;				
		end if					   
		
END FOREACH	
let _renglon = 0;	   
-- Productos clasificados en cuadros estadisticos como OTROS - DETALLE
FOREACH
	SELECT cod_subramo, "1"||cod_subramo[2,3],trim(lower(nombre)) 
	  INTO _cod_subra_015,_codigo,_nombre 
	  FROM prdsubra
	 WHERE cod_ramo = '015'	 
	   and activo = '1'	   
	   order by 1 asc
	   
	   let _renglon = _renglon + 1;		   
	   if _renglon < 10 then
		let _linea = '  3.4.0'||cast(_renglon as char(1));
	 else
	    let _linea = '  3.4.'||cast(_renglon as char(2));
	  end if	  
	   let _nombre = _linea||" "||trim(_nombre);

	INSERT INTO tmp_rpt
	VALUES(_codigo,_nombre,0,0,0,0,0);

	FOREACH WITH HOLD
	   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_suscrita)
		 INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _total_pri_sus
		 FROM tmp_poliza	 	 
		 where cod_ramo = '015' and cod_subramo = _cod_subra_015
		 group by 1	 
				
			if _tipo_persona = "N" then
				UPDATE tmp_rpt
				   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
					   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
					   prima_anual	=	prima_anual	+	_total_pri_sus 				
				 WHERE orden = _codigo ;		
			else
				UPDATE tmp_rpt			   
				   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
					   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
					   prima_anual	=	prima_anual	+	_total_pri_sus 					
				 WHERE orden = _codigo ;				
			end if					   
	END FOREACH	
	let  _linea = '';
	let _nombre  = '';
END FOREACH

-- Responsabilidad Civil (006)
INSERT INTO tmp_rpt
VALUES('200','3.5. Responsabilidad Civil (006)',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_suscrita)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _total_pri_sus
     FROM tmp_poliza	 	 
	 where cod_ramo in ('006')
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 				
			 WHERE orden = '200' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_total_pri_sus 					
			 WHERE orden = '200' ;				
		end if					   
END FOREACH	

-- Devolucion de Prima (006)
INSERT INTO tmp_rpt
VALUES('201','3.5.1. Responsabilidad Civil Devolucion de Prima',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_devuelta)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _prima_devuelta
     FROM tmp_poliza	 	 
	 where cod_ramo in ('006') and prima_devuelta > 0
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_devuelta 				
			 WHERE orden = '201' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_devuelta 					
			 WHERE orden = '201' ;				
		end if					   
END FOREACH	

-- Prima Cedida (006)
INSERT INTO tmp_rpt
VALUES('202','3.5.2 Responsabilidad Civil Primas Cedidas',0,0,0,0,0);

FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),count( no_documento),sum(prima_cedida)
     INTO _tipo_persona,_cnt_contratante,_cnt_polizas, _prima_cedida
     FROM tmp_poliza	 	 
	 where cod_ramo in ('006') and prima_cedida > 0
	 group by 1	 
			
		if _tipo_persona = "N" then
			UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_cedida 				
			 WHERE orden = '202' ;		
		else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante ,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_cedida 					
			 WHERE orden = '202' ;				
		end if
END FOREACH
-- Negocios Fronting  se pone en comentario segun correo de Tatiana del 24/03/2026
--INSERT INTO tmp_rpt
--VALUES('300','3.6.1. Negocios de Fronting',0,0,0,0,0);

{FOREACH WITH HOLD
   SELECT tipo_persona,count(distinct cod_contratante),sum(prima_suscrita),count( no_documento)
     INTO _tipo_persona,_cnt_contratante,_total_pri_sus,_cnt_polizas
     FROM tmp_poliza	 	 
	 where fronting = 1
	 group by 1	 
}			
--		if _tipo_persona = "N" then
			{UPDATE tmp_rpt
			   SET pn_cant_cli	=	pn_cant_cli	+	_cnt_contratante ,
				   pn_cant_pol	=	pn_cant_pol	+	_cnt_polizas ,
				   prima_anual	=	prima_anual	+	_prima_cedida 				
			 WHERE orden = '300' ;}
	{	else
			UPDATE tmp_rpt			   
			   SET pj_cant_cli	=	pj_cant_cli	+	_cnt_contratante,
				   prima_anual	=	prima_anual	+	_total_pri_sus,
				   pj_cant_pol	=	pj_cant_pol	+	_cnt_polizas		--Esta linea no estaba, se coloca 07/03/2025 10:24 am AMM.
			 WHERE orden = '300';				
		end if
END FOREACH}

FOREACH WITH HOLD
   SELECT orden,descripcion,pn_cant_cli,pn_cant_pol,pj_cant_cli,pj_cant_pol,prima_anual
     INTO _orden,_descripcion,_pn_cant_cli,_pn_cant_pol,_pj_cant_cli,_pj_cant_pol,_prima_anual
     FROM tmp_rpt
	 order by orden asc,2
	 
	 return _orden,_descripcion,_pn_cant_cli,_pn_cant_pol,_pj_cant_cli,_pj_cant_pol,_prima_anual with resume; 
	 
END FOREACH	

END PROCEDURE;