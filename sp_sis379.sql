-- Procedimiento que Realiza la Busqueda de la firma si lleva o no la poliza a imprimir

-- Creado    : 03/04/2003 - Autor: Amado Perez  

drop procedure sp_sis379;

create procedure sp_sis379(a_poliza CHAR(10), a_endoso CHAR(5))
 RETURNING CHAR(20), char(30);
--}
DEFINE _firma  			CHAR(25);
DEFINE _ls_autoriza 	CHAR(20);
DEFINE _ls_cotizacion 	CHAR(10);
DEFINE _li_cotizacion 	int;
define _linea_rapida 	integer;
define _user_added 		char(10);
define _descripcion 	char(30);
DEFINE _cod_sucursal 	CHAR(3);
define _cotizacion_1 	char(2);

--SET DEBUG FILE TO "sp_sis373.trc"; 
--trace on;


--IF a_endoso <> '00000' THEN
    RETURN "","";
--END IF

let _linea_rapida = 0;
let _descripcion = "";
let _ls_autoriza = "";

FOREACH WITH HOLD
	SELECT cotizacion,
		   linea_rapida,
		   user_added,
		   cod_sucursal,
		   cotizacion[1,2]
	  INTO _ls_cotizacion,
		   _linea_rapida,
		   _user_added,
		   _cod_sucursal,
		   _cotizacion_1
	  FROM emipomae
	 WHERE no_poliza = a_poliza
	   AND nueva_renov = 'N'

    IF _cod_sucursal <> '009' THEN
		if(_cotizacion_1 <> 'WF') and (_cotizacion_1 <> 'WS') then -- WF WS son cotizaciones que son realizadas desde la web y son de tipo string 
		
			LET _li_cotizacion = _ls_cotizacion;

			SELECT TRIM(userautoriza)
			  INTO _ls_autoriza
			  FROM wf_cotizacion
			 WHERE nrocotizacion = _li_cotizacion;

			SELECT descripcion
			  INTO _descripcion
			  FROM insuser
			 WHERE windows_user = _ls_autoriza;
		end if
    END IF

	RETURN _ls_autoriza,
		   _descripcion
		   WITH RESUME;

END FOREACH
end procedure;
