-- Consulta de Movimientos de Cuentas Sac 
-- Creado    : 29/12/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	

DROP PROCEDURE sp_sac96;
CREATE PROCEDURE sp_sac96(a_tipo char(2),a_cuenta char(12),a_ccosto char(3),a_anio char(4),a_mes char(2), a_anio2 char(4),a_mes2 char(2),a_cuenta2 char(12))
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
			dec(16,2);		--  neto

DEFINE v_debito           DEC(15,2);
DEFINE v_credito          DEC(15,2);
DEFINE v_saldo            DEC(15,2);
DEFINE v_balance		  DEC(15,2);
DEFINE v_speriodo         CHAR(2);
DEFINE v_notrx			  INTEGER;
DEFINE v_comp			  CHAR(15);
DEFINE v_f_inicio		  DATE;
DEFINE v_f_final    	  DATE;
DEFINE v_fecha			  DATE;
DEFINE v_tipo	          CHAR(3);
DEFINE v_tipoc	          CHAR(30);
DEFINE v_saldo_inicial    DEC(15,2);
DEFINE v_leido		      DEC(15,2);
DEFINE v_total            DEC(15,2);
DEFINE v_periodo          CHAR(100);
DEFINE v_descrip          CHAR(50);
DEFINE v_tipoing		  CHAR(2);
DEFINE v_ccosto           CHAR(3);
DEFINE v_cuenta           CHAR(12);
DEFINE _fecha_inicial     DATE;
DEFINE _fecha_final		  DATE;
DEFINE v_origen           CHAR(3);

DEFINE v_anterior  		  DEC(15,2);
DEFINE _mes_ant  		  DEC(15,2);
define _orden			  SMALLINT;
define _neto              DEC(16,2);

SET ISOLATION TO DIRTY READ;

{1:
select res_comprobante,res_fechatrx,res_tipcomp,res_descripcion,sum(res_debito),sum(res_credito)
from cglresumen
where res_cuenta = '121020402'
and res_comprobante = 'COB01101'
and res_fechatrx >= '01/01/2010' and res_fechatrx <= '30/01/2010'
group by res_comprobante,res_fechatrx,res_tipcomp,res_descripcion
order by res_comprobante,res_fechatrx,res_tipcomp,res_descripcion
}
{2:
select res_comprobante,res_fechatrx,res_notrx,res_noregistro,res_origen,res_debito,res_credito
from cglresumen
where res_cuenta = '121020402'
and res_comprobante = 'COB01101'
and res_fechatrx = '04/01/2010'
order by res_comprobante,res_fechatrx,res_notrx,res_noregistro,res_origen
}
{3:
select no_remesa,sum(debito),sum(credito)  ,sum(debito) - sum(credito)
from deivid:cobasien
where sac_notrx = '52882'
and cuenta = '121020402'
group by no_remesa
}
{4:
select no_remesa,renglon,debito,credito,debito - credito
from deivid:cobasien
where sac_notrx = '52882'
and cuenta = '121020402'
}

CREATE TEMP TABLE tmp_saldosac(
		cuenta			char(12),
		comprobante		CHAR(15),
		fechatrx		DATE,
		tipcomp			CHAR(30),
		descripcion		CHAR(50),
		debito			DEC(15,2)   default 0,
		credito			DEC(15,2)   default 0,
		acumulado       DEC(15,2)   default 0,
		total           DEC(15,2)   default 0,
		origen			CHAR(3),
		orden			smallint
		) WITH NO LOG;

      CREATE INDEX isac1_tmp_saldosac ON tmp_saldosac(orden);
      CREATE INDEX isac2_tmp_saldosac ON tmp_saldosac(fechatrx);
      CREATE INDEX isac3_tmp_saldosac ON tmp_saldosac(comprobante);
      CREATE INDEX isac4_tmp_saldosac ON tmp_saldosac(origen);

  --set debug file to "sp_sac96.trc";
  --trace on;

  LET v_saldo = 0;
  LET _orden = 0;
  LET v_balance = 0;
  let _neto = 0;

  if a_mes < 10 then
		if  a_mes[2] is null then
	    	let  v_speriodo = "0" || a_mes[1];
		else
	    	let  v_speriodo = "0" || a_mes[2];
		end if
  else
    	let  v_speriodo = a_mes;
  end if

  let _fecha_inicial = mdy(a_mes, 1, a_anio);
  let _fecha_final   = sp_sis36(a_anio2 || "-" || a_mes2);

  SELECT cglperiodo.per_inicio,
         cglperiodo.per_final,
		 cglperiodo.per_descrip
    INTO v_f_inicio,
		 v_f_final,
		 v_periodo
    FROM cglperiodo
   WHERE ( cglperiodo.per_ano = a_anio ) AND
         ( cglperiodo.per_mes = v_speriodo ) ;

let  v_saldo_inicial = 0;

if a_ccosto = "%" then
		FOREACH
		    SELECT cglsaldoctrl.sld_incioano
		    INTO v_leido
			FROM cglsaldoctrl
			WHERE  ( cglsaldoctrl.sld_tipo like a_tipo ) AND
				 ( cglsaldoctrl.sld_cuenta >= a_cuenta ) AND
				 ( cglsaldoctrl.sld_cuenta <= a_cuenta2 ) AND
				 ( cglsaldoctrl.sld_ccosto like a_ccosto ) AND
				 ( cglsaldoctrl.sld_ano = a_anio )

			IF v_leido IS NULL THEN
				LET v_leido = 0;
			END IF

			let  v_saldo_inicial = v_saldo_inicial + v_leido ;
		END FOREACH;
else
  SELECT cglsaldoctrl.sld_incioano
    INTO v_saldo_inicial
	FROM cglsaldoctrl
	WHERE  ( cglsaldoctrl.sld_tipo like a_tipo ) AND
		 ( cglsaldoctrl.sld_cuenta >= a_cuenta ) AND
		 ( cglsaldoctrl.sld_cuenta <= a_cuenta2 ) AND
		 ( cglsaldoctrl.sld_ccosto like a_ccosto ) AND
		 ( cglsaldoctrl.sld_ano = a_anio ) ;
end if

IF v_saldo_inicial  IS NULL THEN
	LET v_saldo_inicial = 0;
END IF

LET v_anterior = 0;
LET _mes_ant = 0;

if a_mes > 1 then
	LET _mes_ant = a_mes - 1;
	SELECT sum(cglresumen.res_debito-cglresumen.res_credito)
	INTO v_anterior
	FROM cglresumen
	WHERE ( cglresumen.res_cuenta >= a_cuenta ) AND
		 ( cglresumen.res_cuenta <= a_cuenta2 ) AND
	     ( cglresumen.res_tipo_resumen like a_tipo ) AND
	     ( cglresumen.res_ccosto like a_ccosto) AND
	     ( year(cglresumen.res_fechatrx) = a_anio) AND
	     ( month(cglresumen.res_fechatrx) <= _mes_ant ) ;

	IF v_anterior IS NULL THEN
		LET v_anterior = 0;
	END IF
end if

LET v_saldo = v_saldo_inicial + v_anterior ;

foreach
 select res_comprobante,
 		res_fechatrx,
 		res_tipcomp,
 		res_origen,
 		sum(res_debito),
 		sum(res_credito)
   into v_comp,
	    v_fecha,
	    v_tipo,
	    v_origen,
	    v_debito,
        v_credito
   from cglresumen
  where res_cuenta   >= a_cuenta
	and	res_cuenta   <= a_cuenta2
    and res_fechatrx >= _fecha_inicial
    and res_fechatrx <= _fecha_final
  group by res_fechatrx, res_comprobante, res_tipcomp, res_origen
  order by res_fechatrx, res_comprobante, res_tipcomp, res_origen

	if v_tipo = "021" then --ASIENTOS DE CIERRE
	   let _orden = 1;
	else
	   let _orden = 0;
	end if

	foreach
	 select res_descripcion
	   into v_descrip
	   from cglresumen
	  where res_cuenta     >= a_cuenta
	    and	res_cuenta     <= a_cuenta2
	    and res_tipcomp     = v_tipo
	    and res_fechatrx   >= _fecha_inicial
	    and res_fechatrx   <= _fecha_final
	    and res_comprobante	= v_comp
	    and res_origen		= v_origen
	  order by res_fechatrx, res_comprobante, res_tipcomp, res_origen
		exit foreach;
	end foreach

--  	  LET v_saldo = v_saldo + v_debito - v_credito ;

	  SELECT con_descrip
	    into v_tipoc
	    FROM cglconcepto
	   WHERE con_codigo = v_tipo ;

		INSERT INTO tmp_saldosac(
		cuenta,
		comprobante,
		fechatrx,
		tipcomp,
		descripcion,
		debito,
		credito,
		acumulado,
		total,
		origen,
		orden )
		VALUES (a_cuenta,
		   v_comp,
		   v_fecha,
		   v_tipoc,
		   v_descrip,
		   v_debito,
	       v_credito,
		   v_saldo,
		   0.00,
		   v_origen,
		   _orden
		   );

--  LET v_saldo = v_saldo + v_debito - v_credito;

end foreach;

LET  v_balance =  v_saldo_inicial + v_anterior ;

update  tmp_saldosac
set total  = v_balance ;

FOREACH
	SELECT cuenta,
		   comprobante,
		   fechatrx,
		   tipcomp,
		   descripcion,
		   debito,
		   credito,
		   acumulado,
		   total,
		   origen
	  INTO v_cuenta,
		   v_comp,
		   v_fecha,
		   v_tipoc,
		   v_descrip,
		   v_debito,
		   v_credito,
		   v_saldo,
		   v_total,
		   v_origen
	  FROM tmp_saldosac
	 order by orden, fechatrx, comprobante, tipcomp, origen

	LET v_balance = v_balance + v_debito - v_credito;
	let _neto     = v_debito - v_credito;

  RETURN v_cuenta,
  		 v_comp,
  		 v_fecha,
  		 v_tipoc,
  		 v_descrip,
  		 v_debito,
  		 v_credito,
  		 v_balance,  --v_saldo,
  		 v_total,
  		 v_origen,
  		 _neto
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_saldosac;
END PROCEDURE



                                                                                                                                                                                                                             
