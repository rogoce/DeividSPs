-- Cargando la tabla parmailsend con datos de recrcmae
-- Federico Coronado 15/07/2013 


drop procedure ap_corrige_carta;

create procedure ap_corrige_carta()
RETURNING SMALLINT, CHAR(30);

DEFINE r_error        	integer;
DEFINE r_error_isam   	integer;
DEFINE r_descripcion  	CHAR(30);
Define _html_body		char(512);
define _secuencia       integer;
define _secuencia2      integer;
define ls_e_mail        varchar(100);
define _fecha_actual    date;
define _no_tramite      varchar(10);
define _cod_asegurado   varchar(10);
define _sender          varchar(100);
define _no_documento    varchar(15);
define _nombre          varchar(100);
define _cantidad        smallint;
define _email_final     char(384);
define _email_climail   varchar(100);
define _user_added 		varchar(8);
define _fecha_siniestro date;
define _no_unidad       char(5);
define _cnt_pma         smallint;
define _siniest_acumulada dec(16,5);

BEGIN
ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_pro596.trc"; 
--trace on;


foreach
	select poliza,
	       siniest_acumulada
	  into _no_documento,
		   _siniest_acumulada
	  from deivid_tmp:corrige_MSO
	  
	update deivid_tmp:carta16
       set siniest_acumulada = _siniest_acumulada
     where poliza = _no_documento;	   

END FOREACH

RETURN r_error, r_descripcion  WITH RESUME;

END
end procedure