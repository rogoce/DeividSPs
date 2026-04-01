

DROP PROCEDURE sp_rea22c;
CREATE PROCEDURE sp_rea22c(a_compania CHAR(3),a_agencia CHAR(3),a_periodo1 CHAR(7),a_periodo2 CHAR(7),a_sucursal CHAR(255) DEFAULT "*",a_contrato CHAR(255) DEFAULT "*",a_ramo CHAR(255) DEFAULT "*",a_serie CHAR(255) DEFAULT "*",a_subramo CHAR(255) DEFAULT "*") 
RETURNING smallint;
--RETURNING CHAR(3),CHAR(50),DECIMAL(16,2),DECIMAL(16,2),SMALLINT,DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),CHAR(255),CHAR(50),DEC(16,2),DEC(16,2),DEC(16,2);

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
DEFINE _cod_contrato,_cod_grupo      CHAR(5);     
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
DEFINE v_cod_ramo,v_cod_tipo2         CHAR(03);
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
DEFINE _causa_siniestro          SMALLINT;  		 
DEFINE v_filtros1         CHAR(255);  		 
DEFINE v_descr_cia        CHAR(50);  		 
DEFINE v_cod_tipo		  CHAR(3);			 
DEFINE _cod_cober_reas		  CHAR(3);			 
DEFINE v_porcentaje		 							Smallint;			 
DEFINE _cnt_cober_reas		 							Smallint;			 
DEFINE _flag		 							Smallint;			 
DEFINE v_suma_asegurada   							DECIMAL(16,2);			 
DEFINE _t_ramo			  							CHAR(1);			 
define v_no_cambio	       							smallint;
define v_no_unidad		    						char(5);
define v_porc_partic_prima							dec(9,6);
define _porc_coas							dec(7,4);
define ld_comp  									dec(16,2);
define _monto_bruto  									dec(16,2);
define _fac_car_1 	       							dec(16,2);
define _fac_car_2 	        						dec(16,2);
define _fac_car_3 	        						dec(16,2);
define _facilidad_car, v_contador, _cnt       			smallint;	
define _fac_car2, v_cobrada, v_acumulada, v_acumulado,_monto_total 	        dec(16,2);

define v_retenida,v_bouquet,v_facultativo,v_otros,v_fac_car  dec(16,2);
define _cant_pol   integer;
define _no_documento      char(20);
define _cod_cobertura char(5);
	
											   
-- Nombre de la Compania
LET v_compania_nombre = sp_sis01(a_compania);
LET v_descr_cia       = sp_sis01(a_compania);

-- Cargar el Incurrido
-- DROP TABLE tmp_sinis_rea;

-- LET v_filtros = sp_rec35(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*'); -- se le adiciono salvamentos y deducibles.
--LET v_filtros = sp_rec704(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*',a_subramo); 
CALL sp_rea22c1(a_compania, a_agencia, a_periodo2,a_sucursal,'*','*',a_ramo,'*') RETURNING v_filtros; 

-- Cargar el Incurrido
-- DROP TABLE tmp_sinis_rea;
CREATE TEMP TABLE temp_ramos_rea
           (cod_ramo         CHAR(3),
		    cod_sub_tipo     CHAR(3),
			porcentaje       SMALLINT default 100,
        PRIMARY KEY(cod_ramo, cod_sub_tipo)) WITH NO LOG;

--CREATE INDEX xie01_temp_ramos_rea ON temp_ramos_rea(cod_ramo);
--CREATE INDEX xie01_temp_ramos_rea ON temp_ramos_rea(cod_sub_tipo);

-- Tabla Temporal para los Contratos
CREATE TEMP TABLE tmp_contrato_rea(
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

CREATE INDEX xie01_tmp_contrato_rea ON tmp_contrato_rea(cod_contrato);
CREATE INDEX xie02_tmp_contrato_rea ON tmp_contrato_rea(cod_ramo);
CREATE INDEX xie03_tmp_contrato_rea ON tmp_contrato_rea(no_poliza);
CREATE INDEX xie04_tmp_contrato_rea ON tmp_contrato_rea(no_reclamo);

/*CREATE TEMP TABLE tmp_tabla_rea(
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
        PRIMARY KEY (cod_ramo,rango_inicial)) WITH NO LOG; */

--CREATE INDEX xie01_tmp_tabla_rea ON tmp_tabla_rea(cod_ramo);
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
   FROM tmp_sinis_rea 
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

  	select no_documento,cod_grupo into _no_documento,_cod_grupo from emipomae where no_poliza = _no_poliza;
	if _cod_grupo = '77960' then --Se excluye Banisi caso 14047 JHIM 13/06/2025
		continue foreach;
	end if

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
/*
   	IF _pagado_bruto is null  then
		LET _pagado_bruto = 0;
	END IF

	IF _pagado_neto is null  then
		LET _pagado_neto = 0;
	END IF
*/
   	IF _reserva_bruto is null  then
		LET _reserva_bruto = 0;
	END IF
	IF _reserva_neto is null  then
		LET _reserva_neto = 0;
	END IF


	{IF _pagado_neto = 0 and _pagado_bruto = 0 then
		CONTINUE FOREACH;
	END IF}

	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos
	
	{foreach

		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo

	  exit foreach;
	end foreach}

	foreach
		select no_tranrec
		  into _no_tranrec
		  from rectrmae
		 where cod_compania = a_compania
		   and periodo     <= a_periodo2
		   and actualizado  = 1
		   and no_reclamo   = _no_reclamo
	{FOREACH
	 SELECT porc_partic_suma,
		    cod_contrato	
	   INTO _porc_reas,
		    _cod_contrato	
	   FROM recreaco
	  WHERE no_reclamo = _no_reclamo}

		foreach
			select variacion,
				   cod_cobertura
			  into _monto_total,
				   _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and variacion <> 0

			select cod_cober_reas,
				   causa_siniestro
			  into _cod_cober_reas,
				   _causa_siniestro
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
			let _cod_contrato = null;			
			
			select count(*)
			  into _cnt_cober_reas
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cnt_cober_reas is null then
				let _cnt_cober_reas = 0;
			end if

			let _flag = 0;

			if _cnt_cober_reas = 0 then
				if _cod_cober_reas = '002' then
					let _cod_cober_reas = '033';
					let _flag = 1;
				elif _cod_cober_reas = '031' then
					if _no_tranrec in ('1555383','1555327') then
						let _cod_cober_reas = '002';
						let _flag = 1;
					else
						let _cod_cober_reas = '034';
						let _flag = 1;
					end if
				elif _cod_cober_reas = '033' then
					let _cod_cober_reas = '002';
					let _flag = 1;
				elif _cod_cober_reas = '034' then
					let _cod_cober_reas = '031';
					let _flag = 1;
				end if
			end if

			foreach
				select cod_contrato,
					   porc_partic_prima
				  into _cod_contrato,
					   _porc_reas
				  from rectrrea
				 where no_tranrec     = _no_tranrec
				   and cod_cober_reas = _cod_cober_reas

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
				/*let _facilidad_car = 0;*/

				SELECT tipo_contrato,
					   serie,
					   facilidad_car
				  INTO _tipo_contrato,
					   _serie,
					   _facilidad_car
				  FROM reacomae
				 WHERE cod_contrato = _cod_contrato;

				IF _porc_reas IS NULL THEN
					LET _porc_reas = 0;
				END IF

				LET v_pagado_cedido    = _pagado_bruto    * _porc_reas / 100;
				LET v_reserva_cedido   = _monto_bruto   * _porc_reas / 100;
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

				if _facilidad_car = 1 then --_cod_contrato = "00574" or _cod_contrato = "00584" or _cod_contrato = "00594" or _cod_contrato = "00604" then

				   let _fac_car_1 = _res_ret + _res_fac + _res_cont;	  -- siniestros pendiente
				   let _fac_car_3 = _cp_pag + _exc_pag;					  -- contratos
				   let _fac_car_2 = _cp_res + _exc_res;					  -- reserva

				   let _cp_pag   = 0;
				   let _exc_pag  = 0;
				   let _pag_ret  = 0; 
				   let _pag_fac  = 0;
				   let _pag_cont = 0;
				   let _res_ret  = 0; 
				   let _res_fac  = 0;
				   let _res_cont = 0;
				 /*  let _cp_pag     = 0;
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
				   let _fac_car_3  = 0;*/

				end if

				BEGIN
				ON EXCEPTION IN(-239)
					UPDATE tmp_contrato_rea
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

				INSERT INTO tmp_contrato_rea(
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
			end foreach --rectrrea
		end foreach --rectrcob
	END FOREACH --rectrmae
END FOREACH --tmp_sinis

-- Procesos para Filtros

LET v_filtros = "";

IF a_sucursal <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Sucursal: " ||  TRIM(a_sucursal);

	LET _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_sucursal NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato_rea
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

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_contrato NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE tmp_contrato_rea
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

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_contrato_rea
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

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_contrato_rea
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND serie IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF			   

-- Inactiva los reclamos de tmp_sinis_rea         

FOREACH
 SELECT Distinct cod_ramo,no_poliza,no_reclamo
   INTO v_cod_ramo,v_nopoliza,_no_reclamo
   FROM tmp_contrato_rea
  WHERE seleccionado = 0

		UPDATE tmp_sinis_rea
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
   FROM tmp_contrato_rea
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

			INSERT INTO temp_ramos_rea (cod_ramo,cod_sub_tipo,porcentaje)
			VALUES (v_cod_ramo,v_cod_tipo,100);

		   /* let v_cod_tipo = "TE"||_t_ramo;

			INSERT INTO temp_ramos_rea (cod_ramo,cod_sub_tipo,porcentaje)
			VALUES (v_cod_ramo,v_cod_tipo,30);*/
		END
   ELSE
		INSERT INTO temp_ramos_rea (cod_ramo,cod_sub_tipo,porcentaje)
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
	  FROM tmp_contrato_rea 
	 where seleccionado = 1 

	SELECT sum(reserva_bruto),
		   sum(reserva_neto)
	  INTO v_prima,
		   v_prima_1
	  FROM tmp_sinis_rea 
	 WHERE no_poliza = v_nopoliza	
	   AND cod_ramo = v_cod_ramo
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
			   SUM(cp_res),
			   SUM(exc_res)				   
		  INTO v_cod_contrato,
			   v_prima_5,
			   v_prima_7			   	
		  FROM tmp_contrato_rea
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
		   AND cod_cober_reas = v_cobertura; 

		IF _bouquet = 1 THEN
			LET v_prima_bq = v_prima_bq + v_prima_tipo ; 
		END IF 

		LET v_prima_tipo = 0; 
	END FOREACH

	SELECT SUM(fac_res),
		   SUM(ret_res),
		   SUM(cp_res),
		   SUM(exc_res),
		   SUM(fac_car_1),
		   SUM(fac_car_2),
		   SUM(fac_car_3)			   			   
	  INTO v_prima_3,
		   _res_ret,
		   v_prima_5,
		   v_prima_7,
		   _fac_car_1,
		   _fac_car_2,
		   _fac_car_3
	  FROM tmp_contrato_rea
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
	END IF

	FOREACH
		SELECT cod_sub_tipo,
			   porcentaje
		  INTO v_cod_tipo,
			   v_porcentaje
		  FROM temp_ramos_rea
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

		BEGIN
			ON EXCEPTION IN(-239)
			   UPDATE tmp_tabla_rea
				  SET cant_polizas2   = cant_polizas2   + 1,
					  p_cobrada2      = p_cobrada2      + v_prima * v_porcentaje/100,   		
					  p_retenida2     = p_retenida2     + _res_ret * v_porcentaje/100,	
					  p_bouquet2      = p_bouquet2      + v_prima_bq * v_porcentaje/100,	
					  p_facultativo2  = p_facultativo2  + v_prima_3 * v_porcentaje/100,
					  p_otros2		 = p_otros2        + v_prima_Ot * v_porcentaje/100,
					  p_fac_car2	     = p_fac_car2      + _fac_car_1 * v_porcentaje/100,
					  p_acumulada2    = 0.00
				WHERE cod_ramo       = v_cod_tipo  
				  AND rango_inicial  = v_rango_inicial  
				  AND rango_final    = v_rango_final;  

			   END EXCEPTION

				INSERT INTO tmp_tabla_rea(
						cod_ramo,							
						desc_ramo,							
						rango_inicial,					
						rango_final,  					
						cant_polizas2, 					
						p_cobrada2,    					
						p_retenida2,   					
						p_bouquet2,    					
						p_facultativo2,					
						p_otros2,
						p_fac_car2,
						p_acumulada2)
				VALUES(	v_cod_tipo, 
						v_desc_ramo, 
						v_rango_inicial, 
						v_rango_final, 
						1, 
						v_prima + _fac_car_1 * v_porcentaje/100, 
						_res_ret * v_porcentaje/100, 
						v_prima_bq * v_porcentaje/100, 
						v_prima_3 * v_porcentaje/100, 
						v_prima_Ot * v_porcentaje/100, 
						_fac_car_1 * v_porcentaje/100,
						0.00);
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

select count(distinct cod_ramo)
  into _cnt
  from tmp_tabla_rea
 where cod_ramo in('001','003');


if _cnt = 2 then

	foreach
		 select rango_inicial,
		        sum(p_retenida2),
				sum(p_bouquet2),
				sum(p_facultativo2),
				sum(p_otros2), 
				sum(p_fac_car2), 
				sum(p_cobrada2),
				sum(cant_polizas2)
		   into v_rango_inicial,
				v_retenida,
				v_bouquet, 
				v_facultativo,
				v_otros, 
				v_fac_car, 
				v_cobrada,
				_cant_pol
		   from tmp_tabla_rea
	      where cod_ramo in('001','003')
	      group by rango_inicial
	   order by rango_inicial

	   select count(*)
	     into _cnt
	    from tmp_tabla_rea
		WHERE cod_ramo      = '001'
		  AND rango_inicial = v_rango_inicial;  

       if _cnt > 0 then

			update tmp_tabla_rea
			   set p_retenida2    = v_retenida,
				   p_bouquet2	  = v_bouquet, 
				   p_facultativo2 = v_facultativo,
				   p_otros2		  = v_otros, 
				   p_fac_car2	  = v_fac_car, 
				   p_cobrada2	  = v_cobrada,
				   cant_polizas2  = _cant_pol
			 WHERE cod_ramo       = '001'  
			   AND rango_inicial  = v_rango_inicial;  
		else

			update tmp_tabla_rea
			   set p_retenida2    = v_retenida,
				   p_bouquet2	  = v_bouquet, 
				   p_facultativo2 = v_facultativo,
				   p_otros2		  = v_otros, 
				   p_fac_car2	  = v_fac_car, 
				   p_cobrada2	  = v_cobrada,
				   cant_polizas2  = _cant_pol,
				   cod_ramo       = '001'
			 WHERE cod_ramo       = '003'  
			   AND rango_inicial  = v_rango_inicial;  

		end if

		 delete from tmp_tabla_rea
		  where cod_ramo = '003'
		    and rango_inicial = v_rango_inicial;  

	end foreach

end if

select count(distinct cod_ramo)
  into _cnt
  from tmp_tabla_rea
 where cod_ramo in('010','011','014','013','022');

if _cnt > 1 then

	foreach

		select distinct cod_ramo
		  into v_cod_tipo
		  from tmp_tabla_rea
		 where cod_ramo in('010','011','014','013','022')

	    exit foreach;

	end foreach

	foreach
		 select rango_inicial,
		        sum(p_retenida2),
				sum(p_bouquet2),
				sum(p_facultativo2),
				sum(p_otros2), 
				sum(p_fac_car2), 
				sum(p_cobrada2),
				sum(cant_polizas2)
		   into v_rango_inicial,
				v_retenida,
				v_bouquet, 
				v_facultativo,
				v_otros, 
				v_fac_car, 
				v_cobrada,
				_cant_pol
		   from tmp_tabla_rea
	      where cod_ramo in('010','011','014','013','022')
	      group by rango_inicial
	   order by rango_inicial

	   select count(*)
	     into _cnt
	    from tmp_tabla_rea
		WHERE cod_ramo      = v_cod_tipo
		  AND rango_inicial = v_rango_inicial;  

       if _cnt > 0 then

			update tmp_tabla_rea
			   set p_retenida2    = v_retenida,
				   p_bouquet2	  = v_bouquet, 
				   p_facultativo2 = v_facultativo,
				   p_otros2		  = v_otros, 
				   p_fac_car2	  = v_fac_car, 
				   p_cobrada2	  = v_cobrada,
				   cant_polizas2  = _cant_pol
			 WHERE cod_ramo       = v_cod_tipo
			   AND rango_inicial  = v_rango_inicial;

	   else
		  foreach
			   select distinct cod_ramo
			     into v_cod_tipo2
			     from tmp_tabla_rea
			    where cod_ramo in('010','011','014','013','022')
			      and rango_inicial = v_rango_inicial
			  exit foreach;
		  end foreach

			update tmp_tabla_rea
			   set p_retenida2    = v_retenida,
				   p_bouquet2	  = v_bouquet, 
				   p_facultativo2 = v_facultativo,
				   p_otros2		  = v_otros, 
				   p_fac_car2	  = v_fac_car, 
				   p_cobrada2	  = v_cobrada,
				   cant_polizas2  = _cant_pol,
				   cod_ramo		  = v_cod_tipo
			 WHERE cod_ramo       = v_cod_tipo2
			   AND rango_inicial  = v_rango_inicial;

	   end if

		 delete from tmp_tabla_rea
		  where cod_ramo not in(v_cod_tipo)
		    and cod_ramo in('010','011','014','013','022')
		    and rango_inicial = v_rango_inicial;  

	end foreach

end if
-----
select count(distinct cod_ramo)
  into _cnt
  from tmp_tabla_rea
 where cod_ramo in('015','007');

if _cnt > 1 then

	foreach

		select distinct cod_ramo
		  into v_cod_tipo
		  from tmp_tabla_rea
		 where cod_ramo in('015','007')

	    exit foreach;

	end foreach

	foreach
		 select rango_inicial,
		        sum(p_retenida2),
				sum(p_bouquet2),
				sum(p_facultativo2),
				sum(p_otros2), 
				sum(p_fac_car2), 
				sum(p_cobrada2),
				sum(cant_polizas2)
		   into v_rango_inicial,
				v_retenida,
				v_bouquet, 
				v_facultativo,
				v_otros, 
				v_fac_car, 
				v_cobrada,
				_cant_pol
		   from tmp_tabla_rea
	      where cod_ramo in('015','007')
	      group by rango_inicial
	   order by rango_inicial

	   select count(*)
	     into _cnt
	    from tmp_tabla_rea
		WHERE cod_ramo      = v_cod_tipo
		  AND rango_inicial = v_rango_inicial;  

       if _cnt > 0 then

			update tmp_tabla_rea
			   set p_retenida2    = v_retenida,
				   p_bouquet2	  = v_bouquet, 
				   p_facultativo2 = v_facultativo,
				   p_otros2		  = v_otros, 
				   p_fac_car2	  = v_fac_car, 
				   p_cobrada2	  = v_cobrada,
				   cant_polizas2  = _cant_pol
			 WHERE cod_ramo       = v_cod_tipo
			   AND rango_inicial  = v_rango_inicial;

	   else
		  foreach
			   select distinct cod_ramo
			     into v_cod_tipo2
			     from tmp_tabla_rea
			    where cod_ramo in('015','007')
			      and rango_inicial = v_rango_inicial
			  exit foreach;
		  end foreach

			update tmp_tabla_rea
			   set p_retenida2    = v_retenida,
				   p_bouquet2	  = v_bouquet, 
				   p_facultativo2 = v_facultativo,
				   p_otros2		  = v_otros, 
				   p_fac_car2	  = v_fac_car, 
				   p_cobrada2	  = v_cobrada,
				   cant_polizas2  = _cant_pol,
				   cod_ramo		  = v_cod_tipo
			 WHERE cod_ramo       = v_cod_tipo2
			   AND rango_inicial  = v_rango_inicial;

	   end if

		 delete from tmp_tabla_rea
		  where cod_ramo not in(v_cod_tipo)
		    and cod_ramo in('015','007')
		    and rango_inicial = v_rango_inicial;  

	end foreach

end if
{
-----
foreach

	 select distinct cod_ramo
	   into v_cod_tipo
	   from tmp_tabla_rea

	let v_contador = 0;

	FOREACH
		 select p_cobrada2,
				rango_inicial,
				rango_final
		into   	v_cobrada,
				v_rango_inicial,
				v_rango_final
		from tmp_tabla_rea
		WHERE cod_ramo     = v_cod_tipo
		order by cod_ramo, rango_inicial, rango_final

		if  v_contador = 0 then
			let v_acumulada = v_cobrada;
		else 
			select max(p_acumulada2)
			into v_acumulado
	        from tmp_tabla_rea
			WHERE cod_ramo       = v_cod_tipo;
			
			let v_acumulada = v_cobrada + v_acumulado;
		end if
		  
		update tmp_tabla_rea
		set p_acumulada2 = v_acumulada
		WHERE cod_ramo       = v_cod_tipo  
		AND rango_inicial  = v_rango_inicial  
		AND rango_final    = v_rango_final; 
		
		let v_contador = v_contador + 1;
		
	END FOREACH

end foreach
}
RETURN 0;
DROP TABLE if exists tmp_sinis_rea;
--DROP TABLE tmp_contrato_rea;
DROP TABLE if exists tmp_tabla_rea;
DROP TABLE if exists temp_ramos_rea;



END PROCEDURE;