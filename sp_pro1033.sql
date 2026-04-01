-- Procedimiento para crear la carta del suntracs -- 
-- Creado    : 10/03/2010 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_pro1000;
CREATE PROCEDURE "informix".sp_pro1000(a_poliza CHAR(10)) 
RETURNING   CHAR(10),   -- v_no_poliza 
 			CHAR(20),   -- v_no_documento
            char(100),	-- vig inicial
			char(100),	-- vig final
			char(100),  -- aseg.
			char(100),  -- fecha actual
		 varchar(100),
		 decimal(16,2),
		 decimal(16,2),
		 decimal(16,2);

DEFINE _documento		 CHAR(20);
define _vig_ini			 date;
define _vig_fin			 date;
define _fecha_ini        char(100);
define _fecha_fin		 char(100);
define _cod_contratante  char(10);
DEFINE _asegurado		 CHAR(100);
define _fecha_actual     char(100);
define _fecha            date;
define _direccion		 varchar(100);
define _direccion_1      varchar(50);
define _prima_neta		 decimal(16,2);
define _impuesto		 decimal(16,2);
define _prima_bruta		 decimal(16,2);
define _direccion_2      varchar(50);

let _fecha = current;

SET ISOLATION TO DIRTY READ;

let _fecha_actual = "";

-- Lectura de emipomae
SELECT no_documento,
       vigencia_inic,
	   vigencia_final,
	   cod_contratante,
	   prima_neta,
	   impuesto,
	   prima_bruta
  INTO _documento,
       _vig_ini,
       _vig_fin,
	   _cod_contratante,
	   _prima_neta,
	   _impuesto,
	   _prima_bruta
  FROM emipomae
 WHERE no_poliza = a_poliza 
   AND actualizado = 1;

let _asegurado = "";

SELECT trim(upper(nombre)),
       trim(direccion_1),
	   trim(direccion_2)
  INTO _asegurado,
       _direccion_1,
	   _direccion_2
  FROM cliclien
 WHERE cod_cliente = _cod_contratante;

if _direccion_1 is null then
	let _direccion_1 = "";
end if

if _direccion_2 is null then
	let _direccion_2 = "";
end if

let _direccion = _direccion_1 || _direccion_2;

call sp_sis20(_vig_ini) returning _fecha_ini;
call sp_sis20(_vig_fin) returning _fecha_fin;
call sp_sis20(_fecha)   returning _fecha_actual;

	RETURN a_poliza,
		   _documento,
           _fecha_ini,
           _fecha_fin,
		   _asegurado,
		   _fecha_actual,
		   _direccion,
		   _prima_neta,
		   _impuesto,
		   _prima_bruta
		   WITH RESUME;   	


END PROCEDURE			                                                  


{CREATE PROCEDURE "informix".sp_pro1000(a_poliza CHAR(10)) 
RETURNING   CHAR(10),   -- v_no_poliza 
 			CHAR(20),   -- v_no_documento
            char(100),	-- vig inicial
			char(100),	-- vig final
			char(100),  -- aseg.
			char(100),  -- fecha actual
		 varchar(100),	-- 
		 decimal(16,2),	-- prima_neta,
		 decimal(16,2),	-- impuesto,
		 decimal(16,2);	-- prima_bruta

define _documento		 char(20);
define _vig_ini			 date;
define _vig_fin			 date;
define _fecha_ini        char(100);
define _fecha_fin		 char(100);
define _cod_contratante  char(10);
define _asegurado		 char(100);
define _fecha_actual     char(100);
define _fecha            date;
define _direccion		 varchar(100);
define _direccion_1      varchar(50);
define _prima_neta		 decimal(16,2);
define _impuesto		 decimal(16,2);
define _prima_bruta		 decimal(16,2);
define _direccion_2      varchar(50);

let _fecha = current;

SET ISOLATION TO DIRTY READ;

let _fecha_actual = "";

-- Lectura de emipomae
SELECT no_documento,
       vigencia_inic,
	   vigencia_final,
	   cod_contratante,
	   prima_neta,
	   impuesto,
	   prima_bruta
  INTO _documento,
       _vig_ini,
       _vig_fin,
	   _cod_contratante,
	   _prima_neta,
	   _impuesto,
	   _prima_bruta
  FROM emipomae
 WHERE no_poliza = a_poliza 
   AND actualizado = 1;

let _asegurado = "";

SELECT trim(upper(nombre)),
       trim(direccion_1),
	   trim(direccion_2)
  INTO _asegurado,
       _direccion_1,
	   _direccion_2
  FROM cliclien
 WHERE cod_cliente = _cod_contratante;

if _direccion_1 is null then
	let _direccion_1 = "";
end if

if _direccion_2 is null then
	let _direccion_2 = "";
end if

let _direccion = _direccion_1 || _direccion_2;

call sp_sis20(_vig_ini) returning _fecha_ini;
call sp_sis20(_vig_fin) returning _fecha_fin;
call sp_sis20(_fecha)   returning _fecha_actual;

	RETURN a_poliza,
		   _documento,
           _fecha_ini,
           _fecha_fin,
		   _asegurado,
		   _fecha_actual,
		   _direccion,
		   _prima_neta,
		   _impuesto,
		   _prima_bruta
		   WITH RESUME;   	


END PROCEDURE  }			   