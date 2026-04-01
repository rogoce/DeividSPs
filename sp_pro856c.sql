

drop procedure sp_pro856c;
create procedure sp_pro856c(a_periodo char(7)) --(a_cod_sucursal char(3),a_fecha_desde date)
returning   integer,
			char(100);   -- _error

define _error_desc		char(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _suc_origen		char(3);
define _cod_sucursal	char(3);
define _suc_prom		char(3);
define _cod_ramo		char(3);
define _error_isam		smallint;
define _cnt_acr			smallint;
define _error			smallint;
define _ano				smallint;
define _fecha3y         date;
define _per3y			char(7);
--define _fecha_desde     date;

begin
on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

set isolation to dirty read;

let _ano         = a_periodo[1,4];		  
let _ano         = _ano - 3;				  
let _per3y       = _ano || a_periodo[5,7]; 
let _fecha3y     = sp_sis36(_per3y);

---let _fecha3y     =  _fecha_desde - 3 units year;  
--  return 0,'Exito'||cast(_fecha3y as varchar(16));

foreach
	select no_poliza,
           cod_sucursal,
		   no_documento
	  into _no_poliza, 
           _cod_sucursal,
		   _no_documento
      from emirepo  
     where estatus   in (5,9)
	   and fecha_selec <= _fecha3y

		begin
		on exception in (-239,-268)
		end exception
			
			INSERT INTO emirepobk(
					no_poliza,
					user_added,
					cod_no_renov,
					no_documento,
					renovar,
					no_renovar,
					fecha_selec,
					vigencia_inic,
					vigencia_final,
					saldo,
					cant_reclamos,
					no_factura,
					incurrido,
					pagos,
					porc_depreciacion,
					cod_agente,
					estatus,
					observacion,
					cod_sucursal,
					user_cobros ,
					no_poliza2,
					status_imp,
					no_recibo
					)
				SELECT
					no_poliza,
					user_added,
					cod_no_renov,
					no_documento,
					renovar,
					no_renovar,
					fecha_selec,
					vigencia_inic,
					vigencia_final,
					saldo,
					cant_reclamos,
					no_factura,
					incurrido,
					pagos,
					porc_depreciacion,
					cod_agente,
					estatus,
					observacion,
					cod_sucursal,
					user_cobros ,
					no_poliza2,
					status_imp,
					no_recibo
				FROM emirepo
			   where estatus in (5,9)
				 and fecha_selec <= _fecha3y
				 and no_poliza = _no_poliza;		
					
			  delete from emirepo
			   where estatus in (5,9)
				 and fecha_selec <= _fecha3y
				 and no_poliza = _no_poliza;
	end
	
	--return 0,"'"||_no_poliza||"'," with resume;
end foreach

end
return 0,'Exito';
end procedure
                                       
