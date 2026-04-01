DROP PROCEDURE sp_rec718;
CREATE PROCEDURE "informix".sp_rec718(
	a_compania CHAR(3),
	a_agencia CHAR(3),
	a_periodo1 CHAR(7),
	a_periodo2 CHAR(7),
	a_sucursal CHAR(255) DEFAULT "*",
	a_contrato CHAR(255) DEFAULT "*",
	a_ramo CHAR(255) DEFAULT "*",
	a_serie CHAR(255) DEFAULT "*",
	a_subramo CHAR(255) DEFAULT "*",
	a_documento CHAR(20)  DEFAULT "*",
	a_numrecla  CHAR(20)  DEFAULT "*") 
RETURNING CHAR(3),CHAR(50),DECIMAL(16,2),DECIMAL(16,2),SMALLINT,DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),CHAR(255),CHAR(50),DEC(16,2),DEC(16,2),DEC(16,2);

-- Reporte de Perfil de Siniestros Pendientes
-- Creado    : 26/07/2011 - Autor: Henry Giron 
-- SIS v.2.0 - d_recl_sp_rec718_dw1 - DEIVID, S.A.	execute procedure sp_rec718("001","001","2011-06","2011-06","*","*","*","2008,2009,2010,2011;","*")

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_doc_reclamo      CHAR(18);     
DEFINE v_doc_poliza       CHAR(20);     
DEFINE v_cliente_nombre   CHAR(100);    
DEFINE v_fecha_siniestro  DATE;         
DEFINE v_transaccion      CHAR(10);     
DEFINE v_pagado_cedido    DECIMAL(16,2);
DEFINE v_reserva_cedido   DECIMAL(16,2);
DEFINE v_incurrido_cedido DECIMAL(16,2);
DEFINE v_ramo_nombre      CHAR(50);     
DEFINE v_contrato_nombre  CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     

DEFINE _no_reclamo        CHAR(10);     
DEFINE _no_poliza         CHAR(10);     
DEFINE _cod_sucursal      CHAR(3);      
DEFINE _cod_ramo          CHAR(3);      
DEFINE _cod_contrato      CHAR(5);     
DEFINE _cod_cliente       CHAR(10);     
DEFINE _periodo           CHAR(7);      
DEFINE _tipo_contrato     SMALLINT;
DEFINE _porc_reas         DECIMAL;

DEFINE _pagado_bruto      DECIMAL(16,2);
DEFINE _reserva_bruto     DECIMAL(16,2);
DEFINE _incurrido_bruto   DECIMAL(16,2);
DEFINE _pagado_neto       DECIMAL(16,2);
DEFINE _reserva_neto      DECIMAL(16,2);
DEFINE _incurrido_neto    DECIMAL(16,2);
DEFINE _serie 			  SMALLINT;

DEFINE _pag_ret           DECIMAL(16,2);
DEFINE _pag_fac           DECIMAL(16,2);
DEFINE _pag_cont          DECIMAL(16,2);
DEFINE _res_ret           DECIMAL(16,2);
DEFINE _res_fac           DECIMAL(16,2);
DEFINE _res_cont          DECIMAL(16,2);

DEFINE v_suma_pag         DECIMAL(16,2);
DEFINE v_suma_res         DECIMAL(16,2);

DEFINE _cp_pag            DECIMAL(16,2);
DEFINE _exc_pag           DECIMAL(16,2);
DEFINE _cp_res            DECIMAL(16,2);
DEFINE _exc_res           DECIMAL(16,2);

DEFINE _pag_5             DECIMAL(16,2);
DEFINE _pag_7             DECIMAL(16,2);
DEFINE _res_5             DECIMAL(16,2);
DEFINE _res_7             DECIMAL(16,2);
define v_prima_tipo		  DEC(16,2);			 
define v_prima_1 		  DEC(16,2);			 
define v_prima_3 		  DEC(16,2);			 
define v_prima_bq		  DEC(16,2);			 
define v_prima_Ot		  DEC(16,2);			 
define _bouquet			  smallint;			 
DEFINE v_rango_inicial	  DEC(16,2);           
DEFINE v_rango_final	  DEC(16,2);           
define v_prima_5 		  DEC(16,2);
define v_prima_7 		  DEC(16,2);
DEFINE v_cod_ramo         CHAR(03);
DEFINE v_nopoliza         CHAR(10);           
DEFINE v_prima            DEC(16,2);    		 
DEFINE v_prima1           DEC(16,2);     		 
DEFINE v_tipo_contrato    SMALLINT;           
DEFINE v_desc_ramo    	  CHAR(50);			 
DEFINE v_noendoso 		  CHAR(5);			 
DEFINE v_cod_contrato     CHAR(5);			 
define v_no_reclamo		  char(10);			 
DEFINE v_periodo          CHAR(7);        	 
define _no_tranrec		  char(10);			 
DEFINE v_cobertura        CHAR(03);  		 
DEFINE _cantidad          SMALLINT;  		 
DEFINE v_filtros1         CHAR(255);  		 
DEFINE v_descr_cia        CHAR(50);  		 
DEFINE v_cod_tipo		  CHAR(3);			 
DEFINE v_porcentaje		  Smallint;			 
DEFINE v_suma_asegurada   DECIMAL(16,2);			 
DEFINE _t_ramo			  CHAR(1);			 
define v_no_cambio	       	smallint;
define v_no_unidad		    char(5);
define v_porc_partic_prima	dec(9,6);
define ld_comp  			dec(16,2);
define _fac_car_1 	        dec(16,2);
define _fac_car_2 	        dec(16,2);
define _fac_car_3 	        dec(16,2);
define _facilidad_car       smallint;		
											   
-- Nombre de la Compania
LET v_compania_nombre = sp_sis01(a_compania);
LET v_descr_cia       = sp_sis01(a_compania);

-- Cargar el Incurrido
-- DROP TABLE tmp_sinis;

-- LET v_filtros = sp_rec35(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*'); -- se le adiciono salvamentos y deducibles.
--LET v_filtros = sp_rec704(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*',a_subramo); 
CALL sp_rec02(a_compania, a_agencia, a_periodo2,a_sucursal,'*','*',a_ramo,'*') RETURNING v_filtros; 

-- Cargar el Incurrido
-- DROP TABLE tmp_sinis;
CREATE TEMP TABLE tmp_ramos
           (cod_ramo         CHAR(3),
		    cod_sub_tipo     CHAR(3),
			porcentaje       SMALLINT default 100,
        PRIMARY KEY(cod_ramo, cod_sub_tipo)) WITH NO LOG;

--CREATE INDEX xie01_tmp_ramos ON tmp_ramos(cod_ramo);
--CREATE INDEX xie01_tmp_ramos ON tmp_ramos(cod_sub_tipo);

-- Tabla Temporal para los Contratos
CREATE TEMP TABLE tmp_contrato1(
		cod_contrato		 CHAR(5),
		no_reclamo           CHAR(10),
		transaccion			 CHAR(10),
		no_poliza            CHAR(10),
		cod_ramo             CHAR(3),
		periodo              CHAR(7),
		numrecla             CHAR(18),
		ultima_fecha         DATE,
		pagado_bruto         DEC(16,2) NOT NULL,
		reserva_bruto        DEC(16,2) NOT NULL,
		incurrido_bruto      DEC(16,2) NOT NULL,
		pagado_neto          DEC(16,2) NOT NULL,
		reserva_neto         DEC(16,2) NOT NULL,
		incurrido_neto       DEC(16,2) NOT NULL,
		cp_pag 		         DEC(16,2),
		exc_pag    			 DEC(16,2),
		cp_res 		         DEC(16,2),
		exc_res    			 DEC(16,2),
		cod_sucursal         CHAR(3)   NOT NULL,
		serie                SMALLINT,
		ret_pag 		     DEC(16,2),
		fac_pag    			 DEC(16,2),
		cont_pag    		 DEC(16,2),
		ret_res 		     DEC(16,2),
		fac_res    			 DEC(16,2),
		cont_res    		 DEC(16,2),
		fac_car_1 	         dec(16,2),
		fac_car_2 	         dec(16,2),
		fac_car_3 	         dec(16,2),
		seleccionado         SMALLINT DEFAULT 1 NOT NULL,
		PRIMARY KEY (cod_contrato, no_reclamo)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_contrato1 ON tmp_contrato1(cod_contrato);
CREATE INDEX xie02_tmp_contrato1 ON tmp_contrato1(cod_ramo);
CREATE INDEX xie03_tmp_contrato1 ON tmp_contrato1(no_poliza);
CREATE INDEX xie04_tmp_contrato1 ON tmp_contrato1(no_reclamo);

CREATE TEMP TABLE tmp_tabla(
		cod_ramo		 CHAR(3),
		desc_ramo		 CHAR(50),
        rango_inicial    DECIMAL(16,2),
        rango_final      DECIMAL(16,2),
        cant_polizas     SMALLINT,
        p_cobrada        DEC(16,2),
        p_retenida       DEC(16,2),
		p_bouquet        DEC(16,2),
		p_facultativo    DEC(16,2),
		p_otros		     DEC(16,2),
		fac_car_1 	     dec(16,2),
		fac_car_2 	     dec(16,2),
		fac_car_3 	     dec(16,2),
        PRIMARY KEY (cod_ramo,rango_inicial)) WITH NO LOG;

--CREATE INDEX xie01_tmp_tabla ON tmp_tabla(cod_ramo);
--SET DEBUG FILE TO 'sp_rec705.trc';
--TRACE ON;
--CREATE TABLE tmp_dif (cod_ramo  CHAR(3),no_poliza CHAR(10),prima1 DEC(16,2),prima2 DEC(16,2)) ;
{CREATE TEMP TABLE tmp_dif
           (cod_ramo         CHAR(3),
		    no_poliza        CHAR(10),
			prima            DEC(16,2),
			prima1           DEC(16,2),
			prima3           DEC(16,2),
			prima5           DEC(16,2),
			prima7           DEC(16,2),
			primabq			 DEC(16,2),
        PRIMARY KEY(cod_ramo, no_poliza)) WITH NO LOG;}
--CREATE INDEX xie01_tmp_dif ON tmp_dif(cod_ramo);
--CREATE INDEX xie01_tmp_dif ON tmp_dif(no_poliza);

SET ISOLATION TO DIRTY READ;
delete from tmp_dif;

IF a_documento <> "*" THEN
	update tmp_sinis
	   set seleccionado = 0
	 where no_documento <> a_documento;  
END IF 

IF a_numrecla <> "*" THEN
	update tmp_sinis
	   set seleccionado = 0
	 where numrecla <> a_numrecla;
END IF 

FOREACH 
 SELECT no_reclamo,		
 		no_poliza,	
		cod_ramo,		
		periodo,
		numrecla,
--		fecha,
--		transaccion,
		cod_sucursal, 
 		sum(pagado_bruto), 		
	    sum(reserva_bruto), 	
	    sum(incurrido_bruto),	
 		sum(pagado_neto), 		
	    sum(reserva_neto), 	
	    sum(incurrido_neto)
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
		_cod_ramo, 
		_periodo,
		v_doc_reclamo,
--		v_fecha_siniestro,
--		v_transaccion,
		_cod_sucursal,
   		_pagado_bruto, 		
	    _reserva_bruto,		
	    _incurrido_bruto,	
   		_pagado_neto, 		
	    _reserva_neto,		
	    _incurrido_neto	
   FROM tmp_sinis 
  WHERE seleccionado = 1
   GROUP BY no_reclamo,		
 		no_poliza,	
		cod_ramo,		
		periodo,
		numrecla,
--		fecha,
--		transaccion,
		cod_sucursal
  ORDER BY cod_ramo,numrecla

	LET v_transaccion = 'TODOS';
	LET v_fecha_siniestro = current;

   	IF _pagado_bruto is null  then
		LET _pagado_bruto = 0;
	END IF

	IF _pagado_neto is null  then
		LET _pagado_neto = 0;
	END IF

	{IF _pagado_neto = 0 and _pagado_bruto = 0 then
		CONTINUE FOREACH;
	END IF}

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos

	FOREACH
	 SELECT porc_partic_suma,
		    cod_contrato	
	   INTO _porc_reas,
		    _cod_contrato	
	   FROM recreaco
	  WHERE no_reclamo = _no_reclamo

		LET _pag_ret 	= 0;
		LET _pag_fac 	= 0;
		LET _pag_cont 	= 0;
		LET _res_ret 	= 0;
		LET _res_fac 	= 0;
		LET _res_cont 	= 0;
		LET v_suma_pag 	= 0;
		LET v_suma_res 	= 0;
		LET _cp_pag 	= 0;
		LET _exc_pag 	= 0;
		LET _cp_res 	= 0;
		LET _exc_res  	= 0;
		LET _pag_5 		= 0;
		LET _res_5 		= 0;
		LET _pag_7 		= 0;
		LET _res_7 		= 0;
		let _fac_car_1  = 0; 
		let _fac_car_2  = 0;
	    let _fac_car_3  = 0;
		let _facilidad_car = 0;

		SELECT tipo_contrato, serie, facilidad_car
		  INTO _tipo_contrato, _serie, _facilidad_car
		  FROM reacomae
		 WHERE cod_contrato = _cod_contrato;

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF

		LET v_pagado_cedido    = _pagado_bruto    * _porc_reas / 100;
		LET v_reserva_cedido   = _reserva_bruto   * _porc_reas / 100;
		LET v_incurrido_cedido = _incurrido_bruto * _porc_reas / 100;

		if _tipo_contrato = 1 then
	   		let _pag_ret = _pag_ret + v_pagado_cedido;		   
	   		let _res_ret = _res_ret + v_reserva_cedido;		   
		elif _tipo_contrato = 3 then
			let _pag_fac = _pag_fac + v_pagado_cedido;
	   		let _res_fac = _res_fac + v_reserva_cedido;		   
		else
			let _pag_cont = _pag_cont + v_pagado_cedido;
	   		let _res_cont = _res_cont + v_reserva_cedido;		   

			if _tipo_contrato = 5 then
				let _pag_5 = _pag_5 + v_pagado_cedido;
				let _res_5 = _res_5 + v_pagado_cedido;
			end if
			if _tipo_contrato = 7 then
				let _pag_7 = _pag_7 + v_pagado_cedido;
				let _res_7 = _res_7 + v_pagado_cedido;
			end if
		end if

		let v_suma_pag = _pag_ret + _pag_fac + _pag_cont;
		let v_suma_res = _res_ret + _res_fac + _res_cont;

		let _cp_pag  = _pag_ret + _pag_fac ;
		let _exc_pag = _pag_cont;

		let _cp_res  = _res_ret + _res_fac ;
		let _exc_res = _res_cont;

		if _facilidad_car = 1 then --_cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then

		   let _fac_car_1 = _res_ret + _res_fac + _res_cont;	  -- siniestros pendiente
		   let _fac_car_3 = _cp_pag + _exc_pag;					  -- contratos
		   let _fac_car_2 = _cp_res + _exc_res;					  -- reserva

		   let _cp_pag     = 0;
		   let _exc_pag    = 0;
		   let _cp_res     = 0;
		   let _exc_res    = 0;
		   let _pag_ret    = 0; 
		   let _pag_fac    = 0;
		   let _pag_cont   = 0;
		   let _res_ret    = 0; 
		   let _res_fac    = 0;
		   let _res_cont   = 0;
		   let _fac_car_1  = 0; 
		   let _fac_car_2  = 0;
		   let _fac_car_3  = 0;

		end if

		BEGIN
		ON EXCEPTION IN(-239)
			UPDATE tmp_contrato1
			   SET cp_pag       =  cp_pag  	    + _pag_5,
				   exc_pag      =  exc_pag      + _pag_7,
				   cp_res       =  cp_res  	    + _res_5,
				   exc_res      =  exc_res      + _res_7,
				   ret_pag      =  ret_pag      + _pag_ret,
				   fac_pag      =  fac_pag      + _pag_fac,
				   cont_pag     =  cont_pag     + _pag_cont,
				   ret_res      =  ret_res      + _res_ret, --_exc_ret,
				   fac_res      =  fac_res      + _res_fac, --_exc_fac,
				   cont_res     =  cont_res     + _res_cont,
				   fac_car_1	=  fac_car_1	+ _fac_car_1,
				   fac_car_2	=  fac_car_2	+ _fac_car_2,
				   fac_car_3	=  fac_car_3	+ _fac_car_3
			 WHERE cod_contrato = _cod_contrato
			 AND no_reclamo = _no_reclamo ;
--			 AND transaccion = v_transaccion ;

		END EXCEPTION

		INSERT INTO tmp_contrato1(
		cod_contrato,
		no_reclamo,           
		transaccion,
		no_poliza,           
		cod_ramo,            
		periodo,             
		numrecla,            
		pagado_bruto,        
		reserva_bruto,       
		incurrido_bruto,
		cod_sucursal,
		serie,
		pagado_neto,        
		reserva_neto,       
		incurrido_neto,
		cp_pag,
		exc_pag,
		cp_res,
		exc_res,
		ret_pag,
		fac_pag,
		cont_pag,
		ret_res,
		fac_res,
		cont_res,
		fac_car_1,
		fac_car_2,
		fac_car_3
		)
		VALUES(
		_cod_contrato,
		_no_reclamo,
		v_transaccion,           
		_no_poliza,           
		_cod_ramo,            
		_periodo,             
		v_doc_reclamo,            
		_pagado_bruto,        
		_reserva_bruto,       
		_incurrido_bruto,
		_cod_sucursal,
		_serie,
		_pagado_neto,        
		_reserva_neto,       
		_incurrido_neto,
		_pag_5,
		_pag_7,
		_res_5,
		_res_7,
		_pag_ret,
		_pag_fac,
		_pag_cont,
		_res_ret,
		_res_fac,
		_res_cont,
		_fac_car_1,
		_fac_car_2,
		_fac_car_3				     		     
		);
		END 
	END FOREACH
END FOREACH

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_contrato <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Contrato: " ||  TRIM(a_contrato);

	LET _tipo = sp_sis04(a_contrato);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

IF a_serie <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Serie: " ||  TRIM(a_serie);

	LET _tipo = sp_sis04(a_serie);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF			   

-- Inactiva los reclamos de tmp_sinis         

FOREACH
 SELECT Distinct cod_ramo,no_poliza,no_reclamo
   INTO v_cod_ramo,v_nopoliza,_no_reclamo
   FROM tmp_contrato1
  WHERE seleccionado = 0

		UPDATE tmp_sinis
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo =  v_cod_ramo
		   AND no_poliza = 	v_nopoliza 
		   AND no_reclamo =  _no_reclamo;

END FOREACH

--- tabla de ramos:

FOREACH
 SELECT Distinct cod_ramo
   INTO v_cod_ramo
   FROM tmp_contrato1
  WHERE seleccionado = 1

     IF v_cod_ramo in ("INI", "INT") THEN

	     IF v_cod_ramo in ("001") THEN
			LET _t_ramo = "1";
		 END IF
	     IF v_cod_ramo in ("003") THEN
			LET _t_ramo = "3";
		 END IF

		BEGIN
			ON EXCEPTION IN(-239)
			END EXCEPTION

		    let v_cod_tipo = "IN"||_t_ramo;

			INSERT INTO tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			VALUES (v_cod_ramo,v_cod_tipo,70);

		    let v_cod_tipo = "TE"||_t_ramo;

			INSERT INTO tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
			VALUES (v_cod_ramo,v_cod_tipo,30);
		END
   ELSE
		INSERT INTO tmp_ramos (cod_ramo,cod_sub_tipo,porcentaje)
		VALUES (v_cod_ramo,v_cod_ramo,100);
     END IF	   	
END FOREACH

LET v_prima_tipo = 0;
LET v_prima_1  = 0;
LET v_prima_3  = 0;
LET v_prima_5  = 0;
LET v_prima_7  = 0;
LET v_prima_bq = 0;
LET v_prima_Ot = 0;
LET _fac_car_1 = 0;
LET _fac_car_2 = 0;
LET _fac_car_3 = 0;

FOREACH
     SELECT distinct cod_ramo, 
			no_poliza 
       INTO v_cod_ramo, 
			v_nopoliza 
         FROM tmp_contrato1 
	   where seleccionado = 1 

	 SELECT sum(reserva_bruto), 		
		    sum(reserva_neto)
	   INTO	v_prima,
			v_prima_1
	   FROM tmp_sinis 
	  WHERE no_poliza = v_nopoliza	
		AND	cod_ramo = v_cod_ramo 
		AND seleccionado = 1;

		if 	v_prima is null then
			let v_prima = 0;
		end if

		if 	v_prima_1 is null then
			let v_prima_1 = 0;
		end if

		 SELECT suma_asegurada
           INTO v_suma_asegurada
           FROM emipomae 
          WHERE no_poliza    = v_nopoliza
            AND cod_compania = "001"
            AND actualizado  = 1;

       FOREACH				  
		SELECT cod_contrato,
		       SUM(fac_res),
			   SUM(cp_res),
			   SUM(exc_res),
			   SUM(ret_res),
			   SUM(cont_res),
			   SUM(fac_car_1),
		       SUM(fac_car_2),
		       SUM(fac_car_3)
		  INTO v_cod_contrato,
		       v_prima_3,
			   v_prima_5,
			   v_prima_7,
			   _res_ret,			  
			   _res_cont,
			   _fac_car_1,
			   _fac_car_2,
			   _fac_car_3			   	
		  FROM tmp_contrato1
		 WHERE cod_ramo = v_cod_ramo
		   AND no_poliza = v_nopoliza 
		   AND seleccionado = 1
		 GROUP BY  cod_contrato

		   LET v_prima_tipo =  v_prima_5 + v_prima_7; -- + _fac_car_2 ;

		let v_no_cambio = null;
	   	select max(no_cambio)
		  into v_no_cambio
		  from emireama
		 where no_poliza = v_nopoliza;

		if v_no_cambio is null then
		  	select max(no_cambio)
			  into v_no_cambio
			  from emireaco
			 where no_poliza = v_nopoliza;
		end if

		{select max(no_cambio)
		  into v_no_cambio
		  from emireaco
		 where no_poliza = v_nopoliza;}

		select min(no_unidad)
		  into v_no_unidad
		  from emireaco
		 where no_poliza = v_nopoliza
		   and no_cambio = v_no_cambio;
		   
		select min(cod_cober_reas)
		  into v_cobertura
		  from emireaco
		 where no_poliza = v_nopoliza
		   and no_unidad = v_no_unidad
		   and no_cambio = v_no_cambio;

			 SELECT bouquet 
			   INTO _bouquet 
			   FROM reacocob 
			  WHERE cod_contrato   = v_cod_contrato 
			    AND cod_cober_reas = v_cobertura    ; 

			 IF _bouquet = 1 THEN 
		 	    LET v_prima_bq = v_prima_bq + v_prima_tipo ; 
			END IF 

		    LET v_prima_tipo = 0; 
		   END FOREACH

		SELECT SUM(fac_res),
			   SUM(cp_res),
			   SUM(exc_res),
			   SUM(fac_car_1),
		       SUM(fac_car_2),
		       SUM(fac_car_3)			   			   
		  INTO v_prima_3,
			   v_prima_5,
			   v_prima_7,
			   _fac_car_1,
			   _fac_car_2,
			   _fac_car_3
		  FROM tmp_contrato1
		 WHERE cod_ramo = v_cod_ramo
		   AND no_poliza = v_nopoliza 
		   AND seleccionado = 1;

 	       LET v_prima_Ot = (v_prima_5 + v_prima_7) - v_prima_bq ; 

		SELECT parinfra.rango1, 
		       parinfra.rango2
		  INTO v_rango_inicial,
	    	   v_rango_final
		  FROM parinfra
		 WHERE parinfra.cod_ramo = v_cod_ramo 
	       AND parinfra.rango1 <= v_suma_asegurada 
		   AND parinfra.rango2 >= v_suma_asegurada; 

	        IF v_rango_inicial IS NULL THEN
			      LET v_rango_inicial = 0;	
			   SELECT rango2
				 INTO v_rango_final
				 FROM parinfra
				WHERE cod_ramo = v_cod_ramo
				  AND parinfra.rango1 = v_rango_inicial;
	       END IF;

		   FOREACH
			 SELECT cod_sub_tipo, porcentaje
			   INTO v_cod_tipo, v_porcentaje
			   FROM tmp_ramos
			  WHERE cod_ramo = v_cod_ramo										

				SELECT nombre
				  INTO v_desc_ramo
				  FROM prdramo
				 WHERE cod_ramo = v_cod_ramo;

					 if v_cod_tipo[1,2] = "IN" then
						LET v_desc_ramo = Trim(v_desc_ramo)||"-INCENDIO";
					 elif v_cod_tipo[1,2] = "TE" then
						LET v_desc_ramo = Trim(v_desc_ramo)||"-TERREMOTO";
					end if

				 let ld_comp = v_prima - (v_prima_1 + v_prima_bq +	v_prima_3 + v_prima_Ot);

				 if	abs(ld_comp) > 10 then     
						INSERT INTO tmp_dif (cod_ramo,no_poliza,prima,prima1,prima3,prima5,prima7,primabq)
						VALUES (v_cod_tipo,v_nopoliza,v_prima,v_prima_1,v_prima_3,v_prima_5,v_prima_7,v_prima_bq);
--						let v_prima_Ot = ld_comp ;
						let v_prima_bq = v_prima_bq + ld_comp ;
				 end if

			     BEGIN
			        ON EXCEPTION IN(-239)
			           UPDATE tmp_tabla
			              SET cant_polizas   = cant_polizas   + 1,
				 		      p_cobrada      = p_cobrada      + v_prima * v_porcentaje/100,   		
						 	  p_retenida     = p_retenida     + v_prima_1 * v_porcentaje/100,	
						 	  p_bouquet      = p_bouquet      + v_prima_bq * v_porcentaje/100,	
						 	  p_facultativo  = p_facultativo  + v_prima_3 * v_porcentaje/100,
						 	  p_otros		 = p_otros        + v_prima_Ot * v_porcentaje/100,
							  fac_car_1	     = fac_car_1      + _fac_car_1 * v_porcentaje/100,
			                  fac_car_2	     = fac_car_2      + _fac_car_2 * v_porcentaje/100,
			                  fac_car_3	     = fac_car_3      + _fac_car_3 * v_porcentaje/100
			            WHERE cod_ramo       = v_cod_tipo  
			              AND rango_inicial  = v_rango_inicial  
			              AND rango_final    = v_rango_final;  

			           END EXCEPTION

			          INSERT INTO tmp_tabla
							(cod_ramo,							
							 desc_ramo,							
							 rango_inicial,					
							 rango_final,  					
							 cant_polizas, 					
							 p_cobrada,    					
							 p_retenida,   					
							 p_bouquet,    					
							 p_facultativo,					
							 p_otros,
							 fac_car_1,
							 fac_car_2,
							 fac_car_3	
							)
					  VALUES(v_cod_tipo, 
							 v_desc_ramo, 
							 v_rango_inicial, 
							 v_rango_final, 
							 1, 
							 v_prima * v_porcentaje/100, 
							 v_prima_1 * v_porcentaje/100, 
							 v_prima_bq * v_porcentaje/100, 
							 v_prima_3 * v_porcentaje/100, 
							 v_prima_Ot * v_porcentaje/100, 
							 _fac_car_1 * v_porcentaje/100, 
							 _fac_car_2 * v_porcentaje/100, 
							 _fac_car_3 * v_porcentaje/100 
							 );				 
			       END

		   END FOREACH

	        LET v_prima    	  = 0; 
			LET v_prima_1  	  = 0;
			LET v_prima_3  	  = 0;
			LET v_prima_5  	  = 0;
			LET v_prima_7  	  = 0;
			LET v_prima_bq 	  = 0;
			LET v_prima_Ot 	  = 0;
			LET v_prima_tipo  = 0;
			LET _res_ret      = 0;			  
			LET _res_cont     = 0;
			LET _fac_car_1    = 0;
			LET _fac_car_2    = 0;
			LET _fac_car_3    = 0;

END FOREACH

FOREACH
	 SELECT cod_ramo,		
			desc_ramo,		
			rango_inicial,
			rango_final,  
			cant_polizas, 
			p_cobrada,    
			p_retenida,   
			p_bouquet,    
			p_facultativo,
			p_otros,
			fac_car_1,
			fac_car_2,
			fac_car_3							
  	   INTO v_cod_ramo, 
			v_desc_ramo, 
			v_rango_inicial,
			v_rango_final, 
			_cantidad, 
			v_prima, 
			v_prima_1, 
			v_prima_bq, 
			v_prima_3, 
			v_prima_Ot, 
			_fac_car_1,
			_fac_car_2,
			_fac_car_3	
	   FROM tmp_tabla 
	  ORDER BY cod_ramo,rango_inicial

     RETURN v_cod_ramo,  
			v_desc_ramo,  
			v_rango_inicial, 
			v_rango_final,  
     		_cantidad,  
     		v_prima,  
     		v_prima_1,  
     		v_prima_bq,  
     		v_prima_3,  
     		v_prima_Ot, 
     		v_filtros, 
     		v_descr_cia,
			_fac_car_1,
			_fac_car_2,
			_fac_car_3	     		 	          
       WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_contrato1;
DROP TABLE tmp_tabla;

END PROCEDURE
			 