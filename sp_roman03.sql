-- A solicitud de la VP finanzas, es necesario ajustar el código de grupo de las pólizas (todas sus vigencias)
-- del archivo adjunto. El código que debe prevalecer es el código en la columna CodGrupo.
-- 
-- Creado    : 11/01/2024 - Autor: Armando Moreno M.

DROP PROCEDURE sp_roman03;
CREATE PROCEDURE sp_roman03()
Returning integer,char(50);

DEFINE _poliza	   CHAR(20);
define _cod_grupo  varchar(10);
define _mensaje    CHAR(50);
define _error      integer;

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_cob165.trc"; 
--trace on;

let _mensaje = "";

BEGIN

ON EXCEPTION SET _error 
 	RETURN _error,_mensaje;         
END EXCEPTION

foreach
	select no_documento,
	       cod_grupo
	  into _poliza,
	       _cod_grupo
	  from serafin

	update emipomae
	   set cod_grupo    = _cod_grupo
	 where no_documento = _poliza;

end foreach

return 0, "Actualizacion Exitosa";

end

end procedure