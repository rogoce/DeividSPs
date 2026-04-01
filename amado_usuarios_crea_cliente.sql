-- Actualizando la firma en chqchmae

-- Creado    : 16/06/2006 - Autor: Amado Perez M.
-- Modificado: 16/06/2006 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE amado_usuario2;

CREATE PROCEDURE amado_usuario2()
RETURNING char(8),
          char(30),
          char(3),
		  char(30),
		  char(1),
		  char(1),
		  char(1),
		  char(1),
		  char(1),
		  char(3),
		  char(30),
		  char(2),
		  char(30),
		  char(5),
		  varchar(100);

define _error               integer;
define _usuario             char(8);

define _descripcion			char(30);
define _codigo_perfil		char(3);
define _desc_perfil			char(30);
define _autoriza_total		char(1);
define _adicion				char(1);
define _modificar			char(1);
define _eliminar			char(1);
define _status				char(1);
define _aplicacion			char(3);
define _desc_aplicacion		char(30);
define _tipo_autorizacion	char(2);
define _desc_tipoautoriza	char(30);
define _cantidad      		smallint;
define _cia_depto           varchar(5);
define _depto_desc          varchar(100);


--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

BEGIN
ON EXCEPTION SET _error 
	RETURN _error, "", "", "", "", "", "", "", "", "", "","", "", "", "";
END EXCEPTION     
      
foreach	
	SELECT usuario, codigo_perfil, descripcion, cia_depto
	  INTO _usuario, _codigo_perfil, _descripcion, _cia_depto
	  FROM insuser
	 WHERE crear_cliente = 1
	   AND (status = "A"
	    OR  (status  = "I" AND fvac_out is not null AND fvac_duein is not null))

    SELECT descripcion
	  INTO _desc_perfil
	  FROM inspefi
	 WHERE codigo_perfil = _codigo_perfil;

    SELECT nombre
	  INTO _depto_desc
	  FROM insdepto
	 WHERE cod_depto = trim(_cia_depto);

   FOREACH
	SELECT autoriza_total,
		   adicion,
		   modificar,
		   eliminar,
		   status,
		   aplicacion
	  INTO _autoriza_total,
		   _adicion,
		   _modificar,
		   _eliminar,
		   _status,
		   _aplicacion
	  FROM inspapl
	 WHERE codigo_perfil = _codigo_perfil

	IF _adicion = 'N' or trim(_cia_depto) = '005' THEN
		CONTINUE FOREACH;
	END IF

    SELECT descripcion
	  INTO _desc_aplicacion
	  FROM insapli
	 WHERE aplicacion = _aplicacion;

    SELECT count(*) INTO _cantidad
	  FROM insauca
	 WHERE usuario = _usuario
	   AND aplicacion = _aplicacion;

 --   IF _cantidad = 0 THEN
	   RETURN _usuario,
			  _descripcion,
	          _codigo_perfil,
			  _desc_perfil,
			  _autoriza_total,
			  _adicion,
			  _modificar,
			  _eliminar,
			  _status,
			  _aplicacion,
			  _desc_aplicacion,
			  null,
			  null,
			  _cia_depto,
			  trim(_depto_desc)
			  with resume;
--	ELSE
 {	   foreach
		   SELECT tipo_autorizacion
		     INTO _tipo_autorizacion
			 FROM insauca
			WHERE usuario = _usuario
			  AND aplicacion = _aplicacion

       SELECT descripcion
	     INTO _desc_tipoautoriza
		 FROM insauto
		WHERE tipo_autoriza = _tipo_autorizacion
		  AND aplicacion = _aplicacion;

	   RETURN _usuario,
			  _descripcion,
	          _codigo_perfil,
			  _desc_perfil,
			  _autoriza_total,
			  _adicion,
			  _modificar,
			  _eliminar,
			  _status,
			  _aplicacion,
			  _desc_aplicacion,
			  _tipo_autorizacion,
			  _desc_tipoautoriza,
			  _cia_depto,
			  trim(_depto_desc)
			  with resume;
	   end foreach }
  --	 END IF
	END FOREACH

   END FOREACH
    



END

END PROCEDURE;