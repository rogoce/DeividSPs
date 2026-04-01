-- Reporte de Siniestros Pagados
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec705_dw1 - DEIVID, S.A.
-- Modificado: 04/10/2013 - Autor: Amado Perez -- Cambios en los Reaseguros

DROP PROCEDURE sp_rec735bk;
CREATE PROCEDURE "informix".sp_rec735bk(
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
RETURNING	smallint,char(25),integer,decimal(16,2),integer,decimal(16,2),integer,decimal(16,2),integer,decimal(16,2),integer,decimal(16,2),integer,decimal(16,2);

DEFINE _tipo              CHAR(1);

DEFINE v_doc_reclamo      CHAR(18);     
DEFINE _no_unidad         CHAR(5);
DEFINE _uso_auto		  CHAR(1);    
DEFINE v_fecha_siniestro  DATE;         
DEFINE _transaccion       CHAR(10);     
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
DEFINE _porc_coas         dec;

DEFINE _perd_total        smallint;
DEFINE _monto_bruto,_monto_total,_monto_pagado       dec(16,2);
define _cod_cobertura     char(5);
define _cobertura         char(2);
define _cod_tipopago      char(3);
define _tipo_pago         char(1);
define _tipo_linea        char(1);
define v_filtros          char(255);
define _fila 		smallint;
define _a_caso_p,_cnt  	integer;
define _a_monto_p 	dec(16,2);
define _a_caso_c 	integer;
define _a_monto_c	dec(16,2);
define _t_caso_p 	integer;
define _t_monto_p	dec(16,2);
define _t_caso_c 	integer;
define _t_monto_c	dec(16,2);
define _nombre_fila char(25);
define _so_caso_p 	integer;
define _so_monto_p	dec(16,2);
define _so_caso_c 	integer;
define _so_monto_c	dec(16,2);
define _tipo_cobertura char(2);

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania);

-- Cargar el Incurrido
--DROP TABLE tmp_sinis;

LET v_filtros = sp_rec704(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', '002,023,020;','*','*','*','*',a_subramo); 

-- Cargar el Incurrido
--DROP TABLE tmp_sinis;

-- Tabla Temporal para los Contratos
CREATE TEMP TABLE tmp_contrato1(
		tipo_pago		 	 CHAR(1),	--A = pago a asegurado - T = pago a tercero
		uso_auto           	 CHAR(1),   --P = Particular              - C = Comercial
		tipo_linea			 CHAR(1),   --1 = Siniestros Pagados -  2 = Perdida Total   -  3 = Resp. Civil
		cobertura            CHAR(2),	--CO = COLISION, RO = ROBO, I = INCENDIO, IN = INUNDACION, LE = LESIONES, MU = MUERTE, DA = DAÑOS
		casos                integer,
		monto                decimal(16,2),
		numrecla             CHAR(18),
		tipo_cobertura       CHAR(2)	--CO = COMPLETA, DT = DAÑOS A TERCEROS, SO = SEGURO OBLIGATORIO
--		PRIMARY KEY (cod_contrato, no_reclamo)
		) WITH NO LOG;

--CREATE INDEX xie01_tmp_contrato1 ON tmp_contrato1(cod_contrato);

--SET DEBUG FILE TO 'sp_rec735.trc';
--TRACE ON;

SET ISOLATION TO DIRTY READ;

update sinsuper
   set a_caso_p = 0,
	   a_monto_p = 0,
	   a_caso_c = 0,
	   a_monto_c = 0,
	   t_caso_p = 0,
	   t_monto_p = 0,
	   t_caso_c = 0,
	   t_monto_c = 0,
	   so_caso_p = 0,
	   so_monto_p = 0,
	   so_caso_c = 0,
	   so_monto_c = 0;	   
 
FOREACH 
 SELECT no_reclamo,		
 		no_poliza,	
		cod_ramo,		
		periodo,
		numrecla,
		cod_sucursal,
        cod_subramo
   INTO	_no_reclamo, 		
   		_no_poliza,	   	
		_cod_ramo, 
		_periodo,
		v_doc_reclamo,
		_cod_sucursal,
		_cod_subramo
   FROM tmp_sinis 
  WHERE seleccionado = 1
  GROUP BY no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal,cod_subramo
  ORDER BY cod_ramo,numrecla
  
 { if v_doc_reclamo in('20-0216-00006-03') then	--v_doc_reclamo in('02-0114-00102-06','02-0114-00258-10') then
  else
	continue foreach;
  end if}

	select no_unidad,
		   perd_total
	  into _no_unidad,
	       _perd_total
      from recrcmae
	 where no_reclamo = _no_reclamo;

    select uso_auto
	  into _uso_auto
	  from emiauto
	 where no_poliza = _no_poliza
       and no_unidad = _no_unidad;
	   
	if _uso_auto is null then
		foreach
		    select uso_auto
			  into _uso_auto
			  from endmoaut
			 where no_poliza = _no_poliza
               and no_unidad = _no_unidad
			exit foreach;
		end foreach
    end if
	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo

		exit foreach;
    end foreach
		   
	-- Informacion de Reaseguro para Sacar la Distribucion de
	-- los contratos
	let _cod_contrato = null;
	let _monto_pagado = 0;
   	foreach
		SELECT a.transaccion,
			   a.no_tranrec,
			   a.cod_tipopago
		  INTO _transaccion,
			   _no_tranrec,
			   _cod_tipopago
		  FROM rectrmae a,rectitra b
		 WHERE a.no_reclamo   = _no_reclamo
		   AND a.actualizado  = 1
		   AND a.cod_tipotran = b.cod_tipotran
		   AND b.tipo_transaccion IN (4,5,6,7)
		   AND a.periodo  >= a_periodo1 
		   AND a.periodo  <= a_periodo2
		   AND a.monto   <> 0
		   
		let _monto_bruto  = 0;   
	    foreach
			SELECT monto
			  INTO _monto_total
			  FROM rectrcob
			 WHERE no_tranrec = _no_tranrec
			   and monto <> 0

			SELECT porc_partic_coas
			  INTO _porc_coas
			  FROM reccoas
			 WHERE no_reclamo   = _no_reclamo
			   AND cod_coasegur = '036';

			IF _porc_coas IS NULL THEN
				LET _porc_coas = 0;
			END IF

			LET _monto_bruto = _monto_total  / 100 * _porc_coas;
			LET _monto_pagado = _monto_pagado + _monto_bruto;
		end foreach
	end foreach

		if _cod_tipopago = '003' then
			let _tipo_pago = 'A';
		else
			let _tipo_pago = 'T';
		end if
		let _tipo_linea = '0';
		if _cod_cobertura in('00102','01299','01021','00123','01309','01073','00113','00671','01304','01022') then --coberturas de responsabilidad
			let _tipo_linea = '3';
		elif _perd_total = 1 AND _cod_cobertura in('00119','00121','01307','00103','00901','01300','01311','01233','00120','00902','01146','01308','01312') then --perdida total
			let _tipo_linea = '2';
		{else
			let _tipo_linea = '4';	--Otros gastos}
		end if


	    if _cod_cobertura in('00119','00121','01307') then --Colision
			let _cobertura = 'CO';
		elif _cod_cobertura in('00103','00901','01300','01311') then --Robo
			let _cobertura = 'RO';
		elif _cod_cobertura in('00120','00902','01146','01308','01312') then --Incendio
			let _cobertura = 'I';
		elif _cod_cobertura in('01233') then --Inundacion
			let _cobertura = 'IN';
		elif _cod_cobertura in('00102','01299','01021') then --Lesiones
			let _cobertura = 'LE';
		elif _cod_cobertura in('00123','01309','01073') then --Muerte
			let _cobertura = 'MU';
		elif _cod_cobertura in('00113','00671','01304','01022') then --Daños
			let _cobertura = 'DA';
		else
			let _cobertura = 'OT';	--Otros
        end if
		
		if _cod_ramo = '020' then
			let _tipo_cobertura = 'SO';
		elif _cod_ramo in('002','023') then
			if _cobertura = 'CO' then
				let _tipo_cobertura = 'CO';
			end if
			select count(*)
			  into _cnt
			  from emipocob
			 where no_poliza = _no_poliza
               and no_unidad = _no_unidad
               and cod_cobertura  in('00119','00121','01307'); --coberturas de colision
			if _cnt is null then
				let _cnt = 0;
			end if
			if _cnt > 0 then
				let _tipo_cobertura = 'CO';
			else
				let _tipo_cobertura = 'DA';
			end if
			  
		end if
		INSERT INTO tmp_contrato1(
		tipo_pago,
		uso_auto,
		tipo_linea,
		cobertura, 
		casos,
		monto,
		numrecla,
		tipo_cobertura
		)
		VALUES(
		_tipo_pago,
		_uso_auto,
		_tipo_linea,           
		_cobertura,           
		0,            
		_monto_pagado,             
		v_doc_reclamo,
		_tipo_cobertura
		);
END FOREACH		 --tmp_sinis

foreach
	select tipo_pago,
		   uso_auto,
		   tipo_linea,
		   cobertura, 
		   monto,
		   tipo_cobertura
	  into _tipo_pago,
		   _uso_auto,
		   _tipo_linea,           
		   _cobertura,
		   _monto_pagado,
		   _tipo_cobertura
	  from tmp_contrato1
     order by 1,2,3
	 
	if _tipo_pago = 'A' then
		if _uso_auto = 'P' then
			if _tipo_linea = '2' then
				if _cobertura = 'CO' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 7;
			    elif _cobertura = 'RO' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 8;
			    elif _cobertura = 'IN' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 9;
			    elif _cobertura = 'I' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 10;
				end if
			elif _tipo_linea = '3' then
				if _cobertura = 'LE' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 12;
			    elif _cobertura = 'MU' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 13;
			    elif _cobertura = 'DA' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 14;
				end if
			else
				if _cobertura = 'CO' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 2;
			    elif _cobertura = 'RO' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 3;
			    elif _cobertura = 'IN' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 5;
			    elif _cobertura = 'I' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 4;
			    elif _cobertura = 'OT' then
					update sinsuper
					   set a_caso_p = a_caso_p + 1,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 15;
				end if
			end if
		elif _uso_auto = 'C' then
			if _tipo_linea = '2' then
				if _cobertura = 'CO' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 7;
			    elif _cobertura = 'RO' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 8;
			    elif _cobertura = 'IN' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 9;
			    elif _cobertura = 'I' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 10;
				end if
			elif _tipo_linea = '3' then
				if _cobertura = 'LE' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 12;
			    elif _cobertura = 'MU' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 13;
			    elif _cobertura = 'DA' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 14;
				end if
			else
				if _cobertura = 'CO' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 2;
			    elif _cobertura = 'RO' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 3;
			    elif _cobertura = 'IN' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 5;
			    elif _cobertura = 'I' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 4;
			    elif _cobertura = 'OT' then
					update sinsuper
					   set a_caso_c = a_caso_c + 1,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 15;
				end if
			end if
		end if
	elif _tipo_pago = 'T' then
		if _tipo_cobertura = 'DA' then
			if _uso_auto = 'P' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 7;
					elif _cobertura = 'RO' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 8;
					elif _cobertura = 'IN' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'I' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 10;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 12;
					elif _cobertura = 'MU' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 13;
					elif _cobertura = 'DA' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 14;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set t_caso_p = t_caso_p + 1,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 15;
					end if
				end if
			elif _uso_auto = 'C' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 7;
					elif _cobertura = 'RO' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 8;
					elif _cobertura = 'IN' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'I' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 10;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 12;
					elif _cobertura = 'MU' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 13;
					elif _cobertura = 'DA' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 14;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set t_caso_c = t_caso_c + 1,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 15;
					end if
				end if
			end if
		elif _tipo_cobertura = 'SO' then
			if _uso_auto = 'P' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 7;
					elif _cobertura = 'RO' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 8;
					elif _cobertura = 'IN' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'I' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 10;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 12;
					elif _cobertura = 'MU' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 13;
					elif _cobertura = 'DA' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 14;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set so_caso_p = so_caso_p + 1,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 15;
					end if
				end if
			elif _uso_auto = 'C' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 7;
					elif _cobertura = 'RO' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 8;
					elif _cobertura = 'IN' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'I' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 10;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 12;
					elif _cobertura = 'MU' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 13;
					elif _cobertura = 'DA' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 14;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set so_caso_c = so_caso_c + 1,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 15;
					end if
				end if
			end if
		elif _tipo_cobertura = 'CO' then
			if _uso_auto = 'P' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 7;
					elif _cobertura = 'RO' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 8;
					elif _cobertura = 'IN' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'I' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 10;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 12;
					elif _cobertura = 'MU' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 13;
					elif _cobertura = 'DA' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 14;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set a_caso_p = a_caso_p + 1,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 15;
					end if
				end if
			elif _uso_auto = 'C' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 7;
					elif _cobertura = 'RO' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 8;
					elif _cobertura = 'IN' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'I' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 10;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 12;
					elif _cobertura = 'MU' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 13;
					elif _cobertura = 'DA' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 14;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set a_caso_c = a_caso_c + 1,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 15;
					end if
				end if
			end if
		end if
	end if
end foreach

select sum(a_caso_p),sum(a_monto_p),sum(a_caso_c),sum(a_monto_c),sum(t_caso_p),sum(t_monto_p),sum(t_caso_c),sum(t_monto_c),sum(so_caso_p),sum(so_monto_p),sum(so_caso_c),sum(so_monto_c)
  into _a_caso_p,_a_monto_p,_a_caso_c,_a_monto_c,_t_caso_p,_t_monto_p,_t_caso_c,_t_monto_c,_so_caso_p,_so_monto_p,_so_caso_c,_so_monto_c
  from sinsuper;
  
 update sinsuper
    set a_caso_p  = _a_caso_p,
		a_monto_p = _a_monto_p,
		a_caso_c  = _a_caso_c,
		a_monto_c = _a_monto_c,
		t_caso_p  = _t_caso_p,
		t_monto_p = _t_monto_p,
		t_caso_c  = _t_caso_c,
		t_monto_c = _t_monto_c,
		so_caso_p  = _so_caso_p,
		so_monto_p = _so_monto_p,
		so_caso_c  = _so_caso_c,
		so_monto_c = _so_monto_c
	where fila = 1;

select sum(a_caso_p),sum(a_monto_p),sum(a_caso_c),sum(a_monto_c),sum(t_caso_p),sum(t_monto_p),sum(t_caso_c),sum(t_monto_c),sum(so_caso_p),sum(so_monto_p),sum(so_caso_c),sum(so_monto_c)
  into _a_caso_p,_a_monto_p,_a_caso_c,_a_monto_c,_t_caso_p,_t_monto_p,_t_caso_c,_t_monto_c,_so_caso_p,_so_monto_p,_so_caso_c,_so_monto_c
  from sinsuper
 where fila >= 7 and fila <= 10;
 
update sinsuper
    set a_caso_p  = _a_caso_p,
		a_monto_p = _a_monto_p,
		a_caso_c  = _a_caso_c,
		a_monto_c = _a_monto_c,
		t_caso_p  = _t_caso_p,
		t_monto_p = _t_monto_p,
		t_caso_c  = _t_caso_c,
		t_monto_c = _t_monto_c,
		so_caso_p  = _so_caso_p,
		so_monto_p = _so_monto_p,
		so_caso_c  = _so_caso_c,
		so_monto_c = _so_monto_c
	where fila = 6; 
 
select sum(a_caso_p),sum(a_monto_p),sum(a_caso_c),sum(a_monto_c),sum(t_caso_p),sum(t_monto_p),sum(t_caso_c),sum(t_monto_c),sum(so_caso_p),sum(so_monto_p),sum(so_caso_c),sum(so_monto_c)
  into _a_caso_p,_a_monto_p,_a_caso_c,_a_monto_c,_t_caso_p,_t_monto_p,_t_caso_c,_t_monto_c,_so_caso_p,_so_monto_p,_so_caso_c,_so_monto_c
  from sinsuper
 where fila >= 12 and fila <= 14;
 
update sinsuper
    set a_caso_p  = _a_caso_p,
		a_monto_p = _a_monto_p,
		a_caso_c  = _a_caso_c,
		a_monto_c = _a_monto_c,
		t_caso_p  = _t_caso_p,
		t_monto_p = _t_monto_p,
		t_caso_c  = _t_caso_c,
		t_monto_c = _t_monto_c,
		so_caso_p  = _so_caso_p,
		so_monto_p = _so_monto_p,
		so_caso_c  = _so_caso_c,
		so_monto_c = _so_monto_c
	where fila = 11;

foreach
	select fila,
	       a_caso_p,
		   a_monto_p,
		   a_caso_c,
		   a_monto_c,
		   t_caso_p,
		   t_monto_p,
		   t_caso_c,
		   t_monto_c,
		   so_caso_p,
		   so_monto_p,
		   so_caso_c,
		   so_monto_c
	  into _fila,
	       _a_caso_p,
		   _a_monto_p,
		   _a_caso_c,
		   _a_monto_c,
		   _t_caso_p,
		   _t_monto_p,
		   _t_caso_c,
		   _t_monto_c,
		   _so_caso_p,
		   _so_monto_p,
		   _so_caso_c,
		   _so_monto_c
	  from sinsuper
	 order by fila
	 
	if _fila = 1 then
		let _nombre_fila = 'SINIESTROS PAGADOS';
	elif _fila = 2 then
		let _nombre_fila = 'Colision o Vuelco';
	elif _fila = 3 then
		let _nombre_fila = 'Robo';
	elif _fila = 4 then
		let _nombre_fila = 'Incendio';
	elif _fila = 5 then
		let _nombre_fila = 'Inundacion';
	elif _fila = 6 then
		let _nombre_fila = 'PERDIDA TOTAL';
	elif _fila = 7 then
		let _nombre_fila = 'Colision o Vuelco';
	elif _fila = 8 then
		let _nombre_fila = 'Robo';
	elif _fila = 9 then
		let _nombre_fila = 'Inundacion';
	elif _fila = 10 then
		let _nombre_fila = 'Incendio';
	elif _fila = 11 then
		let _nombre_fila = 'RESPONSABILDAD CIVIL';
	elif _fila = 12 then
		let _nombre_fila = 'Lesiones Corporales';
	elif _fila = 13 then
		let _nombre_fila = 'Muerte';
	elif _fila = 14 then
		let _nombre_fila = 'Daños a la propiedad';
	elif _fila = 15 then
		let _nombre_fila = 'OTROS GASTOS';
	end if	
	return _fila,_nombre_fila,_a_caso_p,_a_monto_p,_a_caso_c,_a_monto_c,_t_caso_p,_t_monto_p,_t_caso_c,_t_monto_c,_so_caso_p,_so_monto_p,_so_caso_c,_so_monto_c with resume;
end foreach	

DROP TABLE tmp_sinis;
DROP TABLE tmp_contrato1;
END PROCEDURE;