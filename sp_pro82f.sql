-- Procedimiento para actualizar los valores de emirerea por unidad
-- f_emision_cargar_reaseguro
--
-- Creado:     05/01/2000 - Autor Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor Edgar E. Cano G.
-- copia del sp_proe04

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro82f;
create procedure "informix".sp_pro82f(a_poliza char(10), a_unidad char(5), a_suma dec(16,2), a_cia char(3), a_opcion integer default 0)
returning	integer   -- _error

define ls_contrato			char(5);
define ls_ruta				char(5);
define ls_cober_reas		char(3);
define ls_ase_lider			char(3);
define ls_impuesto			char(3);
define ls_tipopro			char(3);
define ls_perpago			char(3);
define ls_ramo				char(3);
define ld_porc_prima		dec(10,4);
define ld_porc_suma			dec(10,4);
define ld_suma_asegurada	dec(16,2);
define ld_prima_bruta		dec(16,2);
define ld_prima_total		dec(16,2);
define ld_prima_anual		dec(16,2);
define ld_prima_neta		dec(16,2);
define ld_impuesto1		   	dec(16,2);
define ld_imp_total       	dec(16,2);
define ld_descuento		   	dec(16,2);
define ld_impuesto		   	dec(16,2);
define ld_suscrita       	dec(16,2);
define ld_retenida       	dec(16,2);
define ld_recargo		   	dec(16,2);
define ld_prima		   		dec(16,2);
define ld_letra				dec(16,2);
define ld_suma				dec(16,2); 
define ld_porc_impuesto		dec(16,4);
define ld_porc_coaseg		dec(16,4);
define li_tipo_ramo			integer;
define ll_rea_glo			integer;
define li_tipopro			integer;
define li_return			integer;
define li_orden				integer;
define li_meses				integer;
define _error				integer;
define li_uno				integer;

begin

on exception set _error 
 	return _error;         
end exception

set isolation to dirty reaD;

-- Buscar Tipo de Ramo, Periodo de Pago y Tipo de Produccion
select cod_tipoprod
  into ls_tipopro
  from emireaut
 where no_poliza = a_poliza
   and no_unidad = a_unidad;

select tipo_produccion
  into li_tipopro
  from emitipro
 where cod_tipoprod = ls_tipopro;

let ld_porc_coaseg = 0.00;

-- La suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
-- campo - Aseguradora Lider
if li_tipopro = 2 then
	select e.porc_partic_coas
	  into ld_porc_coaseg
	  from parparam p, emicoama e
	 where p.cod_compania = a_cia
	   and e.no_poliza    = a_poliza
	   and e.cod_coasegur = p.par_ase_lider;

	if ld_porc_coaseg is null then
		let ld_porc_coaseg = 0.00;
	end if
end if

-- Verificar si hay datos en Reaseguro Global
select count(*)
  into ll_rea_glo
  from emireglo
 where no_poliza = a_poliza;

if ll_rea_glo is null then
   let ll_rea_glo = 0;
end if

delete from emirerea
 where no_poliza   = a_poliza
   and no_endoso  = '00000'
   and no_unidad  = a_unidad;
	
let ld_suma 	  = 0.00;
let ld_porc_suma  = 0.00;

if a_opcion = 0 then	--renovacion
	foreach
		select c.cod_cober_reas, 
			   sum(e.prima_neta_o)
		  into ls_cober_reas,
			   ld_letra
		  from emireau2 e, prdcober c  
		 where e.no_poliza = a_poliza
		   and e.no_unidad = a_unidad
		   and c.cod_cobertura = e.cod_cobertura
		 group by c.cod_cober_reas

		foreach
			select cod_contrato,
				   porc_partic_suma,
				   porc_partic_prima,
			       cod_ruta,
			       orden
	  		  into ls_contrato,
	  		  	   ld_porc_suma,
	  		  	   ld_porc_prima,
	  		  	   ls_ruta,
	  		  	   li_orden
			  from emireglo
			 where no_poliza = a_poliza
			   and no_endoso = '00000'

			let ld_suma  = 0.00;
			let ld_prima = 0.00;
			
			let ld_suma = (a_suma * ld_porc_suma) / 100;
			if ld_porc_coaseg > 0 then
				let ld_suma = (ld_suma * ld_porc_coaseg) / 100;
			end if

			let ld_prima = (ld_letra * ld_porc_prima) / 100;
			if ld_porc_coaseg > 0 then
				let ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			end if
				 
	       	select count(*)
	       	  into li_return
			  from emirerea
			 where no_poliza      = a_poliza
			   and no_endoso      = '00000'
			   and no_unidad      = a_unidad
			   and cod_cober_reas = ls_cober_reas
			   and orden          = li_orden;

			if li_return = 0 or li_return is null then
				insert into emirerea (
						no_poliza,
						no_endoso,
						no_unidad,
						cod_cober_reas,
						orden,
						cod_contrato,
						porc_partic_suma,
						porc_partic_prima,
						suma_asegurada,
						prima,
						cod_ruta)				
				values	(a_poliza,
						"00000",
						a_unidad,
						ls_cober_reas,
						li_orden,
						ls_contrato,
						ld_porc_suma,
						ld_porc_prima,
						ld_suma,
						ld_prima,
						ls_ruta);
			else
				if ld_prima > 0 then
					update emirerea
					   set prima				= prima + ld_prima,
						   suma_asegurada    = suma_asegurada + ld_suma
					 where no_poliza 		= a_poliza
					   and no_endoso        	= '00000'
					   and no_unidad 		= a_unidad
					   and cod_cober_reas	= ls_cober_reas
					   and orden				= li_orden;
				end if
			end if
		end foreach
	end foreach
	return 0;
end if

if a_opcion = 1 then --opcion1
	foreach
		select c.cod_cober_reas, 
			   sum(e.prima_neta_1)
		  into ls_cober_reas,
			   ld_letra
		  from emireau2 e, prdcober c 
		 where e.no_poliza = a_poliza
		   and e.no_unidad = a_unidad
		   and c.cod_cobertura = e.cod_cobertura
		   and e.chek_1    = 1
		 group by c.cod_cober_reas

		foreach
			select cod_contrato,
				   porc_partic_suma,
				   porc_partic_prima,
			       cod_ruta,
			       orden
	  		  into ls_contrato,
	  		  	   ld_porc_suma,
	  		  	   ld_porc_prima,
	  		  	   ls_ruta,
	  		  	   li_orden
			  from emireglo
			 where no_poliza = a_poliza
			   and no_endoso = '00000'

			let ld_suma  = 0.00;
			let ld_prima = 0.00;
			
			let ld_suma = (a_suma * ld_porc_suma) / 100;
			if ld_porc_coaseg > 0 then
				let ld_suma = (ld_suma * ld_porc_coaseg) / 100;
			end if

			let ld_prima = (ld_letra * ld_porc_prima) / 100;
			if ld_porc_coaseg > 0 then
				let ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			end if
				 
	       	select count(*)
	       	  into li_return
			  from emirerea
			 where no_poliza      = a_poliza
			   and no_endoso      = '00000'
			   and no_unidad      = a_unidad
			   and cod_cober_reas = ls_cober_reas
			   and orden          = li_orden;

			if li_return = 0 or li_return is null then
				insert into emirerea (
						no_poliza,
						no_endoso,
						no_unidad,
						cod_cober_reas,
						orden,
						cod_contrato,
						porc_partic_suma,
						porc_partic_prima,
						suma_asegurada,
						prima,
						cod_ruta)				
				values	(a_poliza,
						"00000",
						a_unidad,
						ls_cober_reas,
						li_orden,
						ls_contrato,
						ld_porc_suma,
						ld_porc_prima,
						ld_suma,
						ld_prima,
						ls_ruta);
			else
				if ld_prima > 0 then
					update emirerea
					   set prima			= prima + ld_prima,
						   suma_asegurada	= suma_asegurada + ld_suma
					 where no_poliza 		= a_poliza
					   and no_endoso        	= '00000'
					   and no_unidad 		= a_unidad
					   and cod_cober_reas	= ls_cober_reas
					   and orden				= li_orden;
				end if
			end if
		end foreach
	end foreach
	return 0;
end if

if a_opcion = 2 then --opcion2
	foreach
		select c.cod_cober_reas, 
			   sum(emireau2.prima_neta_2)
		  into ls_cober_reas,
			   ld_letra
		  from emireau2 e, prdcober c  
		 where e.no_poliza = a_poliza
		   and e.no_unidad = a_unidad
		   and e.chek_2    = 1
		   and c.cod_cobertura = e.cod_cobertura
		 group by c.cod_cober_reas

		foreach
			select cod_contrato,
				   porc_partic_suma,
				   porc_partic_prima,
			       cod_ruta,
			       orden
	  		  into ls_contrato,
	  		  	   ld_porc_suma,
	  		  	   ld_porc_prima,
	  		  	   ls_ruta,
	  		  	   li_orden
			  from emireglo
			 where no_poliza = a_poliza
			   and no_endoso = '00000'

			let ld_suma  = 0.00;
			let ld_prima = 0.00;
			
			let ld_suma = (a_suma * ld_porc_suma) / 100;
			if ld_porc_coaseg > 0 then
				let ld_suma = (ld_suma * ld_porc_coaseg) / 100;
			end if

			let ld_prima = (ld_letra * ld_porc_prima) / 100;
			if ld_porc_coaseg > 0 then
				let ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			end if
				 
	       	select count(*)
	       	  into li_return
			  from emirerea
			 where no_poliza      = a_poliza
			   and no_endoso      = '00000'
			   and no_unidad      = a_unidad
			   and cod_cober_reas = ls_cober_reas
			   and orden          = li_orden;

			if li_return = 0 or li_return is null then
				insert into emirerea (
						no_poliza,
						no_endoso,
						no_unidad,
						cod_cober_reas,
						orden,cod_contrato,
						porc_partic_suma,
						porc_partic_prima,
						suma_asegurada,
						prima,
						cod_ruta)				
				values	(a_poliza,
						"00000",
						a_unidad,
						ls_cober_reas,
						li_orden,
						ls_contrato,
						ld_porc_suma,
						ld_porc_prima,
						ld_suma,
						ld_prima,
						ls_ruta);
			else
				if ld_prima > 0 then
					update emirerea
					  set prima				= prima + ld_prima,
					      suma_asegurada    = suma_asegurada + ld_suma
					 where no_poliza 		= a_poliza
					   and no_endoso        = '00000'
					   and no_unidad 		= a_unidad
					   and cod_cober_reas	= ls_cober_reas
					   and orden			= li_orden;
				end if
			end if
		end foreach
	end foreach
	return 0;
end if
end
end procedure;