DROP PROCEDURE sp_rec717;

CREATE PROCEDURE "informix".sp_rec717(
	a_compania CHAR(3),
	a_agencia CHAR(3),
	a_periodo1 CHAR(7),
	a_periodo2 CHAR(7),
	a_sucursal CHAR(255) DEFAULT "*",
	a_contrato CHAR(255) DEFAULT "*",
	a_ramo CHAR(255) DEFAULT "*",
	a_serie CHAR(255) DEFAULT "*",
	a_coasegur CHAR(255) DEFAULT "*",
	a_documento CHAR(20)  DEFAULT "*",
	a_numrecla  CHAR(20)  DEFAULT "*") 
RETURNING CHAR(18),CHAR(20),CHAR(100),DATE,CHAR(10),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50),CHAR(50),CHAR(255),SMALLINT,DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),DEC(5,2),DEC(16,2);

-- Reporte de Siniestros Incurridos
-- Creado    : 28/03/2011 - Autor: Henry Giron 
-- Modificado: 28/03/2011 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec717_dw1 - DEIVID, S.A.

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);
define _bandera			  char(255);

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
DEFINE _res_cont,v_XL     DECIMAL(16,2);

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
DEFINE _part_res		  DECIMAL(16,2);
DEFINE _part_res_dist     DECIMAL(16,2);
DEFINE n_cod_coasegur     CHAR(50);
DEFINE _cod_coasegur	  CHAR(3);      
DEFINE _tiene_fac         SMALLINT;
DEFINE _no_tranrec        CHAR(10);
DEFINE _renglon			  SMALLINT;
DEFINE _porcentaje		  DEC(5,2);


-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania);
drop table if exists tmp_sinis;
drop table if exists tmp_rec717;
drop table if exists tmp_dist717;
-- Cargar el Incurrido
CALL sp_rec02(a_compania, a_agencia, a_periodo2,a_sucursal,'*','*',a_ramo,'*') RETURNING v_filtros; 

-- Tabla Temporal para los Contratos
set debug file to 'sp_rec717.trc';
trace on;


CREATE TEMP TABLE tmp_rec717(
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
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		part_res    		 DEC(16,2),
		PRIMARY KEY (cod_contrato, no_reclamo)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_rec717 ON tmp_rec717(no_reclamo);
CREATE INDEX xie02_tmp_rec717 ON tmp_rec717(cod_contrato);
CREATE INDEX xie03_tmp_rec717 ON tmp_rec717(cod_ramo);
CREATE INDEX xie04_tmp_rec717 ON tmp_rec717(periodo);
CREATE INDEX xie05_tmp_rec717 ON tmp_rec717(numrecla);
CREATE INDEX xie06_tmp_rec717 ON tmp_rec717(serie);
CREATE INDEX xie07_tmp_rec717 ON tmp_rec717(transaccion);
CREATE INDEX xie08_tmp_rec717 ON tmp_rec717(no_poliza);

CREATE TEMP TABLE tmp_dist717(
		no_reclamo      CHAR(10),
		cod_coasegur	CHAR(3),
		porcentaje		DEC(5,2),
		monto_reas		DEC(16,2),
		seleccionado    SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_reclamo, cod_coasegur)
		) with no log;
CREATE INDEX xie01_tmp_dist717 ON tmp_dist717(no_reclamo);
CREATE INDEX xie02_tmp_dist717 ON tmp_dist717(cod_coasegur);

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
		cod_sucursal

	LET v_transaccion = 'TODOS';
	LET v_fecha_siniestro = current;

   	IF _reserva_bruto is null  then
		LET _reserva_bruto = 0;
	END IF
	IF _reserva_neto is null  then
		LET _reserva_neto = 0;
	END IF

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos
	     LET _tiene_fac = 0;

		SELECT count(*)
		  INTO _tiene_fac
		  FROM reacomae	a,recreaco b
		 WHERE b.no_reclamo = _no_reclamo	
		   AND a.cod_contrato = b.cod_contrato
		   AND a.tipo_contrato = 3;

	IF _tiene_fac = 0 then
		CONTINUE FOREACH;  -- Solo facultativos
	END IF

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
		LET _part_res   = 0;

		SELECT tipo_contrato, serie 
		  INTO _tipo_contrato, _serie 
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
		
			IF _tipo_contrato = 3 then			--	SOLO FACULTATIVOS
				LET _part_res = _reserva_bruto * _porc_reas / 100; 
				foreach
				   select r.orden
					 into _renglon
					 from recreaco r, reacomae c
					where r.no_reclamo  = _no_reclamo
					  and r.cod_contrato = c.cod_contrato
					  and r.cod_contrato = _cod_contrato
					  and c.tipo_contrato = 3
					  exit foreach;
					   end foreach

				foreach
				   select cod_coasegur, porc_partic_reas
					 into _cod_coasegur,_porcentaje
					 from recreafa
					where no_reclamo   = _no_reclamo
					  and cod_contrato = _cod_contrato
					  and orden        = _renglon

						if _porcentaje is null then
							let _porcentaje = 0.00;
						end if

						if _porcentaje <> 0 then
							LET _part_res_dist = _part_res * _porcentaje / 100 ;						
						else
							LET _part_res_dist = 0;
						end if	

						BEGIN
						ON EXCEPTION IN(-239)
							UPDATE tmp_dist717
							   SET monto_reas   = monto_reas + _part_res_dist
							 WHERE no_reclamo   = _no_reclamo 
							   AND cod_coasegur = _cod_coasegur ;
						END EXCEPTION

							INSERT INTO tmp_dist717(
							no_reclamo,
							cod_coasegur,
							porcentaje,
							monto_reas)
							VALUES(
							_no_reclamo,
							_cod_coasegur,
							_porcentaje,
							_part_res_dist);

						END 								
					end foreach
			END IF 
		
			let _pag_fac = _pag_fac + v_pagado_cedido;
	   		let _res_fac = _res_fac + v_reserva_cedido;		   
		else
			let _pag_cont = _pag_cont + v_pagado_cedido;
	   		let _res_cont = _res_cont + v_reserva_cedido;		   

			if _tipo_contrato = 5 then
				let _pag_5 = _pag_5 + v_pagado_cedido;
				let _res_5 = _res_5 + v_reserva_cedido;
			end if
			if _tipo_contrato = 7 then
				let _pag_7 = _pag_7 + v_pagado_cedido;
				let _res_7 = _res_7 + v_reserva_cedido;
			end if
		end if

		let v_suma_pag = _pag_ret + _pag_fac + _pag_cont;
		let v_suma_res = _res_ret + _res_fac + _res_cont;

		let _cp_pag  = _pag_ret + _pag_fac ;
		let _exc_pag = _pag_cont;

		let _cp_res  = _res_ret + _res_fac ;
		let _exc_res = _res_cont;


		BEGIN
		ON EXCEPTION IN(-239)
			UPDATE tmp_rec717
			   SET cp_pag       =  cp_pag  	    + _pag_5,
				   exc_pag      =  exc_pag      + _pag_7,
				   cp_res       =  cp_res  	    + _res_5,
				   exc_res      =  exc_res      + _res_7,
				   ret_pag      =  ret_pag      + _pag_ret,
				   fac_pag      =  fac_pag      + _pag_fac,
				   cont_pag     =  cont_pag     + _pag_cont,
				   ret_res      =  ret_res      + _res_ret,
				   fac_res      =  fac_res      + _res_fac,
				   cont_res     =  cont_res     + _res_cont,
				   part_res     =  part_res     + _part_res
			 WHERE cod_contrato = _cod_contrato
			 AND no_reclamo = _no_reclamo	 ;

		END EXCEPTION

		INSERT INTO tmp_rec717(
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
		part_res
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
		_part_res		     		     
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

		UPDATE tmp_rec717
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_rec717
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

		UPDATE tmp_rec717
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_rec717
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

		UPDATE tmp_rec717
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_rec717
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

		UPDATE tmp_rec717
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_rec717
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


IF a_coasegur <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Reasegurador : " ||  TRIM(a_coasegur);

	LET _tipo = sp_sis04(a_coasegur);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_dist717
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_dist717
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_coasegur IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


FOREACH
SELECT no_reclamo,           
	transaccion,
	no_poliza,           
	cod_ramo,            
	periodo,             
	numrecla,            
	pagado_bruto,        
	reserva_bruto,       
	incurrido_bruto,
	serie,
	pagado_neto,        
	reserva_neto,       
	incurrido_neto,
	sum(cp_pag),
	sum(exc_pag),
	sum(cp_res),
	sum(exc_res),
	sum(ret_pag),
	sum(fac_pag),
	sum(cont_pag),
	sum(ret_res),
	sum(fac_res),
	sum(cont_res),
	sum(part_res)
INTO  _no_reclamo,
	v_transaccion,           
	_no_poliza,           
	_cod_ramo,            
	_periodo,             
	v_doc_reclamo,            
	v_pagado_cedido, 
	v_reserva_cedido, 
	v_incurrido_cedido, 
	_serie, 
	_pagado_neto,       
	_reserva_neto, 
	_incurrido_neto,
	_cp_pag,
	_exc_pag,
	_cp_res,
	_exc_res,
	_pag_ret,
	_pag_fac,
	_pag_cont,
	_res_ret,
	_res_fac,
	_res_cont,
	_part_res
 FROM tmp_rec717
WHERE seleccionado = 1
group by no_reclamo,           
	transaccion,
	no_poliza,           
	cod_ramo,            
	periodo,             
	numrecla,            
	pagado_bruto,        
	reserva_bruto,       
	incurrido_bruto,
	serie,
	pagado_neto,        
	reserva_neto,       
	incurrido_neto

	if v_reserva_cedido = 0 and _reserva_neto = 0 then
		continue Foreach;
	end if

	let _cod_contrato = '';
	let v_contrato_nombre = ''; 
	let _res_ret = 0;
	let _res_cont = _cp_res + _exc_res ;
	LET v_transaccion = _no_reclamo ;
	LET v_XL = v_reserva_cedido - _reserva_neto	;

	if v_XL <> _res_cont then
		-- Informacion de Reaseguro
		LET _porc_reas = 0;

	    FOREACH
		SELECT recreaco.porc_partic_suma
		  INTO _porc_reas
		  FROM recreaco, reacomae
		 WHERE recreaco.no_reclamo    = _no_reclamo
		   AND recreaco.cod_contrato  = reacomae.cod_contrato
		   AND reacomae.tipo_contrato = 1

		IF _porc_reas IS NULL THEN
			LET _porc_reas = 0;
		END IF;
		EXIT FOREACH;
		END FOREACH

		LET _reserva_neto = ( v_reserva_cedido * _porc_reas ) / 100	 ;
		
	end if

	SELECT fecha_siniestro
	  INTO v_fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento,
		   cod_contratante	
	  INTO v_doc_poliza,
	       _cod_cliente
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

		LET _tiene_fac = 0;

	SELECT count(*)
	  INTO _tiene_fac
	  FROM tmp_dist717
	 WHERE no_reclamo = _no_reclamo 
	   AND seleccionado = 1;

	   if _tiene_fac = 0 then
		   LET n_cod_coasegur = '';
		   LET _porcentaje =  0;
		   LET _part_res_dist = 0;
		    IF a_coasegur <> "*" THEN
			   continue foreach;
		   END IF
	   else
			foreach	
			 SELECT cod_coasegur,porcentaje,monto_reas
			   INTO _cod_coasegur,_porcentaje,_part_res_dist
			   FROM tmp_dist717
			  WHERE no_reclamo = _no_reclamo 
			    AND seleccionado = 1
				AND porcentaje <> 0								

					SELECT nombre
					  INTO n_cod_coasegur
					  FROM emicoase
					 WHERE cod_coasegur = _cod_coasegur;

					RETURN v_doc_reclamo,         --1
					       v_doc_poliza,		  --2
					 	   v_cliente_nombre, 	  --3
					 	   v_fecha_siniestro, 	  --4
						   v_transaccion,		  --5
						   v_pagado_cedido,		  --6
						   v_reserva_cedido,  	  --7
						   v_incurrido_cedido,	  --8
						   v_ramo_nombre,		  --9
						   v_contrato_nombre,	  --10
						   v_compania_nombre,	  --11
						   v_filtros,			  --12
						   _serie,				  --13
						   _pagado_neto,          --14
						   _reserva_neto,         --15
					       _incurrido_neto,		  --16
						   _cp_pag,				  --17
						   _exc_pag,			  --18
					       _cp_res,				  --19
						   _exc_res,			  --20
							_pag_ret,			  --21
							_pag_fac,			  --22
							_pag_cont,			  --23
							_res_ret,			  --24
							_res_fac,			  --25
							_res_cont,			  --26		     		     
							_part_res_dist,       --_part_res,
							n_cod_coasegur,
							_porcentaje,
							_part_res_dist
						   WITH RESUME;

			end foreach
       end if
END FOREACH




END PROCEDURE;	   


			