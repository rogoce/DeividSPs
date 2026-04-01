-- Reporte de Registros Contables de Reaseguro
-- 
-- Creado    : 29/10/2002 - Autor: Marquelda Valdelamar
-- Modificado: 29/10/2002 - Autor: Marquelda Valdelamar.
--
-- SIS v.2.0 - d_cobr_sp_cob61_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_par320;

CREATE PROCEDURE "informix".sp_par320(a_compania CHAR(3), a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  CHAR(50),	 -- Compania
		  CHAR(50),	 -- Tipo de comprobante
		  DEC(16,2), -- Diferencia
		  DEC(16,2), -- Debito Aux
		  DEC(16,2); -- Credito	Aux

DEFINE _no_registro		 CHAR(10);
DEFINE _no_poliza		 CHAR(10);
DEFINE _no_endoso		 CHAR(5);
DEFINE v_cuenta			 CHAR(25);	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_compania_nombre CHAR(50); 
DEFINE v_tipo_comp       Smallint;
DEFINE _tipo_compd		 CHAR(50); 

DEFINE v_comprobante     CHAR(25);
define _diferencia		 dec(16,2);
define _cod_ramo		 char(3);

define _cod_auxiliar	 char(5);
define _nombre_auxiliar	 char(50);
define v_debito_aux      dec(16,2);
define v_credito_aux     dec(16,2);
define _cta_auxiliar	 char(1);

LET v_debito  = 0;
LET v_credito = 0;

-- Nombre de la Compania

--set debug file to "sp_par61.trc";
--trace on;

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
        no_endoso,
		no_registro
   INTO _no_poliza,
        _no_endoso,
		_no_registro
   FROM sac999:reacomp
  WHERE periodo    >= a_periodo1 
    AND periodo    <= a_periodo2
--    AND actualizado = 1
--	and user_added = "GERENCIA"
--	and no_factura  in ("01-622209")
--	and no_factura  in ("01-616542", "01-616560", "01-615416", "01-616376", "02-30417")

	select cod_ramo
	  into _cod_ramo 
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if _cod_ramo = "002" or _cod_ramo = "020" then

	else
	
		continue foreach;
				
	end if

   FOREACH
	SELECT debito,
		   credito,
		   cuenta,
		   tipo_comp
	  INTO v_debito,
	       v_credito,
	       v_cuenta,
		   v_tipo_comp
	  FROM sac999:reacompasie
	 WHERE no_registro = _no_registro

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
		   from sac999:reacompasiau
	      WHERE no_registro = _no_registro
			and cuenta      = v_cuenta

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

	let _tipo_compd  = sp_sac11(12, v_tipo_comp);

	let _diferencia = v_debito - v_credito;

	SELECT cta_nombre,
	       cta_auxiliar
	  INTO v_nombre_cuenta,
	       _cta_auxiliar
	  FROM cglcuentas
	 WHERE cta_cuenta = v_cuenta;

	RETURN v_cuenta,			
		   v_nombre_cuenta,  
		   v_debito,         
		   v_credito,        
		   v_compania_nombre,
		   _tipo_compd,
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
				   _tipo_compd,
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

