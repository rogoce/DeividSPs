-- Reporte de Siniestros Pagados
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec705_dw1 - DEIVID, S.A.
-- Modificado: 04/10/2013 - Autor: Amado Perez -- Cambios en los Reaseguros

DROP PROCEDURE sp_rec705_am;
CREATE PROCEDURE sp_rec705_am(
a_compania	CHAR(3),
a_agencia	CHAR(3),
a_periodo1	CHAR(7),
a_periodo2	CHAR(7),
a_sucursal	CHAR(255) DEFAULT "*",
a_contrato	CHAR(255) DEFAULT "*",
a_ramo		CHAR(255) DEFAULT "*",
a_serie		CHAR(255) DEFAULT "*",
a_cober		CHAR(255) DEFAULT "*",
a_subramo	CHAR(255) DEFAULT "*",
a_documento CHAR(20)  DEFAULT "*",
a_numrecla  CHAR(20)  DEFAULT "*")
RETURNING	CHAR(18),
			CHAR(20),
			CHAR(100),
			DATE,
			CHAR(10),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			CHAR(50),
			CHAR(50),
			CHAR(50),
			CHAR(255),
			CHAR(15),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			date,
			date,
			char(30),
			dec(16,2),
			integer,
			char(5),
			dec(16,2);

DEFINE v_filtros          CHAR(255);
DEFINE _tipo              CHAR(1);

DEFINE v_doc_reclamo      CHAR(18);     
DEFINE v_doc_poliza       CHAR(20);     
DEFINE v_cliente_nombre   CHAR(100);    
DEFINE v_fecha_siniestro  DATE;         
DEFINE v_transaccion      CHAR(10);     
DEFINE v_pagado_cedido    dec(16,2);
DEFINE v_reserva_cedido   dec(16,2);
DEFINE v_incurrido_cedido dec(16,2);
DEFINE v_ramo_nombre      CHAR(50);     
DEFINE v_contrato_nombre  CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     

DEFINE _no_reclamo        CHAR(10);     
DEFINE _no_poliza         CHAR(10);     
DEFINE _cod_sucursal      CHAR(3);      
DEFINE _cod_subramo       CHAR(3);
DEFINE _cod_ramo          CHAR(3);      
DEFINE _cod_contrato      CHAR(5);     
DEFINE _cod_cliente,_no_tranrec       CHAR(10);     
DEFINE _periodo           CHAR(7);      
DEFINE _tipo_contrato     SMALLINT;
DEFINE _porc_reas,_porc_coas         dec(9,6);

DEFINE _pagado_bruto      dec(16,2);
DEFINE _reserva_bruto     dec(16,2);
DEFINE _incurrido_bruto   dec(16,2);
DEFINE _pagado_neto       dec(16,2);
DEFINE _reserva_neto      dec(16,2);
DEFINE _incurrido_neto    dec(16,2);
DEFINE _serie 			  SMALLINT;
DEFINE _serie2 			  SMALLINT;
DEFINE _pag_ret           dec(16,2);
DEFINE _pag_fac           dec(16,2);
DEFINE _pag_cont          dec(16,2);
DEFINE _res_ret           dec(16,2);
DEFINE _res_fac           dec(16,2);
DEFINE _res_cont,_reserva_total          dec(16,2);

DEFINE v_suma_pag         dec(16,2);
DEFINE v_suma_res         dec(16,2);

DEFINE _cp_pag            dec(16,2);
DEFINE _exc_pag           dec(16,2);
DEFINE _cp_res            dec(16,2);
DEFINE _exc_res           dec(16,2);
DEFINE _exc_ret           dec(16,2);
DEFINE _exc_fac           dec(16,2);

DEFINE _pag_5,_monto_bruto             dec(16,2);
DEFINE _pag_7             dec(16,2);
DEFINE _res_5             dec(16,2);
DEFINE _res_7             dec(16,2);
define _fac_car_1 	      dec(16,2);
define _fac_car_2 	      dec(16,2);
define _fac_car_3 	      dec(16,2);
define _cod_cobertura     char(5);
define _n_cober           char(30);

DEFINE _dt_siniestro      DATE;
DEFINE _serie1 			  SMALLINT;
define _si_hay            SMALLINT;
define _suma_as           dec(16,2);
define _vig_ini			  DATE;
define _vig_fin			  DATE;
define _facilidad_car     smallint;
define _cnt3			  smallint;
define _serie_char        char(15);
define _serie_c           char(4);
define _pag_ret_casco,_monto_total     dec(16,2);
define _cod_cober_reas    char(3);
define _transaccion       char(10);
define _cnt_existe		  smallint;
define _no_unidad         char(5);
define _cant              integer;
define _vigencia_inic	  date;
define _fecha,_vigencia_hasta DATE;
define _fecha_impresion	  DATE;
define _no_requis    char(10);
define _pag_ret_varios    dec(16,2);

LET  v_compania_nombre = sp_sis01(a_compania);

LET v_filtros = sp_rec704(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*',a_subramo); 

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
		cod_subramo          char(3),
		serie_char           char(15),
		ret_casco            dec(16,2),
		ret_varios			 dec(16,2),
		no_tranrec           char(10),
		PRIMARY KEY (no_tranrec,cod_cobertura)
		) WITH NO LOG;

CREATE INDEX xie01_tmp_contrato1 ON tmp_contrato1(cod_contrato);
CREATE INDEX xie02_tmp_contrato1 ON tmp_contrato1(cod_ramo);
CREATE INDEX xie03_tmp_contrato1 ON tmp_contrato1(no_poliza);
CREATE INDEX xie04_tmp_contrato1 ON tmp_contrato1(no_tranrec);
CREATE INDEX xie05_tmp_contrato1 ON tmp_contrato1(cod_subramo);

--SET DEBUG FILE TO 'sp_rec705.trc';
--TRACE ON;

SET ISOLATION TO DIRTY READ;

update tmp_sinis
   set seleccionado = 0
 where doc_poliza in(select no_documento from reaexpol where activo = 1);  --Tabla para excluir polizas

IF a_documento <> "*" THEN
	update tmp_sinis
	   set seleccionado = 0
	 where doc_poliza <> a_documento;  
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
  GROUP BY no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal,cod_subramo
  ORDER BY cod_ramo,numrecla
  
	let _cnt3 = 0;

	if _cod_ramo in('001','003') then

		select count(*)
		  into _cnt3 
		  from recrccob r, prdcober p
		 where r.cod_cobertura = p.cod_cobertura
	   	   and r.no_reclamo    = _no_reclamo
		   and p.relac_inundacion = 1;

	end if

	--LET v_transaccion = 'TODOS';
	LET v_fecha_siniestro = current;

   	IF _pagado_bruto is null  then
		LET _pagado_bruto = 0;
	END IF

	IF _pagado_neto is null  then
		LET _pagado_neto = 0;
	END IF

	-- Informacion de Reaseguro para Sacar la Distribucion de los contratos
	let _cod_contrato = null;
   	FOREACH
		SELECT a.transaccion,
			   a.variacion,
			   a.no_tranrec
		  INTO _transaccion,
			   _reserva_total,
			   _no_tranrec
		  FROM rectrmae a,rectitra b
		 WHERE a.no_reclamo   = _no_reclamo
		   AND a.actualizado  = 1
		   AND a.cod_tipotran = b.cod_tipotran
		   AND b.tipo_transaccion IN (4,5,6,7)
		   AND a.periodo  >= a_periodo1 
		   AND a.periodo  <= a_periodo2
		   AND a.monto   <> 0
		   
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
		let _exc_ret    = 0;
		let _exc_fac    = 0;
		let _pag_ret_casco = 0;
		let _pag_ret_varios = 0;
		let _pagado_neto = 0;
	 
		foreach
			SELECT monto,
				   cod_cobertura
			  INTO _monto_total,
				   _cod_cobertura
			  FROM rectrcob
			 WHERE no_tranrec = _no_tranrec
			   and monto <> 0

			select cod_cober_reas
			  into _cod_cober_reas
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

			SELECT porc_partic_coas
			  INTO _porc_coas
			  FROM reccoas
			 WHERE no_reclamo   = _no_reclamo
			   AND cod_coasegur = '036';

			IF _porc_coas IS NULL THEN
				LET _porc_coas = 0;
			END IF

			let _monto_bruto = 0;
			LET _monto_bruto = (_monto_total  / 100) * _porc_coas;

			select count(*)
			  into _cnt_existe
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cnt_existe is null or _cnt_existe = 0 then
				RETURN v_doc_reclamo,--1
					   '',--2
					   _transaccion,--3
					   '01/01/1900',--4
					   '',--5
					   0.00,--6
					   0.00,--7
					   0.00,--8
					   '',--9
					   '',--10
					   '',--11
					   "No hay Distribucion de Reaseguro para la Transaccion: " || _no_tranrec || " " || _cod_cober_reas,
					   "Error R. " || _cod_cober_reas,--13
					   0.00,--14
					   0.00,--15
					   0.00,--16
					   0.00,--17
					   0.00,--18
					   0.00,--19
					   0.00,--20
					   0.00,--21
					   0.00,--22
					   0.00,--23
					   0.00,--24
					   0.00,--25
					   0.00,--26
					   0.00,--27
					   0.00,--28
					   0.00,--29
					   0.00,
					   '01/01/1900',
					   '01/01/1900',
					   '',
					   0.00,0,'',0 with resume;
				exit foreach;
			end if

			FOREACH
				select cod_contrato,
					   porc_partic_prima
				  into _cod_contrato,
					   _porc_reas
				  from rectrrea
				 where no_tranrec     = _no_tranrec
				   and cod_cober_reas = _cod_cober_reas

				SELECT tipo_contrato, serie, facilidad_car
				  INTO _tipo_contrato, _serie, _facilidad_car
				  FROM reacomae
				 WHERE cod_contrato = _cod_contrato;
				 
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
				let _exc_ret    = 0;
				let _exc_fac    = 0;
				let _pag_ret_casco = 0;
				let _pag_ret_varios = 0;
				let _pagado_neto = 0; 
				 
				IF _porc_reas IS NULL THEN
					LET _porc_reas = 0;
				END IF

				LET v_pagado_cedido    = _monto_bruto     * _porc_reas / 100;

				LET v_reserva_cedido   = _reserva_bruto   * _porc_reas / 100;
				LET v_incurrido_cedido = _incurrido_bruto * _porc_reas / 100;

				let _serie_char = "";
				let _serie_c    = "";
				let _serie_c    = _serie;
				let _serie_char = _serie_c;
				if _cnt3 > 0 and _serie >= 2011 then
					let _serie_char = _serie_c || ' INUNDACION';
				end if

				if _tipo_contrato = 1 then
					if (_cod_ramo = '002' and _cod_cober_reas = '031') or  (_cod_ramo = '023' and _cod_cober_reas = '034') then
						let _pag_ret_casco = _pag_ret_casco + v_pagado_cedido;
					elif _cod_cober_reas in ('045','047','048') then -- Se agrega la retencion de varios Amado 27-05-2025
						let _pag_ret_varios = _pag_ret_varios + v_pagado_cedido;
					else
						let _pag_ret = _pag_ret + v_pagado_cedido;		   
						let _res_ret = _res_ret + v_reserva_cedido;
					end if
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

				if _facilidad_car = 1 then

				   let _fac_car_1 = _fac_car_1 + v_pagado_cedido;--_pag_ret + _pag_fac + _pag_cont;	  -- pago
				   let _fac_car_2 = _cp_pag + _exc_pag;					  -- contratos
				   let _fac_car_3 = _cp_res + _exc_res;					  -- reserva

				   let _cp_pag   = 0;
				   let _exc_pag  = 0;
				   let _pag_fac  = 0;
				   let _pag_cont = 0;
				   let _res_ret  = 0; 
				   let _res_fac  = 0;
				   let _res_cont = 0;
				   let _pag_ret_casco = 0;
				   let _pag_ret_varios = 0;

				end if

			let _pagado_neto = _pag_ret + _pag_ret_casco + _pag_ret_varios;
			
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
					   fac_car_3	=  fac_car_3	+ _fac_car_3,
					   ret_casco    =  ret_casco    + _pag_ret_casco,
					   ret_varios   =  ret_varios   + _pag_ret_varios,
					   pagado_neto  =  pagado_neto  + _pagado_neto,
					   pagado_bruto =  pagado_bruto + v_pagado_cedido
				 WHERE no_tranrec    = _no_tranrec
				   AND cod_cobertura = _cod_cobertura;
				   
			END EXCEPTION

			INSERT INTO tmp_contrato1(
			cod_contrato,	 --1
			no_reclamo,      --2     
			transaccion,	 --3
			no_poliza,       --4    
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
			cod_subramo,
			serie_char,
			ret_casco,
			ret_varios,
			no_tranrec
			)
			VALUES(
			_cod_contrato,
			_no_reclamo,
			_transaccion,           
			_no_poliza,           
			_cod_ramo,            
			_periodo,             
			v_doc_reclamo,            
			v_pagado_cedido,
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
			_cod_subramo,
			_serie_char,
			_pag_ret_casco,
			_pag_ret_varios,
			_no_tranrec
			);
			END
			END FOREACH	 --rectrrea
			if _cnt_existe is null or _cnt_existe = 0 then -- 
				continue foreach;
			end if

		if _cod_contrato is null then
		   continue foreach;
		end if
	
		END FOREACH	 --rectrcob
	END FOREACH	 --rectrmae
END FOREACH		 --tmp_sinis

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

let _pag_ret_casco = 0;

FOREACH
	SELECT no_reclamo,
		   transaccion,
		   cod_cobertura,
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
		   sum(ret_casco),
		   sum(ret_varios)
	  INTO _no_reclamo,
		   _transaccion,
		   _cod_cobertura,
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
		   _pag_ret_casco,
		   _pag_ret_varios
	  FROM tmp_contrato1
	 WHERE seleccionado = 1
	 group by no_reclamo,           
			  transaccion,
			  cod_cobertura,
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

	 let _cod_contrato = '';
	 let v_contrato_nombre = ''; 
	 let _pag_cont = _cp_pag + _exc_pag;
	 
	let _suma_as       = 0.00;
	
	SELECT fecha_siniestro,
	       no_unidad, 
		   suma_asegurada
	  INTO v_fecha_siniestro,
	       _no_unidad,
		   _suma_as
	  FROM recrcmae
	 WHERE no_reclamo = _no_reclamo;
	--se saca la suma asegurada de ancon, caso 14024 JHIM,11/06/2025 AMM 
	SELECT porc_partic_coas
	  INTO _porc_coas
	  FROM reccoas
	 WHERE no_reclamo   = _no_reclamo
	   AND cod_coasegur = '036';

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 100;
	END IF
	let _suma_as = _suma_as * _porc_coas /100;

	select nombre
	  into _n_cober
	  from prdcober
	 where cod_cobertura = _cod_cobertura;

	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo
	 WHERE cod_ramo = _cod_ramo;

	SELECT no_documento,
		   cod_contratante,
		   vigencia_inic,
		   vigencia_final
	  INTO v_doc_poliza,
	       _cod_cliente,
		   _vig_ini,
		   _vig_fin
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;

	SELECT nombre 
	  INTO v_cliente_nombre	
	  FROM cliclien 
	 WHERE cod_cliente = _cod_cliente;

    select count(*)
	  into _cant
	  from emipouni
	 where no_poliza = _no_poliza;

	 --let v_pagado_cedido = 0;
	 --let v_pagado_cedido = _pag_cont + _pag_ret + _pag_ret_casco + _pag_fac + _fac_car_1 + _pag_ret_varios;
	 
--*************vigencia inicial para salud, Armando 03/04/2025
	if _cod_ramo = '018' then
		let _vig_ini = sp_sis517(a_periodo2, _vig_ini);
	end if

	RETURN v_doc_reclamo,         --1
	       v_doc_poliza,		  --2
	 	   v_cliente_nombre, 	  --3
	 	   v_fecha_siniestro, 	  --4
		   _transaccion,		  --5
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
		   _fac_car_1,			  --28
		   _fac_car_3,			  --29
		   _suma_as,
		   _vig_ini,
		   _vig_fin,
		   _n_cober,
		   _pag_ret_casco,
		   _cant,
		   _no_unidad,
		   _pag_ret_varios
		   WITH RESUME;

END FOREACH

DROP TABLE tmp_sinis;
DROP TABLE tmp_contrato1;

END PROCEDURE;

		  