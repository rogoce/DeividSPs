-- Procedimiento para crear la carta del suntracs -- 
-- Creado    : 10/03/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro1001p;
CREATE PROCEDURE "informix".sp_pro1001p(a_poliza CHAR(10)) 
RETURNING   CHAR(10),
 			VARCHAR(50),
			decimal(16,2),
			char(5);
 

DEFINE _documento		 CHAR(20);
DEFINE _cod_contratante	 CHAR(10);
DEFINE _asegurado		 CHAR(100);
DEFINE _fecha		     DATE;
DEFINE _fecha_actual	 CHAR(100);
DEFINE _fecha_apartir	 CHAR(100);
DEFINE _endoso      	 CHAR(5);
DEFINE _cod_agente       CHAR(5);
DEFINE _corredor		 CHAR(100);
define _cod_acreedor     char(5);
define _acreedor         char(50);
define _suma_asegurada   decimal(16,2);
define _cod_ramo         char(3);
define _no_unidad        char(5);

SET ISOLATION TO DIRTY READ;
let _fecha  = current;
let _endoso = "00000";
let _corredor = "";
let _no_unidad = "";

   FOREACH

		 SELECT cod_acreedor,
		        limite,
		        no_unidad
		   INTO _cod_acreedor,
		        _suma_asegurada,
		        _no_unidad
		   FROM emipoacr
		  WHERE no_poliza = a_poliza

		 SELECT trim(upper(nombre))
		   INTO _acreedor
		   FROM emiacre
		  WHERE cod_acreedor = _cod_acreedor;

	RETURN a_poliza,
		   _acreedor,
		   _suma_asegurada,
		   _no_unidad with resume;   	

   END FOREACH

END PROCEDURE			   