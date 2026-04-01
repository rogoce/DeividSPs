-- Procedimiento para generar endos
-- Creado    : 11/02/2026 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_pro1000_09;
CREATE PROCEDURE "informix".sp_pro1000_09(a_poliza CHAR(10), a_usuario varchar(16) default 'DEIVID', a_secuencia int default 1, a_origen char(3) default null) 
RETURNING   VARCHAR(10),   -- v_no_poliza 
 			VARCHAR(20),   -- v_no_documento
            varchar(100),  -- vig inicial
			varchar(100),  -- vig final
			varchar(100),  -- aseg.
			varchar(100),  -- fecha actual
		 varchar(100),
		 decimal(16,2),
		 decimal(16,2),
		 decimal(16,2),
		 decimal(16,2),
		 varchar(10);

DEFINE _documento		 VARCHAR(20);
define _vig_ini			 date;
define _vig_fin			 date;
define _fecha_ini        char(100);
define _fecha_fin		 varchar(100);
define _cod_contratante  varchar(10);
DEFINE _asegurado		 varCHAR(100);
define _fecha_actual     varchar(100);
define _fecha            date;
define _direccion		 varchar(100);
define _direccion_1      varchar(50);
define _prima_neta		 decimal(16,2);
define _impuesto		 decimal(16,2);
define _prima_bruta		 decimal(16,2);
define _direccion_2      varchar(50);
define _suma_asegurada   decimal(16,2);
define v_certificado     int;

let _fecha = current;

SET ISOLATION TO DIRTY READ;

let _fecha_actual = "";

-- Lectura de emipomae
SELECT trim(no_documento),
       vigencia_inic,
	   vigencia_final,
	   trim(cod_contratante),
	   prima_neta,
	   impuesto,
	   prima_bruta,
	   suma_asegurada
  INTO _documento,
       _vig_ini,
       _vig_fin,
	   _cod_contratante,
	   _prima_neta,
	   _impuesto,
	   _prima_bruta,
	   _suma_asegurada
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


LET v_certificado = 0;

SELECT MAX(no_certificado)
INTO v_certificado
FROM endnocert
WHERE no_poliza = a_poliza;

if a_secuencia = 1 then
	--BEGIN WORK;
		IF v_certificado IS NULL THEN
		   LET v_certificado = 1;
		ELSE
		   LET v_certificado = v_certificado + 1;
		END IF;

		INSERT INTO endnocert
			(no_certificado, no_documento, no_poliza,usuario,no_certificadodoc)
		VALUES
			(v_certificado, _documento, a_poliza, a_usuario, LPAD(v_certificado,5,'0'));
	if a_origen is null then -- el llamado es del Powerbuilder debe hacer commit.		
		COMMIT WORK;
	end if
end if

	RETURN trim(a_poliza),
		   trim(_documento),
           trim(_fecha_ini),
           trim(_fecha_fin),
		   trim(_asegurado),
		   trim(_fecha_actual),
		   trim(_direccion),
		   _prima_neta,
		   _impuesto,
		   _prima_bruta,
		   _suma_asegurada,
		   LPAD(v_certificado,5,'0')
		   WITH RESUME;   	


END PROCEDURE		   