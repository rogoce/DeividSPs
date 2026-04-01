-- Procedimiento que verificar registros de recreaco y cambiarlos al contarto correcto.
-- 
-- Creado    : 21/11/2022 - Autor: Armando Moreno Montenegro
--
drop procedure sp_reainv_amm4;
create procedure sp_reainv_amm4()
returning char(20), char(10), char(5), char(10);
		  	

define _no_poliza    char(10);
define _no_documento char(20);
define _cnt 		 integer;
define _serie 		 char(4);
define _no_unidad, _cod_contrato    char(5);
define _no_reclamo 				char(10);

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
			   and cod_contrato in('00750','00755','00751','00756','00752','00757','00753','00758','00754','00759','00746','00745') --contratos viejos
				   
			if _cod_contrato = '00750' then
				update recreaco
				   set cod_contrato = '00775'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00755' then
				update recreaco
				   set cod_contrato = '00776'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00751' then
				update recreaco
				   set cod_contrato = '00777'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00756' then
				update recreaco
				   set cod_contrato = '00778'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00752' then
				update recreaco
				   set cod_contrato = '00779'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00757' then
				update recreaco
				   set cod_contrato = '00780'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00753' then
				update recreaco
				   set cod_contrato = '00781'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00758' then
				update recreaco
				   set cod_contrato = '00782'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
			end if
			if _cod_contrato = '00754' then
				update recreaco
				   set cod_contrato = '00783'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
		    end if
		    if _cod_contrato = '00759' then
				update recreaco
				   set cod_contrato = '00784'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
		    end if
			
			if _cod_contrato = '00746' then
				update recreaco
				   set cod_contrato = '00785'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
		    end if
		    if _cod_contrato = '00745' then
				update recreaco
				   set cod_contrato = '00786'
				 where no_reclamo   = _no_reclamo
				   and cod_contrato = _cod_contrato;
		    end if
				   
			return  _no_documento,_no_poliza,_no_unidad,_cod_contrato with resume;
					
		end foreach
	end foreach
end foreach
end 
end procedure;
