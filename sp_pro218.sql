-- Verifica si la ruta aplica para la Distribución de Reaseguro por plenos.
-- Creado    : 13/01/2012 - Autor: Roman Gordon
-- SIS v.2.0 - - DEIVID, S.A.


drop procedure sp_pro218;

create procedure sp_pro218(a_no_poliza char(10), a_no_endoso char(5), a_no_unidad char(5),a_cod_ruta char(5))
returning integer;

define _cod_pagador			char(10);
define _no_poliza			char(10);
define _cod_contrato		char(5);
define _cod_ramo			char(4);
define _cod_cober_reas		char(3);
define _par_ase_lider		char(3);
define _cod_tipoprod		char(3);
define _cod_endomov			char(3);
define _ase_lider			char(3);
define _cod_ruta			char(3);
define _tipo_mov			char(1);
define _prima_neta_emifacon	dec(16,2);
define _suma_aseg_emifacon	dec(16,2);
define _porc_partic_prima	dec(16,2);
define _sum_aseg_emifacon	dec(16,2);
define _porc_partic_coas	dec(16,2);
define _porc_partic_suma	dec(16,2);
define _suma_asegurada		dec(16,2);
define _prima_neta			dec(16,2);
define _cant_plenos			dec(8,2);
define _mult_plenos			dec(8,2);
define _signo				dec(8,2);
define _cnt_emigloco		smallint;
define _actualizado			smallint;
define _no_cambio			smallint;
define _tipo_prod			smallint;
define _tipopro				smallint;
define _return				smallint;
define _serie				smallint;
define _orden				smallint;
define _fila				smallint;
define _cont				smallint;
define _row					smallint;
define _vigencia_inic		date; 

--set debug file to "sp_pro218.trc";
--trace on;

set isolation to dirty read;

let _cod_ruta = a_cod_ruta;


select cod_endomov,
	   vigencia_inic,
	   actualizado
  into _cod_endomov,
	   _vigencia_inic,
	   _actualizado
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _actualizado <> 0 then
	return 0;
end if

select tipo_mov
  into _tipo_mov
  from endtimov
 where cod_endomov = _cod_endomov;

if _tipo_mov in ('1','4','5','6','19') then
	
	select count(*)
	  into _cnt_emigloco
	  from emigloco
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso;

	select sum(suma_asegurada)
	  into _suma_asegurada
	  from endeduni
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	   and no_unidad = a_no_unidad;

	if _cnt_emigloco = 0 or _cnt_emigloco is null then
		select cod_ramo,
			   serie
		  into _cod_ramo,
		  	   _serie
		  from emipomae
		 where no_poliza = a_no_poliza;
		
		select mult_plenos
		  into _mult_plenos
		  from rearumae
		 where cod_ruta = a_cod_ruta;
		 
		select sum(cant_plenos)
		  into _cant_plenos
		  from rearucon
		 where cod_ruta = a_cod_ruta;

		if _mult_plenos > 0 and _cant_plenos > 0 then
			delete from emifacon
			      where no_poliza = a_no_poliza
				    and no_endoso = a_no_endoso
					and no_unidad = a_no_unidad;

			if _suma_asegurada = 0 then
				select max(no_cambio)
				  into _no_cambio
				  from emireama
				 where no_poliza = a_no_poliza
				   and no_unidad = a_no_unidad;

				foreach
			   		select prdcober.cod_cober_reas,
			   			   sum(endedcob.prima_neta)
					  into _cod_cober_reas,
						   _prima_neta
					  from endedcob,prdcober
					 where (prdcober.cod_cobertura = endedcob.cod_cobertura)
					   and (( endedcob.no_poliza = a_no_poliza) 
					   and (endedcob.no_endoso = a_no_endoso)
					   and (endedcob.no_unidad = a_no_unidad))
				  group by endedcob.no_poliza,
					       endedcob.no_endoso,
					       endedcob.no_unidad,
					       prdcober.cod_cober_reas
					foreach
						select orden,
							   cod_contrato,
							   porc_partic_prima,
							   porc_partic_suma
						  into _orden,
							   _cod_contrato,
							   _porc_partic_prima,
							   _porc_partic_suma
						  from emireaco
						 where no_poliza = a_no_poliza
						   and no_cambio = _no_cambio
						   and cod_cober_reas = _cod_cober_reas

						select cod_tipoprod 
						  into _cod_tipoprod
						  from emipomae
						 where no_poliza = a_no_poliza;

						select tipo_produccion 
						  into _tipopro
						  from emitipro
						 where cod_tipoprod = _cod_tipoprod;

						if _tipopro = 2 then
							select par_ase_lider
							  into _par_ase_lider								   	
							  from paraparam;
							
							select porc_partic_coas
							  into _porc_partic_coas
							  from emicoama
							 where no_poliza = a_no_poliza
							   and cod_coasegur = _par_ase_lider;

							let _suma_aseg_emifacon = (_suma_asegurada * _porc_partic_coas)/100;
							let _prima_neta_emifacon = (_prima_neta * _porc_partic_coas)/100;
						else
							let _suma_aseg_emifacon = (_suma_asegurada * _porc_partic_suma)/100;
							let _prima_neta_emifacon = (_prima_neta * _porc_partic_prima)/100;
						end if
						
						insert into emifacon(no_poliza,
											 no_endoso,
											 no_unidad,
											 cod_cober_reas,
											 orden,
											 cod_ruta,
											 cod_contrato,
											 prima,
											 suma_asegurada,
											 porc_partic_prima,
											 porc_partic_suma)
									  values (a_no_poliza,
											 a_no_endoso,
											 a_no_unidad,
											 _cod_cober_reas,
											 _orden,
											 a_cod_ruta,
											 _cod_contrato,
											 _prima_neta_emifacon,
											 _suma_aseg_emifacon,
											 _porc_partic_prima,
											 _porc_partic_suma);

					end foreach
				end foreach
			{else
				select sum(suma_asegurada)
				  into _sum_aseg_emifacon
				  from emifacon
				 where no_poliza = a_no_poliza
				   and no_endoso = a_no_endoso
				   and no_unidad = a_no_unidad;

				if _suma_asegurada <> _sum_aseg_emifacon then
					delete from emifacon	
					      where no_poliza = a_no_poliza
						    and no_endoso = a_no_endoso
							and no_unidad = a_no_unidad; 
				end if}
			end if							   			
		end if		 		
	end if
end if
return 0;
end procedure;








																   