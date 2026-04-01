--- Codigo: Colocar Firma Autorizada de Endoso de cancelacion Automatica en INSUSER
--- Creado: Henry Giron 
--- Fecha:  25/08/2010

drop procedure sp_seg009;
create procedure "informix".sp_seg009(a_usuario CHAR(8))
RETURNING SMALLINT, CHAR(30);

DEFINE _cant          	INTEGER;

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
DEFINE _usuario_ant     CHAR(8);
  
BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--SET DEBUG FILE TO "sp_seg009.trc"; 
--TRACE ON;
select Firma_end_canc
  into _usuario_ant
  from parparam;

update insuser
   set Firma_end_canc = 0
 where trim(usuario) = trim(_usuario_ant); -- <> trim(a_usuario);

{update insuser
   set Firma_end_canc = 1
 where trim(usuario) = trim(a_usuario); -- <> trim(a_usuario);}

update parparam
   set Firma_end_canc = trim(a_usuario);

RETURN r_error, r_descripcion ;

END

end procedure;
