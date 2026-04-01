-- Cargando la tabla parmailsend con datos de Red Ancon Premier Care
-- Creado    : 24/07/2024 - Autor: Henry Giron


drop procedure sp_par388a;

create procedure sp_par388a(a_secuencia INTEGER) 
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
define _opcion           smallint;
define _llave           integer;
define _generar_carnet  char(15);

BEGIN
ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error,1;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
let _generar_carnet = '';

--set debug file to "sp_pro596.trc"; 
--trace on;


	select poliza,
	       trim(generar_carnet)
	  into _no_documento,
	       _generar_carnet
	  from deivid_tmp:carta_021
     where secuencia = a_secuencia;
	 
		if _generar_carnet = 'Genera Carnet' then
			let _opcion = 0;
		elif _generar_carnet = 'NO CARNET' then
			let _opcion = 1;
		end if	
	   	

  RETURN _no_documento, _opcion;

END
end procedure