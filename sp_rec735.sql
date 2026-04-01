-- Reporte de Siniestros Pagados
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec705_dw1 - DEIVID, S.A.
-- Modificado: 04/10/2013 - Autor: Amado Perez -- Cambios en los Reaseguros

DROP PROCEDURE sp_rec735;
CREATE PROCEDURE "informix".sp_rec735(
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
define _casos_cerrados integer;
define _cnt_cobertura       SMALLINT;
define v_no_orden    char(5);
define v_desc_orden	   	varchar(50);
define v_deducible	   	varchar(50);
define _fecha_siniestro  date;
define _no_endoso    char(5);
define _opcion       smallint;
define _cod_tipoveh  char(3);

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania);
let _cod_tipopago = null;

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
		tipo_cobertura       CHAR(2),	--CO = COMPLETA, DT = DAÑOS A TERCEROS, SO = SEGURO OBLIGATORIO
		casos_cerrados       INTEGER DEFAULT 0,
		cod_tipoveh          CHAR(3)
--		PRIMARY KEY (cod_contrato, no_reclamo)
		) WITH NO LOG;

create temp table tmp_coberturas1(
                 cod_cobertura  CHAR(5),
				 descripcion    varchar(50),
				 deducible      varchar(50), primary key (cod_cobertura)) WITH NO LOG;
		
create temp table tmp_coberturas2(
                 cod_cobertura  CHAR(5),
				 descripcion    varchar(50),
				 deducible      varchar(50), primary key (cod_cobertura)) WITH NO LOG;
		
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
--    and numrecla = '02-1222-01599-10'
  GROUP BY no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal,cod_subramo
  ORDER BY cod_ramo,numrecla
  
 --SET DEBUG FILE TO 'sp_rec735.trc';
 --TRACE ON;
 
  
  	  IF _cod_ramo = '023' THEN 
		LET _cod_ramo = '002';
	  END IF

 delete from tmp_coberturas1; 
 { if v_doc_reclamo in('20-0216-00006-03') then	--v_doc_reclamo in('02-0114-00102-06','02-0114-00258-10') then
  else
	continue foreach;
  end if}

	select no_poliza,
	       no_unidad,
		   perd_total,
		   fecha_siniestro
	  into _no_poliza,
	       _no_unidad,
	       _perd_total,
		   _fecha_siniestro
      from recrcmae
	 where no_reclamo = _no_reclamo;

			FOREACH
				SELECT no_endoso 
				  INTO _no_endoso
				  FROM endedmae 
				 WHERE no_poliza = _no_poliza
				   AND vigencia_inic <= _fecha_siniestro
				   AND fecha_emision <= _fecha_siniestro
				ORDER BY no_endoso
				   
				   FOREACH
					SELECT cod_cobertura, deducible, opcion
					  INTO v_no_orden, v_deducible, _opcion
					  FROM endedcob
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso
					   AND no_unidad = _no_unidad
					ORDER BY orden
					   
					SELECT nombre
					  INTO v_desc_orden
					  FROM prdcober
					 WHERE cod_cobertura = v_no_orden; 
					 
					 if _opcion in (0,1) then
						 begin
						 on exception in (-239, -268)
						 end exception			 
						 insert into tmp_coberturas1
						  values (v_no_orden, v_desc_orden, v_deducible);
						 end
					 elif _opcion = 3 then
						 delete from tmp_coberturas1 where cod_cobertura = v_no_orden;
					 end if			 
				   END FOREACH
				   
			END FOREACH
	 
	 
    select uso_auto,
	       cod_tipoveh
	  into _uso_auto,
	       _cod_tipoveh
	  from emiauto
	 where no_poliza = _no_poliza
       and no_unidad = _no_unidad;
	   
	if _uso_auto is null then
		foreach
		    select uso_auto,
			       cod_tipoveh
			  into _uso_auto,
			       _cod_tipoveh
			  from endmoaut
			 where no_poliza = _no_poliza
               and no_unidad = _no_unidad
			exit foreach;
		end foreach
    end if
	
	if _uso_auto is null then
	   return 0,v_doc_reclamo,0,0,0,0,0,0,0,0,0,0,0,1;
		LET _uso_auto = 'P';
    end if	
{	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo
   --        and pagos > 0

		exit foreach;
    end foreach}
		   
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
		   AND b.tipo_transaccion IN (4,7)  -- 541
		   AND a.periodo  >= a_periodo1 
		   AND a.periodo  <= a_periodo2
		   AND a.monto   <> 0
		 --  and a.no_tranrec = '2312931'
	
	
		let _monto_bruto  = 0;   
	    foreach
			SELECT monto, cod_cobertura
			  INTO _monto_total, _cod_cobertura
			  FROM rectrcob
			 WHERE no_tranrec = _no_tranrec
			   and monto <> 0
			   
			IF _cod_cobertura = '00887' THEN -- Cobertura ESTADO
				let _cod_cobertura = '00119';
			END IF

			SELECT porc_partic_coas
			  INTO _porc_coas
			  FROM reccoas
			 WHERE no_reclamo   = _no_reclamo
			   AND cod_coasegur = '036';

			IF _porc_coas IS NULL THEN
				LET _porc_coas = 0;
			END IF

		--	LET _monto_bruto = _monto_total  / 100 * _porc_coas;
		--	LET _monto_pagado = _monto_pagado + _monto_bruto;
			LET _monto_pagado = round(_monto_total  / 100 * _porc_coas, 2);
			
			
			
		  select count(*)
		    into _cnt_cobertura   -- Colision y Vuelco
		    from tmp_coberturas1
		   where cod_cobertura in ('00119','00121','01307','01325', '01657', '00901');			 
			 
{		  select count(*)
		    into _cnt_cobertura   -- Colision y Vuelco
		    from endedcob
		   where no_poliza =	_no_poliza
		     and no_unidad =    _no_unidad
			 and cod_cobertura in ('00119','00121','01307','01325');	
}			 
			if _cnt_cobertura > 0 then
			     let _tipo_pago = 'A';   -- Completa
            else 
			     let _tipo_pago = 'T';   -- R.C.
			end if
			
		{	if _cod_tipopago = '003' then
				let _tipo_pago = 'A';
			elif _cod_tipopago = '004' then
				let _tipo_pago = 'T';
			else
				let _tipo_pago = 'A';
			end if
		}	
			let _tipo_linea = '0';
			if _cod_cobertura in('00102','01299','01021','00123','01309','01073','00113','00671','01304','01022','01306','00606','00118','00104','00122','01155','01154','01481','01536','00903','00904','00107','01535','00117','01301','00907','01028','01310','01323','01302','01650','01651','00106','01338','00108','01074','01303','01115','01305','00109','01322') then --coberturas de responsabilidad --,'01650','01651','01657'
				let _tipo_linea = '3';
			elif _perd_total = 1 AND _cod_cobertura in('00119','00121','01307','00103','00901','01300','01311','01233','00120','00902','01146','01308','01312','01145','01315','01677', '01657', '01841') then --perdida total
				let _tipo_linea = '2';
			{else
				let _tipo_linea = '4';	--Otros gastos}
			end if


			if _cod_cobertura in('00119','00121','01307','01145','01315','01677', '01657', '01841') then --Colision
				let _cobertura = 'CO';
			elif _cod_cobertura in('00103','00901','01300','01311') then --Robo
				if _tipo_pago = "A" THEN
					let _cobertura = 'RO';
				else
					let _cobertura = 'CM';
				end if
			elif _cod_cobertura in('00120','00902','01146','01308','01312') then --Incendio
				let _cobertura = 'I';
			elif _cod_cobertura in('01233') then --Inundacion
				let _cobertura = 'IN';
			elif _cod_cobertura in('00102','01299','01021','01028','01650','00106','00108','01074','01303') then --Lesiones --,'01650'
				let _cobertura = 'LE';
			elif _cod_cobertura in('00123','01309','01073','00109','01322') then --Muerte
				let _cobertura = 'MU';
			elif _cod_cobertura in('00113','00671','01304','01022','01651') then --Daños ,'01651'
				let _cobertura = 'DA';
			elif _cod_cobertura in('01306','00606','00118','00104','00122','01155','01154','01481','01536','00903','00904','00107','01535','00117','01301','00907','01115','01310','01323','01302','01338','01305') and _tipo_pago = "A" then --Comprensivo --,'00104','00904','00107'
				let _cobertura = 'CM';
			elif _cod_cobertura in('01306','00606','00118','00104','00122','01155','01154','01481','01536','00903','00904','00107','01535','00117','01301','00907','01115','01310','01323','01302','01338','01305') and _tipo_pago = "T" then --Comprensivo --,'00104','00904','00107'
				let _cobertura = 'LE';
			elif _cod_cobertura = '01075' then
				let _cobertura = 'GM';
			else
				let _cobertura = 'OT';	--Otros
				return 0,v_doc_reclamo,0,0,0,0,0,0,0,0,0,0,0,2;
			end if
			
			if _cod_ramo = '020' then
				let _tipo_cobertura = 'SO';
			elif _cod_ramo in('002','023') then
				if _cobertura = 'CO' then
					let _tipo_cobertura = 'CO';
				end if
{				select count(*)
				  into _cnt
				  from emipocob
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and cod_cobertura  in('00119','00121','01307'); --coberturas de colision}
				select count(*)
				  into _cnt
				  from endedcob
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and cod_cobertura  in('00119','00121','01307','01145','01315', '01657'); --coberturas de colision
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
			tipo_cobertura,
			cod_tipoveh
			)
			VALUES(
			_tipo_pago,
			_uso_auto,
			_tipo_linea,           
			_cobertura,           
			0,            
			_monto_pagado,             
			v_doc_reclamo,
			_tipo_cobertura,
			_cod_tipoveh
			);
			
		end foreach
	end foreach
	

END FOREACH		 --tmp_sinis

let _cod_tipopago = null;
--trace off;
FOREACH -- Casos cerrados automovil
	select no_reclamo
	  into _no_reclamo
      from rectrmae
     where actualizado  = 1
	   and periodo      >= a_periodo1
	   and periodo      <= a_periodo2
	   and (cod_tipotran = '011'
	   or cerrar_rec = 1)
	   and numrecla[1,2] in ('02','20','23')
	 group by no_reclamo
	 order by no_reclamo

   select no_poliza,
          no_unidad
	  into _no_poliza,
	       _no_unidad
	  from recrcmae
	 where no_reclamo = _no_reclamo;

{	select r.no_reclamo,
           t.periodo	
	  into _no_reclamo,
	       _periodo
	  from emipomae e, recrcmae r, rectrmae t
	 where e.no_poliza = r.no_poliza
	   and r.no_reclamo = t.no_reclamo
	   and t.actualizado = 1
	   and t.periodo >= a_periodo1
	   and t.periodo <= a_periodo2
	   and (t.cod_tipotran = '011' 
	   or t.cerrar_rec = 1)	   
	   and e.cod_ramo in ('002','020','023')
	   and (t.variacion <> 0
		or (trim(t.user_added) <> 'informix'
	   and t.variacion = 0))
	 group by r.no_reclamo, t.periodo}

	delete from tmp_coberturas2;
	 
	FOREACH
		select cod_tipopago,
		       no_tranrec
		  into _cod_tipopago,
		       _no_tranrec
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and actualizado = 1
		   and periodo >= a_periodo1
		   and periodo <= a_periodo2
		   and (cod_tipotran = '011' 
	        or cerrar_rec = 1)		 
		 exit foreach;
	END FOREACH
	
	   
	select no_poliza,
	       no_unidad,
		   perd_total,
		   numrecla,
		   fecha_siniestro
	  into _no_poliza,
	       _no_unidad,
	       _perd_total,
		   v_doc_reclamo,
		   _fecha_siniestro
      from recrcmae
	 where no_reclamo = _no_reclamo;

			FOREACH
				SELECT no_endoso 
				  INTO _no_endoso
				  FROM endedmae 
				 WHERE no_poliza = _no_poliza
				   AND vigencia_inic <= _fecha_siniestro
				   AND fecha_emision <= _fecha_siniestro
				ORDER BY no_endoso
				   
				   FOREACH
					SELECT cod_cobertura, deducible, opcion
					  INTO v_no_orden, v_deducible, _opcion
					  FROM endedcob
					 WHERE no_poliza = _no_poliza
					   AND no_endoso = _no_endoso
					   AND no_unidad = _no_unidad
					ORDER BY orden

					IF v_no_orden = '00887' THEN -- Cobertura ESTADO
						let v_no_orden = '00119';
					END IF
					   
					SELECT nombre
					  INTO v_desc_orden
					  FROM prdcober
					 WHERE cod_cobertura = v_no_orden; 
					 
					 if _opcion in (0,1) then
						 begin
						 on exception in (-239, -268)
						 end exception			 
						 insert into tmp_coberturas2
						  values (v_no_orden, v_desc_orden, v_deducible);
						 end
					 elif _opcion = 3 then
						 delete from tmp_coberturas2 where cod_cobertura = v_no_orden;
					 end if			 
				   END FOREACH
				   
			END FOREACH
	 
 {   select uso_auto,
	       cod_tipoveh
	  into _uso_auto,
	       _cod_tipoveh
	  from emiauto
	 where no_poliza = _no_poliza
       and no_unidad = _no_unidad;
	   
	if _uso_auto is null then
		foreach
		    select uso_auto,
			       cod_tipoveh
			  into _uso_auto,
			       _cod_tipoveh
			  from endmoaut
			 where no_poliza = _no_poliza
               and no_unidad = _no_unidad
			exit foreach;
		end foreach
    end if
}
 		SELECT uso_auto,
		       cod_tipoveh
		  INTO _uso_auto,
			   _cod_tipoveh
		  FROM emiauto
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad;         
		 
		IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN  -- Pólizas sin info en Emiauto 
			FOREACH
				  SELECT uso_auto,
				         cod_tipoveh
					INTO _uso_auto,
						 _cod_tipoveh
					FROM endmoaut 
				   WHERE no_poliza = _no_poliza
					 AND no_unidad = _no_unidad         
				exit FOREACH;
			end FOREACH			 
		END IF
		
		IF _uso_auto IS NULL OR TRIM(_uso_auto) = "" THEN
		   LET _uso_auto = 'P';
		END IF 				
		
	
	--if _uso_auto is null then
	--	LET _uso_auto = 'P';
	--end if

	select count(*)
	  into _cnt_cobertura
	  from rectrcob
	 where no_tranrec = _no_tranrec
	   and monto <> 0;
	
	 if _cnt_cobertura > 0 then	
		foreach
			select cod_cobertura
			  into _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and cod_cobertura in ('00102','01299','01021','00123','01309','01073','00113','00671','01304','01022','01306','00606','00118','00119','00121','01307','00103','00901','01300','01311','01233','00120','00902','01146','01308','01312','00907','01028','01310','01323','01302','01650','01651','00106','01075','01145','01315','01677','00108','01074','01303','01657','00887','00109', '01841','01322') --,'01650','01651','01657'
	           and monto <> 0
			exit foreach;
		end foreach
	 else
		foreach
			select cod_cobertura
			  into _cod_cobertura
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and cod_cobertura in ('00102','01299','01021','00123','01309','01073','00113','00671','01304','01022','01306','00606','00118','00119','00121','01307','00103','00901','01300','01311','01233','00120','00902','01146','01308','01312','00907','01028','01310','01323','01302','01650','01651','00106','01075','01145','01315','01677','00108','01074','01303','01657','00887','00109', '01841','01322') --,'01650','01651','01657'
			exit foreach;
		end foreach
	 end if

	IF _cod_cobertura = '00887' THEN -- Cobertura ESTADO
		let _cod_cobertura = '00119';
	END IF
	
{	select count(*)
	  into _cnt_cobertura
	  from recrccob
	 where no_reclamo = _no_reclamo
	   and cod_cobertura in ('00102','01299','01021','00123','01309','01073','00113','00671','01304','01022','01306','00606','00118','00119','00121','01307','00103','00901','01300','01311','01233','00120','00902','01146','01308','01312'); --,'01650','01651','01657'
	
    if _cnt_cobertura > 0 then	
		foreach
			select cod_cobertura
			  into _cod_cobertura
			  from recrccob
			 where no_reclamo = _no_reclamo
			   and cod_cobertura in ('00102','01299','01021','00123','01309','01073','00113','00671','01304','01022','01306','00606','00118','00119','00121','01307','00103','00901','01300','01311','01233','00120','00902','01146','01308','01312') --,'01650','01651','01657'
	  --         and pagos > 0
			exit foreach;
		end foreach
	else
		foreach
			select cod_cobertura
			  into _cod_cobertura
			  from recrccob
			 where no_reclamo = _no_reclamo
			exit foreach;
		end foreach
	end if
}	
	let _cnt_cobertura = 0;

{		  select count(*)
		    into _cnt_cobertura   -- Colision y Vuelco
		    from emipocob
		   where no_poliza =	_no_poliza
			 and cod_cobertura in ('00119','00121','01307');			 
}			 
{		  select count(*)
		    into _cnt_cobertura   -- Colision y Vuelco
		    from endedcob
		   where no_poliza =	_no_poliza
		     and no_unidad =    _no_unidad
			 and cod_cobertura in ('00119','00121','01307');	
}			 
		  select count(*)
		    into _cnt_cobertura   -- Colision y Vuelco
		    from tmp_coberturas2
		   where cod_cobertura in ('00119','00121','01307','01145','01315','00901');	

			 if _cnt_cobertura > 0 then
			     let _tipo_pago = 'A';   -- Completa
            else 
			     let _tipo_pago = 'T';   -- R.C.
			end if
			
			select cod_ramo
			  into _cod_ramo
			  from emipomae
			 where no_poliza = _no_poliza;
	
{		if _cod_tipopago = '003' then
			let _tipo_pago = 'A';
		elif _cod_tipopago = '004' then
			let _tipo_pago = 'T';
		else
			let _tipo_pago = 'A';
		end if
}		
	let _tipo_linea = '0';
	if _cod_cobertura in('00102','01299','01021','00123','01309','01073','00113','00671','01304','01022','01306','00606','00118','00104','00122','01155','01154','01481','01536','00903','00904','00107','01535','00117','01301','00907','01028','01310','01323','01302','01650','01651','00106','01338','00108','01074','01303','01305','00109','01322') then --coberturas de responsabilidad --,'01650','01651','01657'
		let _tipo_linea = '3';
	elif _perd_total = 1 AND _cod_cobertura in('00119','00121','01307','00103','00901','01300','01311','01233','00120','00902','01146','01308','01312','01145','01315','01677','01657', '01841') then --perdida total
		let _tipo_linea = '2';
	{else
		let _tipo_linea = '4';	--Otros gastos}
	end if


	if _cod_cobertura in('00119','00121','01307','01145','01315','01677', '01657', '01841') then --Colision
		let _cobertura = 'CO';
	elif _cod_cobertura in('00103','00901','01300','01311') and _tipo_pago = "A" then --Robo
		let _cobertura = 'RO';
	elif _cod_cobertura in('00103','00901','01300','01311') and _tipo_pago = "T" then --Robo
		let _cobertura = 'CO';
		--return 0,v_doc_reclamo,0,0,0,0,0,0,0,0,0,0,0,0;
	elif _cod_cobertura in('00120','00902','01146','01308','01312') then --Incendio
		let _cobertura = 'I';
	elif _cod_cobertura in('01233') then --Inundacion
		let _cobertura = 'IN';
	elif _cod_cobertura in('00102','01299','01021','01028','00106','01650','00108','01074','01303') then --Lesiones ,'01650'
		let _cobertura = 'LE';
	elif _cod_cobertura in('00123','01309','01073','00109','01322') then --Muerte
		let _cobertura = 'MU';
	elif _cod_cobertura in('00113','00671','01304','01022','01651') then --Daños ,'01651'
		let _cobertura = 'DA';
	elif _cod_cobertura in('01306','00606','00118','00104','00122','01481','01536','00903','00107','01155','01154','01481','01536','00903','00904','00107','01535','00117','01301','00907','01115','01310','01323','01302','01338','01305') and _tipo_pago = "A" then --Comprensivo
		let _cobertura = 'CM';
	elif _cod_cobertura in('01306','00606','00118','00104','00122','01481','01536','00107','01155','01154','01481','01536','00903','00904','00107','01535','00117','01301','00907','01115','01310','01323','01302','01338','01305') and _tipo_pago = "T" then --Comprensivo
		let _cobertura = 'LE';
	elif _cod_cobertura = '01075' then
		let _cobertura = 'GM';
	else
		let _cobertura = 'OT';	--Otros
		--return 0,v_doc_reclamo,0,0,0,0,0,0,0,0,0,0,0,0;
	end if
	
	if _cod_ramo = '020' then
		let _tipo_cobertura = 'SO';
	elif _cod_ramo in('002','023') then
		if _cobertura = 'CO' then
			let _tipo_cobertura = 'CO';
		end if
{		select count(*)
		  into _cnt
		  from emipocob
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura  in('00119','00121','01307'); --coberturas de colision}
		select count(*)
		  into _cnt
		  from endedcob
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and cod_cobertura  in('00119','00121','01307','01145','01315', '01657'); --coberturas de colision
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
	tipo_cobertura,
	casos_cerrados,
	cod_tipoveh
	)
	VALUES(
	_tipo_pago,
	_uso_auto,
	_tipo_linea,           
	_cobertura,           
	0,            
	0,             
	v_doc_reclamo,
	_tipo_cobertura,
	1,
	_cod_tipoveh);
	 
END FOREACH

foreach
	select tipo_pago,
		   uso_auto,
		   tipo_linea,
		   cobertura, 
		   monto,
		   tipo_cobertura,
		   casos_cerrados
	  into _tipo_pago,
		   _uso_auto,
		   _tipo_linea,           
		   _cobertura,
		   _monto_pagado,
		   _tipo_cobertura,
		   _casos_cerrados
	  from tmp_contrato1
     order by 1,2,3
	 
	if _tipo_pago = 'A' then
		if _uso_auto = 'P' then
			if _tipo_linea = '2' then
				if _cobertura = 'CO' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 9;
			    elif _cobertura = 'RO' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 10;
			    elif _cobertura = 'IN' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 11;
			    elif _cobertura = 'I' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 12;
				end if
			elif _tipo_linea = '3' then
				if _cobertura = 'LE' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 14;
			    elif _cobertura = 'MU' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 15;
			    elif _cobertura = 'DA' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 16;
			    elif _cobertura = 'CM' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 6;
				end if
			else
				if _cobertura = 'CO' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 2;
			    elif _cobertura = 'RO' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 3;
			    elif _cobertura = 'IN' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 5;
			    elif _cobertura = 'I' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 4;
			    elif _cobertura = 'OT' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 17;
			    elif _cobertura = 'GM' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 7;
				end if
			end if
		elif _uso_auto = 'C' then
			if _tipo_linea = '2' then
				if _cobertura = 'CO' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 9;
			    elif _cobertura = 'RO' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 10;
			    elif _cobertura = 'IN' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 11;
			    elif _cobertura = 'I' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 12;
				end if
			elif _tipo_linea = '3' then
				if _cobertura = 'LE' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 14;
			    elif _cobertura = 'MU' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 15;
			    elif _cobertura = 'DA' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 16;
			    elif _cobertura = 'CM' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 6;
				end if
			else
				if _cobertura = 'CO' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 2;
			    elif _cobertura = 'RO' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 3;
			    elif _cobertura = 'IN' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 5;
			    elif _cobertura = 'I' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 4;
			    elif _cobertura = 'OT' then
					update sinsuper
					   set a_caso_c = a_caso_c + _casos_cerrados,
					       a_monto_c = a_monto_c + _monto_pagado
					 where fila = 16;
			    elif _cobertura = 'GM' then
					update sinsuper
					   set a_caso_p = a_caso_p + _casos_cerrados,
					       a_monto_p = a_monto_p + _monto_pagado
					 where fila = 7;
				end if
			end if
		end if
	elif _tipo_pago = 'T' then
		if _tipo_cobertura = 'DA' then
			if _uso_auto = 'P' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'RO' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 10;
					elif _cobertura = 'IN' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 11;
					elif _cobertura = 'I' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 12;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 14;
					elif _cobertura = 'MU' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 15;
					elif _cobertura = 'DA' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 16;
					elif _cobertura = 'CM' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 6;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set t_caso_p = t_caso_p + _casos_cerrados,
							   t_monto_p = t_monto_p + _monto_pagado
						 where fila = 17;
					elif _cobertura = 'GM' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 7;
					end if
				end if
			elif _uso_auto = 'C' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'RO' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 10;
					elif _cobertura = 'IN' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 11;
					elif _cobertura = 'I' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 12;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 14;
					elif _cobertura = 'MU' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 15;
					elif _cobertura = 'DA' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 16;
					elif _cobertura = 'CM' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 6;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set t_caso_c = t_caso_c + _casos_cerrados,
							   t_monto_c = t_monto_c + _monto_pagado
						 where fila = 17;
					elif _cobertura = 'GM' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 7;
					end if
				end if
			end if
		elif _tipo_cobertura = 'SO' then
			if _uso_auto = 'P' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'RO' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 10;
					elif _cobertura = 'IN' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 11;
					elif _cobertura = 'I' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 12;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 14;
					elif _cobertura = 'MU' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 15;
					elif _cobertura = 'DA' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 16;
					elif _cobertura = 'CM' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 6;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set so_caso_p = so_caso_p + _casos_cerrados,
							   so_monto_p = so_monto_p + _monto_pagado
						 where fila = 17;
					elif _cobertura = 'GM' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 7;
					end if
				end if
			elif _uso_auto = 'C' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'RO' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 10;
					elif _cobertura = 'IN' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 11;
					elif _cobertura = 'I' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 12;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 14;
					elif _cobertura = 'MU' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 15;
					elif _cobertura = 'DA' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 16;
					elif _cobertura = 'CM' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 6;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set so_caso_c = so_caso_c + _casos_cerrados,
							   so_monto_c = so_monto_c + _monto_pagado
						 where fila = 17;
					elif _cobertura = 'GM' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 7;
					end if
				end if
			end if
		elif _tipo_cobertura = 'CO' then
			if _uso_auto = 'P' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'RO' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 10;
					elif _cobertura = 'IN' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 11;
					elif _cobertura = 'I' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 12;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 14;
					elif _cobertura = 'MU' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 15;
					elif _cobertura = 'DA' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 16;
					elif _cobertura = 'CM' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 6;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 16;
					elif _cobertura = 'GM' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 7;
					end if
				end if
			elif _uso_auto = 'C' then
				if _tipo_linea = '2' then
					if _cobertura = 'CO' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 9;
					elif _cobertura = 'RO' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 10;
					elif _cobertura = 'IN' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 11;
					elif _cobertura = 'I' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 12;
					end if
				elif _tipo_linea = '3' then
					if _cobertura = 'LE' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 14;
					elif _cobertura = 'MU' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 15;
					elif _cobertura = 'DA' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 16;
					elif _cobertura = 'CM' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 6;
					end if
				else
					if _cobertura = 'CO' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 2;
					elif _cobertura = 'RO' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 3;
					elif _cobertura = 'IN' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 5;
					elif _cobertura = 'I' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 4;
					elif _cobertura = 'OT' then
						update sinsuper
						   set a_caso_c = a_caso_c + _casos_cerrados,
							   a_monto_c = a_monto_c + _monto_pagado
						 where fila = 17;
					elif _cobertura = 'GM' then
						update sinsuper
						   set a_caso_p = a_caso_p + _casos_cerrados,
							   a_monto_p = a_monto_p + _monto_pagado
						 where fila = 7;
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
 where fila >= 9 and fila <= 12;
 
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
	where fila = 8; 
 
select sum(a_caso_p),sum(a_monto_p),sum(a_caso_c),sum(a_monto_c),sum(t_caso_p),sum(t_monto_p),sum(t_caso_c),sum(t_monto_c),sum(so_caso_p),sum(so_monto_p),sum(so_caso_c),sum(so_monto_c)
  into _a_caso_p,_a_monto_p,_a_caso_c,_a_monto_c,_t_caso_p,_t_monto_p,_t_caso_c,_t_monto_c,_so_caso_p,_so_monto_p,_so_caso_c,_so_monto_c
  from sinsuper
 where fila >= 14 and fila <= 16;
 
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
	where fila = 13;

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
		let _nombre_fila = 'Comprensivo';
	elif _fila = 7 then
		let _nombre_fila = 'GASTOS MEDICOS';
	elif _fila = 8 then
		let _nombre_fila = 'PERDIDA TOTAL';
	elif _fila = 9 then
		let _nombre_fila = 'Colision o Vuelco';
	elif _fila = 10 then
		let _nombre_fila = 'Robo';
	elif _fila = 11 then
		let _nombre_fila = 'Inundacion';
	elif _fila = 12 then
		let _nombre_fila = 'Incendio';
	elif _fila = 13 then
		let _nombre_fila = 'RESPONSABILDAD CIVIL';
	elif _fila = 14 then
		let _nombre_fila = 'Lesiones Corporales';
	elif _fila = 15 then
		let _nombre_fila = 'Muerte';
	elif _fila = 16 then
		let _nombre_fila = 'Daños a la propiedad';
	elif _fila = 17 then
		let _nombre_fila = 'OTROS GASTOS';
	end if	
	return _fila,_nombre_fila,_a_caso_p,round(_a_monto_p,2),_a_caso_c,round(_a_monto_c,2),_t_caso_p,round(_t_monto_p,2),_t_caso_c,round(_t_monto_c,2),_so_caso_p,round(_so_monto_p,2),_so_caso_c,round(_so_monto_c,2) with resume;
end foreach	

DROP TABLE tmp_sinis;
DROP TABLE tmp_contrato1;
DROP TABLE tmp_coberturas1;
DROP TABLE tmp_coberturas2;
END PROCEDURE;