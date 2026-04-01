-- Procedimiento que busca las polizas de los productos sobat y le coloca motivo de no renovacion 

-- Creado:	14/06/2022 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_web69;
 
create procedure sp_web69()
returning VARCHAR(10),
		   varchar(2),
		   varchar(20),
		   integer;

define _no_documento 	char(20);
define _no_poliza		char(10);
define _cnt_cod_renov   integer;
define _descripcion     char(2);
define _no_renovar      integer;

--set debug file to "sp_json02.trc";
--trace on;
let _descripcion   = ' ';
	foreach 
		select distinct(no_documento)
		  into _no_documento
		  from emipouni a inner join emipomae b on a.no_poliza = b.no_poliza
		 where cod_producto in('06132', '06134', '06140') 
		   and actualizado = 1
		 
		let _cnt_cod_renov = 0;
		let _no_renovar    = 0;

		call sp_sis21(_no_documento) returning _no_poliza;
		
		select count(*)
		  into _cnt_cod_renov
		  from emipomae
		 where no_poliza = _no_poliza
		   and cod_no_renov is null;
		   
		if _cnt_cod_renov is null then
			let _cnt_cod_renov = 0;
		end if
		
		if _cnt_cod_renov > 0 then
		
			update emipomae
			   set cod_no_renov 	= '041',
			       fecha_no_renov 	= today, 
				   no_renovar	 	= 1, 
				   user_no_renov 	= 'DEIVID'
		     where no_poliza  	    = _no_poliza;
			 
			let _descripcion   = 'SI';
		else
			continue foreach;
		end if
		
		return _no_poliza,
			   _descripcion,
			   _no_documento,
			   _no_renovar
			   with resume;
					
	end foreach
end procedure