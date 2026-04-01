-- Consulta de Auditores
-- Creado    : 12/12/2019 - Autor: Henry Girón  
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac252('01','41701010401','%','2019','01','2019','10','sac','417020105')

DROP PROCEDURE sp_sac252;
CREATE PROCEDURE sp_sac252(a_tipo char(2),a_cuenta char(12),a_ccosto char(3),a_anio char(4),a_mes char(2), a_anio2 char(4),a_mes2 char(2),a_db CHAR(18),a_cuenta2 char(12)) 
RETURNING	CHAR(15)  as comprobante,     -- numero de comprobante  -- 2
			DATE      as fecha_registro,  -- fecha de registro      -- 3			
			DEC(15,2) as debito,          -- monto debito           -- 5
			DEC(15,2) as credito,         -- monto credito          -- 6
			DEC(15,2) as acumulado,       -- acumulado              -- 7			
			CHAR(50)  as cia_nom,	      -- cia                    -- 11			
			CHAR(50)  as cuenta,          -- cuenta                 -- 12			 			
			CHAR(7)   as desde,	          -- concepto               -- 15
			CHAR(7)   as hasta,	          -- concepto               -- 16
			CHAR(12)  as cuenta1,         -- cuenta                 -- 17
			CHAR(50)  as nombre_cta1,     -- desc_cuenta2           -- 18 
			char(12)  as cuenta2,         -- cuenta2                -- 19
			CHAR(12)  as grupo_cuenta,	  -- grupo_cuenta           -- 20
			CHAR(50)  as grupo_nombre,    -- grupo_nombre           -- 21
			CHAR(50)  as descripcion, 	  -- descripcion 			-- 22						
			CHAR(20)  as poliza2,
		    CHAR(10)  as transaccion2,
		    CHAR(18)  as numrecla2,
		    DEC(15,2) as monto_reclamo2,
		    DATE      as fecha_reclamo2,			
		    DEC(15,2) as debito2,
		    DEC(15,2) as credito2,
		    DEC(15,2) as monto_pagado2,
		    CHAR(5)   as cod_contrato2,
		    CHAR(50)  as desc_contrato2,		
		    DEC(15,2) as porc_partic_suma2,
		    CHAR(3)   as cod_ramo2,
		    CHAR(50)  as desc_ramo2,
			char(7)   as _periodo_trx,
			varchar(50) as tipo_tran;

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


DEFINE i_no_registro    char(10);
DEFINE i_notrx			INTEGER;
DEFINE i_auxiliar		CHAR(5);
DEFINE i_origen			CHAR(15);
DEFINE i_no_poliza		CHAR(10);
DEFINE i_no_endoso		CHAR(5);
DEFINE i_no_remesa		CHAR(10);
DEFINE i_renglon		smallint;
DEFINE i_no_tranrec		CHAR(10);
define _mostrar_trx     char(10);
DEFINE _mostrar         CHAR(10);
DEFINE _tipo            CHAR(15);
define _tipo_contrato   integer;

define _cod_tipotran    char(3);
define _nombre_tipotran varchar(50);

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
        transaccion_1       INTEGER,      -- numero de transaccion
		comprobante_1	    CHAR(15),     -- numero de comprobante 
		fecha_registro_1	DATE,        -- fecha de registro
		tipo_comprobante_1	CHAR(3),     -- tipo de comprobante
		debito_1	        DEC(15,2),   -- monto debito
		credito_1	        DEC(15,2),   -- monto credito
		acumulado_1	        DEC(15,2),   -- acumulado
		total_1	            DEC(15,2),	 -- total
		tipo_ingreso_1 	    CHAR(2),	 -- tipo de ingreso
		centro_costo_1	    CHAR(3),	 -- centro de costo
		cia_nom_1       	CHAR(50),	 -- cia
		cuenta_1	        CHAR(50),    -- cuenta
		desc_centro_1       CHAR(50),	 -- centro
		desc_concepto_1	    CHAR(50),	 -- concepto
		desde_1             CHAR(7),	 -- concepto
		hasta_1             CHAR(7),	 -- concepto
		cuenta1_1           CHAR(12),    -- cuenta
		nombre_cta1_1       CHAR(50),    -- desc_cuenta2
		cuenta2_1           char(12),    -- cuenta2
		grupo_cuenta_1	    CHAR(12),	 -- grupo_cuenta
		grupo_nombre_1      CHAR(50),    -- grupo_nombre
		descripcion_1  	    CHAR(50), 			
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
		periodo            CHAR(7),
		nombre_tipotran    varchar(50)
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
 WHERE referencia is not null
   and cta_cuenta >= a_cuenta  AND cta_cuenta <= a_cuenta2 
   and cta_cuenta not in ('54402010802')
   --and cta_cuenta in ('41701010101')  --'417020105','41701010401')   
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
		fecha,
		no_trx, 
		comp,
		sum(debito),
		sum(credito)
	INTO f_cuenta,	     
		 v_fecha,
		 i_notrx, 
		 v_comp,
		 v_debito,
	     v_credito
    FROM tmp_saldosac
GROUP BY cuenta, fecha, no_trx, comp
order by cuenta, fecha, no_trx, comp

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
			 and no_trx = i_notrx
		order by cuenta,fecha, comp, no_trx, descripcion
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
	
	let i_cuenta = f_cuenta;
	let i_comprobante = v_comp;	
	let i_fechatrx = v_fecha;		
	LET _mostrar_trx = "";
	
	if _res_origen <> 'CGL' then			
	
			FOREACH	
				select b.cuenta,
					   b.fecha,
					   b.no_registro,
					   b.debito,
					   b.credito,
					   decode(c.tipo_registro,"1","PRODUCCION","2","COBROS","3","RECLAMOS", "4", "CHEQUES", "5", "ANULADOS"),
					   c.no_documento,
					   c.no_poliza,
					   c.no_endoso,
					   c.no_remesa,
					   c.renglon,
					   c.no_tranrec --,b.sac_notrx
				  into i_cuenta,
					   i_fechatrx,
					   i_no_registro,
					   i_debito,
					   i_credito,
					   i_origen,
					   i_no_documento,
					   i_no_poliza,
					   i_no_endoso,
					   i_no_remesa,
					   i_renglon,
					   i_no_tranrec --,i_notrx
				  from sac999:reacompasie b, sac999:reacomp c
				 where b.no_registro = c.no_registro
				   and b.cuenta = f_cuenta          
				   and b.fecha  = v_fecha           
				   and b.sac_notrx = i_notrx
				   order by c.no_tranrec, c.renglon

					LET _mostrar = "";					

					if trim(i_origen) = "PRODUCCION" then

						LET _tipo = 'No. Factura';

						 SELECT no_factura
						   INTO _mostrar
						   FROM endedmae
						  WHERE no_poliza = i_no_poliza
							AND	no_endoso = i_no_endoso
							AND actualizado = 1;	 

					elif trim(i_origen) = "COBROS" then

						LET _tipo    = 'No. Remesa';
						LET _mostrar = i_no_remesa;

					elif trim(i_origen) = "RECLAMOS" then

						LET _tipo = 'No. transaccion';

						 SELECT transaccion,numrecla,monto, fecha, cod_tipotran
						   INTO _mostrar,_numrecla, _monto_reclamo, _fecha_reclamo, _cod_tipotran
						   FROM rectrmae
						  WHERE no_tranrec  = i_no_tranrec
							AND actualizado = 1;		
							
						 select trim(upper(nombre)) 
						   into _nombre_tipotran
						   from rectitra
                          where cod_tipotran = _cod_tipotran;							 			 		 							
						  
							let _transaccion = _mostrar;
			  
						 SELECT cod_ramo
						   INTO _cod_ramo
						   FROM emipoliza 
						  WHERE no_documento = i_no_documento;						
						  
						select nombre
						  into _desc_ramo
						  from prdramo
						 where cod_ramo = _cod_ramo;							 			 		 
						 
						 let i_total = i_debito - i_credito;
						  call sp_sis39(v_fecha) returning _periodo_trx;
						 
						foreach 
						select a.cod_contrato, b.nombre, a.porc_partic_suma, b.tipo_contrato
						  into _cod_contrato, _desc_contrato, _porc_partic_suma, _tipo_contrato
						  from rectrrea a, reacomae b
						 where a.no_tranrec = i_no_tranrec
						   and a.cod_contrato = b.cod_contrato
						   and a.tipo_contrato = b.tipo_contrato						   
						 order by a.orden			 
						 
						 {if f_cuenta[1,3] = '544' and _tipo_contrato in ('1') then
						    continue foreach;
						 end if}
						 
						  if _mostrar_trx = i_no_tranrec then
						     let v_debito = 0;
							 let v_credito = 0;
							 let v_saldo = 0;
							 let v_total = 0;
							 let i_debito = 0;
							 let i_credito = 0;
							 let i_total = 0;
							 let _monto_reclamo = 0;
						  else
						      LET _mostrar_trx = i_no_tranrec;					
						 end if
						 
								INSERT INTO tmp_zule (
										transaccion_1,
										comprobante_1,
										fecha_registro_1,
										tipo_comprobante_1,
										debito_1,
										credito_1,
										acumulado_1,
										total_1,
										tipo_ingreso_1,
										centro_costo_1,
										cia_nom_1,
										cuenta_1,
										desc_centro_1,
										desc_concepto_1,
										desde_1,
										hasta_1,
										cuenta1_1,
										nombre_cta1_1,
										cuenta2_1,
										grupo_cuenta_1,
										grupo_nombre_1,
										descripcion_1,
										cuenta,
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
										periodo,
                                        nombre_tipotran										
										 )
										VALUES (
										v_notrx,  			--1
										v_comp,			    --2
										v_fecha,			--3
										v_tipo,			    --4
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
										i_cuenta,
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
										_periodo_trx,
										_nombre_tipotran
										);			 			 			 
						 end foreach
						 

					elif trim(i_origen) = "CHEQUES" then

						LET _tipo = 'No. Requisicion';
						LET _mostrar = i_no_remesa;

					elif trim(i_origen) = "ANULADOS" then

						LET _tipo = 'No. Requisicion';
						LET _mostrar = i_no_remesa;

					end if

			   
			END FOREACH;
	
		
else

			call sp_sis39(v_fecha) returning _periodo_trx;	 		 			 
			 
			INSERT INTO tmp_zule (
				transaccion_1,
				comprobante_1,
				fecha_registro_1,
				tipo_comprobante_1,
				debito_1,
				credito_1,
				acumulado_1,
				total_1,
				tipo_ingreso_1,
				centro_costo_1,
				cia_nom_1,
				cuenta_1,
				desc_centro_1,
				desc_concepto_1,
				desde_1,
				hasta_1,
				cuenta1_1,
				nombre_cta1_1,
				cuenta2_1,
				grupo_cuenta_1,
				grupo_nombre_1,
				descripcion_1,
				cuenta,
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
				periodo,
                nombre_tipotran				
				 )
				VALUES (
				v_notrx,  			--1
				v_comp,			    --2
				v_fecha,			--3
				v_tipo,			    --4
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
				i_cuenta,
				i_comprobante,		
				i_fechatrx,
				i_no_documento,
				_transaccion,
				_numrecla,
				_monto_reclamo,
				_fecha_reclamo,							
				v_debito,
				v_credito,
				i_total,
				_cod_contrato,
				_desc_contrato,
				_porc_partic_suma,
				_cod_ramo,
				_desc_ramo,
				_periodo_trx,
				_nombre_tipotran
				);	
end if		

END FOREACH;

{foreach
 select transaccion_1,
		comprobante_1,
		fecha_registro_1,
		tipo_comprobante_1,
		debito_1,
		credito_1,
		acumulado_1,
		total_1,
		tipo_ingreso_1,
		centro_costo_1,
		cia_nom_1,
		cuenta_1,
		desc_centro_1,
		desc_concepto_1,
		desde_1,
		hasta_1,
		cuenta1_1,
		nombre_cta1_1,
		cuenta2_1,
		grupo_cuenta_1,
		grupo_nombre_1,
		descripcion_1,
		cuenta,
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
   into v_notrx,  			--1
		v_comp,			    --2
		v_fecha,			--3
		v_tipo,			    --4
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
        i_cuenta,
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
}

foreach
 select transaccion_1,
		comprobante_1,
		fecha_registro_1,
		tipo_comprobante_1,
		debito_1,
		credito_1,
		acumulado_1,
		total_1,
		tipo_ingreso_1,
		centro_costo_1,
		cia_nom_1,
		cuenta_1,
		desc_centro_1,
		desc_concepto_1,
		desde_1,
		hasta_1,
		cuenta1_1,
		nombre_cta1_1,
		cuenta2_1,
		grupo_cuenta_1,
		grupo_nombre_1,
		descripcion_1,
		cuenta,
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
		periodo,
        nombre_tipotran		
   into v_notrx,  			--1
		v_comp,			    --2
		v_fecha,			--3
		v_tipo,			    --4
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
        i_cuenta,
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
		_periodo_trx,
		_nombre_tipotran
from tmp_zule


	  RETURN v_comp,			--2
			 v_fecha,			--3
			 v_debito,			--5
			 v_credito,			--6
			 v_saldo,			--7
			 _cia_nom,			--11
			 l_nombre,			--12			 			 
			 l_desde,			--15
			 l_hasta,			--16
			 a_cuenta,			--17
			 l_nombre2,			--18
			 a_cuenta2,			--19
			 f_cuenta,			--20
			 f_nombre,			--21
			 l_desc_concepto,	--22
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
			_periodo_trx,       -- periodo_trx
			_nombre_tipotran    -- tipo_transac
			 WITH RESUME;
			 
END FOREACH;	

--DROP TABLE tmp_saldosac;
END PROCEDURE			