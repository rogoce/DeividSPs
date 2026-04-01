-- Procedure para auditar unidades de tmp_end_xls
-- Creado    : 30/10/2017 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A. 
-- execute procedure sp_aud56(); 
--drop procedure sp_aud56; 

create procedure "informix".sp_aud56() 
Returning smallint;											
		  
define _no_poliza	        char(10);
define _no_endoso	        char(5);
define _no_factura          char(15);
define _cantidad			integer;
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

set isolation to dirty read;

begin 
on exception set _error
	return _error; 
end exception 

set debug file to "sp_aud56.trc";
trace on;

select *
  from tmp_end_xls 
  into temp tmp_end_xls_tmp; 
  let _cantidad = 0;

foreach 
	select 	no_factura
	  into _no_factura
	  from tmp_end_xls_tmp
	 
	 --call sp_sis21(_poliza) returning _no_poliza;
	 
		select e.no_poliza,e.no_endoso,count(u.no_unidad)
          into _no_poliza,_no_endoso,_cantidad					   
		  from endedmae e, endeduni u
		 where e.no_factura = _no_factura
		   and e.no_poliza = u.no_poliza
		   and e.no_endoso = u.no_endoso
		   and e.actualizado = 1
		   group by e.no_poliza,e.no_endoso;				   
		   
		   if _no_poliza is null then
		     continue foreach;
		   end if
		   
		   if _cantidad is null then
		   let _cantidad = 0;
		   end if

		update tmp_end_xls
		   set poliza = _no_poliza,endoso = _no_endoso,cantidad = _cantidad
		 where no_factura = _no_factura;   
	

	end foreach
	
end 
trace off;
return 0;			
end procedure
                                                                                                                                                                                     
