-- Procedimiento que carga la tabla camrea con registros para realizar cambios referente a reaseguro.
-- 
-- Creado    : 21/11/2022 - Autor: Armando Moreno Montenegro
--
drop procedure sp_1reainv_amm;
create procedure sp_1reainv_amm()
returning char(10), char(5),char(20);
		  	

define _no_poliza    char(10);
define _no_documento char(20);
define _cnt 		 integer;
define _no_unidad    char(5);
define _max_no_cambio smallint;
define _serie         char(4);

set isolation to dirty read;

begin 

--set debug file to "sp_reainv.trc";
--trace on;

let _cnt = 0;
let _no_poliza = "";
foreach
	select no_poliza,
	       no_documento,
		   serie
	  into _no_poliza,
           _no_documento,
		   _serie
      from emipomae
	 where actualizado = 1
	   and cod_ramo in('001','003','006','010','011','012','013','014','021','022')
	 order by no_poliza
	 
	foreach
		select no_unidad
		  into _no_unidad
		  from emipouni
		 where no_poliza = _no_poliza

		select max(no_cambio)
		  into _max_no_cambio
		  from emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
	   
		select count(*)
		  into _cnt
		  from emireaco	  
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and no_cambio = _max_no_cambio
		   and cod_contrato in('00750','00755','00751','00756','00752','00757','00753','00758','00754','00759','00746','00745');
	   
		if _cnt is null then
			let _cnt = 0;
		end if
		if _cnt > 0 then
			return  _no_poliza,_no_unidad,_no_documento with resume;
			select count(*)
			  into _cnt
			  from camrea
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
			 
			if _cnt is null THEN
				let _cnt = 0;
			end if	
			
			if _cnt = 0 then 
				insert into camrea(
				no_poliza,no_unidad,actualizado,no_endoso,periodo,no_documento,tipo,fecha)
				values(_no_poliza,_no_unidad,0,'',_serie,_no_documento,1,today);
			end if
		end if
	end foreach	
end foreach
end 
end procedure;
