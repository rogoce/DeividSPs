-- Procedure que retorna el porcentaje de comision del corredor dependiendo del ramo

drop procedure ap_rec_doc3;

create procedure ap_rec_doc3() 
returning char(20) as reclamo, 
          date as fecha_siniestro,
          char(10) as cod_tercero, 
		  varchar(100) as tercero, 
		  date as fecha_tercero,
		  char(8) as usuario,
		  smallint as completa, 
		  date as fecha_completo, 
		  char(3) as cod_docra, 
		  varchar(50) as documento, 
		  smallint as entregado, 
		  datetime year to fraction(5) as fecha_entregado, 
		  datetime year to fraction(5) as fecha_adicionado, 
		  char(8) as usuario_adiciono,
		  varchar(50) as agencia;

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
define _cod_docra          char(3);
define _entregado          smallint;
define _date_added         datetime year to fraction(5);
define _user_added		   char(8);	   
define _date_doc_comp_ter  date;
define _documento          varchar(50);
define _agencia            varchar(50);
define _cod_agencia        char(3);
define _tercero            varchar(100);
define _fecha_siniestro    date;
define _date_added_ter     date;
define _user_added_ter     char(8);

set isolation to dirty read;

foreach with hold
	select no_reclamo,
	       numrecla,
	       doc_completa,
		   fecha_siniestro
	  into _no_reclamo,
	       _numrecla,
	       _doc_completa,
		   _fecha_siniestro
	  from recrcmae
	 where fecha_reclamo >= '02/11/2016'
	order by 1
	 
{	let _cnt = 0;
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
			 
		--	update recrcmae
		--	   set doc_completa = 1,
		--	       date_doc_comp = _date_entrega
		--	 where no_reclamo = _no_reclamo;
			 
			return _numrecla, "", _date_entrega with resume;			
		end if
	end if
}
    foreach
		select cod_tercero,
		       doc_completa,
			   date_doc_comp,
			   date_added,
			   user_added
		  into _cod_tercero,
		       _doc_completa_ter,
			   _date_doc_comp_ter,
			   _date_added_ter,
			   _user_added_ter
		  from recterce
		 where no_reclamo = _no_reclamo
		 
		select nombre
		  into _tercero
		  from cliclien 
		 where cod_cliente = _cod_tercero;
		
		select count(*)
		  into _cnt_tercero
		  from recterdoc
		 where no_reclamo = _no_reclamo
		   and cod_tercero = _cod_tercero;
		
		if _cnt_tercero > 0 then
			foreach
				select cod_docra,
					   entregado,
					   date_entrega,
					   date_added,
					   user_added,
                       cod_agencia					   
				  into _cod_docra,
					   _entregado,
					   _date_entrega,
					   _date_added,
					   _user_added,
                       _cod_agencia					   
				  from recterdoc
				 where no_reclamo = _no_reclamo
				   and cod_tercero = _cod_tercero
				   
				select descripcion
                  into _documento
                  from recdocra
                 where cod_docra = _cod_docra;	

                select descripcion
                  into _agencia
                  from insagen
                 where codigo_agencia = _cod_agencia;				  
			  
				return _numrecla, 
				       _fecha_siniestro,
					   _cod_tercero,
					   _tercero,
					   _date_added_ter,
					   _user_added_ter,
					   _doc_completa_ter,
					   _date_doc_comp_ter,
					   _cod_docra, 
					   _documento,
					   _entregado, 
					   _date_entrega,  
					   _date_added, 
					   _user_added,
					   _agencia with resume;		
			end foreach	
        else
			return _numrecla, 
			       _fecha_siniestro,
				   _cod_tercero, 
				   _tercero,
				   _date_added_ter,
				   _user_added_ter,
				   _doc_completa_ter,
				   _date_doc_comp_ter,
				   null, 
				   null, 
				   null,  
				   null,  
				   null, 
				   null,
                   null with resume;		
		end if
		
	end foreach
end foreach



end procedure