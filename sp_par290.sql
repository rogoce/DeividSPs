-- Reporte de Registros Contables de Produccion
-- 
-- Creado    : 29/10/2002 - Autor: Marquelda Valdelamar
-- Modificado: 29/10/2002 - Autor: Marquelda Valdelamar.
--
-- SIS v.2.0 - d_cobr_sp_cob61_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_par290;

CREATE PROCEDURE "informix".sp_par290(a_no_factura CHAR(10))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  CHAR(50),	 -- Tipo de comprobante
		  DEC(16,2), -- Diferencia
		  DEC(16,2), -- Debito Aux
		  DEC(16,2); -- Credito	Aux

DEFINE _no_poliza		 CHAR(10);
DEFINE _no_endoso		 CHAR(5);
DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_tipo_comp       smallint;
DEFINE v_comprobante     CHAR(50);
define _diferencia		 dec(16,2);
define a_compania 		 char(3);

define _cod_auxiliar	 char(5);
define _nombre_auxiliar	 char(50);
define v_debito_aux      dec(16,2);
define v_credito_aux     dec(16,2);
define _cta_auxiliar	 char(1);

LET v_debito  = 0;
LET v_credito = 0;
let a_compania = "001";

-- Nombre de la Compania

LET  v_compania_nombre = sp_sis01(a_compania); 

CREATE TEMP TABLE tmp_prod(
		tipo_comprobante smallint,
		cuenta		   	 CHAR(25),
		debito      	 DECIMAL(16,2),
		credito		     DECIMAL(16,2)
		) WITH NO LOG;

CREATE TEMP TABLE tmp_prod2(
		tipo_comprobante smallint,
		cuenta		   	 CHAR(25),
		cod_auxiliar	 char(5),
		debito      	 DECIMAL(16,2),
		credito		     DECIMAL(16,2)
		) WITH NO LOG;

-- Lectura de la Tabla de Remesas detalle

SET ISOLATION TO DIRTY READ;

FOREACH 
 SELECT no_poliza,
        no_endoso
   INTO _no_poliza,
        _no_endoso
   FROM endedmae
  WHERE no_factura  = a_no_factura
    AND actualizado = 1

   FOREACH
	SELECT debito,
		   credito,
		   cuenta,
		   tipo_comp
	  INTO v_debito,
	       v_credito,
	       v_cuenta,
		   v_tipo_comp
	  FROM endasien
	 WHERE no_poliza = _no_poliza
	   AND no_endoso = _no_endoso

		INSERT INTO tmp_prod(
		tipo_comprobante,
		cuenta,   
		debito,	  
	    credito
		)
		VALUES(
		v_tipo_comp,
		v_cuenta,  
		v_debito,
		v_credito
		);

		foreach
		 select cod_auxiliar,
		        debito,
				credito
		   into _cod_auxiliar,
		        v_debito_aux,
				v_credito_aux
		   from endasiau
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
			and cuenta    = v_cuenta

			insert into tmp_prod2
			values (v_tipo_comp, v_cuenta, _cod_auxiliar, v_debito_aux, v_credito_aux);

		end foreach

  END FOREACH

END FOREACH;

FOREACH
 SELECT tipo_comprobante,
        cuenta, 
        SUM(debito), 
        SUM(credito)
   INTO v_tipo_comp,
   		v_cuenta, 
        v_debito, 
        v_credito
   FROM tmp_prod
  GROUP BY 1, 2
  ORDER BY 1, 2

	let _diferencia = v_debito + v_credito;

	SELECT cta_nombre,
	       cta_auxiliar
	  INTO v_nombre_cuenta,
	       _cta_auxiliar
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;
	
	let v_comprobante = sp_sac11(1, v_tipo_comp); 

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre,
		   v_comprobante,
		   _diferencia,
		   null,
		   null
		   WITH RESUME;

	if _cta_auxiliar = "S" then
			   
		foreach
		 select cod_auxiliar, 
	        	sum(debito), 
	        	sum(credito)
	   	   into _cod_auxiliar,
	            v_debito_aux, 
	            v_credito_aux
	       from tmp_prod2
		  where	tipo_comprobante = v_tipo_comp
		    and cuenta           = v_cuenta
	      group by 1
	      order by 1
	      
			select ter_descripcion
			  into _nombre_auxiliar
			  from cglterceros
			 where ter_codigo = _cod_auxiliar;

			let _diferencia      = 0.00;
--			let _nombre_auxiliar = _cod_auxiliar || " " || trim(_nombre_auxiliar);

			RETURN _cod_auxiliar,			
				   _nombre_auxiliar,  
				   0.00,         
				   0.00,        
				   v_compania_nombre,
				   v_comprobante,
				   0.00,
				   v_debito_aux,         
				   v_credito_aux        
				   WITH RESUME;
			
		end foreach      		   	 		

		{
		RETURN "",			
			   "",  
			   null,         
			   null,        
			   v_compania_nombre,
			   v_comprobante,
			   null
			   WITH RESUME;
		}

	end if

END FOREACH;

DROP TABLE tmp_prod;
DROP TABLE tmp_prod2;

END PROCEDURE;
