-- Realiza cambios de Enmoaut a Emiauto
-- Creado    : 06/04/2016 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_pro4955('877853','00004')
  
drop procedure sp_pro4955;

create procedure sp_pro4955(a_no_poliza char(10), a_no_endoso char(5))
returning	int,
			char(100);

define _error_desc,_mensaje		CHAR(100);
DEFINE _no_unidad       CHAR(5);
DEFINE _cod_tipoveh     CHAR(3);
DEFINE _uso_auto        CHAR(1);
define _error_isam		integer;
define _error			integer;
DEFINE _no_documento     CHAR(20);
define _no_poliza char(10);
set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || trim(a_no_poliza) || ' no_endoso: ' || trim(a_no_endoso);
	return _error, _error_desc;
end exception

--set debug file to "sp_pro4955.trc";
--trace on;
--return _error, _error_desc;

BEGIN

		select no_documento
		  into _no_documento
		  from emipomae
		 where no_poliza = a_no_poliza;

	   FOREACH	
		SELECT no_unidad,
		       cod_tipoveh,
               uso_auto			   
		  INTO _no_unidad,
		       _cod_tipoveh,
			   _uso_auto
		  FROM endmoaut
		 WHERE no_poliza = a_no_poliza
		   AND no_endoso = a_no_endoso

			IF _no_unidad IS NOT NULL THEN
				IF _cod_tipoveh IS NOT NULL THEN
				    IF _uso_auto IS NOT NULL THEN
					
						--UPDATE emiauto
						--   SET cod_tipoveh = _cod_tipoveh,
						--          uso_auto = _uso_auto
						-- WHERE no_poliza   = a_no_poliza
						--   AND no_unidad   = _no_unidad;
						   
						foreach
							select no_poliza
							  into _no_poliza
							  from emipomae
							 where actualizado  = 1
							   and no_documento = _no_documento
							   
							UPDATE emiauto
							   SET cod_tipoveh = _cod_tipoveh,
								   uso_auto    = _uso_auto
							 WHERE no_poliza   = _no_poliza
							   AND no_unidad   = _no_unidad;   
							 
						end foreach						   
						   
					ELSE
						LET _mensaje = 'No Existe Uso de Vehiculo, Por Favor Actualice Nuevamente ...';
						RETURN 1, _mensaje;
					END IF						   
				ELSE
					LET _mensaje = 'No Existe Tipo de Vehiculo, Por Favor Actualice Nuevamente ...';
					RETURN 1, _mensaje;
				END IF
			ELSE
				LET _mensaje = 'No Existe Unidad, Por Favor Actualice Nuevamente ...';
				RETURN 1, _mensaje;
			END IF
		END FOREACH		
	END
	
end
--trace off;

return 0,'Actualización Exitosa';
end procedure;