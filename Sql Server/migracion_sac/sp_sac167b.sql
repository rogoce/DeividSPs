-- Consulta de Saldos de terceros por cuenta
-- Creado    : 10/02/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_sac167;
CREATE PROCEDURE sp_sac167(a_tipo char(2),a_cuenta char(12),a_aux char(5),a_anio char(4),a_mes smallint,a_db CHAR(18)) 
RETURNING   CHAR(7),	--  periodo
			CHAR(5),	--  tercero
			CHAR(50),	--  Nombre
			DEC(15,2),  --  Monto Sld Inicial 
			DEC(15,2),  --  Monto Debito 
			DEC(15,2),	--  Monto Credito 
			DEC(15,2),	--  Monto Acumulado 	
			CHAR(100),	--  periodo nombre
			CHAR(50),	--  cia
			CHAR(50);   --  cuenta

DEFINE v_debito           DEC(15,2);
DEFINE v_credito          DEC(15,2);	
DEFINE v_monto            DEC(15,2);
DEFINE v_monto_a          DEC(15,2);
DEFINE v_saldo            DEC(15,2);
DEFINE v_saldo_ant        DEC(15,2);
DEFINE v_saldo_acum       DEC(15,2);
DEFINE v_anio_ant         SMALLINT;
DEFINE v_periodo          CHAR(100);
DEFINE v_speriodo         CHAR(2);
DEFINE v_valor            SMALLINT;
DEFINE t_periodo          CHAR(7);
DEFINE v_aux_terc		  CHAR(5);
DEFINE v_nom_terc		  CHAR(50);
DEFINE l_cia_nom		  char(50);
DEFINE l_nombre     	  char(50);
DEFINE _fecha1    		  DATE;
DEFINE _fecha2    		  DATE;
DEFINE pdebitos1          DEC(15,2);
DEFINE pcreditos1		  DEC(15,2);
DEFINE ptotal1		      DEC(15,2);
DEFINE pdebitos2          DEC(15,2);
DEFINE pcreditos2		  DEC(15,2);
DEFINE ptotal2		      DEC(15,2);
DEFINE v_encontro         smallint;


SET ISOLATION TO DIRTY READ;

--set debug file to "sp_sac167.trc";
--trace on;

--DROP TABLE tmp_saldosat;
Let a_aux = '*';

CREATE TEMP TABLE tmp_saldosat(
	    periodo         CHAR(100),
		tercero         CHAR(3),
		nombre			CHAR(50),
		inicial         DEC(15,2)	default 0,
		debito          DEC(15,2)	default 0,
		credito         DEC(15,2)	default 0,
		acumulado       DEC(15,2)	default 0,
		cia				CHAR(50),
		cuenta			CHAR(50)
		) WITH NO LOG; 	


if a_mes < 10 then
	let  v_speriodo = "0" || a_mes;
else 
	let  v_speriodo = a_mes;
end if

SELECT cia_nom
  INTO l_cia_nom
  FROM deivid:sigman02
 WHERE cia_bda_codigo = a_db;

SELECT cta_nombre
  INTO l_nombre
  FROM cglcuentas
 WHERE cta_cuenta = a_cuenta;

SELECT per_descrip  
INTO v_periodo
FROM cglperiodo  
WHERE per_ano = a_anio 
AND   per_mes = v_speriodo ;

LET t_periodo =  a_anio||"-"||v_speriodo ;

let _fecha1 = mdy(a_mes, 1, a_anio);	
let _fecha2 = sp_sis36(a_anio || "-" || a_mes) ;

FOREACH
	select aux_tercero 
	into v_aux_terc
	from cglauxiliar where aux_cuenta = a_cuenta and aux_tercero = "A0001"

		LET v_saldo = 0;
		LET v_saldo_ant = 0;
		LET v_saldo_acum = 0;
		LET v_debito = 0;
		LET v_credito = 0;
		LET v_monto = 0;
		LET v_saldo_ant = 0 ;
		LET v_encontro = 0;
		LET pdebitos1 = 0;
		LET pcreditos1  = 0;
		LET ptotal1	 = 0;
		LET pdebitos2  = 0;
		LET pcreditos2  = 0;

		LET v_anio_ant = a_anio;

		FOREACH
			select b.res1_debito,
			      b.res1_credito
			 into pdebitos1,
			      pcreditos1
			 from cglresumen a, cglresumen1 b
			where a.res_noregistro = b.res1_noregistro
			  and a.res_cuenta     = b.res1_cuenta
			  and b.res1_auxiliar   = v_aux_terc
			  and a.res_cuenta     = a_cuenta
			  and a.res_fechatrx   < _fecha1 

			select ter_descripcion
			into v_nom_terc
			from cglterceros
			where ter_codigo = v_aux_terc;

			IF v_nom_terc IS NULL THEN
			 LET v_nom_terc = " " ;
			END IF

			LET v_encontro = 1 ;

			IF pdebitos1 IS NULL THEN
			 LET pdebitos1 = 0 ;
			END IF

			IF pdebitos1 IS NULL THEN
			 LET pdebitos1 = 0 ;
			END IF

			LET v_saldo_ant = pdebitos1 - pdebitos1 ;

			IF v_saldo_ant IS NULL THEN
			 LET v_saldo_ant = 0 ;
			END IF


		END FOREACH

		if v_encontro = 1 then

			LET v_saldo = v_saldo_ant ;

			FOREACH
				select b.res1_debito,
				      b.res1_credito
				 into pdebitos2,
				      pcreditos2
				 from cglresumen a, cglresumen1 b
				where a.res_noregistro = b.res1_noregistro
				  and a.res_cuenta     = b.res1_cuenta
				  and b.res1_auxiliar  = v_aux_terc
				  and a.res_cuenta     = a_cuenta
				  and a.res_fechatrx   >= _fecha1
				  and a.res_fechatrx   <= _fecha2 

				IF pdebitos2 IS NULL THEN
				 LET pdebitos2 = 0 ;
				END IF

				IF pdebitos2 IS NULL THEN
				 LET pdebitos2 = 0 ;
				END IF

				let v_debito = v_debito + pdebitos2;
				let v_credito = v_credito + pcreditos2;

				IF v_debito IS NULL THEN
				 LET v_debito = 0 ;
				END IF

				IF v_credito IS NULL THEN
				 LET v_credito = 0 ;
				END IF

				LET ptotal2 = pdebitos2 - pcreditos2 ;

				IF ptotal2 IS NULL THEN
				 LET ptotal2 = 0 ;
				END IF

			END FOREACH

			LET v_saldo = v_saldo + v_debito + v_credito;
		end if
	   
		INSERT INTO tmp_saldosat(
			periodo,
			tercero,
			nombre,
			inicial,
			debito,
			credito,
			acumulado,
			cia,
			cuenta )
		VALUES(	v_periodo,
			 v_aux_terc,
			 v_nom_terc,
			 v_saldo_ant,
			 v_debito,
		     v_credito,
			 v_saldo,
			 l_cia_nom,
			 l_nombre ) ;

END FOREACH;

FOREACH	
  SELECT periodo,
		 tercero,
		 nombre,
		 inicial,
		 debito,
		 credito,
		 acumulado,
		 cia,
		 cuenta
	INTO t_periodo,
		 v_aux_terc,
		 v_nom_terc,
		 v_saldo_ant,
	     v_debito,
	     v_credito,
	     v_saldo,
		 l_cia_nom,
		 l_nombre 
    FROM tmp_saldosat
	where inicial <> 0 and debito <> 0 and credito <> 0 and acumulado <> 0

  RETURN v_periodo,
		 v_aux_terc,
		 v_nom_terc,
		 v_saldo_ant,
	     v_debito,
	     v_credito,
		 v_saldo,
		 v_periodo,
		 l_cia_nom,
		 l_nombre 
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_saldosat;
END PROCEDURE	