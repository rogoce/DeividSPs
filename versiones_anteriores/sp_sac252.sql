-- Consulta de Auditores
-- Creado    : 12/12/2019 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	

-- execute procedure sp_sac252('01','417020105','%','2019','01','2019','10','sac','417020105')

DROP PROCEDURE sp_sac252;
CREATE PROCEDURE sp_sac252(a_tipo char(2),a_cuenta char(12),a_ccosto char(3),a_anio char(4),a_mes char(2), a_anio2 char(4),a_mes2 char(2),a_db CHAR(18),a_cuenta2 char(12)) 
RETURNING	INTEGER as transaccion,      -- numero de transaccion
			CHAR(15) as comprobante,     -- numero de comprobante 
			DATE as fecha_registro,      -- fecha de registro
			CHAR(3) as tipo_comprobante, -- tipo de comprobante
			DEC(15,2) as debito,         -- monto debito
			DEC(15,2) as credito,        -- monto credito
			DEC(15,2) as acumulado,      -- acumulado
			DEC(15,2) as total,	         -- total
			CHAR(2) as tipo_ingreso,	 -- tipo de ingreso
			CHAR(3) as centro_costo,	 -- centro de costo
			CHAR(50) as cia_nom,	     -- cia
			CHAR(50) as cuenta,          -- cuenta
			CHAR(50) as desc_centro,	 -- centro
			CHAR(50) as desc_concepto,	 -- concepto
			CHAR(7) as desde,	         -- concepto
			CHAR(7) as hasta,	         -- concepto
			CHAR(12) as cuenta1,         -- cuenta
			CHAR(50) as nombre_cta1,     -- desc_cuenta2
			char(12) as cuenta2,         -- cuenta2
			CHAR(12) as grupo_cuenta,	 -- grupo_cuenta
			CHAR(50) as grupo_nombre,    -- grupo_nombre
			CHAR(50) as descripcion, 	 -- descripcion 
			CHAR(20) as poliza2,
		    CHAR(10) as transaccion2,
		    CHAR(18) as numrecla2,
		    DEC(15,2) as monto_reclamo2,
		    DATE as fecha_reclamo2,			
		    DEC(15,2) as debito2,
		    DEC(15,2) as credito2,
		    DEC(15,2) as monto_pagado2,
		    CHAR(5) as cod_contrato2,
		    CHAR(50) as desc_contrato2,		
		    DEC(15,2) as porc_partic_suma2,
		    CHAR(3) as cod_ramo2,
		    CHAR(50) as desc_ramo2,
			char(7) as _periodo_trx;

DEFINE v_debito           DEC(15,2);
DEFINE v_credito          DEC(15,2);	
DEFINE v_saldo            DEC(15,2);
DEFINE v_speriodo         CHAR(2);
DEFINE v_notrx			  INTEGER;
DEFINE v_comp			  CHAR(15);
DEFINE v_f_inicio		  DATE;
DEFINE v_f_final    	  DATE;
DEFINE v_fecha			  DATE;
DEFINE v_tipo	          CHAR(3);
DEFINE v_saldo_inicial    DEC(15,2);
DEFINE v_leido		      DEC(15,2);
DEFINE v_total            DEC(15,2);
DEFINE v_periodo          CHAR(100);
DEFINE v_tipoing		  CHAR(2);
DEFINE v_ccosto           CHAR(3);
DEFINE _fecha_inicial     date;
DEFINE _fecha_final		  date;
DEFINE _cia_nom			  char(50);
DEFINE l_nombre     	  char(50);
DEFINE l_nombre2     	  char(50);
DEFINE l_desc_concepto    char(50);
DEFINE l_desc_centro      char(50);
DEFINE l_desde,l_hasta    char(7);

DEFINE v_anterior  		  DEC(15,2);
DEFINE _mes_ant  		  DEC(15,2);
DEFINE f_cuenta			  CHAR(12);
DEFINE b_cuenta			  CHAR(12);
DEFINE f_nombre			  CHAR(50);
DEFINE v_descrip          CHAR(50);


define _error			  INTEGER;
define _error_desc		  CHAR(50);
define _id_detalle		  INTEGER;

DEFINE i_cuenta			char(12);
DEFINE i_comprobante	CHAR(15);
DEFINE i_fechatrx		DATE;
DEFINE i_no_documento	CHAR(20);
DEFINE i_debito			DEC(15,2);
DEFINE i_credito		DEC(15,2);
DEFINE _transaccion        CHAR(10);
DEFINE _numrecla           CHAR(18);
DEFINE _monto_reclamo      DEC(15,2);
DEFINE _fecha_reclamo	   DATE;			
DEFINE _debito             DEC(15,2);
DEFINE _credito            DEC(15,2);
DEFINE i_total             DEC(15,2);
DEFINE _monto_pagado       DEC(15,2);
DEFINE _cod_contrato       CHAR(5);
DEFINE _desc_contrato      CHAR(50);
DEFINE _porc_partic_suma   DEC(15,2);
DEFINE _cod_ramo           CHAR(3);
DEFINE _desc_ramo          CHAR(50);
define _periodo_trx        char(7);
define _res_origen         char(3);

let _id_detalle = 0;


SET ISOLATION TO DIRTY READ;

select cia_nom
  into _cia_nom
  from deivid:sigman02
 where cia_bda_codigo = a_db;

SELECT cta_nombre
  INTO l_nombre
  FROM cglcuentas
 WHERE cta_cuenta = a_cuenta;

SELECT cta_nombre
  INTO l_nombre2
  FROM cglcuentas
 WHERE cta_cuenta = a_cuenta2;

if a_mes < 10 then
	let a_mes = "0"||a_mes;
end if
if a_mes2 < 10 then
	let a_mes2 = "0"||a_mes2;
end if

let l_desde	=  a_anio || "-" || a_mes;
let l_hasta =  a_anio2 || "-" || a_mes2;

--call sp_sac148(a_tipo,a_cuenta,a_ccosto,a_anio,a_mes,a_anio2,a_mes2,a_db) returning _error, _error_desc; 

Drop Table If Exists tmp_saldosac;
CREATE TEMP TABLE tmp_saldosac(
		cuenta			CHAR(12),
		nombre			CHAR(50),
	    no_trx          INTEGER	    default 0,
		comp            CHAR(15),
		fecha           DATE,
		tipocomp        CHAR(3),
		debito          DEC(15,2)	default 0,
		credito        	DEC(15,2)	default 0,
		acumulado       DEC(15,2)   default 0,
		total           DEC(15,2)   default 0,
		tipo 			CHAR(2),
		ccosto 			CHAR(3),
		cia_nom			CHAR(50),
		cta_nombre   	CHAR(50),
		descripcion		CHAR(50),
		res_origen      char(3)
		) WITH NO LOG; 	
		
Drop Table If Exists tmp_zule;
CREATE TEMP TABLE tmp_zule(
		cuenta			   CHAR(12),
		comprobante        CHAR(15),
		fechatrx           DATE,
		poliza             CHAR(20),
		transaccion        CHAR(10),
		numrecla           CHAR(18),
		monto_reclamo      DEC(15,2)	default 0,
		fecha_reclamo	   DATE,			
		debito             DEC(15,2)	default 0,
		credito            DEC(15,2)	default 0,
		monto_pagado       DEC(15,2)	default 0,
		cod_contrato       CHAR(5),
		desc_contrato      CHAR(50),		
		porc_partic_suma   DEC(15,2)	default 0,
		cod_ramo           CHAR(3),
		desc_ramo          CHAR(50),		
		periodo            CHAR(7)
		) WITH NO LOG; 						

--  set debug file to "sp_sac96.trc";	
--  trace on;

  if a_mes < 10 then
		if  a_mes[2] is null then
	    	let  v_speriodo = "0" || a_mes[1] ;
		else
	    	let  v_speriodo = "0" || a_mes[2] ;
		end if
  else 
    	let  v_speriodo = a_mes;
  end if

  let _fecha_inicial = mdy(a_mes, 1, a_anio) ;
  let _fecha_final   = sp_sis36(a_anio2 || "-" || a_mes2) ;

  SELECT cglperiodo.per_inicio,   
         cglperiodo.per_final,
		 cglperiodo.per_descrip
    INTO v_f_inicio,
		 v_f_final,
		 v_periodo
    FROM cglperiodo  
   WHERE ( cglperiodo.per_ano = a_anio ) AND  
         ( cglperiodo.per_mes = v_speriodo ) ;

LET b_cuenta = "";
FOREACH
SELECT cta_cuenta,cta_nombre
  INTO f_cuenta,f_nombre
  FROM cglcuentas
 WHERE cta_cuenta >= a_cuenta  
   AND cta_cuenta <= a_cuenta2 
   order by 1

		LET v_saldo = 0;
		LET v_leido = 0;
		LET v_saldo_inicial = 0;
		LET l_desc_centro   = "";
		LET l_desc_concepto = "";
        LET _id_detalle = _id_detalle + 1;
		if a_ccosto = "%" then							 
				FOREACH	
				    SELECT cglsaldoctrl.sld_incioano
				    INTO v_leido
					FROM cglsaldoctrl  
					WHERE  ( cglsaldoctrl.sld_tipo like a_tipo ) AND  
						 ( cglsaldoctrl.sld_cuenta = f_cuenta ) AND  
						 ( cglsaldoctrl.sld_ccosto like a_ccosto ) AND  
						 ( cglsaldoctrl.sld_ano = a_anio )			 

					IF v_leido IS NULL THEN
						LET v_leido = 0;
					END IF

					let  v_saldo_inicial = v_saldo_inicial + v_leido	;
				END FOREACH;
		else
		  SELECT cglsaldoctrl.sld_incioano
		    INTO v_saldo_inicial
			FROM cglsaldoctrl  
			WHERE  ( cglsaldoctrl.sld_tipo like a_tipo ) AND  
				 ( cglsaldoctrl.sld_cuenta = f_cuenta ) AND   
				 ( cglsaldoctrl.sld_ccosto like a_ccosto ) AND  
				 ( cglsaldoctrl.sld_ano = a_anio ) ;
		end if

		IF v_saldo_inicial  IS NULL THEN
			LET v_saldo_inicial = 0 ;
		END IF


		LET v_anterior = 0;
		LET _mes_ant = 0;

		if a_mes > 1 then
			LET _mes_ant = a_mes - 1;
			SELECT sum(cglresumen.res_debito-cglresumen.res_credito)
			INTO v_anterior
			FROM cglresumen
			WHERE ( cglresumen.res_cuenta = f_cuenta ) AND
			     ( cglresumen.res_tipo_resumen like a_tipo ) AND
			     ( cglresumen.res_ccosto like a_ccosto) AND
			     ( year(cglresumen.res_fechatrx) = a_anio) AND
			     ( month(cglresumen.res_fechatrx) <= _mes_ant ) ;

			IF v_anterior IS NULL THEN
				LET v_anterior = 0 ;
			END IF
		end if

		LET v_saldo = v_saldo_inicial + v_anterior ;

		FOREACH
		  SELECT cglresumen.res_notrx,
		         cglresumen.res_comprobante,
		         cglresumen.res_fechatrx,
		         cglresumen.res_tipcomp,
		         cglresumen.res_debito,
		         cglresumen.res_credito,
				 cglresumen.res_tipo_resumen,
				 cglresumen.res_ccosto,
				 cglresumen.res_descripcion,
				 cglresumen.res_origen
		    INTO v_notrx,
			     v_comp,
				 v_fecha,
				 v_tipo,
				 v_debito,
			     v_credito,
				 v_tipoing,
				 v_ccosto,
				 v_descrip,
				 _res_origen
		    FROM cglresumen
		   WHERE ( cglresumen.res_cuenta = f_cuenta ) AND
		         ( cglresumen.res_tipo_resumen like a_tipo ) AND
		         ( cglresumen.res_ccosto like a_ccosto ) AND		 
		         ( cglresumen.res_fechatrx >= _fecha_inicial ) AND
		         ( cglresumen.res_fechatrx <= _fecha_final )  
		  order by cglresumen.res_fechatrx, cglresumen.res_comprobante, cglresumen.res_tipcomp, cglresumen.res_origen

		  LET v_saldo = v_saldo + v_debito - v_credito ;

		INSERT INTO tmp_saldosac(cuenta,
			    nombre,
				no_trx,
				comp,
				fecha,
				tipocomp,
				debito,
				credito,
				acumulado,
				total,
				tipo,
				ccosto,
				cia_nom,
				cta_nombre,
				descripcion,
				res_origen)
			VALUES(	f_cuenta,
			     f_nombre,
			     v_notrx,
			     v_comp,
				 v_fecha,
				 v_tipo,
				 v_debito,
			     v_credito,
				 v_saldo,
				 0.00,
				 v_tipoing,
				 v_ccosto,
				 _cia_nom,
				 l_nombre,
				 v_descrip,
				 _res_origen);

		END FOREACH;

		LET v_saldo = v_saldo_inicial + v_anterior ;

		update  tmp_saldosac
		set total  = v_saldo 
		where cuenta = f_cuenta;

END FOREACH
let b_cuenta = "";
FOREACH
  SELECT cuenta,
		comp,
		fecha,
		sum(debito),
		sum(credito)
	INTO f_cuenta,
	     v_comp,
		 v_fecha,
		 v_debito,
	     v_credito
    FROM tmp_saldosac
GROUP BY cuenta,fecha, comp
order by cuenta,fecha, comp




	   FOREACH
		  SELECT  nombre,
				tipocomp,
				total,
				tipo,
				ccosto,
				cia_nom,
				cta_nombre,
		        descripcion,
				res_origen
			INTO f_nombre,
				 v_tipo,
				 v_total,
				 v_tipoing,
				 v_ccosto,
				 _cia_nom,
				 l_nombre,
   		         v_descrip,
				 _res_origen
		    FROM tmp_saldosac
		   WHERE cuenta = f_cuenta 
		     AND fecha	= v_fecha
		     AND comp	= v_comp
		order by cuenta,fecha, comp, descripcion
		EXIT FOREACH;
	  END FOREACH
	  

	IF trim(f_cuenta) <> trim(b_cuenta) THEN
	   LET b_cuenta = f_cuenta ;
	   LET v_saldo = v_total ;
	END IF

	IF v_debito IS NULL THEN
		LET v_debito = 0;
	END IF
	IF v_credito IS NULL THEN
		LET v_credito = 0;
	END IF

  SELECT cen_descripcion
    INTO l_desc_centro
    FROM cglcentro
    where cen_codigo = v_ccosto;

    SELECT con_descrip
      INTO l_desc_concepto
      FROM cglconcepto
    where con_codigo = v_tipo;

	let v_saldo = v_saldo + v_debito - v_credito;
	let v_notrx = 0;	
	
	let i_no_documento = '';
	let _transaccion = '';
	let _numrecla = '';
	let _monto_reclamo = 0.00;
	let _fecha_reclamo = null;			
	let i_debito = 0.00;			
	let i_credito = 0.00;
	let i_total = 0.00;			
	let _cod_contrato = '';
	let _desc_contrato = '';
	let _porc_partic_suma = 0.00;			
	let _cod_ramo = '';
	let _desc_ramo = '';
	let _periodo_trx = '';	
	
	if _res_origen <> 'CGL' then
	
			call sp_sac253(f_cuenta,v_comp,v_fecha)
		returning _error, _error_desc;
		
		{if _error <> 0 then
		end if}	  

	
		foreach
		 select cuenta,
				comprobante,
				fechatrx,
				poliza,
				transaccion,
				numrecla,
				monto_reclamo,
				fecha_reclamo,
				debito,
				credito,
				monto_pagado,
				cod_contrato,
				desc_contrato,							
				porc_partic_suma,
				cod_ramo,
				desc_ramo,
                periodo				
		   into i_cuenta,
				i_comprobante,		
				i_fechatrx,
				i_no_documento,
				_transaccion,
				_numrecla,
				_monto_reclamo,
				_fecha_reclamo,							
				i_debito,
				i_credito,
				i_total,
				_cod_contrato,
				_desc_contrato,
				_porc_partic_suma,
				_cod_ramo,
				_desc_ramo,
				_periodo_trx
		from tmp_zule
	

			  RETURN v_notrx,  			--1
					 v_comp,			--2
					 v_fecha,			--3
					 v_tipo,			--4
					 v_debito,			--5
					 v_credito,			--6
					 v_saldo,			--7
					 v_total,			--8
					 v_tipoing,			--9
					 v_ccosto,			--10
					 _cia_nom,			--11
					 l_nombre,			--12
					 l_desc_centro,		--13
					 l_desc_concepto,	--14
					 l_desde,			--15
					 l_hasta,			--16
					 a_cuenta,			--17
					 l_nombre2,			--18
					 a_cuenta2,			--19
					 f_cuenta,			--20
					 f_nombre,			--21
					 v_descrip,			--22
					 i_no_documento,    -- poliza
					_transaccion,       -- transaccion
					_numrecla,          -- reclamo
					_monto_reclamo,     -- monto_reclamo
					_fecha_reclamo,		-- fecha_reclamo					
					i_debito,           -- DB reclamo
					i_credito,          -- DB reclamo
					i_total,            -- DB - CR reclamo
					_cod_contrato,      -- cod_contrato
					_desc_contrato,     -- desc_contrato
					_porc_partic_suma,  -- porc_partic_suma
					_cod_ramo,          -- ramo
					_desc_ramo,         -- desc ramo
					_periodo_trx        -- periodo_trx
					 WITH RESUME;
					 
		END FOREACH;			
else
			  RETURN v_notrx,  			--1
					 v_comp,			--2
					 v_fecha,			--3
					 v_tipo,			--4
					 v_debito,			--5
					 v_credito,			--6
					 v_saldo,			--7
					 v_total,			--8
					 v_tipoing,			--9
					 v_ccosto,			--10
					 _cia_nom,			--11
					 l_nombre,			--12
					 l_desc_centro,		--13
					 l_desc_concepto,	--14
					 l_desde,			--15
					 l_hasta,			--16
					 a_cuenta,			--17
					 l_nombre2,			--18
					 a_cuenta2,			--19
					 f_cuenta,			--20
					 f_nombre,			--21
					 v_descrip,			--22
					 i_no_documento,    -- poliza
					_transaccion,       -- transaccion
					_numrecla,          -- reclamo
					_monto_reclamo,     -- monto_reclamo
					_fecha_reclamo,		-- fecha_reclamo					
					i_debito,           -- DB reclamo
					i_credito,          -- DB reclamo
					i_total,            -- DB - CR reclamo
					_cod_contrato,      -- cod_contrato
					_desc_contrato,     -- desc_contrato
					_porc_partic_suma,  -- porc_partic_suma
					_cod_ramo,          -- ramo
					_desc_ramo,         -- desc ramo
					_periodo_trx        -- periodo_trx
					 WITH RESUME;
end if		

END FOREACH;
--DROP TABLE tmp_saldosac;
END PROCEDURE			