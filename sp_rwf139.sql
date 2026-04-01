-- Procedure que verifica si es posible perdida total													   
-- Creado por: Amado Perez 05/05/2015

drop procedure sp_rwf139;

create procedure sp_rwf139()
returning char(20), char(3), varchar(50);

DEFINE _codigo_agencia 		char(3);
DEFINE _no_documento 		char(20);
DEFINE _no_poliza    		char(10);
DEFINE _cant  	            integer;
DEFINE _cod_producto  	    char(5);
DEFINE _no_unidad           char(5);
DEFINE _no_motor        	varchar(30);
DEFINE _nuevo, _cuenta 			    smallint;

define _error           integer;
define _descripcion		varchar(50);
define _monto           dec(16,2);
define _retorno         integer;

--SET DEBUG FILE TO "sp_rwf137.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin

ON EXCEPTION SET _error 
 --	RETURN _error, "Error al buscar las piezas";         
END EXCEPTION

let _error = 0;
let _retorno = 0;

let _descripcion = "Verificacion exitosa";

FOREACH
  SELECT codigo_agencia, descripcion
    INTO _codigo_agencia, _descripcion
	FROM insagen
   WHERE banco_tarjeta is not null
     and codigo_agencia <> '004'
	 order by 1
	 
	LET _cuenta = 0;

	FOREACH
	  SELECT no_documento,
	         no_poliza
		INTO _no_documento,
		     _no_poliza
		FROM emipomae
       WHERE sucursal_origen = _codigo_agencia 
         AND cod_ramo = "002"	   
		 AND cod_subramo = '001'
		 AND estatus_poliza = 1
		 AND nueva_renov = "N"
		 AND actualizado = 1
	ORDER BY fecha_suscripcion desc   
	
	  SELECT COUNT(*)
	    INTO _cant
		FROM emipouni
	   WHERE no_poliza = _no_poliza;
	   
	  IF _cant > 1 THEN
	     CONTINUE FOREACH;
	  END IF
	  
	SELECT cod_producto,
	       no_unidad
	  INTO _cod_producto,
	       _no_unidad
	  FROM emipouni
	 WHERE no_poliza = _no_poliza;
		 
		IF _cod_producto = '00312' THEN
			SELECT no_motor
			  INTO _no_motor
			  FROM emiauto
			 WHERE no_poliza = _no_poliza
			   AND no_unidad = _no_unidad;
			   
			SELECT nuevo
			  INTO _nuevo
			  FROM emivehic
			 WHERE no_motor = _no_motor;
			 
			IF _nuevo = 0 THEN
			    LET _cuenta = _cuenta + 1;
				RETURN _no_documento, _codigo_agencia, _descripcion WITH RESUME;
			END IF
			
        END IF	
        IF _cuenta = 5 THEN
			EXIT FOREACH;
        END IF		
	END FOREACH
END FOREACH
END
end procedure