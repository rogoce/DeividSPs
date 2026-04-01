-- Procedimiento para actualizar los valores de emifacon por unidad
-- f_emision_cargar_reaseguro
--
-- Creado:     05/01/2000 - Autor Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe04bbk;
create procedure "informix".sp_proe04bbk(a_poliza char(10), a_unidad char(5), a_suma dec(16,2), a_no_endoso char(5),a_cod_ruta char(5))
returning	integer;

define _mensaje             char(100);
define _error_desc			char(100);
define ls_contrato			char(5);
define ls_ruta				char(5);
define ls_cober_reas		char(3);
define ls_ase_lider			char(3);
define _cod_endomov			char(3);
define ls_impuesto			char(3);
define ls_perpago			char(3);
define ls_tipopro			char(3);
define ls_ramo				char(3);
define ld_porc_impuesto		dec(16,4);
define ld_porc_coaseg		dec(16,4);
define ld_suma_asegurada	dec(16,2);
define _ld_prima_neta_t     dec(16,2);
define _prima_neta_emif     dec(16,2);
define _suma_aseg_emif      dec(16,2);
define ld_prima_bruta		dec(16,2);
define ld_prima_total		dec(16,2);
define ld_prima_anual		dec(16,2);
define ld_suma_plenos		dec(16,2);
define ld_prima_neta		dec(16,2);
define ld_descuento		   	dec(16,2);
define ld_impuesto1		   	dec(16,2);
define ld_imp_total       	dec(16,2);
define ld_impuesto		   	dec(16,2);
define ld_suma_dif			dec(16,2);
define ld_suscrita       	dec(16,2);
define ld_retenida       	dec(16,2);
define ld_recargo		   	dec(16,2);
define _prima_dif           dec(16,2);
define _suma_dif            dec(16,2);
define ld_prima		   		dec(16,2);
define ld_letra				dec(16,2);
define ld_suma				dec(16,2); 
define ld_porc_prima  		dec(10,4);
define ld_porc_suma			dec(10,4);
define _porc_proporcion		dec(9,6);
define _max_no_cambio		smallint;
define _tipo_mov			smallint;
define _cant				smallint;
define li_tipo_ramo			integer;
define _cant_plenos			integer;
define _mult_plenos			integer;
define _error_isam			integer;
define li_tipopro			integer;
define ll_rea_glo 			integer;
define li_return		 	integer;
define li_orden				integer;
define li_meses				integer;
define _error				integer;
define li_uno				integer;
define _vigencia_inic		date;
define _max_orden			integer;
define _cod_contrato        char(5);

--set debug file to "sp_proe04b.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

-- buscar tipo de ramo, periodo de pago y tipo de produccion
select cod_tipoprod,
	   cod_ramo
  into ls_tipopro,
	   ls_ramo
  from emipomae
 where no_poliza = a_poliza;
 
let _max_orden = 0;

foreach
	select c.cod_cober_reas,   
		   sum(e.prima_neta)
	  into ls_cober_reas,
		   ld_letra
	  from endedcob e, prdcober c
	 where c.cod_cobertura = e.cod_cobertura
	   and e.no_poliza = a_poliza
	   and e.no_endoso = a_no_endoso
	   and e.no_unidad = a_unidad
	 group by e.no_poliza,e.no_endoso,e.no_unidad,c.cod_cober_reas
	 
	if ls_ramo = '002' or ls_ramo = '023' then
		 select max(no_cambio)
		  into _max_no_cambio
		  from emireaco
		 where no_poliza = a_poliza
		   and no_unidad = a_unidad;

		select count(*)
		  into li_orden
		  from emireaco
		 where no_poliza      = a_poliza
		   and no_unidad      = a_unidad
		   and cod_cober_reas = ls_cober_reas
		   and no_cambio      = _max_no_cambio;

		if li_orden is null then
			let li_orden = 0;
		end if
		if li_orden = 0 then
			select first 1 * from emireama
			where no_poliza = a_poliza
			  and no_unidad = a_unidad
			  and no_cambio = _max_no_cambio into temp prueba;
			
			update prueba
			   set cod_cober_reas = ls_cober_reas;
			   
			insert into emireama
			select * from prueba;
			
			drop table prueba;
			
			select max(orden)
			  into _max_orden
			  from emireaco
			 where no_poliza = a_poliza
			   and no_unidad = a_unidad;
			foreach
				select cod_contrato,
					   porc_partic_prima,
					   porc_partic_suma
				 into _cod_contrato,
					  ld_porc_prima,
					  ld_porc_suma
				 from rearucon
				where cod_ruta       = a_cod_ruta
				  and cod_cober_reas = ls_cober_reas
				  
				let _max_orden = _max_orden + 1;  
				insert into emireaco(no_poliza,no_unidad,no_cambio,cod_cober_reas,orden,cod_contrato,porc_partic_suma,porc_partic_prima)
				values(a_poliza,a_unidad,_max_no_cambio,ls_cober_reas,_max_orden,_cod_contrato, ld_porc_suma,ld_porc_prima);
			end foreach	  
			 
		end if
	end if
end foreach	

return 0;
end
end procedure;