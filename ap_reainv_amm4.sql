-- Procedimiento que verificar registros de recreaco y cambiarlos al contarto correcto.
-- 
-- Creado    : 21/11/2022 - Autor: Armando Moreno Montenegro
--
drop procedure ap_reainv_amm4;
create procedure ap_reainv_amm4()
returning char(20), char(10), char(5), char(10);
		  	

define _no_poliza    char(10);
define _no_documento char(20);
define _cnt 		 integer;
define _serie 		 char(4);
define _no_unidad, _cod_contrato    char(5);
define _no_reclamo 				char(10);
define _tipo_contrato smallint;

set isolation to dirty read;

begin 

--set debug file to "sp_reainv.trc";
--trace on;

let _no_poliza = "";

foreach
	select no_poliza,
	       no_unidad,
		   no_documento
	  into _no_poliza,
           _no_unidad,
		   _no_documento
      from camrea
	 order by no_poliza,no_unidad

	foreach
		select no_reclamo
		  into _no_reclamo
		  from recrcmae
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		   and actualizado = 1
		   
		foreach
			select cod_contrato
			  into _cod_contrato
			  from recreaco
			 where no_reclamo = _no_reclamo
			  				   
			select tipo_contrato
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato; 		  		   
			  
			if _tipo_contrato = 1 then
				update recreaco
				   set cod_contrato = '00766',
					   porc_partic_suma = 5.00,
					   porc_partic_prima = 5.00
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
			if _tipo_contrato = 5 then
				update recreaco
				   set cod_contrato = '00767',
					   porc_partic_suma = 95.00,
					   porc_partic_prima = 95.00
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
			if _tipo_contrato = 3 then
				update recreaco
				   set cod_contrato = '00768'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
				   
			return  _no_documento,_no_poliza,_no_unidad,_cod_contrato with resume;
					
		end foreach
	end foreach
end foreach
end 
end procedure;
