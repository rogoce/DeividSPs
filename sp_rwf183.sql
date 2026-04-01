-- Consulta de Reclamo

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE sp_rwf183;

CREATE PROCEDURE sp_rwf183(a_no_reclamo char(10), a_cod_tercero char(10))
RETURNING char(100)  as asegurado,   --0
		  char(50)    as corredor,
		  char(18)    as numrecla,
		  char(20)    as no_documento,
		  char(5)     as no_unidad,
		  char(3)     as cod_ramo,
		  char(50)    as ramo,
		  varchar(255) as narracion,
		  varchar(20) as hora_reclamo, --datetime hour to fraction(5),
		  smallint   as asis_legal ,
		  char(30)    as no_motor,
		  date        as fecha_siniestro,		   --21
		  char(20)    as suma_asegurada,
		  date        as fecha_tramite,
		  varchar(20) as hora_tramite,
		  char(3)     as cod_sucursal,
		  integer     as incidente,
		  char(3)     as cod_evento,
		  char(1)     as estatus_reclamo,
          date        as fecha_reclamo,
		  char(10)    as no_tramite,
		  char(50)    as nombre_ajustador,
		  varchar(40) as user_windows,
		  char(8)     as user_deivid,
		  char(10)    as no_reclamo,
		  varchar(30) as email_ajustador,
		  smallint    as tiene_audiencia,
		  integer     as estatus_audiencia,
          char(10)    as cod_tercero,
          char(10)    as t_cod_conductor,
          varchar(30) as t_no_motor,
          integer     as t_ano_auto, 
          char(5)     as t_cod_marca,
          char(5)     as t_cod_modelo,
          date        as t_date_doc_comp,
          varchar(255) as t_descripcion,
          smallint     as t_doc_completa,
          varchar(30)  as t_no_chasis,
          char(10)     as t_placa,
          char(8)      as t_user_added,
          char(8)      as t_user_changed,
		  char(10)     as cod_asegurado,
		  char(10)     as cod_conductor,
		  char(10)     as no_poliza,
		  char(7)      as periodo,
		  smallint     as perd_total,
		  smallint     as cons_legal,
		  char(3)      as cod_compania,
		  date         as fecha_audiencia,
		  varchar(20)  as hora_audiencia,
		  char(30)     as parte_policivo,
		  varchar(20)  as no_resolucion,
		  smallint     as formato_unico,
		  varchar(50)  as email_agente,
		  smallint     as tipo_dano,
		  smallint     as liviano,
		  smallint     as mediano,
		  smallint     as fuerte,
		  varchar(200) as ls_cobertura,
		  varchar(50)  as email_consulta,
		  varchar(50)  as email_asistencia,
		  char(3)      as cod_ajustador,
		  date         as fecha_documento,
		  varchar(20)  as hora_siniestro,
		  varchar(40)  as user_actualiza,
		  varchar(50)  as nom_user_actualiza,
		  varchar(30)  as email_user_actualiza;
		 
		-- ls_coberturas
        -- email_consulta
        -- email_asistencia		
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
define _cod_modelo		char(5);
define _cod_conductor   char(10);
define _cod_tipolic 	char(3);
define _fecha_aniversario date;
define v_cod_evento     char(3);
define v_evento			varchar(50);
define v_estatus_reclamo char(1);

define _fecha_reclamo      	date;
define _no_tramite			char(10);
define _cod_ajustador      	char(10);
define _nombre_ajustador  	char(100);
define _nombre_conductor  	char(100);
define _user_windows		varchar(40);
define _user_deivid			char(8);
define _dominio_ultimus		varchar(20);
define _e_mail              varchar(30);
define _estatus_audiencia   integer;
define _tiene_audiencia     smallint;
define _periodo             char(7);
define _cons_legal          smallint;
define _cod_compania        char(3);
define _fecha_audiencia     date;
define _hora_audiencia   	varchar(20);
define _parte_policivo      char(30);
define _no_resolucion       varchar(20);
define _formato_unico       smallint;
define _email_agente        varchar(50);
define _tipo_dano           smallint;
define _liviano             smallint;
define _mediano             smallint;
define _fuerte              smallint;
define _cod_cobertura       char(5);
define _ls_cobertura		varchar(200);
define _nombre_cobertura    varchar(50);
define _deducible           varchar(10);
define _email_consulta      varchar(50);
define _email_asistencia    varchar(50);
define _fecha_documento     date;
define _hora_siniestro	    varchar(20);

define _t_cod_conductor char(10);
define _t_no_motor      varchar(30);
define _t_ano_auto      integer; 
define _t_cod_marca     char(5);
define _t_cod_modelo    char(5);
define _t_date_doc_comp date;
define _t_descripcion   varchar(255);
define _t_doc_completa  smallint;
define _t_no_chasis     varchar(30);
define _t_placa         char(10);
define _t_user_added    char(8);
define _t_user_changed  char(8);
define _t_user_windows  varchar(40);
define _t_e_mail        varchar(50);
define _t_nombre_user   varchar(30);

if a_no_reclamo = '481942' then
	set debug file to "sp_rwf21.trc";
	trace on;
end if

SET ISOLATION TO DIRTY READ;

FOREACH
	SELECT numrecla,
		   no_poliza,
		   no_documento,
		   no_unidad,
		   cod_lugar,
		   hora_reclamo,
		   asis_legal,
		   cons_legal,
		   cod_reclamante,
		   no_motor,
		   fecha_siniestro,
		   perd_total,
		   cod_conductor,
		   cod_tipolic,
		   fecha_tramite,
		   hora_tramite,
		   cod_sucursal,
		   incidente,
		   cod_evento,
		   estatus_reclamo,
           fecha_reclamo,
		   no_tramite,
		   ajust_interno,
		   tiene_audiencia,
		   estatus_audiencia,
		   periodo,
		   fecha_audiencia,
		   hora_audiencia,
		   parte_policivo,
		   no_resolucion,
		   formato_unico,
		   tipo_dano,
		   cod_compania,
           fecha_documento,
           hora_siniestro		   
	  INTO v_numrecla,         	
		   _no_poliza,				
		   v_no_documento,		
		   v_no_unidad,		
		   _cod_lugar,		
		   v_hora_reclamo,		
		   v_asis_legal,
		   _cons_legal,
		   _cod_asegurado,
		   v_no_motor,
		   v_fecha_siniestro,
		   _perd_total,
		   _cod_conductor,
		   _cod_tipolic,
		   v_fecha_tramite,
		   v_hora_tramite,
		   v_cod_sucursal,
		   v_incidente,
		   v_cod_evento,
		   v_estatus_reclamo,
           _fecha_reclamo,
		   _no_tramite,
		   _cod_ajustador,
		   _tiene_audiencia,
		   _estatus_audiencia,
		   _periodo,
		   _fecha_audiencia,
		   _hora_audiencia,
		   _parte_policivo,
		   _no_resolucion,
		   _formato_unico,
		   _tipo_dano,
		   _cod_compania,
		   _fecha_documento,
		   _hora_siniestro
	  FROM recrcmae 		  
	 WHERE no_reclamo = a_no_reclamo
	   AND actualizado = 1

    SELECT nombre
	  INTO v_evento
	  FROM recevent
	 WHERE cod_evento =  v_cod_evento;

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


	SELECT nombre,
	       email_reclamo
	  INTO v_corredor,
	       _email_agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;
     
    IF _email_agente is null then
        let _email_agente = "";
    END IF
	 
	--let v_corredor = replace(v_corredor, "(", "");
	--let v_corredor = replace(v_corredor, ")", "");

	LET v_narracion = "";

	FOREACH
		SELECT desc_transaccion
		  INTO _desc_transaccion
		  FROM recrcde2
		 WHERE no_reclamo = a_no_reclamo
		 
		IF _desc_transaccion IS NULL THEN
			LET _desc_transaccion = "";
        END IF		

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


	select nombre,
		   usuario	
	  into _nombre_ajustador,
	       _user_deivid
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select windows_user, e_mail
	  into _user_windows, _e_mail
	  from insuser
	 where usuario = _user_deivid;

    select dominio_ultimus
	  into _dominio_ultimus
	  from parparam
	 where cod_compania = '001';

    let	_user_windows = trim(_dominio_ultimus) || trim(_user_windows);
    
    select cod_conductor,
           no_motor, 
           ano_auto , 
           cod_marca , 
           cod_modelo , 
           date_doc_comp, 
           descripcion, 
           doc_completa , 
           no_chasis ,  
           placa , 
           user_added , 
           user_changed
     into  _t_cod_conductor,
           _t_no_motor, 
           _t_ano_auto , 
           _t_cod_marca , 
           _t_cod_modelo , 
           _t_date_doc_comp, 
           _t_descripcion, 
           _t_doc_completa , 
           _t_no_chasis ,  
           _t_placa , 
           _t_user_added , 
           _t_user_changed  
    from recterce
   where no_reclamo = a_no_reclamo
     and cod_tercero = a_cod_tercero; 
	 
	select windows_user, e_mail, descripcion
	  into _t_user_windows, _t_e_mail, _t_nombre_user
	  from insuser
	 where usuario = _t_user_added;

    select dominio_ultimus
	  into _dominio_ultimus
	  from parparam
	 where cod_compania = '001';

    let	_t_user_windows = trim(_dominio_ultimus) || trim(_t_user_windows);	 

    let _liviano = 0;
    let _mediano = 0;
    let _fuerte = 0;	

    if _tipo_dano = 1 then
		let _liviano = 1;
	elif _tipo_dano = 2 then
	    let _mediano = 1;
	elif _tipo_dano = 3 then
		let _fuerte = 3;
	end if

    let _ls_cobertura = '';
	
	foreach
		select a.cod_cobertura,
		       b.nombre,
			   a.deducible
		  into _cod_cobertura,
		       _nombre_cobertura, 
			   _deducible
		  from recrccob a inner join prdcober b on a.cod_cobertura = b.cod_cobertura
		 where a.no_reclamo = trim(a_no_reclamo)
		   
		let _ls_cobertura = trim(_ls_cobertura) || trim(_cod_cobertura)||'^'||trim(_nombre_cobertura)||'^'||_deducible||'^Si^~';
	end foreach
	
	let _email_asistencia = '';
	let _email_consulta = '';
	
	if v_asis_legal = 1 then
		select email
		  into _email_asistencia
		  from parcocue 
		 where cod_correo = '013' 
		   and activo = 1;
	end if
	
	if _cons_legal = 1 then
		select email
		  into _email_consulta
		  from parcocue 
		 where cod_correo = '014' 
		   and activo = 1;
	end if

    IF _t_user_windows IS NULL THEN
		LET _t_user_windows = "";
	END IF
	
    IF _t_e_mail IS NULL THEN
		LET _t_e_mail = "";
	END IF
    
    IF trim(_t_e_mail) = "" THEN
		LET _t_e_mail = "0";
	END IF
	
    IF _t_nombre_user IS NULL THEN
		LET _t_nombre_user = "";
	END IF
	
	IF _t_cod_conductor IS NULL THEN
		LET _t_cod_conductor = "";
	END IF
	
    IF _t_no_motor IS NULL THEN
		LET _t_no_motor = "";
	END IF
	
    IF _t_ano_auto IS NULL THEN
		LET _t_ano_auto = "";
	END IF
	
    IF _t_cod_marca IS NULL THEN
		LET _t_cod_marca = "";
	END IF
	
    IF _t_cod_modelo IS NULL THEN
		LET _t_cod_modelo = "";
	END IF
	
    IF _t_date_doc_comp IS NULL THEN
		LET _t_date_doc_comp = "";
	END IF
	
    IF _t_doc_completa IS NULL THEN
		LET _t_doc_completa = "";
	END IF
	
    IF _t_placa IS NULL THEN
		LET _t_placa = "";
	END IF
	
    IF _t_user_added IS NULL THEN
		LET _t_user_added = "";
	END IF
	
    IF _t_user_changed IS NULL THEN
		LET _t_user_changed = "";
	END IF

    IF v_hora_tramite IS NULL THEN
		LET v_hora_tramite = "";
	END IF

    IF _t_no_chasis IS NULL THEN
		LET _t_no_chasis = "";
	END IF

    IF _t_no_chasis IS NULL THEN
		LET _t_no_chasis = "";
	END IF

    IF _t_descripcion IS NULL THEN
		LET _t_descripcion = "";
	END IF

    IF _email_asistencia IS NULL THEN
		LET _email_asistencia = "";
	END IF
	
    IF _email_consulta IS NULL THEN
		LET _email_consulta = "";
	END IF

    IF v_lugar IS NULL THEN
		LET v_lugar = "";
	END IF

	--IF v_narracion IS NULL THEN
		LET v_narracion = "";
	--END IF
	
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
	
	IF v_modelo IS NULL THEN
		LET v_modelo = "";
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

    IF v_chasis IS NULL THEN
		LET v_chasis = "";
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
	
	RETURN v_nombre,				 --0
		   v_corredor,      		 --4
		   v_numrecla,    			 --5
		   v_no_documento,  		 --6
		   v_no_unidad,     		 --7
		   v_cod_ramo,				 --8
		   v_ramo,					 --9
		   v_narracion,     		 --11
		   trim(v_hora_reclamo),  	 --12
		   v_asis_legal,    		 --13
		   v_no_motor,      		 --18
		   v_fecha_siniestro,  -- 22 --21
		   v_suma_asegurada,		 --22
		   v_fecha_tramite,			 --28
		   v_hora_tramite,			 --29
		   v_cod_sucursal,			 --32
		   v_incidente,					 --33
		   v_cod_evento, 		   --35	 --34
           v_estatus_reclamo, 
           _fecha_reclamo,
           _no_tramite,
           _nombre_ajustador,
           _user_windows,
           _user_deivid,
           a_no_reclamo,
           _e_mail,
		   _tiene_audiencia,
           _estatus_audiencia,
           a_cod_tercero,
           _t_cod_conductor,
           _t_no_motor, 
           _t_ano_auto , 
           _t_cod_marca , 
           _t_cod_modelo , 
           _t_date_doc_comp, 
           _t_descripcion, 
           _t_doc_completa , 
           _t_no_chasis ,  
           _t_placa , 
           _t_user_added , 
           _t_user_changed,
		   _cod_asegurado,
		   _cod_conductor,
           _no_poliza,
		   _periodo,
           _perd_total,
		   _cons_legal,
		   _cod_compania,
		   _fecha_audiencia,
		   _hora_audiencia,
		   _parte_policivo,
		   _no_resolucion,
		   _formato_unico,
		   _email_agente,
		   _tipo_dano, 
		   _liviano,
		   _mediano,
		   _fuerte,
		   _ls_cobertura,
		   _email_consulta,
		   _email_asistencia,
		   _cod_ajustador,
		   _fecha_documento,
 		   _hora_siniestro,
		   _t_user_windows,
		   _t_nombre_user,
		   _t_e_mail WITH RESUME;   --36	 --35

END FOREACH
END PROCEDURE;
