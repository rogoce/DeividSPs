-- Cargando la tabla parmailsend con datos de recrcmae
-- Federico Coronado 15/07/2013 


drop procedure sp_par386b1;

create procedure sp_par386b1(a_secuencia INTEGER) 
RETURNING VARCHAR(20), SMALLINT;

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
define _llave           integer;

BEGIN
ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error,1;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_pro596.trc"; 
--trace on;


	select poliza,
	       opcion
	  into _no_documento,
	       _cnt_pma
	  from deivid_tmp:carta16dep
     where secuencia = a_secuencia;
	   	

  RETURN _no_documento, _cnt_pma;

END
end procedure