

CREATE PROCEDURE sp_sac198(a_tipo char(2),a_cuenta char(12),a_ccosto char(3),a_aux char(5),a_anio char(4),a_mes char(2),a_anio2 char(4),a_mes2 char(2),a_db CHAR(18))
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
			CHAR(7),
            CHAR(10) ;     	--  hasta				 

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
DEFINE _li_cnt            integer;
define _fecha_inicial	  date;
define _fecha_final		  date;
define _mes_inic		  char(2);
define _mes_fin			  char(2);
define v_origen           CHAR(3);
define v_cuenta           char(12);
define v_auxiliar         char(5);
DEFINE v_descrip          CHAR(50);
define _orden			  SMALLINT;
DEFINE v_balance		  DEC(15,2);
DEFINE v_tipoc	          CHAR(30);
define _error			  integer;
define _cnt_tab			  integer;
define a_cuenta2          char(12);
DEFINE v_anterior  		  DEC(15,2);
DEFINE _mes_ant  		  DEC(15,2);
define _neto              DEC(16,2);
DEFINE _cia_nom			  char(50);
DEFINE l_nombre     	  char(50);
DEFINE l_desde,l_hasta    char(7);
DEFINE v_nom_terc		  CHAR(50);

DEFINE vd_cuenta 	char(12);
DEFINE vd_comprobante 	char(15);
DEFINE vd_fecha	DATE;
DEFINE vd_requisicion	CHAR(10);
DEFINE vd_debito	DEC(15,2);
DEFINE vd_credito	DEC(15,2);
DEFINE vd_neto	DEC(15,2);



--set debug file to "sp_sac198.trc";
--trace on;

SET ISOLATION TO DIRTY READ;


CREATE TEMP TABLE tmp_saldosac198(
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

    CREATE INDEX isac1_tmp_saldosac198 ON tmp_saldosac198(cuenta);  
    CREATE INDEX isac2_tmp_saldosac198 ON tmp_saldosac198(orden);  
    CREATE INDEX isac3_tmp_saldosac198 ON tmp_saldosac198(fecha);  
    CREATE INDEX isac4_tmp_saldosac198 ON tmp_saldosac198(comp);  
    CREATE INDEX isac5_tmp_saldosac198 ON tmp_saldosac198(tipocomp);  
    CREATE INDEX isac6_tmp_saldosac198 ON tmp_saldosac198(origen);  
    CREATE INDEX isac7_tmp_saldosac198 ON tmp_saldosac198(auxiliar);  
    CREATE INDEX isac8_tmp_saldosac198 ON tmp_saldosac198(descripcion);  

begin
on exception set _error
	DROP TABLE tmp_saldosac198;
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
	let _mes_inic  = v_speriodo;
	let _mes_fin   = v_speriodo;
	let a_mes      = v_speriodo;
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

				INSERT INTO tmp_saldosac198(
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
from tmp_saldosac198;

if _li_cnt = 0 then
	INSERT INTO tmp_saldosac198(
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

--trace off;

LET v_balance = psaldo5 + v_saldo_ant ;

update  tmp_saldosac198
set total  = v_balance ;

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
	FROM tmp_saldosac198
	group by cuenta,orden, fecha, comp, tipocomp, origen ,auxiliar ,descripcion
	order by cuenta,orden, fecha, comp, tipocomp, origen ,auxiliar ,descripcion

  	  LET v_balance = v_balance + v_debito - v_credito ;
	  let vd_requisicion = '';
	 if v_comp[1,3] = 'CHE' and trim(v_auxiliar) = 'A0035' and trim(v_cuenta) = '26410' then

	    FOREACH EXECUTE PROCEDURE sp_sac187a(v_cuenta,v_comp,v_fecha,v_auxiliar)
			 INTO vd_cuenta,vd_comprobante,vd_fecha,vd_requisicion,vd_debito,vd_credito,vd_neto		
		  

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
		   vd_requisicion
    	 WITH RESUME;
		 let vd_requisicion = '';
		 end foreach;
else


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
		   vd_requisicion
    	 WITH RESUME;
       end if
END FOREACH;

DROP TABLE tmp_saldosac198;
end
END PROCEDURE					 				 
                                                           
             
