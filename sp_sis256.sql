

drop procedure sp_sis256;
create procedure "informix".sp_sis256() 
returning	integer		as err,
			varchar(100)	as descripcion;
			
define _no_documento	char(20);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _desc_error		varchar(50);
define _error_desc		varchar(50);
define _mensaje			varchar(50);
define _valor			varchar(50);
define _error			smallint;
define _return			smallint;
define _vigencia_inic	date;
define _fecha_hoy 		date;
define _ld_prima_neta_t dec(16,2);
define _prima_neta, _prima_neta_sin, _suma_asegurada, _prima_resultado  dec(16,2);
define _calculo         dec(5,2);
define _cod_producto    char(5);


--set debug file to "sp_sis256.trc";
--trace on;


set isolation to dirty read;

let _no_poliza = null;
let _fecha_hoy = today;

foreach with hold
	select distinct no_poliza,
		   no_endoso
	  into _no_poliza,
		   _no_endoso
	  from deivid_tmp:det_emifacon
	 where procesado != 1
	 order by 1,2
	  
	let _error = sp_par12a(_no_poliza,_no_endoso);
	
	if _error = 0 then
		update deivid_tmp:det_emifacon
		   set procesado = 1
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;
	else
		update deivid_tmp:det_emifacon
		   set procesado = _error
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;
		   
		return _error, _no_poliza || _no_endoso with resume;
	end if
end foreach

return 0,'Actualización Exitosa';

end procedure;