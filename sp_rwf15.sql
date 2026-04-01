-- Consulta de Reclamos

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf15;

CREATE PROCEDURE sp_rwf15(a_no_documento VARCHAR(20) default "%", a_numrecla VARCHAR(18) default "%", a_no_tramite VARCHAR(10) default "%", a_tipo_r CHAR(1) default "%", a_inc_padre INT default 0)
RETURNING char(50),	 -- 
		  char(50),	 -- 
		  char(50),  -- 
		  char(30),
		  smallint,
		  char(30),
		  char(30),
		  char(30),
		  dec(16,2),
		  varchar(100),
		  varchar(100),
		  smallint,
		  varchar(30),
		  char(50),
		  char(10),
		  char(50),
		  smallint,
		  smallint,
		  char(10),
		  smallint;

define v_no_motor			char(30);
define _cod_marca			char(5);
define _cod_modelo			char(5);
define _nombre_marca		char(50);
define _nombre_modelo		char(50);
define _cod_ramo, _cod_tipoauto	char(3);
define _cod_color			char(3);
define _placa				char(10);
define _ano_auto			smallint;
define _placa_taxi			char(10);
define _no_chasis			char(30);
define _valor_auto			dec(16,2);
define _cod_tipolic			char(3);
define v_nombre_conductor	varchar(100);
define v_cedula         	varchar(30);
define v_nombre_taller  	varchar(100);
define v_fecha_aniversario	DATE;
define v_edad, v_capacidad, v_tiene_inspeccion smallint;
define v_telefono1			char(10);
define v_tipo_licencia		char(50);
define v_color				char(50);
define v_tipoauto			char(50);
define _cod_conductor		char(10);
define _cod_taller			char(10);
define _no_reclamo          char(10);
define v_tamano             smallint;

--set debug file to "sp_rwf15.trc";
--trace on;


SET ISOLATION TO DIRTY READ;

LET a_no_documento = TRIM(a_no_documento);
LET a_numrecla = TRIM(a_numrecla);
LET a_no_tramite = TRIM(a_no_tramite);
LET a_tipo_r = TRIM(a_tipo_r);
LET a_inc_padre = a_inc_padre;

FOREACH
 SELECT	no_reclamo,
        no_motor,
        cod_conductor,
		cod_tipolic,
		cod_taller,
		tiene_inspeccion
   INTO _no_reclamo,
        v_no_motor,
        _cod_conductor,
		_cod_tipolic,
		_cod_taller,
		v_tiene_inspeccion
   FROM	recrcmae 
  WHERE numrecla like a_numrecla
    AND no_documento like a_no_documento
	AND no_tramite like a_no_tramite
	AND actualizado = 1

	 IF a_tipo_r = "T" THEN
	    LET _cod_taller = "";
		LET v_no_motor = "";

	    SELECT no_motor, cod_taller 
		  INTO v_no_motor, _cod_taller
		  FROM recterce
		 WHERE no_reclamo   = _no_reclamo
		   AND no_incidente = a_inc_padre; 
	 END IF

	LET _cod_marca = NULL;
	LET _cod_modelo = NULL;
	LET _cod_color = NULL;
	LET _placa = NULL;
	LET _ano_auto = NULL;
	LET _placa_taxi = NULL;
	LET _no_chasis = NULL;
	LET _valor_auto = NULL;

	If a_tipo_r = "T" THEN
	   foreach
	   	select cod_marca,
	   	       cod_modelo,
			   placa,
			   ano_auto
	   	  into _cod_marca,
	   	       _cod_modelo,
			   _placa,
			   _ano_auto
	   	  from recterce
	   	 where no_reclamo = _no_reclamo
		   and no_motor = trim(v_no_motor)
	   	 
	   	exit foreach;

	   end foreach
	else
		select cod_marca,
		       cod_modelo,
			   cod_color,
			   placa,
			   ano_auto,
			   placa_taxi,
			   no_chasis,
			   valor_auto
		  into _cod_marca,
		       _cod_modelo,
			   _cod_color,
			   _placa,
			   _ano_auto,
			   _placa_taxi,
			   _no_chasis,
			   _valor_auto
		  from emivehic
		 where no_motor = v_no_motor;
	end if
	 
	 select nombre
	   into _nombre_marca
	   from emimarca
	  where cod_marca = _cod_marca;

	 select nombre,
	        cod_tipoauto,
			capacidad,
			tamano
	   into _nombre_modelo,
	    	_cod_tipoauto,
			v_capacidad,
			v_tamano
	   from emimodel
	  where cod_modelo = _cod_modelo;

     select nombre
	   into v_tipoauto
	   from emitiaut
	  where cod_tipoauto = _cod_tipoauto;

	 select nombre,
	        cedula,
	        fecha_aniversario,
			telefono1
	   into v_nombre_conductor,
	        v_cedula,
	        v_fecha_aniversario,
			v_telefono1
	   from cliclien
	  where cod_cliente = _cod_conductor;

		LET v_edad = YEAR(TODAY) - YEAR(v_fecha_aniversario);

		IF MONTH(TODAY) < MONTH(v_fecha_aniversario) THEN
			LET v_edad = v_edad - 1;
		ELIF MONTH(v_fecha_aniversario) = MONTH(TODAY) THEN
			IF DAY(TODAY) < DAY(v_fecha_aniversario) THEN
				LET v_edad = v_edad - 1;
			END IF
		END IF

	 select nombre
	   into v_nombre_taller
	   from cliclien
	  where cod_cliente = _cod_taller;

     select nombre
       into v_tipo_licencia
       from rectilic 
	  where cod_tipolic = _cod_tipolic;

     select nombre
	   into v_color
	   from emicolor
	  where cod_color = _cod_color;
	  
	RETURN  _nombre_marca,
			v_color,		 
			_nombre_modelo,
			_placa,
			_ano_auto,
			_placa_taxi,
			v_no_motor,
			_no_chasis,
			_valor_auto,
			trim(v_nombre_taller),
			trim(v_nombre_conductor),
			v_edad,
			v_cedula,
			v_tipo_licencia,
			v_telefono1,
			v_tipoauto,
			v_capacidad,
			v_tiene_inspeccion,
			_cod_taller,
			v_tamano
			WITH RESUME;

END FOREACH


	


END PROCEDURE;