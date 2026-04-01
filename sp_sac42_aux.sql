-- Consulta de Saldos de terceros por cuenta
-- Creado    : 10/02/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	 d_sac_aud_sldaux_rep

DROP PROCEDURE sp_sac42_aux;
CREATE PROCEDURE sp_sac42_aux(a_tipo char(2),a_cuenta char(12),a_aux char(5),a_anio char(4),a_mes smallint,a_db CHAR(18)) 
returning	integer,
			varchar(100);	

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
DEFINE l_cia_nom		  CHAR(50);
DEFINE l_nombre     	  CHAR(50);
DEFINE _fecha    		  DATE;
define _cuenta            char(12);

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_sac167.trc";
--trace on;

--DROP TABLE tmp_saldos;
--Let a_aux = '*';
			
{
drop table if exists tmp_saldos;
CREATE TEMP TABLE tmp_saldos(
	    periodo         CHAR(100),
		tercero         CHAR(5),
		nombre			CHAR(50),
		inicial         DEC(15,2)	default 0,
		debito          DEC(15,2)	default 0,
		credito         DEC(15,2)	default 0,   
		neto            DEC(15,2)	default 0,
		acumulado       DEC(15,2)	default 0,
		cia				CHAR(50),
		nom_cuenta		CHAR(50),
		cuenta          char(12)
		) WITH NO LOG; 	
}

if a_mes < 10 then
	let  v_speriodo = "0" || a_mes;
else 
	let  v_speriodo = a_mes;
end if

SELECT cia_nom
  INTO l_cia_nom
  FROM deivid:sigman02
 WHERE cia_bda_codigo = a_db;

SELECT per_descrip  
INTO v_periodo
FROM cglperiodo  
WHERE per_ano = a_anio 
AND   per_mes = v_speriodo ;

LET t_periodo =  a_anio||"-"||v_speriodo ;

let _fecha = mdy(a_mes, 1, a_anio);	

LET v_monto = 0;
let _cuenta = a_cuenta;

SELECT cta_nombre
  INTO l_nombre
  FROM cglcuentas
 WHERE cta_cuenta = _cuenta;  

foreach with hold
	select aux_tercero 
	into v_aux_terc
	from cglauxiliar 
   where aux_cuenta = _cuenta
   and aux_tercero = a_aux

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
		WHERE  ( cglsaldoaux.sld_tipo = a_tipo )  AND
		 ( cglsaldoaux.sld_cuenta = _cuenta )    AND
		 ( cglsaldoaux.sld_tercero = v_aux_terc ) AND
		 ( cglsaldoaux.sld_ano = v_anio_ant )  ;

		IF v_saldo_ant IS NULL THEN
		 LET v_saldo_ant = 0 ;
		END IF

		LET v_saldo = v_saldo_ant;

		if a_mes > 1 then
			LET v_saldo_ant = 0 ;
			SELECT sum(cglsaldoaux1.sld1_debitos - cglsaldoaux1.sld1_creditos )
			INTO v_saldo_ant
			FROM cglsaldoaux1
			WHERE ( cglsaldoaux1.sld1_cuenta = _cuenta ) AND
			     ( cglsaldoaux1.sld1_ano = a_anio ) AND
			     ( cglsaldoaux1.sld1_tercero = v_aux_terc ) AND
			     ( cglsaldoaux1.sld1_periodo < a_mes ) ;

			IF v_saldo_ant IS NULL THEN
			 LET v_saldo_ant = 0 ;
			END IF

			LET v_saldo = v_saldo + v_saldo_ant;
		end if


		SELECT sum(sld1_debitos),
		     sum(sld1_creditos)
		INTO v_debito,
		     v_credito
		FROM cglsaldoaux1
		WHERE sld1_tipo = a_tipo  AND
		     sld1_cuenta = _cuenta  AND
		     sld1_tercero = v_aux_terc  AND
		     sld1_ano = a_anio  AND
			 sld1_periodo =  a_mes;

		IF v_debito IS NULL THEN
		 LET v_debito = 0 ;
		END IF

		IF v_credito IS NULL THEN
		 LET v_credito = 0 ;
		END IF

		LET v_saldo = v_saldo + v_debito + v_credito ;

		LET v_monto = v_monto + v_saldo ;

		begin
			on exception in(-239,-268)
			end exception
			INSERT INTO tmp_saldos(
				periodo,
				tercero,
				nombre,
				inicial,
				debito,
				credito,
				neto,
				acumulado,
				cia,
				nom_cuenta,
				cuenta )
			VALUES(	v_periodo,
				 v_aux_terc,
				 v_nom_terc,
				 v_saldo_ant,
				 v_debito,
				 v_credito,
				 v_saldo,
				 v_monto,
				 l_cia_nom,
				 l_nombre,
				 _cuenta) ;
		end			 

END FOREACH;

return 0, 'Carga Exitosa';

END PROCEDURE  