-- Modificado Armando Moreno	12/10/2004

--Procedimiento para borrar los endosos y polizas no act. mayores de 90 dias.
--Ademas, actualiza los endosos y las polizas no act. con periodo menor al cerrado con el periodo nvo.
--lo ultimo se identifica con parametro a_flag = 1
--Este procedure es llamado desde el programa cierre de prod.

drop procedure ap_sis61b_ap;
create procedure ap_sis61b_ap(a_no_poliza char(10))
returning integer,char(10);
--) returning char(10),char(20);

define _poliza 		char(20);
define _no_poliza 	char(10);
define _no_endoso   char(5);
define _error		integer;
define _existe		integer;
define _fecha_hoy 	date;
define _error_desc		char(50);

begin
on exception set _error
	return _error,_no_poliza;
end exception

let _fecha_hoy = sp_sis26();

--set debug file to "sp_sis61b.trc";
--trace on;

foreach
	select no_poliza,
		   no_endoso
	  into _no_poliza,
		   _no_endoso
	  from endedmae
	 where no_poliza in (
 select distinct no_poliza_r 
   from prdpreren 
  where periodo = '2025-06' 
   and tipo_ren =1 
   and pre_renovado = 1 
   and no_documento not in ('0222-02720-09','0224-00670-10','0223-05359-09','0222-01989-09')
    and no_poliza_r is not null
)
	   and cod_endomov = '024' 
    call sp_pro379(_no_poliza,_no_endoso) returning _error, _error_desc;
	
	return _error, _no_poliza with resume;
end foreach
end

return 0,_no_poliza;

end procedure;