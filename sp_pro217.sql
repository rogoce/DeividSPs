-- Procedimiento que verifica la Distribucion de Reaseguro Inidividual y recalcula los porcentajes si la distribucion esta
-- el calculo de plenos

-- Creado    : 15/12/2011 - Autor: Roman Gordon
drop procedure sp_pro217;

create procedure sp_pro217(a_no_poliza char(10), a_no_endoso char(5))
returning smallint,
          char(50);

define _cantidad    			smallint;
define _no_cambio				smallint;
define _mult_plenos				smallint;
define _orden					smallint;
define _error					smallint;
define _error_isam				smallint;
define _cnt_emireama			smallint;
define _suma_asegurada			dec(16,2);
define _sum_prima_neta			dec(16,2);
define _sum_prima_neta_contr	dec(16,2);	
define _suma_asegurada_contr	dec(16,2);
define _sum_aseg_endedmae		dec(16,2);
define _porc_partic_prima		dec(9,6);
define _porc_partic_suma		dec(9,6);
define _cod_cober_reas			char(3);
define _cod_cober_reas2			char(3);
define _cod_ruta				char(5);
define _cod_contrato			char(5);
define _no_unidad				char(5);
define _error_desc				char(50);
define _vigencia_inic			date;
define _vigencia_final			date;

--set debug file to "sp_pro217.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception
end


let _no_cambio  = 0;
--let a_no_endoso = "00000";
let _sum_aseg_endedmae = 0.00;

select suma_asegurada,
	   vigencia_inic,		   
	   vigencia_final
  into _sum_aseg_endedmae,
	   _vigencia_inic,
	   _vigencia_final
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _sum_aseg_endedmae <> 0 then

	foreach
		select no_unidad
		  into _no_unidad
		  from endeduni
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		  

		foreach
			select cod_ruta,
				   cod_cober_reas
			  into _cod_ruta,
				   _cod_cober_reas
			  from emifacon
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad
			   and no_endoso = a_no_endoso

			exit foreach;
		end foreach

		select mult_plenos
		  into _mult_plenos
		  from rearumae
		 where cod_ruta = _cod_ruta;

		if _mult_plenos > 0 then
			select sum(suma_asegurada),
				   sum(prima)
			  into _suma_asegurada,
				   _sum_prima_neta
			  from emifacon
			 where no_poliza 	  = a_no_poliza
			   and no_unidad 	  = _no_unidad
			   and cod_cober_reas = _cod_cober_reas;

			select max(no_cambio)
			  into _no_cambio
			  from emireaco
			 where no_poliza = a_no_poliza
			   and no_unidad = _no_unidad;

			let _no_cambio = _no_cambio + 1;

			foreach
				select cod_contrato
				  into _cod_contrato
				  from rearucon
				 where cod_ruta = _cod_ruta

				select sum(suma_asegurada),
					   sum(prima)
				  into _suma_asegurada_contr,
					   _sum_prima_neta_contr
				  from emifacon
				 where no_poliza = a_no_poliza
				   and no_unidad = _no_unidad 
				   and cod_contrato = _cod_contrato
				   and cod_cober_reas = _cod_cober_reas;

				foreach
					select orden
					  into _orden
					  from emifacon
					 where no_poliza 	  = a_no_poliza
					   and no_unidad 	  = _no_unidad 
					   and cod_contrato   = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas
					exit foreach;
				end foreach

				let _porc_partic_prima	= (_sum_prima_neta_contr/_sum_prima_neta) * 100;
				let _porc_partic_suma	= (_suma_asegurada_contr/_suma_asegurada) * 100;

								
				foreach
					select distinct cod_cober_reas
					  into _cod_cober_reas2
					  from emifacon
					 where no_poliza = a_no_poliza
					   and no_unidad = _no_unidad

					select count(*)
					  into _cnt_emireama
					  from emireama
					 where no_poliza	  = a_no_poliza
					   and no_unidad	  = _no_unidad
					   and no_cambio	  = _no_cambio
					   and cod_cober_reas = _cod_cober_reas2;

					if _cnt_emireama = 0 then		 

						insert into emireama(
						no_poliza,
						no_unidad,
						no_cambio,
						cod_cober_reas,
						vigencia_inic,
						vigencia_final
						)
						values(
						a_no_poliza, 
						_no_unidad,
						_no_cambio,
						_cod_cober_reas2,
						_vigencia_inic,
						_vigencia_final
						);
					end if
										
					insert into emireaco(no_poliza,
										 no_unidad,
										 no_cambio,
										 cod_cober_reas,
										 orden,
										 cod_contrato,
										 porc_partic_suma,
										 porc_partic_prima)
								 values (a_no_poliza,
										 _no_unidad,
										 _no_cambio,
										 _cod_cober_reas2,
										 _orden,
										 _cod_contrato,
										 _porc_partic_suma,
										 _porc_partic_prima);
				end foreach					   
			end foreach
		else
			return 0,'Calculo de % de Reaseguro no es necesario' with resume;
		end if
	end foreach
else
	return 0,'Calculo de % de Reaseguro no es necesario' with resume;	
end if

return 0,'Calculo de % de Reaseguro Exitoso';

end procedure


