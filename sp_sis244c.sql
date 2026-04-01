-- Cartera Activa Insurance Solutions
-- Creado por: Amado Pérez Mendoza
-- Fecha 	 : 07/08/2019

drop procedure sp_sis244c;

create procedure sp_sis244c() returning
			varchar(100) as asegurado,
			varchar(30) as cedula,
			varchar(50) as e_mail,
			date as fecha_nacimiento,
			char(10) as telefono1,
			char(10) as telefono2,
			char(10) as telefono3,
			char(10) as celular,
			varchar(50) as direccion_1,
			varchar(50) as direccion_2;

define v_filtros   	    char(255);
define _no_poliza       char(10);   
define _cod_contratante	char(10);
define _cod_asegurado   char(10);
define _cod_pagador     char(10);
define _asegurado       varchar(100);
define _contratante     varchar(100);
define _cedula          varchar(30);
define _e_mail          varchar(50); 
define _fecha_aniversario date;
define _telefono1       char(10);
define _telefono2       char(10);
define _telefono3       char(10);
define _celular         char(10);
define _direccion_1     varchar(50);
define _direccion_2     varchar(50);
--SET DEBUG FILE TO "sp_che133.trc";
--tRACE ON;

CREATE TEMP TABLE temp_cliente
	 (cod_cliente      	CHAR(10),
	  nombre            VARCHAR(100),
	  PRIMARY KEY(cod_cliente))
	  WITH NO LOG;


SET ISOLATION TO DIRTY READ;

CALL sp_sis244b(
'001',
'001',
'30/08/2019',
'*',
'4;Ex') RETURNING v_filtros;

 
FOREACH
	SELECT no_poliza,   
           cod_contratante		 
	  INTO _no_poliza,   
           _cod_contratante
      FROM temp_perfil 
    ORDER BY no_documento	 
	
	SELECT nombre
	  INTO _asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_contratante;

	BEGIN
		ON EXCEPTION IN(-239)
		END EXCEPTION
		INSERT INTO temp_cliente
			VALUES(_cod_contratante, _asegurado);
	END	
		
	SELECT cod_pagador
      INTO _cod_pagador
	  FROM emipomae
     WHERE no_poliza = _no_poliza;	 

	SELECT nombre
	  INTO _asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_pagador;
	 
	BEGIN
		ON EXCEPTION IN(-239)
		END EXCEPTION
		INSERT INTO temp_cliente
			VALUES(_cod_pagador, _asegurado);
	END	
	
	FOREACH 
		SELECT cod_asegurado
		  INTO _cod_asegurado
		  FROM emipouni
		 WHERE no_poliza = _no_poliza
		ORDER BY no_unidad

		SELECT nombre
		  INTO _asegurado
		  FROM cliclien
		 WHERE cod_cliente = _cod_asegurado;
		
	BEGIN
		ON EXCEPTION IN(-239)
		END EXCEPTION
		INSERT INTO temp_cliente
			VALUES(_cod_asegurado, _asegurado);
	END
    END FOREACH
END FOREACH	


FOREACH
    SELECT cod_cliente,
	       nombre
      INTO _cod_asegurado,
	       _asegurado
      FROM temp_cliente
	ORDER BY nombre
 	 
	SELECT cedula,
	       e_mail,
		   fecha_aniversario,
		   telefono1,
		   telefono2,
		   telefono3,
		   celular,
		   direccion_1,
		   direccion_2
	  INTO _cedula,
	       _e_mail,
		   _fecha_aniversario,
		   _telefono1,
		   _telefono2,
		   _telefono3,
		   _celular,
		   _direccion_1,
		   _direccion_2
	  FROM cliclien 
	 WHERE cod_cliente = _cod_asegurado;

	RETURN _asegurado,
		   _cedula,
	       _e_mail,
		   _fecha_aniversario,
		   _telefono1,
		   _telefono2,
		   _telefono3,
		   _celular,
		   _direccion_1,
		   _direccion_2
		   with resume;
END FOREACH
	
DROP TABLE temp_perfil;
DROP TABLE temp_cliente;
end procedure
