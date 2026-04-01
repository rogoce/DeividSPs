--Procedimiento para realizar la carga en Rentabilidad2 para BONO DE RENTABILIDAD OPCION2
--Creado 19/04/2016	Henry Girón

DROP PROCEDURE sp_che221;
CREATE PROCEDURE sp_che221
--(a_compania CHAR(3), a_sucursal CHAR(3))
--RETURNING SMALLINT;
(a_compania         CHAR(3),
a_sucursal          CHAR(3),
a_periodo           CHAR(7),  
a_usuario           CHAR(8))
RETURNING SMALLINT,SMALLINT,CHAR(50);

-- SET DEBUG FILE TO "sp_che221.trc";
-- TRACE ON;
define _error           smallint;
define _error_desc      char(50);
define _cod_agente   	char(5);
define _pri_susc_aa	    dec(16,2);
define _crecimiento     dec(16,2);
define _sini_incu		dec(16,2);
define _pri_dev_max_aa	dec(16,2);
define _bono         	dec(16,2);
define _aplica          smallint;		   
define _error_isam		integer;

let _error              = 0;
let _error_isam         = 0;

set isolation to dirty read;
begin
on exception set _error,_error_isam,_error_desc
	return cast(_error as smallint),
	cast(_error_isam as smallint),
	cast(_error_desc as vachar(50)); 
end exception

let _bono = 0;
let _aplica = 0;

foreach	 
	select cod_agente,
		   bono,
		   aplica,                   
		   sum(pri_susc_aa),		  
		   sum(por_crecimiento),			  
		   sum(sini_inc),
		   sum(pri_dev_max_aa)
	  into _cod_agente,
		   _bono,
		   _aplica,
		   _pri_susc_aa,
		   _crecimiento,
		   _sini_incu,
		   _pri_dev_max_aa
	  from rentabilidad2
	 where periodo    = a_periodo
	   and aplica     = 1 
	   and bono     > 0 
	 group by cod_agente,bono,aplica
	 order by cod_agente,bono,aplica
			
insert into chqrentaii(
            periodo,
			cod_agente,
			comision,
			aplica,
			pri_susc_aa,
			por_crecimiento,
			sini_inc,
			pri_dev_max_aa,
			no_requis,
			tipo_requis,
			usuario)
	values(	a_periodo,
	        _cod_agente,
			_bono,
			_aplica,
		    _pri_susc_aa,
		    _crecimiento,
		    _sini_incu,
		    _pri_dev_max_aa,
			'',
			'',
            a_usuario			
			);									
	    
end foreach	  

return 0,0, "Actualizacion Exitosa ...";
end
END PROCEDURE                                                                                                                                                                                                 
