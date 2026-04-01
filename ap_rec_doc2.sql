-- Procedure que retorna el porcentaje de comision del corredor dependiendo del ramo

drop procedure ap_rec_doc2;

create procedure ap_rec_doc2() 
returning char(20), char(10), datetime year to fraction(5);

define _no_reclamo         char(10);
define _numrecla           char(20);
define _doc_completa       smallint;
define _cnt       		   smallint;
define _cnt_entregado      smallint;
define _cnt_tercero  	   smallint;
define _cnt_entregado_ter  smallint;
define _doc_completa_ter   smallint;
define _cod_tercero        char(10);
define _date_entrega       datetime year to fraction(5);
define _date_entrega_ter   datetime year to fraction(5);

set isolation to dirty read;

foreach with hold

		select numrecla,
		       cod_tercero,
		       date_entrega
		  into _numrecla,
		       _cod_tercero,
		       _date_entrega_ter
		  from tmp_doc_tercero
		
        select no_reclamo
          into _no_reclamo
          from recrcmae
         where numrecla = _numrecla;		  
        
				 
				update recterce
				   set doc_completa = 1,
					   date_doc_comp = _date_entrega_ter
				 where no_reclamo = _no_reclamo
				   and cod_tercero = _cod_tercero;
			 
				return _numrecla, _cod_tercero, _date_entrega_ter with resume;			
		

end foreach



end procedure