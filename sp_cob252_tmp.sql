-- Procedimiento que Genera las Cancelaciones Automaticas Proceso de Avisos de Cancelacion.
-- Creado     : 27/09/2010  -- Autor: Henry Giron.	-- execute procedure sp_cob252('501536','00014','HGIRON')
-- Para colocarle la observacion a las polizas que fueron canceladas que no teneian la observacion.
-- SIS v.2.0 -- DEIVID, S.A.
Drop procedure sp_cob252_tmp;
create procedure sp_cob252_tmp()
returning smallint,Char(255);
define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _no_endoso		char(5);
define _no_factura		char(10);
define _user_added		char(8);
define _estatus_poliza	smallint;
define _fecha_end_canc	date;
define _cancelada		smallint;
define _fecha_canc		date;
define _fecha_perdida	date;
define _fecha_vence 	date;

-- Vigencia Actual
define _no_poliza2		char(10);
define _estatus_poliza2 smallint;
define _desc_estatus	char(10);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _descripcion		char(50);
define _cantidad		integer;
define _cod_cliente		char(10);
define _saldo_canc		dec(16,2);

--set debug file to "sp_cob252.trc";
--trace on;

set isolation to dirty read;
--return 0,"Realizado Exitosamente. En Base de prueba de Sistema.";

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _cantidad   = 0;
let _saldo_canc = 0;
 
foreach	
 select no_poliza,
		no_endoso,
		no_documento
   into _no_poliza, 
		_no_endoso, 
		_no_documento
   from avisocanc 
  where estatus = "Z"  
--    and no_documento not in ('0211-00082-04')

		foreach
		 select no_unidad
		   into _no_unidad
		   from emipouni
		  where no_poliza = _no_poliza

			select count(*)
			  into _cantidad
			  from endedde2
			 WHERE no_poliza = _no_poliza  
			   AND no_endoso = _no_endoso 
			   AND no_unidad = _no_unidad;

			   if _cantidad = 0 then

				-- Cancelacion de Unidades
				INSERT INTO endedde2(
			    no_poliza,
				no_endoso,
			    no_unidad,
			    descripcion
				)
				SELECT _no_poliza,
					   _no_endoso,
					   _no_unidad,
					   descripcion
				  FROM endedde2
		         WHERE no_poliza = '557015'	   -- Mientras investigo como colocar un blod desde un insert en informix. Henry     00001  '01-1186686'
		           AND no_endoso = '00001'	   -- OBSERVACION: MEDIANTE EL PRESENTE ENDOSO SE CANCELA LA PÓLIZA ARRIBA DESCRITA POR FALTA DE PAGO 
		           AND no_unidad = '00001';	
		           
	          end if	

		end foreach 
end foreach
--trace off;
if _error <> 0 then
	return 1,"Error de Proceso." ;
else
	return 0,"Realizado Exitosamente.";
end if

end 

end procedure
 
 
   