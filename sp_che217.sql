 													   
drop procedure sp_che217;

create procedure sp_che217(a_transaccion char(10))
returning integer,		  
          varchar(150);

define _no_ajus_orden   char(10);
define _cnt, _renglon   smallint;
define _renglon_str     varchar(5);
define _no_tranrec      char(10);

--SET DEBUG FILE TO "sp_rec231a.trc"; 
--TRACE ON;                                                                
set isolation to dirty read;

begin


let _cnt       = 0;


select count(*)
  into _cnt
  from recordad
 where transaccion_alq = a_transaccion;

if _cnt > 0 then
	select no_ajus_orden,
	       renglon
	  into _no_ajus_orden,
	       _renglon
	  from recordad
	 where transaccion_alq = a_transaccion;

 	let _renglon_str = _renglon;

	return -1, "Esta transaccion ya se ingreso en el ajuste "  || TRIM(_no_ajus_orden)  ||  " en el renglon " || trim(_renglon_str);
end if

select no_tranrec
  into _no_tranrec
  from rectrmae
 where transaccion = a_transaccion;
 
select count(*)
  into _cnt
  from recordad
 where no_tranrec_neg = _no_tranrec
    or no_tranrec_pos = _no_tranrec
	or no_tranrec_pre = _no_tranrec;

if _cnt > 0 then
	select no_ajus_orden,
	       renglon
	  into _no_ajus_orden,
	       _renglon
	  from recordad
	 where no_tranrec_neg = _no_tranrec
		or no_tranrec_pos = _no_tranrec
		or no_tranrec_pre = _no_tranrec;
	   
 	let _renglon_str = _renglon;

	return -1, "Esta transaccion ya se ingreso en el ajuste "  || trim(_no_ajus_orden)  ||  " en el renglon " || trim(_renglon_str);
end if 

select count(*)
  into _cnt
  from recordma
 where transaccion = a_transaccion
    or trans_pend  = a_transaccion;

if _cnt > 0 then
	select no_orden	  
	  into _no_ajus_orden
	  from recordma
     where transaccion = a_transaccion
        or trans_pend  = a_transaccion;

	return -1, "Esta transaccion ya se ingreso en la orden de compra - reparacion "  || TRIM(_no_ajus_orden);
end if

return 0, "";

end

end procedure