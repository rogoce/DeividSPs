DROP PROCEDURE sp_rec7055;

CREATE PROCEDURE "informix".sp_rec7055(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_serie CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*")
RETURNING CHAR(18),CHAR(20),CHAR(100),DATE,CHAR(10),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50),CHAR(50),CHAR(255),CHAR(14),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),date,date,char(30);

--execute procedure sp_rec7055('001','001','2012-01','2012-03',"*","*","001,003,004,005,008,010,011,012,013,014,022","2012,2011,2010,2009,2008;")
-- Reporte de Siniestros Pagados
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec705_dw1 - DEIVID, S.A.

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
DEFINE _serie2 			  SMALLINT;
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
define _fac_car_1 	      dec(16,2);
define _fac_car_2 	      dec(16,2);
define _fac_car_3 	      dec(16,2);
define _cod_cobertura     char(5);
define _n_cober           char(30);		

DEFINE _dt_siniestro      DATE;
DEFINE _serie1 			  SMALLINT;
define _si_hay            SMALLINT;
define _suma_as           DECIMAL(16,2);
define _vig_ini			  DATE;
define _vig_fin			  DATE;
define _facilidad_car     smallint;
define _cnt3              smallint;
define _serie_char        char(14);
define _serie_c           char(4);
define _cod_subramo		  char(3);


-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido
--DROP TABLE tmp_sinis;

--LET v_filtros = sp_rec35(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*'); -- se le adiciono salvamentos y deducibles.
LET v_filtros = sp_rec704(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*','*'); 


-- Cargar el Incurrido
--DROP TABLE tmp_sinis;

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
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		cod_subramo          char(3),
		serie_char           char(14),
		PRIMARY KEY (cod_contrato, no_reclamo, serie_char)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_contrato1 ON tmp_contrato1(cod_contrato);
CREATE INDEX xie02_tmp_contrato1 ON tmp_contrato1(cod_ramo);
CREATE INDEX xie03_tmp_contrato1 ON tmp_contrato1(no_poliza);
CREATE INDEX xie04_tmp_contrato1 ON tmp_contrato1(no_reclamo);
CREATE INDEX xie05_tmp_contrato1 ON tmp_contrato1(cod_subramo);

--SET DEBUG FILE TO 'sp_rec705.trc';
--TRACE ON;

SET ISOLATION TO DIRTY READ;

update tmp_sinis
   set seleccionado = 0
 where doc_poliza in(select no_documento from reaexpol where activo = 1);  --Tabla para excluir polizas

FOREACH 
 SELECT no_reclamo,		
 		no_poliza,	
		cod_ramo,		
		periodo,
		numrecla,
		cod_sucursal,
		cod_subramo, 
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
		_cod_subramo,
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
		cod_sucursal,
		cod_subramo
  ORDER BY cod_ramo,numrecla

	let _cnt3 = 0;

	if _cod_ramo in('001','003') then
		select count(*)
		  into _cnt3
		  from recrccob
		 where no_reclamo = _no_reclamo
		   and cod_cobertura in('00010','00013','00036','00057','00058',
		                        '00059','00068','00089','00097','00125',
		                        '00160','00179','00182','00725','00726',
		                        '00732','00742','00743','00748','00754',
		                        '00781','00785','00790','00793','00855',
		                        '00878','00024');
	end if



	LET v_transaccion = 'TODOS';
	LET v_fecha_siniestro = current;

   	IF _pagado_bruto is null  then
		LET _pagado_bruto = 0;
	END IF

	IF _pagado_neto is null  then
		LET _pagado_neto = 0;
	END IF

	IF _pagado_neto = 0 and _pagado_bruto = 0 then
		CONTINUE FOREACH;
	END IF

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos

   	FOREACH
	 SELECT porc_partic_prima,
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

		let _serie_char = "";
		let _serie_c    = "";
		let _serie_c    = _serie;
		let _serie_char = _serie_c;
        if _cnt3 > 0 and _serie >= 2011 then
			let _serie_char = _serie_c || 'INUNDACION';
		end if

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
				if _facilidad_car = 1 then
				else
					let _pag_7 = _pag_7 + v_pagado_cedido;
					let _res_7 = _res_7 + v_pagado_cedido;
				end if
			end if
		end if

		let v_suma_pag = _pag_ret + _pag_fac + _pag_cont;
		let v_suma_res = _res_ret + _res_fac + _res_cont;

		let _cp_pag  = _pag_ret + _pag_fac ;
		let _exc_pag = _pag_cont;

		let _cp_res  = _res_ret + _res_fac ;
		let _exc_res = _res_cont;

		if _facilidad_car = 1 then --_cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then

		   let _fac_car_1 = _pag_ret + _pag_fac + _pag_cont;	  -- pago
		   let _fac_car_2 = _cp_pag + _exc_pag;					  -- contratos
		   let _fac_car_3 = _cp_res + _exc_res;					  -- reserva

		   let _cp_pag   = 0;
		   let _exc_pag  = 0;
		   let _pag_ret  = 0; 
		   let _pag_fac  = 0;
		   let _pag_cont = 0;
		   let _res_ret  = 0; 
		   let _res_fac  = 0;
		   let _res_cont = 0;

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
				   ret_res      =  ret_res      + _exc_ret,
				   fac_res      =  fac_res      + _exc_fac,
				   cont_res     =  cont_res     + _res_cont,
				   fac_car_1	=  fac_car_1	+ _fac_car_1,
				   fac_car_2	=  fac_car_2	+ _fac_car_2,
				   fac_car_3	=  fac_car_3	+ _fac_car_3
			 WHERE cod_contrato = _cod_contrato
			   AND no_reclamo   = _no_reclamo
			   AND serie_char   = _serie_char;


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
		fac_car_3,
		cod_subramo,
		serie_char
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
		_fac_car_3,
		_cod_subramo,
		_serie_char		     		     				     		     
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

IF a_subramo <> "*" THEN
	LET v_filtros = TRIM(v_filtros) ||" Sub Ramo "||TRIM(a_subramo);
	LET _tipo = sp_sis04(a_subramo); -- Separa los valores del String

	IF _tipo <> "E" THEN -- Incluir los Registros
		UPDATE tmp_contrato1
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND cod_subramo NOT IN(SELECT codigo FROM tmp_codigos);
	ELSE
		UPDATE tmp_contrato1
	       SET seleccionado = 0
	     WHERE seleccionado = 1
	       AND cod_subramo IN(SELECT codigo FROM tmp_codigos);
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

	--DROP TABLE tmp_codigos;

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
	   serie_char,
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
	   sum(fac_car_1), 
	   sum(fac_car_2),
	   sum(fac_car_3)
  INTO _no_reclamo,
	   v_transaccion,           
	   _no_poliza,           
	   _cod_ramo,            
	   _periodo,             
	   v_doc_reclamo,            
	   v_pagado_cedido, 
	   v_reserva_cedido, 
	   v_incurrido_cedido, 
	   _serie_char, 
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
	   _fac_car_1,
	   _fac_car_2,
	   _fac_car_3		 
  FROM tmp_contrato1
 WHERE seleccionado = 1
 group by no_reclamo,transaccion,no_poliza,cod_ramo,periodo,numrecla,pagado_bruto,reserva_bruto,incurrido_bruto,serie_char,pagado_neto,reserva_neto,incurrido_neto

	let _cod_contrato = '';
	let v_contrato_nombre = ''; 
	let _pag_ret = 0;
	let _pag_cont = _cp_pag + _exc_pag;
	LET v_transaccion = _no_reclamo ;

	SELECT fecha_siniestro
	  INTO v_fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo

		exit foreach;
    end foreach

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento,
		   cod_contratante,
		   suma_asegurada,
		   vigencia_inic,
		   vigencia_final
	  INTO v_doc_poliza,
	       _cod_cliente,
		   _suma_as,
		   _vig_ini,
		   _vig_fin
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre 
	  INTO v_cliente_nombre	
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

	if _cod_ramo = '006' then
	   LET v_ramo_nombre = 'R.C.G.';
	   let _n_cober = "1";
	elif _cod_ramo = '001' or _cod_ramo = '003' then
	   LET v_ramo_nombre = 'Incendio';
	   let _n_cober = "2";
	elif _cod_ramo in("010","011","012","013","014","022") then
	   LET v_ramo_nombre = 'Ramos Tecnicos';
	   let _n_cober = "3";
	elif _cod_ramo = '008' then
	   LET v_ramo_nombre = 'Fianzas';
	   let _n_cober = "4";
	elif _cod_ramo = '004' then
	   LET v_ramo_nombre = 'Acc. Personales';
	   let _n_cober = "5";
	elif _cod_ramo = '019' then
	   LET v_ramo_nombre = 'Vida Indindividual';
	   let _n_cober = "7";
	elif _cod_ramo = '016' then
	   LET v_ramo_nombre = 'Colectivo de Vida';
	   let _n_cober = "6";
	else
	   let _n_cober = "8";
	end if

---	/***************** la serie cambia por la vigencia del contrato ********/

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
		   _serie_char,			  --13
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
		   _fac_car_1,			  --27
		   _fac_car_2,			  --28
		   _fac_car_3,			  --29
		   _suma_as,
		   _vig_ini,
		   _vig_fin,
		   _n_cober
		   WITH RESUME;

END FOREACH

IF a_serie <> "*" THEN
	DROP TABLE tmp_codigos;
END IF

DROP TABLE tmp_sinis;
DROP TABLE tmp_contrato1;

END PROCEDURE;

		  