
drop procedure sp_pro534bk;

create procedure sp_pro534bk()
RETURNING varchar(10), varchar(10),varchar(15),varchar(8),date,varchar(5);

DEFINE r_error        	integer;
DEFINE r_error_isam   	integer;
DEFINE r_descripcion  	CHAR(30);
Define _html_body		char(512);
define _secuencia       integer;
define _secuencia2      integer;
define ls_e_mail        varchar(50);
define _fecha_actual    date;
define _no_tramite      varchar(10);
define _cod_contratante varchar(10);
define _sender          varchar(100);
define _no_documento    varchar(15);
define _nombre          varchar(100);
define _cantidad        smallint;
define _email_final     char(384);
define _email_climail   varchar(50);
define _user_added 		varchar(8);
define _fecha_siniestro date;
define _no_unidad       char(5);
define _cnt_pma         smallint;

BEGIN
ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion,"","","","";
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_pro534.trc"; 
--trace on;

let _fecha_actual = sp_sis26();
let _fecha_actual = _fecha_actual - 1 units day;
let ls_e_mail = "";
let _email_final = '';
let _email_climail = '';

foreach
	select no_tramite,
	       cod_contratante,
		   b.no_documento,
		   a.user_added, 
		   a.fecha_siniestro,
		   a.no_unidad
	  into _no_tramite,
		   _cod_contratante,
		   _no_documento,
		   _user_added,
		   _fecha_siniestro,
		   _no_unidad
	  from recrcmae a inner join emipomae b on a.no_poliza = b.no_poliza
     where fecha_reclamo = _fecha_actual
	   and cod_ramo in ('020','002','023')
	   and no_tramite is not null
	   
	--Verificamos si el reclamo llego por el archivo txt que envia panama asistencia 
	---*** si es asi el proceso debe realizar el envio por correo de la apertura del reclamo.
	let _cnt_pma = sp_rec206f (_no_documento,_no_unidad, _fecha_siniestro);
	
	if _cnt_pma = 0 then
		continue foreach;
	end if
	
		return _no_tramite,
			   _cod_contratante,
			   _no_documento,
			   _user_added,
	 		   _fecha_siniestro,
			   _no_unidad with resume;
end foreach
end
end procedure