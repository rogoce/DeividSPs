-- Procedimiento que crear una gestion en cobgesti
-- Creado    : 01/11/2016 - Autor: Henry Giron
-- SIS v.2.0 - - DEIVID, S.A.
DROP PROCEDURE sp_log018;

CREATE PROCEDURE "informix".sp_log018(a_no_documento varchar(20),
								   a_no_poliza    char(10),
								   a_codigo  char(10),
								   a_user_proceso char(15))
RETURNING integer,
          char(100); 
		      
DEFINE _cod_pagador		 	char(10);
DEFINE _bitacora		 	char(255);
DEFINE _nombre              CHAR(50);
DEFINE _existe	 	        integer;
DEFINE _fecha_actual		date;
DEFINE _fecha_gestion    	datetime year to second;
DEFINE _fecha_gestion2	 	datetime year to second;
DEFINE _fecha_marcar		date;
define _fecha_m   char(12);
define _error			integer;
define _error_isam      integer;
define _error_desc      char(50);
--set debug file to "sp_log018.trc";
--trace on;
set isolation to dirty read;


begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

LET _fecha_actual	= sp_sis26();
LET _fecha_gestion2	= _fecha_actual;

LET _fecha_gestion  = current year to second;
LET _fecha_gestion  = _fecha_gestion + 1 units second;		

If _fecha_gestion = _fecha_gestion2 Then
	LET _fecha_gestion  = _fecha_gestion + 1 units second;
End If

LET _fecha_gestion2 = _fecha_gestion;	

	select fecha_marcar 
	  into _fecha_marcar 
	  from avisocanc 
	 where no_aviso     = a_codigo 
	   and no_documento = a_no_documento;   
	   
	   let _fecha_m = trim(cast(_fecha_marcar as varchar(12))); -- "11/11/2011"; 

LET _bitacora = "SE ENTREGO AVISO DE CANCELACION, FECHA: "||_fecha_m||" - REF.:"||a_codigo;

SELECT cod_pagador
  INTO _cod_pagador
  FROM emipomae
 WHERE trim(no_poliza) = a_no_poliza;

SELECT count(*)
  INTO _existe
  FROM cobgesti
 WHERE no_poliza = a_no_poliza
   AND fecha_gestion = _fecha_gestion;

If _existe = 0 Then
	INSERT INTO cobgesti(
		   no_poliza,
		   fecha_gestion,
		   desc_gestion,
		   user_added,
		   no_documento,
		   fecha_aviso,
		   tipo_aviso,
		   cod_gestion,
		   cod_pagador)
	VALUES(
		   a_no_poliza,
		   _fecha_gestion,
		   _bitacora,
		   a_user_proceso,
		   a_no_documento,
		   '',
		   17,
		   '033',
		   _cod_pagador);
End If
--trace on;

return 0, "Actualizacion Exitosa ...";
end 	  
END PROCEDURE;