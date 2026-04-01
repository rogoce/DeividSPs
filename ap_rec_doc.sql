-- Procedure que retorna el porcentaje de comision del corredor dependiendo del ramo

drop procedure ap_rec_doc;

create procedure ap_rec_doc() 
returning char(20), char(10), datetime year to fraction(5), char(8);

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
define _user_added         char(8);

set isolation to dirty read;

--set debug file to "ap_rec_doc.trc";
--trace on;

foreach with hold
	select no_reclamo,
	       numrecla,
	       doc_completa,
		   user_added
	  into _no_reclamo,
	       _numrecla,
	       _doc_completa,
		   _user_added
	  from recrcmae
	 where actualizado = 1
	   and fecha_reclamo >= '01/01/2016'
	   and numrecla[1,2] in ('02','20','23')
--	   and numrecla = '02-0918-00244-11'
	order by 1
	 
	let _cnt = 0;
	let _cnt_entregado = 0;
	 
	select count(*)
	  into _cnt
	  from recrcdoc
	 where no_reclamo = _no_reclamo;
	
	if _cnt > 0 then
		select count(*) 
		  into _cnt_entregado
		  from recrcdoc
		 where no_reclamo = _no_reclamo
		   and entregado = 1;
	  
        if _cnt = _cnt_entregado and _doc_completa = 0 then
		    select max(date_entrega)
			  into _date_entrega
		      from recrcdoc
		     where no_reclamo = _no_reclamo;
			 
			{
		    update recrcmae
			   set doc_completa = 1,
			       date_doc_comp = _date_entrega
			 where no_reclamo = _no_reclamo;
		--	 }
		--	return _numrecla, "", _date_entrega with resume;	
        elif _cnt <> _cnt_entregado and _doc_completa = 1 then
	{	    update recrcmae
			   set doc_completa = 0,
			       date_doc_comp = null
			 where no_reclamo = _no_reclamo;
	}	    
			return _numrecla, "", null, _user_added with resume;
		end if
	else
	    if _doc_completa = 1 then
			return _numrecla, "", null, _user_added with resume;
		end if
	end if

    foreach
		select cod_tercero,
		       doc_completa
		  into _cod_tercero,
		       _doc_completa_ter
		  from recterce
		 where no_reclamo = _no_reclamo
		 
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
			{	 
				update recterce
				   set doc_completa = 1,
					   date_doc_comp = _date_entrega_ter
				 where no_reclamo = _no_reclamo
				   and cod_tercero = _cod_tercero;
			 }
			--	return _numrecla, _cod_tercero, _date_entrega_ter with resume;			
			elif _cnt_tercero <> _cnt_entregado_ter and _doc_completa_ter = 1 then
{				update recterce
				   set doc_completa = 0,
					   date_doc_comp = null
				 where no_reclamo = _no_reclamo
				   and cod_tercero = _cod_tercero;
}				
                 return _numrecla, _cod_tercero, null, _user_added with resume;	
				
			end if
		else
			if _doc_completa_ter = 1 then
				return _numrecla, _cod_tercero, null, _user_added with resume;
            end if				
		end if
		
	end foreach
end foreach


end procedure