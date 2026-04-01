-- Reporte de Totales de Cuentas para una Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 13/12/2000 - Autor: Armando Moreno Montenegro.
--
-- SIS v.2.0 - d_cobr_sp_cob40_dw1 - DEIVID, S.A.

 DROP PROCEDURE sp_cob158a;

CREATE PROCEDURE "informix".sp_cob158a(a_compania CHAR(3), a_fecha date, a_fecha2 date, a_cuenta char(255) DEFAULT "*")
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  CHAR(1),	 -- Tipo de Remesa
		  integer,
		  CHAR(255); 

DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_no_remesa		 CHAR(10);
DEFINE v_compania_nombre CHAR(50); 
define _fecha            date;
DEFINE v_renglon         SMALLINT; 
DEFINE _debito	         DEC(16,2);
DEFINE _credito	         DEC(16,2);
DEFINE v_tipo_remesa	 CHAR(1);
define _dia              integer;
DEFINE _tipo             CHAR(1);
DEFINE v_filtros 		 CHAR(255);

LET v_filtros = "";
LET v_debito  = 0;
LET v_credito = 0;
LET _debito   = 0;
LET _credito  = 0;
LET _dia      = 0;

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_prod(
		tipo_remesa		CHAR(1),
		cuenta		   	CHAR(25),
		debito      	DECIMAL(16,2),
		credito		    DECIMAL(16,2),
		dia				integer,
		seleccionado    SMALLINT    DEFAULT 1 NOT NULL
		) WITH NO LOG;

-- Lectura de la Tabla de Remesas detalle

SET ISOLATION TO DIRTY READ;

FOREACH 
SELECT no_remesa,
       tipo_remesa,
	   fecha
  INTO v_no_remesa,
       v_tipo_remesa,
	   _fecha
  FROM cobremae
 WHERE fecha between a_fecha and a_fecha2
   and actualizado = 1
 order by 3

	IF v_tipo_remesa = "A" Or
	   v_tipo_remesa = "M" THEN
	   LET v_tipo_remesa = "R";
	ELSE
	   continue foreach;	
	   LET v_tipo_remesa = "C";
	END IF

 let _dia = day(_fecha);

   FOREACH
	SELECT debito,
		   credito,
		   cuenta
	  INTO v_debito,
	       v_credito,
	       v_cuenta
	  FROM cobasien
	 WHERE no_remesa = v_no_remesa


		INSERT INTO tmp_prod(
		tipo_remesa,
		cuenta,   
		debito,	  
	    credito,
		dia
		)
		VALUES(
		v_tipo_remesa,
		v_cuenta,  
		v_debito,
		v_credito,
		_dia
		);

  END FOREACH

END FOREACH;

let a_cuenta = trim(a_cuenta);

IF a_cuenta <> "*" THEN
     LET v_filtros = TRIM(v_filtros) ||"Cuenta: " || TRIM(a_cuenta);
     LET _tipo = sp_sis04(a_cuenta); -- Separa los valores del String

     IF _tipo <> "E" THEN -- Incluir los Registros

        UPDATE tmp_prod
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cuenta NOT IN(SELECT codigo FROM tmp_codigos);
     ELSE
        UPDATE temp_prod
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND cuenta IN(SELECT codigo FROM tmp_codigos);
     END IF
     DROP TABLE tmp_codigos;
END IF

FOREACH

 SELECT tipo_remesa,
		dia,
        cuenta, 
        SUM(debito), 
        SUM(credito)
   INTO v_tipo_remesa,
		_dia,
   		v_cuenta, 
        v_debito, 
        v_credito
   FROM tmp_prod
  WHERE seleccionado = 1
  GROUP BY 1, 2, 3
  ORDER BY 1, 2, 3

	SELECT cta_nombre
	  INTO v_nombre_cuenta
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre,
		   v_tipo_remesa,
		   _dia,
		   v_filtros
		   WITH RESUME;	 		

END FOREACH;

DROP TABLE tmp_prod;

END PROCEDURE;

