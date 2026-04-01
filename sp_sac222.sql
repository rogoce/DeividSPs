-- Consulta de Movimientos de Auxiliar Sac 
-- Creado    : 29/12/2008 -- Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_sac222('01','231020304','%','BQ089','2012','01','2012','01','sac')

DROP PROCEDURE sp_sac222;
CREATE PROCEDURE sp_sac222(a_tipo char(2),a_cuenta char(12),a_ccosto char(3),a_aux char(5),a_anio char(4),a_mes char(2),a_anio2 char(4),a_mes2 char(2),a_db CHAR(18)) 
RETURNING	char(12),		-- 	cuenta
			CHAR(15),		-- 	comprobante
			DATE,			-- 	fechatrx
			CHAR(30),		-- 	tipcomp
			CHAR(50),		-- 	descripcion
			DEC(15,2),		-- 	debito
			DEC(15,2),		-- 	credito
			DEC(15,2),		-- 	acumulado
			DEC(15,2),		-- 	total
			CHAR(3),		--  ORiGEN
			char(5), 		--  Reaseguro
			CHAR(50),     	-- 	nombre_Reaseguro	  
			CHAR(50),	  	-- 	cia				  
			CHAR(50),     	--  nombre_cuenta		 
			CHAR(7),	  	--  desde,				 
			CHAR(7),      	--  hasta				 
			CHAR(10),		--  numero_aux #Remesa
			DEC(15,2),		--  debito_aux
			DEC(15,2),		--  credito_aux
			char(15),		--  tipo_aux de transaccion
			CHAR(20),		--  documento
			CHAR(15)        --  origen

--comprobante 	 	 sac/detalle
--fecha			 	 sac/detalle
--tipo_comprobante 	 sac/detalle
--descripcion		 sac/detalle
--no_documento	 	 auxiliar
--origen			 auxiliar
--registro		 	 auxiliar
--debito			 auxiliar
--credito			 auxiliar

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
DEFINE v_linea			  INTEGER;
DEFINE v_norgt			  INTEGER;
DEFINE v_periodo          CHAR(100);
DEFINE v_total            DEC(15,2);  
DEFINE v_tipoing		  CHAR(2);
DEFINE v_ccosto           CHAR(3);
DEFINE v_saldo_ant        DEC(15,2);
DEFINE v_saldo_acum       DEC(15,2);
DEFINE psaldo5            DEC(15,2);
DEFINE v_anio_ant         SMALLINT;
DEFINE v_mes_ant          SMALLINT;
DEFINE _li_cnt            INTEGER;
define _fecha_inicial	  DATE;
define _fecha_final		  DATE;
define _mes_inic		  CHAR(2);
define _mes_fin			  CHAR(2);
define v_origen           CHAR(3);
define v_cuenta           CHAR(12);
define v_auxiliar         CHAR(5);
DEFINE v_descrip          CHAR(50);
define _orden			  SMALLINT;
DEFINE v_balance		  DEC(15,2);
DEFINE v_tipoc	          CHAR(30);
define _error			  INTEGER;
define _cnt_tab			  INTEGER;
define a_cuenta2          CHAR(12);
DEFINE v_anterior  		  DEC(15,2);
DEFINE _mes_ant  		  DEC(15,2);
define _neto              DEC(16,2);
DEFINE _cia_nom			  CHAR(50);
DEFINE l_nombre     	  CHAR(50);
DEFINE l_desde,l_hasta    CHAR(7);
DEFINE v_nom_terc		  CHAR(50);
DEFINE d_remesa			  CHAR(10);
DEFINE d_debito			  DEC(15,2);
DEFINE d_credito		  DEC(15,2);

DEFINE i_cuenta			char(12);
DEFINE i_comprobante	CHAR(15);
DEFINE i_fechatrx		DATE;
DEFINE i_no_registro    char(10);
DEFINE i_notrx			INTEGER;
DEFINE i_auxiliar		CHAR(5);
DEFINE i_debito			DEC(15,2);
DEFINE i_credito		DEC(15,2);
DEFINE i_origen			CHAR(15);
DEFINE i_no_documento	CHAR(20);
DEFINE i_no_poliza		CHAR(10);
DEFINE i_no_endoso		CHAR(5);
DEFINE i_no_remesa		CHAR(10);
DEFINE i_renglon		smallint;
DEFINE i_no_tranrec		CHAR(10);
DEFINE _mostrar         CHAR(10);
DEFINE _tipo            CHAR(15);
define _error_desc      char(100);
define _error_isam      integer;

--set debug file to "sp_sac222.trc";
----trace on;

SET ISOLATION TO DIRTY READ;


CREATE TEMP TABLE tmp_saldosac222(
    no_trx          INTEGER,
	linea           INTEGER,
	no_rgt          INTEGER,
	comp            CHAR(15),
	fecha           DATE,
	tipocomp        CHAR(30),
	debito          DEC(15,2)	default 0,
	credito        	DEC(15,2)	default 0,
	acumulado       DEC(15,2)   default 0,
	total           DEC(15,2)   default 0,
	tipo 			CHAR(2),
	ccosto 			CHAR(3),
	origen          CHAR(3),
	cuenta          char(12),
	auxiliar        char(5),
	descripcion		CHAR(50),
	orden			smallint
	) WITH NO LOG;

    CREATE INDEX isac1_tmp_saldosac222 ON tmp_saldosac222(cuenta);  
    CREATE INDEX isac2_tmp_saldosac222 ON tmp_saldosac222(orden);  
    CREATE INDEX isac3_tmp_saldosac222 ON tmp_saldosac222(fecha);  
    CREATE INDEX isac4_tmp_saldosac222 ON tmp_saldosac222(comp);  
    CREATE INDEX isac5_tmp_saldosac222 ON tmp_saldosac222(tipocomp);  
    CREATE INDEX isac6_tmp_saldosac222 ON tmp_saldosac222(origen);  
    CREATE INDEX isac7_tmp_saldosac222 ON tmp_saldosac222(auxiliar);  
    CREATE INDEX isac8_tmp_saldosac222 ON tmp_saldosac222(descripcion);  

CREATE TEMP TABLE tmp_reasiento(
		cuenta			char(12),
		comprobante		char(15),
		fechatrx		date,
		no_registro		CHAR(10),
		auxiliar     	char(5),
		debito			DEC(15,2)   default 0,
		credito			DEC(15,2)   default 0,
		origen          char(15),
		no_documento	char(20),
		no_poliza       char(10),
		no_endoso       char(5),
		no_remesa		char(10),
		renglon			smallint,
		no_tranrec		char(10),
		notrx           integer,
		mostrar			char(10),
		tipo            char(15)
		) WITH NO LOG; 	
BEGIN
ON EXCEPTION SET _error,_error_isam,_error_desc 
--	DROP TABLE tmp_saldosac222; 
--	DROP TABLE tmp_asiento;
  {	trace on;
	let _error = _error;
	let _error_desc = _error_desc;
	trace off; }
	RETURN '', 				
		   '', 				
		   current, 		
		   '',				
		   '',				
		   0,				
	       0,				
		   0,  				
		   0,				
		   '',				
		   '',				
		   '',				
		   '',				
		   '',				
		   '',				
		   '',				
		   '',				
		   0,				
		   0,				
		   '',
		   '',
		   ''
		   WITH RESUME;         
end exception

LET v_saldo      = 0;
LET psaldo5      = 0;
LET v_saldo_ant  = 0;
LET v_saldo_acum = 0;
let v_cuenta     = a_cuenta;
let v_auxiliar   = a_aux;
LET _orden       = 0;

select cia_nom
  into _cia_nom
  from deivid:sigman02
 where cia_bda_codigo = a_db;

SELECT cta_nombre
  INTO l_nombre
  FROM cglcuentas
 WHERE cta_cuenta = a_cuenta;

SELECT ter_descripcion
  INTO v_nom_terc
  FROM cglterceros
 WHERE ter_codigo = a_aux;

IF v_nom_terc IS NULL THEN
   LET v_nom_terc = " " ;
END IF

if a_mes = "*" then
	
	let _mes_inic = "01";
	let _mes_fin  = "12";

else

	if a_mes < "10" then
	   if length(a_mes) = 1 then
			let  v_speriodo = "0" || a_mes;
	   end if
	end if

	let v_speriodo = a_mes;
	let _mes_inic = v_speriodo;
	let _mes_fin  = v_speriodo;
	let a_mes = v_speriodo;
end if

let _fecha_inicial = mdy(_mes_inic, 1, a_anio);

if 	a_mes = "*" then
	let _fecha_final   = sp_sis36(a_anio || "-" || _mes_fin);  -- aun mantengo la busqueda por *
else
	let _fecha_final   = sp_sis36(a_anio2 || "-" || a_mes2);
end if

let l_desde	=  a_anio || "-" || a_mes;
let l_hasta =  a_anio2 || "-" || a_mes2;


LET v_saldo_inicial = 0;
LET v_anio_ant      = a_anio - 1;

SELECT cglsaldoaux.sld_incioano
  INTO v_saldo_ant
  FROM cglsaldoaux
 WHERE ( cglsaldoaux.sld_tipo    like a_tipo )  AND
       ( cglsaldoaux.sld_cuenta  = a_cuenta )   AND
       ( cglsaldoaux.sld_tercero = a_aux )      AND
       ( cglsaldoaux.sld_ano     = a_anio ) ; 

IF v_saldo_ant IS NULL THEN
	LET v_saldo_ant = 0;
END IF

if 	a_mes = "01" or a_mes = "*" then
    LET psaldo5    = 0;
else
	LET v_anio_ant = a_anio ;
	LET v_mes_ant  = a_mes - 1 ;
	LET psaldo5    = 0;

	SELECT sum(sld1_debitos + sld1_creditos)
	  INTO  psaldo5
	  FROM cglsaldoaux1
	 WHERE sld1_tipo    = "01"
	   AND sld1_cuenta  = a_cuenta
	   AND sld1_tercero = a_aux
	   AND sld1_ano     = v_anio_ant
	   AND sld1_periodo <= v_mes_ant;

	IF psaldo5 IS NULL THEN
		LET psaldo5 = 0;
	END IF

end if

LET v_saldo_inicial = psaldo5 + v_saldo_ant ;
LET v_saldo = v_saldo_inicial;	

LET _mostrar  = '';
LET d_debito  = 0;
LET d_credito = 0;
LET _tipo     = '';

FOREACH
  SELECT cglresumen.res_notrx,   
         cglresumen1.res1_linea,   
         cglresumen1.res1_noregistro,   
         cglresumen.res_comprobante,   
         cglresumen.res_fechatrx,   
         cglresumen.res_tipcomp,   
         cglresumen1.res1_debito,   
         cglresumen1.res1_credito,
		 cglresumen1.res1_tipo_resumen,
		 cglresumen.res_ccosto,
		 cglresumen.res_origen
    INTO v_notrx,
	     v_linea,
		 v_norgt,
	     v_comp,
		 v_fecha,
		 v_tipo,
		 v_debito,
	     v_credito,
         v_tipoing,
		 v_ccosto,
		 v_origen
    FROM cglresumen1,   
         cglresumen  
   WHERE ( cglresumen.res_noregistro = cglresumen1.res1_noregistro ) and  
         ( cglresumen1.res1_cuenta = a_cuenta ) AND  
         ( cglresumen1.res1_tipo_resumen like a_tipo ) AND  
         ( cglresumen1.res1_auxiliar = a_aux ) AND  
         ( cglresumen.res_ccosto like a_ccosto ) AND		 
         ( cglresumen.res_fechatrx >= _fecha_inicial ) AND
         ( cglresumen.res_fechatrx <= _fecha_final )  
  order by res_fechatrx, res_comprobante, res_tipcomp, res_origen

				let v_descrip = " ";

				if v_tipo = "021" then --ASIENTOS DE CIERRES
				   let _orden = 1;
				else
				   let _orden = 0;
				end if

				foreach
				 select res_descripcion
				   into v_descrip
				   from cglresumen
				  where res_cuenta      = a_cuenta
				    and res_fechatrx   >= _fecha_inicial 
				    and res_fechatrx   <= _fecha_final
				    and res_comprobante	= v_comp
				    and res_tipcomp     = v_tipo
				    and res_origen		= v_origen 
				  order by res_fechatrx, res_comprobante, res_tipcomp, res_origen
					exit foreach;
				end foreach

			   	IF v_descrip IS NULL THEN
					LET v_descrip = "";
				END IF

				SELECT con_descrip
				  into v_tipoc
				  FROM cglconcepto   
				 WHERE con_codigo = v_tipo ;

--				LET v_saldo = v_saldo + v_debito - v_credito;

				INSERT INTO tmp_saldosac222(
				no_trx,
				linea, 
				no_rgt, 
				comp,
				fecha,
				tipocomp,
				debito,
				credito,
				acumulado,
				total,
				tipo,
				ccosto,
				origen,
				cuenta,
				auxiliar,
				descripcion,
				orden )
				VALUES(	v_notrx,
				 v_linea,
				 v_norgt,
				 v_comp,
				 v_fecha,
				 v_tipoc,
				 v_debito,
				 v_credito,
				 v_saldo,
				 0.00,
				 v_tipoing,
				 v_ccosto,
				 v_origen,
				 v_cuenta,
				 v_auxiliar,
				 v_descrip,
				 _orden);

END FOREACH;

select count(*) 
  into _li_cnt
  from tmp_saldosac222;

if _li_cnt = 0 then
	INSERT INTO tmp_saldosac222(
	no_trx,
	linea, 
	no_rgt, 
	comp,
	fecha,
	tipocomp,
	debito,
	credito,
	acumulado, 
	total, 
	tipo, 
	ccosto, 
	origen, 
	cuenta, 
	auxiliar, 
    descripcion,
	orden )
	VALUES(	
	0,
	0,
	0,
	'',
	current,
	'',
	0,
	0,
	0,
	0.00,
	'',
	'',
	'',
	'',
	'',
	'',
	1);
end if

-----trace off;

LET v_balance = psaldo5 + v_saldo_ant ;

update tmp_saldosac222
   set total  = v_balance ;

-----****

FOREACH	
  SELECT DISTINCT cuenta,
		 fecha,
		 auxiliar,
		 comp,
		 origen
	INTO v_cuenta,
		 v_fecha,
		 v_auxiliar,
		 v_comp,
		 i_origen
    FROM tmp_saldosac222
   ORDER BY cuenta, fecha, comp, auxiliar 


		FOREACH	
			select a.cuenta,
			a.fecha,
			a.no_registro,
			a.cod_auxiliar,
			a.debito,
			a.credito,
			decode(c.tipo_registro,"1","PRODUCCION","2","COBROS","3","RECLAMOS"),
			c.no_documento,
			c.no_poliza,
			c.no_endoso,
			c.no_remesa,
			c.renglon,
			c.no_tranrec,
			b.sac_notrx
			into i_cuenta,
				 i_fechatrx,
				 i_no_registro,
				 i_auxiliar,
				 i_debito,
				 i_credito,
				 i_origen,
				 i_no_documento,
				 i_no_poliza,
				 i_no_endoso,
				 i_no_remesa,
				 i_renglon,
				 i_no_tranrec,
				 i_notrx
			from sac999:reacompasiau a, sac999:reacompasie b, sac999:reacomp c
			where a.periodo = b.periodo
			and a.cuenta = b.cuenta
			and a.tipo_comp = b.tipo_comp
			and a.no_registro = b.no_registro
			and a.no_registro = c.no_registro
			and a.cod_auxiliar = v_auxiliar    
			and a.cuenta = v_cuenta          
			and a.fecha = v_fecha

				LET _mostrar = "";

				if trim(i_origen) = "PRODUCCION" then
					LET _tipo = 'No. Factura';
					 SELECT no_factura
					   INTO _mostrar
					   FROM endedmae
					  WHERE no_poliza = i_no_poliza
					    AND	no_endoso = i_no_endoso
					    AND actualizado = 1	  ;	 
				end if
				if trim(i_origen) = "COBROS" then
					LET _tipo = 'No. Remesa';
					 LET _mostrar = i_no_remesa;
			    end if
				if trim(i_origen) = "RECLAMOS" then
					LET _tipo = 'No. transaccion';
					 SELECT transaccion
					   INTO _mostrar
					   FROM deivid:rectrmae
					  WHERE no_tranrec = i_no_tranrec
					    AND actualizado = 1;
				end if

				INSERT INTO tmp_reasiento (
				cuenta,
				comprobante,
				fechatrx,
				no_registro,
				auxiliar,
				debito,
				credito,
				origen,
				no_documento,
				no_poliza,
				no_endoso,
				no_remesa,
				renglon,
				no_tranrec,
				notrx,
				mostrar,
				tipo
				 )
				VALUES (
				i_cuenta,
				v_comp,		
				i_fechatrx,
				i_no_registro,
				i_auxiliar,
				i_debito,
				i_credito,
				i_origen,
				i_no_documento,
				i_no_poliza,
				i_no_endoso,
				i_no_remesa,
				i_renglon,
				i_no_tranrec,
				i_notrx,
				_mostrar,
				_tipo
				);
		   
		END FOREACH;

END FOREACH;

-----****

FOREACH	
  SELECT cuenta,
		 comp,
		 fecha,
		 tipocomp,
		 descripcion,
		 auxiliar,
		 sum(debito),
		 sum(credito),
		 sum(acumulado),
		 sum(total),
		 origen,
		 orden
	INTO v_cuenta,
		 v_comp,
		 v_fecha,
		 v_tipoc,
		 v_descrip,
		 v_auxiliar,
		 v_debito,
	     v_credito,
		 v_saldo,
		 v_total,
		 v_origen,
		 _orden
    FROM tmp_saldosac222
   group by cuenta,orden, fecha, comp, tipocomp, origen ,auxiliar ,descripcion
   order by cuenta,orden, fecha, comp, tipocomp, origen ,auxiliar ,descripcion

   LET v_balance = v_balance + v_debito - v_credito ;

{  RETURN  v_cuenta,
		  v_comp,
		  v_fecha,
		  v_tipoc,
		  v_descrip,
		  v_debito,
	      v_credito,
		  v_balance,  
		  v_total,
		  v_origen,
		  v_auxiliar,
		  v_nom_terc,
		  _cia_nom,
		  l_nombre,
		  l_desde,
		  l_hasta,
		  _mostrar,
		  d_debito,
		  d_credito,
		  _tipo	
     WITH RESUME;}


		FOREACH	
		  SELECT mostrar,
				 tipo,
				 no_documento,
				 origen,
				 sum(debito),
				 sum(credito)
			INTO _mostrar,
				 _tipo,
				 i_no_documento,
				 i_origen,
				 d_debito,
			     d_credito
		    FROM tmp_reasiento
		   where cuenta      = v_cuenta
			 and fechatrx    = v_fecha
			 and auxiliar    = v_auxiliar
		   group by mostrar,tipo,no_documento,origen
		   order by mostrar,tipo,no_documento,origen

		  RETURN   v_cuenta,
				   v_comp,
				   v_fecha,
				   v_tipoc,
				   v_descrip,
				   v_debito,
			       v_credito,
				   v_balance,  
				   v_total,
				   v_origen,
				   v_auxiliar,
				   v_nom_terc,
				   _cia_nom,
				   l_nombre,
				   l_desde,
				   l_hasta,
				   _mostrar,
				   d_debito,
				   d_credito,
				   _tipo,
				   i_no_documento,
				   i_origen
		    	 WITH RESUME;

		END FOREACH;



END FOREACH;

DROP TABLE tmp_saldosac222;
DROP TABLE tmp_reasiento;

end
END PROCEDURE					 				 


