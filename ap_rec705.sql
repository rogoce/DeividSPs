-- Reporte de Siniestros Pagados
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec705_dw1 - DEIVID, S.A.
-- Modificado: 04/10/2013 - Autor: Amado Perez -- Cambios en los Reaseguros

DROP PROCEDURE ap_rec705;
CREATE PROCEDURE ap_rec705(
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
			char(5);

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
DEFINE _porc_reas,_porc_coas         dec;

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
define _fecha			  DATE;
define _fecha_impresion	  DATE;
define _no_requis         char(10);

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
		PRIMARY KEY (cod_contrato, no_reclamo)
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

	LET v_transaccion = 'TODOS';
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
			   a.no_tranrec,
			   a.fecha
		  INTO _transaccion,
			   _reserva_total,
			   _no_tranrec,
			   _fecha
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
			LET _monto_bruto = _monto_total  / 100 * _porc_coas;

			select count(*)
			  into _cnt_existe
			  from rectrrea
			 where no_tranrec     = _no_tranrec
			   and cod_cober_reas = _cod_cober_reas;

			if _cnt_existe is null or _cnt_existe = 0 then
				RETURN v_doc_reclamo,--1
					   _no_tranrec,--2
					   _no_reclamo,--3
					   _fecha,--4
					   '',--5
					   _monto_bruto,--6
					   0.00,--7
					   0.00,--8
					   '',--9
					   '',--10
					   '',--11
					   "No hay Distribucion de Reaseguro para la Transaccion: " || _no_tranrec || " " || _cod_cober_reas,
					   _transaccion,--13
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
					   0.00,0,'' with resume;
			end if

		END FOREACH	 --rectrcob


	END FOREACH	 --rectrmae
END FOREACH		 --tmp_sinis



DROP TABLE tmp_sinis;
DROP TABLE tmp_contrato1;

END PROCEDURE;

		  