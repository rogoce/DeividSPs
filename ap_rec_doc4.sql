-- Procedure que retorna el porcentaje de comision del corredor dependiendo del ramo

drop procedure ap_rec_doc4;

create procedure ap_rec_doc4() 
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


    foreach
		select no_reclamo,
		       cod_tercero,
		       doc_completa
		  into _no_reclamo,
		       _cod_tercero,
		       _doc_completa_ter
		  from recterce
		 where user_added >= '01/11/2016'
		 
		select numrecla
		  into _numrecla
		  from recrcmae
		 where no_reclamo = _no_reclamo;
		 
		let _cnt_tercero = 0;
		let _cnt_entregado_ter = 0;

		select count(*)
		  into _cnt_tercero
		  from recterdoc
		 where no_reclamo = _no_reclamo
		   and cod_tercero = _cod_tercero;
		
		if _cnt_tercero > 0 then
			select count(*) 
			  into _cnt_entregado_ter
			  from recterdoc
			 where no_reclamo = _no_reclamo
			   and cod_tercero = _cod_tercero
			   and entregado = 1;
		  
			if _cnt_tercero = _cnt_entregado_ter and _doc_completa_ter = 0 then
				select max(date_entrega)
				  into _date_entrega_ter
				  from recterdoc
				 where no_reclamo = _no_reclamo
				   and cod_tercero = _cod_tercero;
				 
				update recterce
				   set doc_completa = 1,
					   date_doc_comp = _date_entrega_ter
				 where no_reclamo = _no_reclamo
				   and cod_tercero = _cod_tercero;
			 
				return _numrecla, _cod_tercero, _date_entrega_ter with resume;			
			end if
		end if
		
	end foreach




end procedure