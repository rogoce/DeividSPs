-- Consulta de Diferencias Saldos de terceros 26410 
-- Creado    : 10/02/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	 d_sac_aud_sldaux_rep

DROP PROCEDURE sp_sac262c;
CREATE PROCEDURE sp_sac262c(a_tipo char(2),a_cuenta char(12), a_anio char(4),a_mes smallint, a_auxiliar CHAR(5)) 
RETURNING   VARCHAR(7) as Periodo,			--  Periodo 1
			CHAR(5) as Tercero,				--  Tercero 2
			CHAR(50) as Nombre,				--  Nombre 3
			CHAR(50) as Cuenta_Nombre,   	--  Nombre Cuenta 11
			CHAR(12) as Cuenta,   			--  a_Cuenta 12
			DATE as Fecha_Asiento, 			--13
			CHAR(15) as Comprobante, 		--14
			VARCHAR(50) as Descripcion, 	--15
			DEC(15,2) as Debito_C, 			--16
			DEC(15,2) as Credito_C, 		--17
 			DEC(15,2) as Comision_T, 			--25
			DEC(15,2) as Diferencia; 			--28

DEFINE v_debito           DEC(15,2);
DEFINE v_credito          DEC(15,2);	
DEFINE v_monto            DEC(15,2);
DEFINE v_monto_a          DEC(15,2);
DEFINE v_saldo            DEC(15,2);
DEFINE v_saldo_ant,v_saldo_p1        DEC(15,2);
DEFINE v_saldo_acum       DEC(15,2);
DEFINE v_anio_ant         SMALLINT;
DEFINE v_periodo          CHAR(100);
DEFINE v_speriodo         CHAR(2);
DEFINE v_valor            SMALLINT;
DEFINE t_periodo          CHAR(7);
DEFINE v_aux_terc		  CHAR(5);
DEFINE v_nom_terc		  CHAR(50);
DEFINE l_cia_nom		  CHAR(50);
DEFINE l_nombre     	  CHAR(50);
DEFINE _fecha    		  DATE;
DEFINE _comprobante       char(15); 
DEFINE _fechatrx          date; 
DEFINE _descripcion       varchar(50); 
DEFINE _debito			  DEC(15,2);
DEFINE _credito           DEC(15,2); 
DEFINE _notrx			  integer; 
DEFINE _origen            char(3);
DEFINE _no_remesa		  char(10);
DEFINE _renglon           smallint;
DEFINE _fecha2    		  DATE;
DEFINE _no_remesa2        char(10);
DEFINE _no_recibo		  char(10);
DEFINE _no_documento	  char(18);
DEFINE v_nombre_clte      varchar(100);
DEFINE _comision		  DEC(15,2);
DEFINE _fecha_com         DATE;
DEFINE _fecha_desde_com   DATE;
DEFINE _fecha_hasta_com   DATE;
DEFINE _no_poliza         CHAR(10);
DEFINE _cod_cliente       CHAR(10);
DEFINE _tipocomp          CHAR(3);
DEFINE _debito_com 		  DEC(15,2);
DEFINE _credito_com 	  DEC(15,2);
DEFINE _tipo_remesa       CHAR(1);
DEFINE _monto_chequeo     DEC(15,2);
DEFINE _saldo_c			  DEC(15,2); 
DEFINE _saldo_com         DEC(15,2);

--EXECUTE PROCEDURE sp_sac262c('01','26410','2023',3,'A2311')
-- EXECUTE PROCEDURE sp_sac262('01','26410','*','2000',1,'001','A2311') 

SET ISOLATION TO DIRTY READ;

---set debug file to "sp_sac262.trc";
--trace on;


CREATE TEMP TABLE tmp_saldosat(
	    periodo         CHAR(100),
		tercero         CHAR(5),
		nombre			CHAR(50),
		inicial         DEC(15,2)	default 0,
		debito          DEC(15,2)	default 0,
		credito         DEC(15,2)	default 0,   
		neto            DEC(15,2)	default 0,
		acumulado       DEC(15,2)	default 0,
		cia				CHAR(50),
		cuenta			CHAR(50)
		) WITH NO LOG; 	

CREATE TEMP TABLE tmp_diferencia(
        periodo        	VARCHAR(7),		
		cod_tercero	   	CHAR(5),				
		nom_tercero	   	CHAR(50),			
		saldo_inicial  	DEC(15,2),		
		debito			DEC(15,2),  		
		credito			DEC(15,2),		
		neto			DEC(15,2),			
		acumulado		DEC(15,2),			
		periodo_nombre	CHAR(100),	
		cia				CHAR(50),		
		cuenta_nombre	CHAR(50),  
		cuenta			CHAR(12),   
		fecha_asiento	DATE, 		
		comprobante		CHAR(15), 	
		decripcion		VARCHAR(50), 
		debito_c		DEC(15,2), 		
		credito_c		DEC(15,2), 	
		remesa			CHAR(10), 
		renglon			INTEGER,
 		debito_cobros	DEC(15,2), 	
		credito_cobros	DEC(15,2), 	
		requisicion		CHAR(10), 
		remesa_comis	CHAR(10), 
		requis_comis	CHAR(10), 
		renglon_comis	INTEGER,
		no_poliza		CHAR(10),
		recibo	 		CHAR(10),
		documento_comis	CHAR(18), 
		desc_comis		VARCHAR(100),
		debito_comis	DEC(15,2), 
		credito_comis	DEC(15,2), 
		fecha			DATE,  
		fecha_desde		DATE,  
		fecha_hasta		DATE,
		origen      	CHAR(3)
		) WITH NO LOG; 	


if a_mes < 10 then
	let  v_speriodo = "0" || a_mes;
else 
	let  v_speriodo = a_mes;
end if

SELECT cia_nom
  INTO l_cia_nom
  FROM deivid:sigman02
 WHERE cia_comp = '001';

SELECT cta_nombre
  INTO l_nombre
  FROM cglcuentas
 WHERE cta_cuenta = a_cuenta;


SELECT per_descrip  
  INTO v_periodo
  FROM cglperiodo  
 WHERE per_ano = a_anio 
   AND per_mes = v_speriodo;

LET t_periodo =  a_anio||"-"||v_speriodo ;

let _fecha = mdy(a_mes, 1, a_anio);	

let _fecha2 = _fecha + 1 units month;	

let _fecha2 = _fecha2 - 1 units day;

let _fecha = mdy(1, 1, a_anio);


LET v_monto = 0;

{FOREACH
	select aux_tercero 
	  into v_aux_terc
	  from cglauxiliar 
	 where aux_cuenta = a_cuenta  
	 and aux_tercero = a_auxiliar
	 order by aux_tercero

		LET v_saldo = 0;
		LET v_saldo_ant = 0;
		LET v_saldo_acum = 0;
		LET v_debito = 0;
		LET v_credito = 0;
		LET v_saldo_ant = 0 ;

		LET v_anio_ant = a_anio;

		select ter_descripcion
		  into v_nom_terc
		  from cglterceros
		 where ter_codigo = v_aux_terc;

		IF v_nom_terc IS NULL THEN
			LET v_nom_terc = " " ;
		END IF

		SELECT cglsaldoaux.sld_incioano
		  INTO v_saldo_ant
		  FROM cglsaldoaux
		 WHERE ( cglsaldoaux.sld_tipo = a_tipo )  AND
		       ( cglsaldoaux.sld_cuenta = a_cuenta )    AND
		       ( cglsaldoaux.sld_tercero = v_aux_terc ) AND
			   ( cglsaldoaux.sld_ano = a_anio )  ;

		IF v_saldo_ant IS NULL THEN
		 LET v_saldo_ant = 0 ;
		END IF

		LET v_saldo_p1 = 0 ;

	   	if a_mes > 1 then

			SELECT sum( cglsaldoaux1.sld1_debitos + cglsaldoaux1.sld1_creditos )
			  INTO v_saldo_p1
			  FROM cglsaldoaux1
			 WHERE ( cglsaldoaux1.sld1_tipo = a_tipo ) AND 
				   ( cglsaldoaux1.sld1_cuenta = a_cuenta ) AND
			       ( cglsaldoaux1.sld1_tercero = v_aux_terc ) AND
			       ( cglsaldoaux1.sld1_ano = a_anio ) AND
			       ( cglsaldoaux1.sld1_periodo < a_mes ) ;

			IF v_saldo_p1 IS NULL THEN
				LET v_saldo_p1 = 0 ;
			END IF
   		end if 

		LET v_saldo = v_saldo_ant + v_saldo_p1 ;

		SELECT sum(sld1_debitos),
		       sum(sld1_creditos)
		  INTO v_debito,
		       v_credito
		  FROM cglsaldoaux1
		 WHERE ( cglsaldoaux1.sld1_tipo = a_tipo ) AND 
			   ( cglsaldoaux1.sld1_cuenta = a_cuenta ) AND
		       ( cglsaldoaux1.sld1_tercero = v_aux_terc ) AND
		       ( cglsaldoaux1.sld1_ano = a_anio ) AND
			   ( cglsaldoaux1.sld1_periodo =  a_mes );

		IF v_debito IS NULL THEN
			LET v_debito = 0 ;
		END IF

		IF v_credito IS NULL THEN
		 LET v_credito = 0 ;
		END IF	 

		LET v_monto = v_monto + v_saldo + v_debito + v_credito;

		INSERT INTO tmp_saldosat(
			periodo,
			tercero,
			nombre,
			inicial,
			debito,
			credito,
			neto,
			acumulado,
			cia,
			cuenta )
		VALUES(	v_periodo,
			 v_aux_terc,
			 v_nom_terc,
			 v_saldo,
			 v_debito,
			 v_credito,
			 v_debito + v_credito,
			 v_monto,
			 l_cia_nom,
			 l_nombre );

END FOREACH;}
{FOREACH	
	SELECT periodo,
		   tercero,
		   nombre,
		   inicial,
		   debito,
		   credito,
		   neto,
		   acumulado,
		   cia,
		   cuenta
	  INTO v_periodo,
		   v_aux_terc,
		   v_nom_terc,
		   v_saldo_ant,
		   v_debito,
		   v_credito,
		   v_saldo,
		   v_monto,
		   l_cia_nom,
		   l_nombre 
	  FROM tmp_saldosat
	 where acumulado <> 0
	 order by periodo,nombre,tercero

	-- Cambios solicitado . Sr. Naranjo 30/04/2010

	IF v_saldo_ant IS NULL THEN
	   LET v_saldo_ant = 0 ;
	END IF

	IF v_saldo IS NULL THEN
	   LET v_saldo = 0 ;
	END IF

	LET v_monto =  v_saldo_ant + v_saldo ;

	IF 	v_saldo_ant = 0 and v_saldo = 0 and v_debito = 0 and v_credito = 0 THEN
		continue foreach;
	END IF
}
	let v_saldo_ant = 0;
	let v_saldo = 0;
	let v_debito = 0;
	let v_credito = 0;	
	
	foreach
		select res_comprobante, 
		       res_tipcomp,
			   res_fechatrx, 
			   res_descripcion, 
			   sum(res1_debito), 
			   sum(res1_credito), 
			   res_origen,
			   res1_auxiliar
		  into _comprobante, 
		       _tipocomp,
			   _fechatrx, 
			   _descripcion, 
			   _debito, 
			   _credito, 
			   _origen,
			   v_aux_terc
		from cglresumen1 a, cglresumen c
		where a.res1_noregistro = c.res_noregistro
		and a.res1_cuenta = '26410'
	--	and a.res1_auxiliar = v_aux_terc
		and c.res_fechatrx >= _fecha
		and c.res_fechatrx <= _fecha2 
		and res_origen = 'CHE'
   group by res1_auxiliar, res_fechatrx, res_comprobante, res_tipcomp, res_origen ,res_descripcion
   order by res1_auxiliar, res_fechatrx, res_comprobante, res_tipcomp, res_origen ,res_descripcion
		
		let _no_remesa = null;
		let _renglon = null;
		
		select ter_descripcion
		  into v_nom_terc
		  from cglterceros
		 where ter_codigo = v_aux_terc;		
		
		if _origen = 'COB' then
			foreach
				select a.no_remesa,
				       a.renglon,
					   b.prima_neta * e.porc_comis_agt / 100 * e.porc_partic_agt / 100
				  into _no_remesa,
				       _renglon,
					   _debito_com
				  from cobasien a, cobredet b, cglresumen c, cobreagt e
				 where a.no_remesa = b.no_remesa
				   and a.renglon = b.renglon
				   and b.no_remesa = e.no_remesa
				   and b.renglon = e.renglon
				   and e.cod_agente = REPLACE(v_aux_terc,'A','0')
				   and a.sac_notrx = c.res_notrx
				   and a.cuenta = c.res_cuenta
				   and b.cod_auxiliar = v_aux_terc
				   and c.res_cuenta = '26410'
				   and c.res_comprobante = _comprobante
				   and c.res_fechatrx = _fechatrx 
			--  group by a.no_remesa,

        insert into tmp_diferencia VALUES(       
			   t_periodo,
			   v_aux_terc,
			   v_nom_terc,
			   0,
			   v_debito,
			   v_credito,
			   v_saldo,
			   v_monto,
			   v_periodo,
			   l_cia_nom,
			   l_nombre,
			   a_cuenta,
			   _fechatrx, 
			   _comprobante,
			   _descripcion, 
			   _debito, 
			   _credito, 
			   _no_remesa,
			   _renglon,
			   _debito_com,
			   0.00,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null,
			   _origen);
					   
			end foreach
		else
			foreach 
				select a.no_requis
				  into _no_remesa
				  from chqchcta a, chqctaux b, cglresumen c
				 where a.no_requis = b.no_requis
				   and a.sac_notrx = c.res_notrx
				   and b.cod_auxiliar = v_aux_terc
				   and a.cuenta = '26410'
				   and c.res_comprobante = _comprobante
				   and c.res_fechatrx = _fechatrx 
				group by a.no_requis
				
				-- Pago de comisiones
				foreach			
				  select a.no_remesa, 
				         b.no_recibo,
						 b.comision,
						 b.no_poliza,
						 b.no_documento,
						 b.fecha,
						 b.fecha_desde,
						 b.fecha_hasta,
						 a.prima_neta * d.porc_comis_agt / 100 * d.porc_partic_agt / 100,
						 a.renglon,
						 c.tipo_remesa,
						 c.monto_chequeo
					into _no_remesa2,
					     _no_recibo,
						 _comision,
						 _no_poliza,
						 _no_documento,
						 _fecha_com,
						 _fecha_desde_com,
						 _fecha_hasta_com,
				         _debito_com,
						 _renglon,
						 _tipo_remesa,
						 _monto_chequeo
					from cobredet a, chqcomis b, cobremae c, cobreagt d, cobasien e 
					where a.no_remesa = c.no_remesa
					  and a.no_remesa = d.no_remesa
					  and a.renglon = d.renglon
					  and a.no_recibo = b.no_recibo
                      and a.no_poliza = b.no_poliza
					  and d.no_remesa = e.no_remesa
					  and d.renglon = e.renglon
					  and a.fecha = b.fecha 
					  and a.actualizado = 1
					  and b.no_requis = _no_remesa
					  and b.no_poliza <> '00000'
					  AND a.tipo_mov  IN ('P','N')
					  AND a.monto_descontado = 0
					  AND c.tipo_remesa IN ('A', 'M', 'C')
					  and d.cod_agente = REPLACE(v_aux_terc,'A','0')
					  and e.cuenta = '26410'
				-- GROUP BY a.no_remesa, b.no_recibo, b.comision, b.no_poliza, b.no_documento, b.fecha, b.fecha_desde, b.fecha_hasta
				
				  --  if _tipo_remesa = "C" and _monto_chequeo = 0 then
				--		continue foreach;
				--	end if
					  
					SELECT cod_contratante
					  INTO _cod_cliente
					  FROM emipomae
					 WHERE no_poliza = _no_poliza;

					SELECT nombre
					  INTO v_nombre_clte
					  FROM cliclien
					 WHERE cod_cliente = _cod_cliente;					  
				   									
       insert into tmp_diferencia VALUES(       
						   t_periodo,
						   v_aux_terc,
						   v_nom_terc,
						   0,
						   v_debito,
						   v_credito,
						   v_saldo,
						   v_monto,
						   v_periodo,
						   l_cia_nom,
						   l_nombre,
						   a_cuenta,
						   _fechatrx, 
						   _comprobante,
						   _descripcion, 
						   _debito, 
						   _credito, 
						   null,
						   null,
						   null,
						   null,
						   _no_remesa,
						   _no_remesa2,
						   null,
						   _renglon,
						   _no_poliza,
						   _no_recibo,
						   _no_documento,
						   v_nombre_clte,
				           _debito_com,
					       0.00,
						   _fecha_com,
						   _fecha_desde_com,
						   _fecha_hasta_com,
						   _origen);
				end foreach   
				
				--Comisión descontada
				foreach
				  select a.no_remesa, 
				         b.no_recibo,
						 b.comision,
						 b.no_poliza,
						 b.no_documento,
						 b.fecha,
						 b.fecha_desde,
						 b.fecha_hasta,
						 a.renglon
					into _no_remesa2,
					     _no_recibo,
						 _comision,
						 _no_poliza,
						 _no_documento,
						 _fecha_com,
						 _fecha_desde_com,
						 _fecha_hasta_com,
						 _renglon
					from cobredet a, chqcomis b
				   where a.no_recibo = b.no_recibo
					 and a.fecha = b.fecha
					 and a.actualizado = 1
					 and b.no_requis = _no_remesa
					 and b.no_poliza = '00000'
					 AND a.tipo_mov = 'C'
					 AND a.monto_descontado = 0
                     and a.cod_agente = REPLACE(v_aux_terc,'A','0')
					 
					let v_nombre_clte = 'COMISION DESCONTADA';

      insert into tmp_diferencia VALUES(       
					       t_periodo,
						   v_aux_terc,
						   v_nom_terc,
						   0,
						   v_debito,
						   v_credito,
						   v_saldo,
						   v_monto,
						   v_periodo,
						   l_cia_nom,
						   l_nombre,
						   a_cuenta,
						   _fechatrx, 
						   _comprobante,
						   _descripcion, 
						   _debito, 
						   _credito, 
						   null,
						   null,
						   null,
						   null,
						   _no_remesa,
						   _no_remesa2,
						   null,
						   _renglon,
						   _no_poliza,
						   _no_recibo,
						   _no_documento,
						   v_nombre_clte,
				           _comision,
					       0,
						   _fecha_com,
						   _fecha_desde_com,
						   _fecha_hasta_com,
						   _origen);
				end foreach   
 
				-- Devolución de prima
				foreach
				  SELECT a.no_requis,
				         d.no_recibo,
						 d.comision,
						 d.no_poliza,
						 d.no_documento,
						 d.fecha,
						 d.fecha_desde,
						 d.fecha_hasta,
						 e.debito,
						 e.credito,
						 e.renglon
					into _no_remesa2,
					     _no_recibo,
						 _comision,
						 _no_poliza,
						 _no_documento,
						 _fecha_com,
						 _fecha_desde_com,
						 _fecha_hasta_com,
				         _debito_com,
					     _credito_com,
						 _renglon
				    FROM chqchmae a, chqchpol b, chqchpoa c, chqcomis d, chqctaux e
				   WHERE a.fecha_impresion  = d.fecha
					 AND a.pagado           = 1
					 AND a.origen_cheque    = 6
					 AND a.no_requis        = b.no_requis
					 AND b.no_requis        = c.no_requis
					 AND b.no_documento     = c.no_documento
					 AND a.no_cheque        = d.no_recibo
					 AND d.no_requis        = _no_remesa
					 AND b.no_poliza        = d.no_poliza
					 AND a.no_requis        = e.no_requis
					 AND a.fecha_impresion  = e.fecha
					 AND e.cod_auxiliar		= v_aux_terc
					 AND e.cuenta           = '26410'
					 AND c.cod_agente       = REPLACE(v_aux_terc,'A','0')

					SELECT cod_contratante
					  INTO _cod_cliente
					  FROM emipomae
					 WHERE no_poliza = _no_poliza;

					SELECT nombre
					  INTO v_nombre_clte
					  FROM cliclien
					 WHERE cod_cliente = _cod_cliente;					  
				   									
      insert into tmp_diferencia VALUES(       
					       t_periodo,
						   v_aux_terc,
						   v_nom_terc,
						   0,
						   v_debito,
						   v_credito,
						   v_saldo,
						   v_monto,
						   v_periodo,
						   l_cia_nom,
						   l_nombre,
						   a_cuenta,
						   _fechatrx, 
						   _comprobante,
						   _descripcion, 
						   _debito, 
						   _credito, 
						   null,
						   null,
						   null,
						   null,
						   _no_remesa,
						   null,
						   _no_remesa2,
						   _renglon,
						   _no_poliza,
						   _no_recibo,
						   _no_documento,
						   trim(v_nombre_clte) || ' DEVOLUCION DE PRIMA',
				           _debito_com,
					       _credito_com,
						   _fecha_com,
						   _fecha_desde_com,
						   _fecha_hasta_com,
						   _origen);
				end foreach   

				-- Devolucion de prima
				foreach	
				  SELECT a.no_requis,
				         d.no_recibo,
						 d.comision,
						 d.no_poliza,
						 d.no_documento,
						 d.fecha,
						 d.fecha_desde,
						 d.fecha_hasta,
						 e.debito,
						 e.credito,
						 e.renglon
					into _no_remesa2,
					     _no_recibo,
						 _comision,
						 _no_poliza,
						 _no_documento,
						 _fecha_com,
						 _fecha_desde_com,
						 _fecha_hasta_com,
				         _debito_com,
					     _credito_com,
						 _renglon
					   FROM chqchmae a, chqchpol b, chqchpoa c, chqcomis d, chqctaux e
					  WHERE a.fecha_anulado 	= d.fecha
						AND a.pagado           = 1
						AND a.origen_cheque    = 6
						AND a.anulado           = 1
						AND a.no_requis        = b.no_requis
						AND b.no_requis        = c.no_requis
						AND b.no_documento     = c.no_documento
						AND a.no_cheque        = d.no_recibo
						AND d.no_requis        = _no_remesa
						AND b.no_poliza        = d.no_poliza
					    AND a.no_requis        = e.no_requis
						AND a.fecha_anulado	   = e.fecha
					    AND e.cod_auxiliar		= v_aux_terc
					    AND e.cuenta           = '26410'
						AND c.cod_agente       = REPLACE(v_aux_terc,'A','0')

					SELECT cod_contratante
					  INTO _cod_cliente
					  FROM emipomae
					 WHERE no_poliza = _no_poliza;

					SELECT nombre
					  INTO v_nombre_clte
					  FROM cliclien
					 WHERE cod_cliente = _cod_cliente;					  
				   									
      insert into tmp_diferencia VALUES(       
						   t_periodo,
						   v_aux_terc,
						   v_nom_terc,
						   v_saldo_ant,
						   v_debito,
						   v_credito,
						   v_saldo,
						   v_monto,
						   v_periodo,
						   l_cia_nom,
						   l_nombre,
						   a_cuenta,
						   _fechatrx, 
						   _comprobante,
						   _descripcion, 
						   _debito, 
						   _credito, 
						   null,
						   null,
						   null,
						   null,
						   _no_remesa,
						   null,
						   _no_remesa2,
						   _renglon,
						   _no_poliza,
						   _no_recibo,
						   _no_documento,
						   trim(v_nombre_clte) || ' DEVOLUCION DE PRIMA ANULADA',
				           _debito_com,
					       _credito_com,
						   _fecha_com,
						   _fecha_desde_com,
						   _fecha_hasta_com,
						   _origen);
				end foreach   

			end foreach
		end if

	end foreach		   

--END FOREACH;

{FOREACH
	SELECT 	periodo,		
			cod_tercero,				
			nom_tercero,			
			cuenta_nombre,  
			cuenta,   
			fecha_asiento, 		
			comprobante, 	
			decripcion, 
			debito_c, 
			credito_c, 	
			sum(debito_cobros),
			sum(credito_cobros), 	
			origen 
	  INTO	t_periodo,
			v_aux_terc,
			v_nom_terc,
			l_nombre,
			a_cuenta,
			_fechatrx,
			_comprobante,
			_descripcion, 
			_debito, 
			_credito,
			_debito_com,
			_credito_com,
			_origen
	  FROM 	tmp_diferencia
	 WHERE  origen = "COB"
	GROUP BY periodo, cod_tercero, nom_tercero, cuenta_nombre, cuenta, fecha_asiento, comprobante, decripcion, debito_c, credito_c, origen
	ORDER BY fecha_asiento
	
	let _saldo_c = _debito + _credito;
	let _saldo_com = _debito_com + _credito_com;
	
	if _saldo_c <> _saldo_com then
		return  t_periodo,
				v_aux_terc,
				v_nom_terc,
				l_nombre,
				a_cuenta,
				_fechatrx,
				_comprobante,
				_descripcion, 
				_debito, 
				_credito,
				_debito_com,
				_credito_com with resume;
	end if
	
END FOREACH
}
FOREACH
	SELECT 	periodo,		
			cod_tercero,				
			nom_tercero,			
			cuenta_nombre,  
			cuenta,   
			fecha_asiento, 		
			comprobante, 	
			decripcion, 
			debito_c,
			credito_c, 	
			sum(debito_comis),
			sum(credito_comis), 	
			origen 
	  INTO	t_periodo,
			v_aux_terc,
			v_nom_terc,
			l_nombre,
			a_cuenta,
			_fechatrx,
			_comprobante,
			_descripcion, 
			_debito, 
			_credito,
			_debito_com,
			_credito_com,
			_origen
	  FROM 	tmp_diferencia
	 WHERE  origen = "CHE"
	GROUP BY periodo, cod_tercero, nom_tercero, cuenta_nombre, cuenta, fecha_asiento, comprobante, decripcion, debito_c, credito_c, origen
	ORDER BY fecha_asiento
	
	let _saldo_c = _debito - _credito;
	let _saldo_com = _debito_com - _credito_com;
	
	if _saldo_c <> _saldo_com then
		return  t_periodo,
				v_aux_terc,
				v_nom_terc,
				l_nombre,
				a_cuenta,
				_fechatrx,
				_comprobante,
				_descripcion, 
				_debito, 
				_credito,
				_debito_com,
				_saldo_c - _saldo_com with resume;
	end if
	
END FOREACH

DROP TABLE tmp_saldosat;
DROP TABLE tmp_diferencia;

END PROCEDURE  
