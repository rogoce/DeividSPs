-- Procedimiento que disminuye la reserva del reclamo y la aumenta

-- Creado    : 22/09/2015 - Autor: Armando Moreno

drop procedure sp_rea067;

create procedure sp_rea067()
returning char(10),
          decimal(16,2),
		  decimal(16,2),
		  decimal(16,2),
		  decimal(16,2);

define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _reserva_cob			dec(16,2);

DEFINE _cod_cobertura   	CHAR(5);  
DEFINE _cod_cliente     	CHAR(10); 
DEFINE _numrecla        	CHAR(18); 

DEFINE _no_tranrec_char 	CHAR(10); 
DEFINE _no_tran_char    	CHAR(10); 

DEFINE _version		    	CHAR(2);
DEFINE _aplicacion	    	CHAR(3);
DEFINE _valor_parametro 	CHAR(20);
DEFINE _valor_parametro2	CHAR(20);
DEFINE _fecha_no_server  	DATE;
DEFINE _periodo_rec     	CHAR(7);  

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _no_poliza           char(10);
define _reserva		        decimal(16,2);
define _cod_ramo            char(3);
define _no_reclamo          char(10);
define _variacion_acum      dec(16,2);
define _variacion           dec(16,2);
define _reserva2            dec(16,2);
define _variacion_acum2     dec(16,2);

set isolation to dirty read;

begin 

let _variacion_acum   = 0.00;
let _variacion        = 0.00;
let _variacion_acum2  = 0.00;
let _reserva2         = 0.00;
foreach

	select reserva, no_reclamo
	  into _reserva, _no_reclamo
	  from rec_pen
	 order by no_reclamo
	 
	 let _variacion_acum = 0;
	foreach
		select sum(r.variacion),
		       r.cod_cobertura
          into _variacion,
               _cod_cobertura		  
		 from rectrcob r, rectrmae t
		where r.no_tranrec = t.no_tranrec
		  and t.no_reclamo = _no_reclamo
		  and t.actualizado = 1
		  and t.periodo <= '2015-06'
		group by r.cod_cobertura
		having sum(r.variacion) <> 0
		
		let _variacion_acum = _variacion_acum + _variacion;
		
	end foreach	
    	 
    if _variacion_acum <> _reserva then
	    let _variacion_acum2 = _variacion_acum2 + _variacion_acum;
		let _reserva2 = _reserva2 + _reserva;
		
		update rec_pen
		   set reserva = _variacion_acum
		 where no_reclamo = _no_reclamo;
		 
		return _no_reclamo, _reserva, _variacion_acum,0,0 with resume;
	end if

end foreach
return _no_reclamo,0,0,_variacion_acum2,_reserva2;
end

end procedure