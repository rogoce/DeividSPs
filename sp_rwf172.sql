-- Procedimiento que Busca el banco y chequera dado el ramo de excepcion

-- Creado    : 19/05/2006 - Autor: Armando Moreno.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

DROP PROCEDURE sp_rwf172;

CREATE PROCEDURE "informix".sp_rwf172()
returning char(10) as no_reclamo,
          char(10) as cod_tercero,
		  char(10) as no_tramite,
		  char(30) as motor_reclamante,
		  char(5) as marca_reclamante,
		  char(5) as modelo_reclamante,
		  char(10) as placa_reclamante,
		  smallint as anoauto_reclaman,
		  char(30) as chasis_reclamante,		  
          char(100) as asegurado,   --0
      	  char(30) as cedula,
		  char(10) as vigencia_inic,
		  char(10) as vigencia_final,
		  char(50) as corredor,
		  char(18) as numrecla,
		  char(20) as no_documento,
		  char(5) as no_unidad,
		  char(3) as cod_ramo,
		  char(50) as ramo,
		  char(50) as lugar,
		  varchar(255) as narracion,
		  varchar(20) as hora_reclamo, --datetime hour to fraction(5),
		  smallint as asis_legal,
		  date as fecha_tramite,		   --21
		  varchar(40) as ajustador,
		  varchar(30) as ajust_email,
          smallint as bandera;

define _no_reclamo       char(10);
define _cod_tercero      char(10);
define _no_tramite       char(10);
define _motor_reclamante char(30);
define _marca_reclamante char(5);
define _modelo_reclamante char(5);
define _placa_reclamante  char(10);
define _anoauto_reclaman  smallint;
define _chasis_reclamante char(30);

define _nombre			char(100);
define _cedula			char(30);
define _vigencia_inic	char(10);
define _vigencia_final	char(10);
define _corredor       char(50);
define _numrecla    	char(18);
define _no_documento  	char(20);
define _no_unidad      char(5);
define _cod_ramo		char(3);
define _ramo			char(50);
define _lugar          char(50);
define _narracion      varchar(255);
define _hora_reclamo   varchar(20);--datetime hour to fraction(5);
define _asis_legal     smallint;
define _marca			char(50);
define _modelo			char(50);
define _ano_auto		smallint;
define _placa			char(10);
define _no_motor       char(30);
define _color			char(50);
define _chasis			char(30);
define _fecha_siniestro date;
define _suma_asegurada dec(16,2);
define _desc_perdida   char(15);
define _conductor      char(100);
define _cedula_cond	varchar(30);
define _telefono		char(10);
define _email			varchar(50);
define _fecha_tramite	date;
define _hora_tramite	varchar(20);
define _licencia       varchar(50); 
define _edad           smallint;
define _cod_sucursal   char(3);
define _incidente      integer;

define _cod_ajustador  char(3);
define _user_deivid    char(8);
define _user_windows   varchar(40);
define _e_mail              varchar(30);
define _dominio_ultimus		varchar(20);
define _cod_evento     char(3);
define _evento			varchar(50);

SET ISOLATION TO DIRTY READ;
FOREACH
 SELECT recpanter.no_reclamo,   
         recpanter.cod_tercero,   
         recpanter.no_tramite,   
         recpanter.motor_reclamante,   
         recpanter.marca_reclamante,   
         recpanter.modelo_reclamante,   
         recpanter.placa_reclamante,   
         recpanter.anoauto_reclaman,   
         recpanter.chasis_reclamante  
	INTO _no_reclamo,
	     _cod_tercero,
		 _no_tramite,
		 _motor_reclamante,
		 _marca_reclamante,
		 _modelo_reclamante,
		 _placa_reclamante,
		 _anoauto_reclaman,
		 _chasis_reclamante
    FROM recpanter  
   WHERE recpanter.estatus = 0
   
   select ajust_interno,
          fecha_tramite
     into _cod_ajustador,
	      _fecha_tramite
	 from recrcmae
	where no_reclamo = _no_reclamo;

 	select usuario	
	  into _user_deivid
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
	 
	call sp_rwf21(_no_reclamo) 
	returning 
	_nombre,				 --0
	_cedula,				 --1
	_vigencia_inic,			 --2
	_vigencia_final,		 --3
	_corredor,      		 --4
	_numrecla,    			 --5
	_no_documento,  		 --6
	_no_unidad,     		 --7
	_cod_ramo,				 --8
	_ramo,					 --9
	_lugar,         		 --10
	_narracion,     		 --11
	_hora_reclamo,  	 --12
	_asis_legal,    		 --13
	_marca,					 --14
	_modelo,				 --15
	_ano_auto,				 --16
	_placa,					 --17
	_no_motor,      		 --18
	_color,					 --19
	_chasis,				 --20
	_fecha_siniestro,  -- 22 --21
	_suma_asegurada,		 --22
	_desc_perdida,			 --23
	_conductor,    	 --24
	_cedula_cond,			 --25
	_telefono,				 --26
	_email,					 --27
	_fecha_tramite,			 --28
	_hora_tramite,			 --29
	_licencia,     			 --30
	_edad,         			 --31
	_cod_sucursal,			 --32
	_incidente,					 --33
	_cod_evento, 		   --35	 --34
	_evento;

Return _no_reclamo,
	   _cod_tercero,
	   _no_tramite,
	   _motor_reclamante,
	   _marca_reclamante,
	   _modelo_reclamante,
	   _placa_reclamante,
	   _anoauto_reclaman,
	   _chasis_reclamante,
       _nombre,				 --0
	   _cedula,				 --1
	   _vigencia_inic,			 --2
	   _vigencia_final,		 --3
	   _corredor,      		 --4
	   _numrecla,    			 --5
	   _no_documento,  		 --6
	   _no_unidad,     		 --7
	   _cod_ramo,				 --8
	   _ramo,					 --9
	   _lugar,         		 --10
	   _narracion,     		 --11
	   trim(_hora_reclamo),  	 --12
	   _asis_legal,    		 --13
	   _fecha_siniestro,
	   _user_windows,
	   _e_mail,
	   0 WITH RESUME;  -- 22 --21
END FOREACH

END PROCEDURE
