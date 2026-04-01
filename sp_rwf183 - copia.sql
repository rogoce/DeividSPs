-- WorkFlow - Busqueda por Asegurado

-- Creado    : 11/03/2004 - Autor: Amado Perez  
-- Modificado: 24/03/2004 - Autor: Demetrio Hurtado Almanza
-- Modificado: 12/04/2004 - Autor: Demetrio Hurtado Almanza
			   -- Se agregaron a la salida el user_windows, user_deivid, no_reclamo
			    
drop procedure sp_rwf183;

create procedure "informix".sp_rwf183(a_no_reclamo char(10), a_cod_tercero char(10))
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
		  integer,
		  char(3),
		  varchar(50),
		  char(1),
          date,
		  char(10),
		  char(50),
		  char(100),
		  varchar(40),
		  char(8),
		  char(10),
		  varchar(30),
		  integer;

define _fecha_reclamo      	date;
define _no_tramite			char(10);
define _cod_ajustador      	char(10);
define _cod_conductor      	char(10);
define _nombre_ajustador  	char(100);
define _nombre_conductor  	char(100);
define _user_windows		varchar(40);
define _user_deivid			char(8);
define _dominio_ultimus		varchar(20);
define _e_mail              varchar(30);
define _estatus_audiencia   integer;

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

define v_cod_evento     char(3);
define v_evento			varchar(50);
define v_estatus_reclamo char(1);

SET ISOLATION TO DIRTY READ;


foreach with hold
	select fecha_reclamo,
		   no_tramite,
		   ajust_interno,
		   cod_conductor,
		   estatus_audiencia
	  into _fecha_reclamo,
		   _no_tramite,
		   _cod_ajustador,
		   _cod_conductor,
		   _estatus_audiencia
	  from recrcmae
	 where no_reclamo = a_no_reclamo

	select nombre
	  into _nombre_conductor
	  from cliclien
	 where cod_cliente = _cod_conductor;

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
    
    call sp_rwf21(a_no_reclamo) returning 
    v_nombre,				 --0
    v_cedula,				 --1
    v_vigencia_inic,		 --2
    v_vigencia_final,		 --3
    v_corredor,      		 --4
    v_numrecla,    			 --5
    v_no_documento,  		 --6
    v_no_unidad,     		 --7
    v_cod_ramo,				 --8
    v_ramo,					 --9
    v_lugar,         		 --10
    v_narracion,     		 --11
    v_hora_reclamo,  	 --12
    v_asis_legal,    		 --13
    v_marca,				 --14
    v_modelo,				 --15
    v_ano_auto,				 --16
    v_placa,				 --17
    v_no_motor,      		 --18
    v_color,				 --19
    v_chasis,				 --20
    v_fecha_siniestro,  -- 22 --21
    v_suma_asegurada,		 --22
    v_desc_perdida,			 --23
    v_conductor,    	 --24
    v_cedula_cond,			 --25
    v_telefono,				 --26
    v_email,			 --27
    v_fecha_tramite,		 --28
    v_hora_tramite,			 --29
    v_licencia,     		 --30
    v_edad,         		 --31
    v_cod_sucursal,			 --32
    v_incidente,			 --33
    v_cod_evento, 		   --35	 --34
    v_evento,
    v_estatus_reclamo;        
 
    return  v_nombre,				 --0
            v_cedula,				 --1
            v_vigencia_inic,		 --2
            v_vigencia_final,		 --3
            v_corredor,      		 --4
            v_numrecla,    			 --5
            v_no_documento,  		 --6
            v_no_unidad,     		 --7
            v_cod_ramo,				 --8
            v_ramo,					 --9
            v_lugar,         		 --10
            v_narracion,     		 --11
            trim(v_hora_reclamo),  	 --12
            v_asis_legal,    		 --13
            v_marca,				 --14
            v_modelo,				 --15
            v_ano_auto,				 --16
            v_placa,				 --17
            v_no_motor,      		 --18
            v_color,				 --19
            v_chasis,				 --20
            v_fecha_siniestro,  -- 22 --21
            v_suma_asegurada,		 --22
            v_desc_perdida,			 --23
            TRIM(v_conductor),    	 --24
            v_cedula_cond,			 --25
            v_telefono,				 --26
            TRIM(v_email),			 --27
            v_fecha_tramite,		 --28
            v_hora_tramite,			 --29
            v_licencia,     		 --30
            v_edad,         		 --31
            v_cod_sucursal,			 --32
            v_incidente,			 --33
            v_cod_evento, 		   --35	 --34
            v_evento,
            v_estatus_reclamo,     
            _fecha_reclamo,
            _no_tramite,
            _nombre_ajustador,
            _nombre_conductor,
            _user_windows,
            _user_deivid,
            a_no_reclamo,
            _e_mail,
            _estatus_audiencia
		   with resume;

end foreach

drop table tmp_filtro;
drop table tmp_reclamo;

end procedure;
