-- Consulta de la web de SEMM
-- Creado    : 01/03/2023 - Autor: FEDERICO CORONADO.

DROP PROCEDURE sp_web74;

CREATE PROCEDURE sp_web74(a_entrada varchar(50))
RETURNING varchar(30),
		  varchar(50);

DEFINE v_cedula  			varchar(30);
DEFINE v_nombre				varchar(50);   

--SET DEBUG FILE TO "sp_pro67.trc"; 
--trace on;

SET ISOLATION TO DIRTY READ;

		foreach  --MULTI RIESGOS', 'ACCIDENTES PERSONALES', 'SODA', 'INCENDIO', 'AUTOMOVIL', 'AUTOMOVIL FLOTAS'
			SELECT cliclien.cedula, cliclien.nombre
			  into v_cedula, v_nombre
			  FROM  cliclien, emipomae, emipouni, cliclien  BO_Deivid_dbo_cliclien6
			 WHERE (cliclien.cod_cliente = emipomae.cod_contratante)
			   and (BO_Deivid_dbo_cliclien6.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza)
               AND emipomae.cod_ramo in('003','004','020','001','002','023')
			   AND emipomae.estatus_poliza = 1
			   AND emipouni.activo = 1
               AND cliclien.nombre like a_entrada||"%"
		UNION 
		--SALUD ASEGURADO PRINCIPAL
			SELECT cliclien.cedula, cliclien.nombre
			  FROM  cliclien, emipomae, emipouni
			 WHERE (cliclien.cod_cliente = emipomae.cod_contratante)
               AND (cliclien.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza)
               AND emipomae.cod_ramo in('018')
			   AND emipomae.estatus_poliza = 1
			   AND emipouni.activo = 1
               AND cliclien.nombre like a_entrada||"%"
	    UNION
		--SALUD DEPENDIENTES
			SELECT BO_Deivid_dbo_cliclien6.cedula, BO_Deivid_dbo_cliclien6.nombre
			  FROM cliclien, emipomae, emidepen, cliclien  BO_Deivid_dbo_cliclien6, emipouni
			 WHERE (cliclien.cod_cliente=emipomae.cod_contratante)
			   AND (emipomae.cod_ramo in('018'))
			   AND (emidepen.cod_cliente=BO_Deivid_dbo_cliclien6.cod_cliente)
			   AND (emipomae.no_poliza=emipouni.no_poliza)
			   AND (emipouni.no_poliza=emidepen.no_poliza)
			   AND (emipouni.no_unidad=emidepen.no_unidad)
			   AND emipomae.estatus_poliza = 1
			   AND BO_Deivid_dbo_cliclien6.nombre like a_entrada||"%"
		UNION 
		--Asegurado
			SELECT BO_Deivid_dbo_cliclien6.cedula, BO_Deivid_dbo_cliclien6.nombre  
			  FROM emipomae, emipouni, cliclien  BO_Deivid_dbo_cliclien6
			 WHERE (BO_Deivid_dbo_cliclien6.cod_cliente = emipouni.cod_asegurado)
			   AND (emipouni.no_poliza = emipomae.no_poliza)
			   AND emipomae.cod_ramo  IN  ('018')
               AND emipomae.estatus_poliza = 1
			   AND emipouni.activo = 1
               AND BO_Deivid_dbo_cliclien6.nombre like a_entrada||"%"
			   
		  group by nombre, cedula
          order by nombre
		
		return v_cedula, 
		       v_nombre 
			   WITH RESUME;
	end foreach
END PROCEDURE;