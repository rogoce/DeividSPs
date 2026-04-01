-- Consulta de Reclamo

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

--DROP PROCEDURE sp_rwf21c;

CREATE PROCEDURE sp_rwf21c(a_no_reclamo CHAR(10) default "%")
RETURNING char(100),   --0
      	  char(30),
		  char(10),
		  char(10),
		  char(50),
		  char(18),
		  char(20),
		  char(5),
		  char(3),
		  char(50),
		  char(50),
		  varchar(255),
		  varchar(20), --datetime hour to fraction(5),
		  smallint,
		  char(50),
		  char(50),
		  smallint,
		  char(10),
		  char(30),
		  char(50),
		  char(30),
		  date,		   --21
		  char(20),
		  char(15),
		  char(100),
		  varchar(30),
		  char(10),
		  varchar(50),
		  date,
		  varchar(20),
		  varchar(50),
		  smallint,
		  char(3),
		  integer;	   --33

define v_nombre			char(100);
define v_cedula			char(30);
define v_vigencia_inic	char(10);
define v_vigencia_final	char(10);
define v_corredor       char(50);
define v_numrecla    	char(18);
define v_no_documento  	char(20);
define v_no_unidad      char(5);
define v_cod_ramo		char(3);
define v_ramo			char(50);
define v_lugar          char(50);
define v_narracion      varchar(255);
define v_hora_reclamo   varchar(20);--datetime hour to fraction(5);
define v_asis_legal     smallint;
define v_marca			char(50);
define v_modelo			char(50);
define v_ano_auto		smallint;
define v_placa			char(10);
define v_no_motor       char(30);
define v_color			char(50);
define v_chasis			char(30);
define v_fecha_siniestro date;
define v_suma_asegurada dec(16,2);
define v_desc_perdida   char(15);
define v_conductor      char(100);
define v_cedula_cond	varchar(30);
define v_telefono		char(10);
define v_email			varchar(50);
define v_fecha_tramite	date;
define v_hora_tramite	varchar(20);
define v_licencia       varchar(50); 
define v_edad           smallint;
define v_cod_sucursal   char(3);
define v_incidente      integer;

define _no_poliza		char(10);
define _cod_lugar     	char(3);
define _cod_asegurado	char(10);
define _cod_agente		char(5);
define _desc_transaccion varchar(60);
define _cadena          smallint;
define _perd_total      smallint;
define _cod_marca		char(5);
define _cod_color		char(5);
define _cod_modelo		char(3);
define _cod_conductor   char(10);
define _cod_tipolic 	char(3);
define _fecha_aniversario date;

--set debug file to "sp_rwf02.trc";

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT numrecla,
		   no_poliza,
		   no_documento,
		   no_unidad,
		   cod_lugar,
		   hora_reclamo,
		   asis_legal,
		   cod_asegurado,
		   no_motor,
		   fecha_siniestro,
		   perd_total,
		   cod_conductor,
		   cod_tipolic,
		   fecha_tramite,
		   hora_siniestro,
		   cod_sucursal,
		   incidente
	  INTO v_numrecla,         	
		   _no_poliza,				
		   v_no_documento,		
		   v_no_unidad,		
		   _cod_lugar,		
		   v_hora_reclamo,		
		   v_asis_legal,			
		   _cod_asegurado,
		   v_no_motor,
		   v_fecha_siniestro,
		   _perd_total,
		   _cod_conductor,
		   _cod_tipolic,
		   v_fecha_tramite,
		   v_hora_tramite,
		   v_cod_sucursal,
		   v_incidente
	  FROM recrcmae 		  
	 WHERE no_reclamo = a_no_reclamo
	   AND actualizado = 1

	SELECT nombre,
	       cedula,
		   e_mail
	  INTO v_nombre,
		   v_cedula,
		   v_email
	  FROM cliclien
	 WHERE cod_cliente = _cod_asegurado;

	SELECT cod_ramo,
	       vigencia_inic,
		   vigencia_final
	  INTO v_cod_ramo,
		   v_vigencia_inic,
		   v_vigencia_final
	  FROM emipomae
	 WHERE no_poliza = _no_poliza;	 

	SELECT nombre
	  INTO v_ramo
	  FROM prdramo
	 WHERE cod_ramo = v_cod_ramo;

    FOREACH
		SELECT cod_agente
		  INTO _cod_agente
		  FROM emipoagt
		 WHERE no_poliza = _no_poliza
		EXIT FOREACH;
	END FOREACH

	LET v_suma_asegurada = 0;

    FOREACH
		SELECT suma_asegurada
		  INTO v_suma_asegurada
		  FROM endeduni
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = v_no_unidad
		   AND suma_asegurada > 0
		EXIT FOREACH;
	END FOREACH


	SELECT nombre
	  INTO v_corredor
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	LET v_narracion = "";

	FOREACH
		SELECT desc_transaccion
		  INTO _desc_transaccion
		  FROM recrcde2
		 WHERE no_reclamo = a_no_reclamo

		LET _cadena = length(v_narracion) + length(trim(_desc_transaccion));

		IF _cadena < 255 THEN
			LET v_narracion = v_narracion || " " || trim(_desc_transaccion);
		ELSE 
		  	EXIT FOREACH;
		END IF
	END FOREACH

    SELECT cod_marca,
	       cod_color,
	       no_chasis,
	       cod_modelo,
		   placa,
		   ano_auto
	  INTO _cod_marca,
	       _cod_color,
           v_chasis,
	       _cod_modelo,
		   v_placa,
		   v_ano_auto
	  FROM emivehic
	 WHERE no_motor = v_no_motor;

    IF v_chasis IS NULL THEN
		LET v_chasis = "";
	END IF

    SELECT nombre
	  INTO v_marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

    SELECT nombre
	  INTO v_modelo
	  FROM emimodel
	 WHERE cod_marca = _cod_marca
	   AND cod_modelo = _cod_modelo;

    IF v_modelo IS NULL THEN
		LET v_modelo = "";
	END IF

    SELECT nombre
	  INTO v_color
	  FROM emicolor
	 WHERE cod_color = _cod_color;

    SELECT nombre
	  INTO v_lugar
	  FROM prdlugar
	 WHERE cod_lugar = 	_cod_lugar;

    SELECT nombre,
	       cedula,
		   fecha_aniversario,
		   telefono1
	  INTO v_conductor,
	       v_cedula_cond,
		   _fecha_aniversario,
		   v_telefono
	  FROM cliclien
	 WHERE cod_cliente = _cod_conductor;

	LET v_edad = YEAR(TODAY) - YEAR(_fecha_aniversario);

	IF MONTH(TODAY) < MONTH(_fecha_aniversario) THEN
		LET v_edad = v_edad - 1;
	ELIF MONTH(_fecha_aniversario) = MONTH(TODAY) THEN
		IF DAY(TODAY) < DAY(_fecha_aniversario) THEN
			LET v_edad = v_edad - 1;
		END IF
	END IF
    
    SELECT nombre
	  INTO v_licencia
	  FROM rectilic
	 WHERE cod_tipolic = _cod_tipolic;

    IF v_lugar IS NULL THEN
		LET v_lugar = "";
	END IF

    IF v_nombre IS NULL THEN
		LET v_nombre = "";
	END IF

    IF v_cedula IS NULL THEN
		LET v_cedula = "";
	END IF

    IF v_corredor IS NULL THEN
		LET v_corredor = "";
	END IF

    IF v_numrecla IS NULL THEN
		LET v_numrecla = "";
	END IF

    IF v_no_documento IS NULL THEN
		LET v_no_documento = "";
	END IF

    IF v_marca IS NULL THEN
		LET v_marca = "";
	END IF

    IF v_no_documento IS NULL THEN
		LET v_no_documento = "";
	END IF

    IF v_no_unidad IS NULL THEN
		LET v_no_unidad = "";
	END IF

    IF v_cod_ramo IS NULL THEN
		LET v_cod_ramo = "";
	END IF

    IF v_ramo IS NULL THEN
		LET v_ramo = "";
	END IF

    IF v_asis_legal IS NULL THEN
		LET v_asis_legal = 0;
	END IF

    IF v_ano_auto IS NULL THEN
		LET v_ano_auto = 0;
	END IF

    IF v_placa IS NULL THEN
		LET v_placa = "";
	END IF

    IF v_no_motor IS NULL THEN
		LET v_no_motor = "";
	END IF

    IF v_color IS NULL THEN
		LET v_color = "";
	END IF

    IF v_hora_reclamo IS NULL THEN
		LET v_hora_reclamo = "";
	END IF

    IF v_suma_asegurada IS NULL THEN
		LET v_suma_asegurada = 0;
	END IF

    IF v_conductor IS NULL THEN
		LET v_conductor = "";
	END IF

    IF v_cedula_cond IS NULL THEN
		LET v_cedula_cond = "";
	END IF

    IF v_telefono IS NULL THEN
		LET v_telefono = "";
	END IF

    IF v_email IS NULL THEN
		LET v_email = "";
	END IF

    IF v_licencia IS NULL THEN
		LET v_licencia = "";
	END IF

    IF v_edad IS NULL THEN
		LET v_edad = 0;
	END IF

	IF _perd_total = 1 then
	   let v_desc_perdida = "Perdida Total";
	ELSE
	   let v_desc_perdida = "";
	END IF	

	RETURN v_nombre,			
		   v_cedula,			
		   v_vigencia_inic,	
		   v_vigencia_final,
		   v_corredor,      
		   v_numrecla,    	
		   v_no_documento,  
		   v_no_unidad,     
		   v_cod_ramo,		
		   v_ramo,			
		   v_lugar,         
		   v_narracion,     
		   trim(v_hora_reclamo),  
		   v_asis_legal,    
		   v_marca,			
		   v_modelo,			
		   v_ano_auto,		
		   v_placa,			
		   v_no_motor,      
		   v_color,			
		   v_chasis,
		   v_fecha_siniestro,
		   v_suma_asegurada,
		   v_desc_perdida,
		   TRIM(v_conductor),    
		   v_cedula_cond,	
		   v_telefono,		
		   v_email,			
		   v_fecha_tramite,
		   v_hora_tramite,	
		   v_licencia,     
		   v_edad,         
		   v_cod_sucursal,
		   v_incidente 
	 	   WITH RESUME;

END FOREACH
END PROCEDURE;