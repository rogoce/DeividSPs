-- sp_aux26612
-- Creado    : 26/06/2024 - Autor: Hgiron
drop procedure sp_aux26612;		
create procedure "informix".sp_aux26612() 
returning integer, integer, varchar(100); 

define _fecha 			  date;
define _fecha_hoy	      date;
define _fecha_documento	  date;
define _transaccion		char(10);
define _numrecla		char(20);
define _no_documento	char(20);
define _no_reclamo		char(10);
define _no_tranrec      char(10);
define _no_unidad		char(5);
define _vigencia_inic	date;
define _vigencia_final	date;
define _error_cod  		integer;
define _error_desc      varchar(50);
define _error_isam	    integer;
define _serie			smallint;
define _cod_ramo		char(3);
define _no_poliza       char(10);
define _periodo         char(7);

set isolation to dirty read;

begin

on exception set _error_cod, _error_isam, _error_desc
	return _error_cod, _error_isam, trim(_error_desc) ; --|| " " || _transaccion;
end exception

--SET DEBUG FILE TO "sp_aux26612.trc";
--trace on;
drop table if exists tmp_aux26612_x;

let _fecha_hoy = current;

 SELECT * FROM tmp_aux26612 into temp tmp_aux26612_x;

foreach
 SELECT numrecla,transaccion		
   INTO _numrecla,_transaccion
   FROM tmp_aux26612_x
  GROUP BY numrecla,transaccion

	foreach 
	 select no_reclamo,
	        no_tranrec,
	        fecha	        
	   into _no_reclamo,
	        _no_tranrec,
	        _fecha
	   from	rectrmae
	  where numrecla  = _numrecla	
	    and transaccion = _transaccion		
	  order by fecha


      select no_documento, 
             no_unidad, 
             fecha_documento, 
             no_poliza
	    into _no_documento, 
	         _no_unidad, 
	         _fecha_documento, 
			 _no_poliza
		from recrcmae
	   where no_reclamo = _no_reclamo;

      select vigencia_inic,
	         vigencia_final,
			 serie,
			 cod_ramo,
		     periodo
	    into _vigencia_inic,
			 _vigencia_final,
			 _serie,
			 _cod_ramo,
		     _periodo
	    from emipomae
	   where no_poliza = _no_poliza
	   and _fecha between vigencia_inic and vigencia_final;           

   update tmp_aux26612
	  set serie = _serie  -- _periodo
	where numrecla = _numrecla
	  and transaccion = _transaccion;	
   
	end foreach
end foreach

return 0, 0, "Exitoso";

end
end procedure

