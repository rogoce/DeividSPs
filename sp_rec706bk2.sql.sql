DROP PROCEDURE sp_rec706;

CREATE PROCEDURE "informix".sp_rec706(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_serie CHAR(255) DEFAULT "*",a_cober CHAR(255) DEFAULT "*")
RETURNING CHAR(18),CHAR(20),CHAR(100),DATE,CHAR(10),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),CHAR(50),CHAR(50),CHAR(50),CHAR(255),CHAR(15),DECIMAL(16,2),
DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),
DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),DECIMAL(16,2),date,date,char(30),DECIMAL(16,2);

-- Reporte de Siniestros Incurridos
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec706_dw1 - DEIVID, S.A.

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
define _fac_car_1 	      dec(16,2);
define _fac_car_2 	      dec(16,2);
define _fac_car_3 	      dec(16,2);	
DEFINE _dt_siniestro      DATE;
DEFINE _serie1 			  SMALLINT;
define _si_hay            SMALLINT;
define _cod_cobertura     char(5);
define _vig_ini           date;
define _vig_fin           date;
define _n_cober           char(30);
define _suma_asegurada    DECIMAL(16,2);
define _inc_bruto         DECIMAL(16,2);
define _facilidad_car     smallint;
define _no_documento      char(20);
define _cnt,_cnt3		  smallint;
define _serie_c           char(4);
define _serie_char        char(15);
define _no_tranrec        char(10);
define _cod_cober_reas     char(3);

DEFINE _exc_ret           DECIMAL(16,2);
DEFINE _exc_fac           DECIMAL(16,2);
define _ret_casco         DECIMAL(16,2);
define _monto_total       DECIMAL(16,2);
define _porc_coas         decimal;
define _monto_bruto       DECIMAL(16,2);


-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania);

CALL sp_rec02(a_compania, a_agencia, a_periodo2,a_sucursal,'*','*',a_ramo,'*') RETURNING v_filtros; 

--SET DEBUG FILE TO "sp_rec706.trc"; 
--TRACE ON; 

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
        cod_cobertura        char(5),
		serie_char           char(15),
		ret_casco        	 dec(16,2) default 0,
		PRIMARY KEY (cod_contrato, no_reclamo, serie_char)
		) WITH NO LOG;

foreach 
	select no_reclamo,		
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
	  into _no_reclamo,
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
	  from tmp_sinis 
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal

	let _cnt3 = 0;

	if _cod_ramo in('001','003') then
		select count(*)
		  into _cnt3 
		  from recrccob r, prdcober p
		 where r.cod_cobertura = p.cod_cobertura
	   	   and r.no_reclamo    = _no_reclamo
		   and p.relac_inundacion = 1;
	end if

	select no_documento 
	  into _no_documento
	  from emipomae 
	 where no_poliza = _no_poliza;

	select count(*) 
	  into _cnt 
	  from reaexpol 
	 where no_documento = _no_documento
       and activo       = 1;  			--Tabla para excluir polizas

    if _cnt > 0 then
		continue foreach;
	end if

	LET v_transaccion = 'TODOS';
	LET v_fecha_siniestro = current;


   	IF _reserva_bruto is null  then
		LET _reserva_bruto = 0;
	END IF
	IF _reserva_neto is null  then
		LET _reserva_neto = 0;
	END IF

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo
		exit foreach;
	end foreach

	{IF _reserva_neto = 0 and _reserva_bruto = 0 then
		CONTINUE FOREACH;
	END IF	   }

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos

	let _cod_contrato = null;

	foreach 
		select no_tranrec
		  into _no_tranrec
		  from rectrmae 
		 where cod_compania = a_compania
		   and periodo     <= a_periodo2 
		   and actualizado  = 1
		   and no_reclamo   = _no_reclamo

		foreach
			select variacion,
				   cod_cobertura
			  into _monto_total,
				   _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec

			select cod_cober_reas
			  into _cod_cober_reas
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

			select porc_partic_coas
			  into _porc_coas
			  from reccoas
			 where no_reclamo   = _no_reclamo
			   and cod_coasegur = '036';

			if _porc_coas is null then
				let _porc_coas = 0;
			end if
			
			let _monto_bruto = 0;
			let _monto_bruto = _monto_total  / 100 * _porc_coas;

			let _pag_ret 	= 0;
			let _pag_fac 	= 0;
			let _pag_cont 	= 0;
			let _res_ret 	= 0;
			let _res_fac 	= 0;
			let _res_cont 	= 0;
			let v_suma_pag 	= 0;
			let v_suma_res 	= 0;
			let _cp_pag 	= 0;
			let _exc_pag 	= 0;
			let _cp_res 	= 0;
			let _exc_res  	= 0;
			let _pag_5 		= 0;
			let _res_5 		= 0;
			let _pag_7 		= 0;
			let _res_7 		= 0;
			let _fac_car_1  = 0;
			let _fac_car_2  = 0;
			let _fac_car_3  = 0;
			let _exc_ret    = 0;
			let _exc_fac    = 0;
			let _ret_casco  = 0;

			FOREACH
				select cod_contrato,
					   porc_partic_prima
				  into _cod_contrato,
					   _porc_reas
				  from rectrrea
				 where no_tranrec     = _no_tranrec
				   and cod_cober_reas = _cod_cober_reas

				select tipo_contrato, serie, facilidad_car
				  into _tipo_contrato, _serie, _facilidad_car
				  from reacomae
				 where cod_contrato = _cod_contrato;

				if _porc_reas is null then
					let _porc_reas = 0;
				end if

				LET v_reserva_cedido = _monto_bruto * _porc_reas / 100;

				let _serie_char = "";
				let _serie_c    = "";
				let _serie_c    = _serie;
				let _serie_char = _serie_c;
				if _cnt3 > 0 and _serie >= 2011 then
					let _serie_char = _serie_c || ' INUNDACION';
				end if

				if _tipo_contrato = 1 then --retencion
					if _cod_ramo = '002' and _cod_cober_reas = '031' then
						let _ret_casco = _ret_casco + v_reserva_cedido; 
					else
						let _res_ret = _res_ret + v_reserva_cedido;
					end if

				elif _tipo_contrato = 3 then
					--let _pag_fac = _pag_fac + v_pagado_cedido;
					let _res_fac = _res_fac + v_reserva_cedido;		   
				else
					--let _pag_cont = _pag_cont + v_pagado_cedido;
					let _res_cont = _res_cont + v_reserva_cedido;		   

					if _tipo_contrato = 5 then
						--let _pag_5 = _pag_5 + v_pagado_cedido;
						let _res_5 = _res_5 + v_reserva_cedido;
					end if
					if _tipo_contrato = 7 then
						--let _pag_7 = _pag_7 + v_pagado_cedido;
						let _res_7 = _res_7 + v_reserva_cedido;
					end if
				end if

				let v_suma_pag = _pag_ret + _pag_fac + _pag_cont;
				let v_suma_res = _res_ret + _res_fac + _res_cont;

				let _cp_pag  = _pag_ret + _pag_fac ;
				let _exc_pag = _pag_cont;

				let _cp_res  = _res_ret + _res_fac ;
				let _exc_res = _res_cont;

				if _facilidad_car = 1 then
					let _fac_car_1 = _res_ret + _res_fac + _res_cont;	  -- pago
					let _fac_car_2 = _cp_res + _exc_res;					  -- reserva
					let _fac_car_3 = _cp_pag + _exc_pag;					  -- contratos
					let _cp_pag   = 0;
					let _exc_pag  = 0;
					let _pag_ret  = 0; 
					let _pag_fac  = 0;
					let _pag_cont = 0;
					let _res_ret  = 0; 
					let _res_fac  = 0;
					let _res_cont = 0;
				end if
			end foreach
		end foreach

		if _cod_contrato is null then
			continue foreach;
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
				   ret_res      =  ret_res      + _res_ret,
				   fac_res      =  fac_res      + _exc_fac,
				   cont_res     =  cont_res     + _res_cont,
				   fac_car_1	=  fac_car_1	+ _fac_car_1,
				   fac_car_2	=  fac_car_2	+ _fac_car_2,
				   fac_car_3	=  fac_car_3	+ _fac_car_3,
				   ret_casco    =  ret_casco    + _ret_casco
			 WHERE cod_contrato = _cod_contrato
			 AND no_reclamo = _no_reclamo	 ;

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
		cod_cobertura,
		serie_char,
		ret_casco
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
		_cod_cobertura,
		_serie_char,
		_ret_casco
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

END IF

IF a_serie <> "*" THEN
	DROP TABLE tmp_codigos;
END IF

IF a_cober <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Cobertura: " ||  TRIM(a_cober);

	LET _tipo = sp_sis04(a_cober);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobertura NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_contrato1
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_cobertura IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF


let _inc_bruto = 0;
FOREACH
SELECT 
	no_reclamo,           
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
	sum(fac_car_3),
	sum(ret_casco)
INTO 
	_no_reclamo,
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
	_fac_car_3,
	_ret_casco			 
 FROM tmp_contrato1
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
	serie_char,
	pagado_neto,        
	reserva_neto,       
	incurrido_neto

	if v_reserva_cedido = 0 and _reserva_neto = 0 then
		continue Foreach;
	end if

	 let _cod_contrato = '';
	 let v_contrato_nombre = ''; 

	 --let _res_ret = 0;
	 let _res_cont = _cp_res + _exc_res ; --v_reserva_cedido - _reserva_neto;

	LET v_transaccion = _no_reclamo ;

	LET v_XL = v_reserva_cedido - _reserva_neto;

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

		LET _reserva_neto = ( v_reserva_cedido * _porc_reas ) / 100;
		
	end if

	SELECT fecha_siniestro
	  INTO v_fecha_siniestro
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo

		exit foreach;
	end foreach

	select nombre
	  into _n_cober
	  from prdcober
	 where cod_cobertura = _cod_cobertura;

	SELECT no_documento,
		   cod_contratante,
		   suma_asegurada,
		   vigencia_inic,
		   vigencia_final
	  INTO v_doc_poliza,
	       _cod_cliente,
		   _suma_asegurada,
		   _vig_ini,
		   _vig_fin
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre
	  INTO v_cliente_nombre		
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

   let _inc_bruto = v_reserva_cedido + _fac_car_1;

	RETURN v_doc_reclamo,         --1
	       v_doc_poliza,		  --2
	 	   v_cliente_nombre, 	  --3
	 	   v_fecha_siniestro, 	  --4
		   v_transaccion,		  --5
		   v_pagado_cedido,		  --6
		   _inc_bruto, --v_reserva_cedido,  	  --7
		   v_incurrido_cedido,	  --8
		   v_ramo_nombre,		  --9
		   v_contrato_nombre,	  --10
		   v_compania_nombre,	  --11
		   v_filtros,			  --12
		   _serie_char,				  --13
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
		   _suma_asegurada,
		   _vig_ini,
		   _vig_fin,
		   _n_cober,
		   _ret_casco
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_contrato1;

END PROCEDURE;	   