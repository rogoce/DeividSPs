-- 

drop procedure sp_rec246;

create procedure sp_rec246()
returning char(10), 
          char(10);
		  
define _transaccion	char(10);
define _anular_nt	char(10);
define _no_tranrec	char(10);

define _cantidad 	smallint;

let _cantidad = 0;

foreach
select transaccion,
       anular_nt,
	   no_tranrec
  into _transaccion,
       _anular_nt,
       _no_tranrec	   
  from rectrmae
 where actualizado  = 1
   and user_added   = "DEIVID"
   and periodo      = "2015-07"
   and cod_tipotran <> "004"
--   and transaccion  = "01-1200280"

	let _cantidad = _cantidad + 1;
   
   update rectrmae 
      set anular_nt   = null,
	      user_anulo  = null,
		  fecha_anulo = null,
	      pagado      = 0
    where transaccion = _anular_nt;		  

	DELETE FROM rectrcob WHERE no_tranrec = _no_tranrec;
	DELETE FROM rectrcon WHERE no_tranrec = _no_tranrec;
	DELETE FROM rectrdes WHERE no_tranrec = _no_tranrec;
	DELETE FROM rectrde2 WHERE no_tranrec = _no_tranrec;
	DELETE FROM rectrref WHERE no_tranrec = _no_tranrec;
	DELETE FROM rectrrea WHERE no_tranrec = _no_tranrec;
	DELETE FROM rectrmae WHERE no_tranrec = _no_tranrec;
	
	return _transaccion,
	       _anular_nt
		   with resume;
		   
	if _cantidad >= 100 then
		exit foreach;
	end if
	
end foreach   

return "",
       "";
	   
end procedure