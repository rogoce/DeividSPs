-- Realiza cambios de Enmoaut a Emiauto --JEPEREZ: 14122021
-- Creado    : 14/12/20201 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_sis417o('877853','00004')

drop procedure sp_sis417o;

create procedure "informix".sp_sis417o(a_no_poliza char(10), a_no_endoso char(5))
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
define _opcion           char(1);
define _cod_producto  	char(5);
define _cod_ramo    	char(3);
define _cod_subramo  	char(3);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	let _error_desc = trim(_error_desc) || 'no_poliza: ' || trim(a_no_poliza) || ' no_endoso: ' || trim(a_no_endoso);
	return _error, _error_desc;
end exception

--set debug file to "sp_sis417o.trc";
--trace on;
--return _error, _error_desc;

BEGIN
	 
		select no_documento, cod_ramo, cod_subramo
		  into _no_documento, _cod_ramo, _cod_subramo
		  from emipomae
		 where no_poliza = a_no_poliza;

		if _cod_ramo Not in('002') and  _cod_subramo Not in('002','001')  then
			return 0,'';
		end if

		FOREACH	
		select no_unidad,
			   cod_producto
		  into _no_unidad,
			   _cod_producto
		  from endeduni
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		   
			If (_cod_ramo  = '002'  and _cod_subramo = '001'  and ( _cod_producto   = '00312' or  _cod_producto   = '02894' or  _cod_producto   = '02699' or  _cod_producto   = '04563' or  _cod_producto   = '07287'))  Then  

			   FOREACH	
				SELECT cod_tipoveh,
					   uso_auto,
					   opcion			   
				  INTO _cod_tipoveh,
					   _uso_auto,
					   _opcion
				  FROM endmoaut
				 WHERE no_poliza = a_no_poliza
				   AND no_endoso = a_no_endoso
				   AND no_unidad = _no_unidad

					IF _no_unidad IS NOT NULL THEN
						IF _cod_tipoveh IS NOT NULL THEN
							IF _uso_auto IS NOT NULL THEN				

								   
								foreach
									select no_poliza
									  into _no_poliza
									  from emipomae
									 where actualizado  = 1
									   and no_documento = _no_documento
									   and no_poliza = a_no_poliza
									   
									UPDATE emiauto
									   SET cod_tipoveh = _cod_tipoveh,
										   uso_auto    = _uso_auto,
										   opcion      = _opcion
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
			end if			
		END FOREACH			
	END
	
end
--trace off;

return 0,'Actualización Exitosa';
end procedure;

