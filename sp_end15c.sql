-- proceso que realiza la modificacion de unidad en negativo tecnica de seguros

-- Creado: 11/08/2017 - Autor: Federico Coronado

drop procedure sp_end15c;

create procedure "informix".sp_end15c()
returning integer;



define _no_documento			varchar(20);
define _vigencia_inic			date;
define _vigencia_final			date;
define _observaciones			varchar(15);
define _no_poliza 				varchar(10);
define _no_unidad    			varchar(10);
define _cod_producto			varchar(10);
define _num_carga               varchar(10);
define _proceso                 varchar(1);
define _renglon                 smallint;


set isolation to dirty read;
--SET DEBUG FILE TO "sp_end15.trc"; 
--TRACE ON;


	foreach
		select observaciones,
		       no_documento, 
		       vigencia_inic,
			   vigencia_final,
			   num_carga,
			   proceso,
			   renglon
         into _observaciones,
		      _no_documento,
			  _vigencia_inic,
			  _vigencia_final,
			  _num_carga,
			  _proceso,
			  _renglon
	     from prdemielctdet
		where cod_agente = '00180'
		  and actualizado = 2
		  and year(fecha_registro) = 2017
		
		if trim(_observaciones) = '4.50' then	
			select a.no_poliza, 
				   no_unidad,
				   cod_producto
			  into _no_poliza,
				   _no_unidad,
				   _cod_producto
			  from emipomae a inner join emipouni b on a.no_poliza = b.no_poliza 
			 where no_documento = _no_documento
			   and year(a.vigencia_inic) >= year(_vigencia_inic)
			   and year(a.vigencia_final)  <= year(_vigencia_final)
			   and actualizado = 1 
			   and cod_producto = '02052';
		end if
		
		if trim(_observaciones) = '8.00' then	
			select a.no_poliza, 
				   no_unidad,
				   cod_producto
			  into _no_poliza,
				   _no_unidad,
				   _cod_producto
			  from emipomae a inner join emipouni b on a.no_poliza = b.no_poliza 
			 where no_documento = _no_documento
			   and year(a.vigencia_inic) >= year(_vigencia_inic)
			   and year(a.vigencia_final)  <= year(_vigencia_final)
			   and actualizado = 1 
			   and cod_producto = '02053';
		end if 
		
		if trim(_observaciones) = '14.00' then	
			select a.no_poliza, 
				   no_unidad,
				   cod_producto
			  into _no_poliza,
				   _no_unidad,
				   _cod_producto
			  from emipomae a inner join emipouni b on a.no_poliza = b.no_poliza 
			 where no_documento = _no_documento
			   and year(a.vigencia_inic) >= year(_vigencia_inic)
			   and year(a.vigencia_final)  <= year(_vigencia_final)
			   and actualizado = 1 
			   and cod_producto = '02054';
		end if 
		
		update prdemielctdet
		   set no_poliza = _no_poliza,
               no_unidad = _no_unidad,
			   cod_producto = _cod_producto
		 where no_documento = _no_documento
		   and num_carga	= _num_carga
		   and proceso 		= _proceso
		   and renglon      = _renglon;

		

		return  0
	    with resume;
	end foreach
end procedure