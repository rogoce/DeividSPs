-- Consulta de Reclamos

-- Creado    : 24/06/2008 - Autor: Amado Perez M.
-- Modificado: 24/06/2008 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf63;

CREATE PROCEDURE sp_rwf63(a_no_tramite VARCHAR(10) default "%", a_inc_padre INT default 0)
RETURNING char(50),	 -- 
		  char(50),  -- 
		  char(30),	 --
		  smallint,	 --
		  varchar(100),
		  char(30),
		  smallint,
		  varchar(30);

define v_no_motor			char(30);
define _cod_marca			char(5);
define _cod_modelo			char(5);
define _nombre_marca		char(50);
define _nombre_modelo		char(50);
define _placa				char(10);
define _ano_auto			smallint;
define v_nombre_conductor	varchar(100);
define _cod_conductor		char(10);
define _cod_taller			char(10);
define _no_reclamo          char(10);
define _no_chasis           varchar(30);
--set debug file to "sp_rwf15.trc";
--trace on;


SET ISOLATION TO DIRTY READ;

LET a_no_tramite = TRIM(a_no_tramite);
LET a_inc_padre = a_inc_padre;

FOREACH
 SELECT	no_reclamo,
        cod_conductor
   INTO _no_reclamo,
        _cod_conductor
   FROM	recrcmae 
  WHERE no_tramite like a_no_tramite
	AND actualizado = 1

 SELECT	cod_tercero,
        no_motor,
        cod_marca,
		cod_modelo,
		ano_auto,
		placa,
		no_chasis
   INTO	_cod_conductor,
        v_no_motor,
        _cod_marca,
		_cod_modelo,
		_ano_auto,
		_placa,
		_no_chasis
   FROM recterce
  WHERE no_reclamo = _no_reclamo
    AND no_incidente = a_inc_padre;

IF _no_chasis IS NULL THEN
 let _no_chasis = "";
END IF

 IF _cod_conductor Is Null OR _cod_conductor = "" THEN
	RETURN "ERROR",	"ERROR","ERROR","0","CREAR TERCERO EN DEIVID o NUMERO DE INCIDENTE ERRADO","ERROR",0,"ERROR";
 END IF
	 
	 select nombre
	   into _nombre_marca
	   from emimarca
	  where cod_marca = _cod_marca;

	 select nombre	   
	   into _nombre_modelo
	   from emimodel
	  where cod_marca = _cod_marca
	    and cod_modelo = _cod_modelo;

	 select nombre	   
	   into v_nombre_conductor
	   from cliclien
	  where cod_cliente = _cod_conductor;
	  
	LET v_nombre_conductor = UPPER(v_nombre_conductor);
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"Á","A");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"É","E");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"Í","I");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"Ó","O");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"Ú","U");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,","," ");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,";"," ");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"|"," ");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"'"," ");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"Ñ","N");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"!'"," ");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"$"," ");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"%"," ");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"&"," ");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"^"," ");
	LET v_nombre_conductor = REPLACE(v_nombre_conductor,"ñ","N");
	  

 {		LET v_edad = YEAR(TODAY) - YEAR(v_fecha_aniversario);

		IF MONTH(TODAY) < MONTH(v_fecha_aniversario) THEN
			LET v_edad = v_edad - 1;
		ELIF MONTH(v_fecha_aniversario) = MONTH(TODAY) THEN
			IF DAY(TODAY) < DAY(v_fecha_aniversario) THEN
				LET v_edad = v_edad - 1;
			END IF
		END IF
  }
	RETURN  _nombre_marca,	--1
			_nombre_modelo,	--2
			_placa,			--3
			_ano_auto,		--4
			trim(v_nombre_conductor), --5
			v_no_motor,
			1,
			_no_chasis
			WITH RESUME;

END FOREACH


	


END PROCEDURE;
