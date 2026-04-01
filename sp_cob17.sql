-- Reporte de Totales de Cuentas para una Remesa
-- 
-- Creado    : 21/09/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 21/09/2000 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob17_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_cob17;

CREATE PROCEDURE "informix".sp_cob17(a_compania CHAR(3), a_remesa CHAR(10))
RETURNING CHAR(25),	 -- Cuenta
		  CHAR(50),	 -- Nombre Cuenta
		  DEC(16,2), -- Debito
		  DEC(16,2), -- Credito
		  DATE,		 -- Fecha
		  CHAR(7),	 -- Periodo
		  CHAR(50),	 -- Compania
		  smallint,
		  dec(16,2),
		  dec(16,2);

DEFINE v_cuenta			 CHAR(25);
define _renglon			 smallint;	
DEFINE v_nombre_cuenta   CHAR(50);
DEFINE v_debito          DEC(16,2);
DEFINE v_credito         DEC(16,2);
DEFINE v_fecha           DATE;
DEFINE v_periodo		 CHAR(7);
DEFINE v_compania_nombre CHAR(50); 

define _cod_auxiliar	 char(5);
define _nombre_auxiliar	 char(50);
define _debito_aux       DEC(16,2);
define _credito_aux      DEC(16,2);
define _cta_auxiliar	 char(1);

-- Nombre de la Compania

SET ISOLATION TO DIRTY READ;

LET  v_compania_nombre = sp_sis01(a_compania); 

-- Lectura de la Tabla de Remesas

SELECT fecha,
	   periodo
  INTO v_fecha,
	   v_periodo	
  FROM cobremae
 WHERE no_remesa = a_remesa;	   	

FOREACH 
 SELECT SUM(debito),
        sum(credito),
		renglon,
		cuenta
   INTO	v_debito,
        v_credito,	
		_renglon,
		v_cuenta	 		
   FROM cobasien
  WHERE no_remesa = a_remesa
  GROUP BY renglon, cuenta
  ORDER BY renglon, cuenta

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
		   v_fecha,          
		   v_periodo,		
		   v_compania_nombre,
		   _renglon,
		   null,
		   null
		   WITH RESUME;	 	
		   
	if _cta_auxiliar is null then
		let _cta_auxiliar = "S";
	end if

	if _cta_auxiliar = "S" then

		foreach
		 select cod_auxiliar,
		        sum(debito),
			    sum(credito)
		   into _cod_auxiliar,
		        _debito_aux,
			    _credito_aux
		   from cobasiau
		  where no_remesa = a_remesa
		    and renglon   = _renglon
		    and cuenta    = v_cuenta
		  group by cod_auxiliar 	
		  order by cod_auxiliar 	

			select ter_descripcion
			  into _nombre_auxiliar
			  from cglterceros
			 where ter_codigo = _cod_auxiliar;
		
			RETURN _cod_auxiliar,			
				   _nombre_auxiliar,  
				   null,         
				   null,        
				   v_fecha,          
				   v_periodo,		
				   v_compania_nombre,
				   _renglon,
				   _debito_aux,
				   _credito_aux
				   WITH RESUME;	 		
	
		end foreach
	end if 
END FOREACH
END PROCEDURE;