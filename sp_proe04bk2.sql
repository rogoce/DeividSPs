-- Procedimiento para actualizar los valores de emifacon por unidad
-- f_emision_cargar_reaseguro
--
-- Creado:     05/01/2000 - Autor Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_proe04bk2;
create procedure "informix".sp_proe04bk2(a_poliza char(10), a_unidad char(5), a_suma decimal(16,2), a_no_endoso char(5))
			returning   integer   -- _error
						--char(100);


define _error_desc			char(100);
define ls_contrato			char(5);
define ls_ruta				char(5);
define ls_cober_reas		char(3);
define ls_ase_lider			char(3);
define ls_impuesto			char(3);
define ls_perpago			char(3);
define ls_tipopro			char(3);
define ls_ramo				char(3);
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
define _cant				smallint;
define ld_porc_impuesto		decimal(16,4);
define ld_porc_coaseg		decimal(16,4);
define ld_suma_asegurada	decimal(16,2);
define ld_prima_bruta		decimal(16,2);
define ld_prima_total		decimal(16,2);
define ld_prima_anual		decimal(16,2);
define ld_suma_plenos		decimal(16,2);
define ld_prima_neta		decimal(16,2);
define ld_descuento		   	decimal(16,2);
define ld_impuesto1		   	decimal(16,2);
define ld_imp_total       	decimal(16,2);
define ld_impuesto		   	decimal(16,2);
define ld_suma_dif			decimal(16,2);
define ld_suscrita       	decimal(16,2);
define ld_retenida       	decimal(16,2);
define ld_recargo		   	decimal(16,2);
define ld_prima		   		decimal(16,2);
define ld_letra				decimal(16,2);
define ld_suma				decimal(16,2); 
define ld_porc_prima  		decimal(10,4);
define ld_porc_suma			decimal(10,4);

begin

on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

--set debug file to "sp_proe04.trc";
--trace on;
                                                                     
-- buscar tipo de ramo, periodo de pago y tipo de produccion
select emipomae.cod_tipoprod
  into ls_tipopro
  from emipomae
 where emipomae.no_poliza = a_poliza;

select emitipro.tipo_produccion into li_tipopro
  from emitipro
 where emitipro.cod_tipoprod = ls_tipopro;

let ld_porc_coaseg = 0.00;

if li_tipopro = 2 then
-- la suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
-- campo - aseguradora lider

	select emicoama.porc_partic_coas 					  
	  into ld_porc_coaseg
	  from parparam, emicoama
	 where parparam.cod_compania = '001'
	   and emicoama.no_poliza    = a_poliza
	   and emicoama.cod_coasegur = parparam.par_ase_lider;

	if ld_porc_coaseg is null then
		let ld_porc_coaseg = 0.00;
	end if
end if

-- verificar si hay datos en reaseguro global
select count(*) 
  into ll_rea_glo
  from emigloco
 where emigloco.no_poliza = a_poliza;

if ll_rea_glo is null then
   let ll_rea_glo = 0;
end if

delete from emifacon
 where no_poliza   = a_poliza
   and no_endoso  = a_no_endoso
   and no_unidad  = a_unidad;
	
let ld_suma 	  = 0.00;
let ld_porc_suma  = 0.00;


foreach
	select emigloco.cod_ruta
	  into ls_ruta
	  from emigloco
	 where emigloco.no_poliza = a_poliza
	   and emigloco.no_endoso = a_no_endoso
	exit foreach;
end foreach

select mult_plenos
  into _mult_plenos
  from rearumae
 where cod_ruta = ls_ruta;

foreach

  SELECT prdcober.cod_cober_reas,   
         Sum(endedcob.prima_neta)
    INTO ls_cober_reas,
	     ld_letra
    FROM endedcob,   
         prdcober  
   WHERE ( prdcober.cod_cobertura = endedcob.cod_cobertura ) and  
         ( (endedcob.no_poliza = a_poliza ) AND  
         ( endedcob.no_endoso = a_no_endoso ) AND  
         ( endedcob.no_unidad = a_unidad ) )   
GROUP BY endedcob.no_poliza,   
         endedcob.no_endoso,   
         endedcob.no_unidad,   
         prdcober.cod_cober_reas


	select count(*)
	  into li_orden
	  from rearucon
	 where cod_ruta       = ls_ruta
	   and cod_cober_reas = ls_cober_reas;

	if li_orden = 0 then  --No hay contrato en la ruta para esa cobertura
		return 1;
	end if
	
	if _mult_plenos > 0 then
		let ld_suma_dif = a_suma;

		foreach
			select cant_plenos,
				   orden,
				   cod_contrato
			  into _cant_plenos,
			  	   li_orden,
			  	   ls_contrato
			  from rearucon
			 where cod_ruta = ls_ruta
			 order by orden

			let ld_suma_plenos = 0.00;

			if _cant_plenos > 0 then 
				let ld_suma_plenos	= _cant_plenos * _mult_plenos;
				
				if ld_suma_plenos > ld_suma_dif then
					let ld_suma = ld_suma_dif;
				else
					let ld_suma 	= ld_suma_plenos;
					let ld_suma_dif	= ld_suma_dif - ld_suma_plenos;
				end if
			else
				let ld_suma	= ld_suma_dif;				
			end if

			let ld_porc_prima = (ld_suma / a_suma) * 100;
			let ld_prima = (ld_letra * ld_porc_prima) / 100;

			if ld_porc_coaseg > 0 then
				let ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			end if

			select count(*)
	       	  into li_return
			  from emifacon
			 where emifacon.no_poliza = a_poliza
			   and emifacon.no_endoso = '00000'
			   and emifacon.no_unidad = a_unidad
			   and emifacon.cod_cober_reas = ls_cober_reas
			   and emifacon.orden = li_orden;

			If li_return = 0 Or li_return IS NULL Then
				Insert Into emifacon (no_poliza,
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
							  Values (a_poliza,
							  		  "00000",
							  		  a_unidad,
							  		  ls_cober_reas,
							  		  li_orden,
							  		  ls_contrato,
									  ld_porc_prima,
									  ld_porc_prima,
									  ld_suma,
									  ld_prima,
									  ls_ruta);
			else
				if ld_prima > 0 then
					update emifacon
					   set prima			= prima + ld_prima,
						   suma_asegurada	= suma_asegurada + ld_suma
					 where no_poliza 		= a_poliza
					   and no_endoso		= '00000'
					   and no_unidad 		= a_unidad
					   and cod_cober_reas	= ls_cober_reas
					   and orden			= li_orden;
				end if
			end if									
		end foreach 
	
	else
		foreach

			select orden,
				   cod_contrato,
				   porc_partic_suma,
				   porc_partic_prima
			  into li_orden,
			  	   ls_contrato,
				   ld_porc_suma,
				   ld_porc_prima
			  from rearucon
			 where cod_ruta       = ls_ruta
			   and cod_cober_reas = ls_cober_reas
			 order by orden

			let ld_suma  = 0.00;
			let ld_prima = 0.00;
			let ld_suma  = (a_suma * ld_porc_suma) / 100;

			if ld_porc_coaseg > 0 then
				let ld_suma = (ld_suma * ld_porc_coaseg) / 100;
			end if

			let ld_prima = (ld_letra * ld_porc_prima) / 100;
			if ld_porc_coaseg > 0 then
				let ld_prima = (ld_prima * ld_porc_coaseg) / 100;
			end if
				 
			select count(*)
			  into li_return
			  from emifacon
			 where emifacon.no_poliza		= a_poliza
			   and emifacon.no_endoso		= a_no_endoso
			   and emifacon.no_unidad		= a_unidad
			   and emifacon.cod_cober_reas	= ls_cober_reas
			   and emifacon.orden			= li_orden;

			if li_return = 0 Or li_return is null then
				Insert Into emifacon (no_poliza,
									  no_endoso,
									  no_unidad,
									  cod_cober_reas,
									  orden,
									  cod_contrato,
									  porc_partic_suma,
									  porc_partic_prima,
									  suma_asegurada,
									  prima,
									  cod_ruta
									 )				
							  Values (a_poliza,
							  		  a_no_endoso,
							  		  a_unidad,
							  		  ls_cober_reas,
							  		  li_orden,
							  		  ls_contrato,
							  		  ld_porc_suma,
							  		  ld_porc_prima,
							  		  ld_suma,
							  		  ld_prima,
							  		  ls_ruta
							  		 );
		   	else
				if ld_prima > 0 then
					update emifacon
					   set prima			= prima          + ld_prima,
						   suma_asegurada	= suma_asegurada + ld_suma
					 where no_poliza		= a_poliza
					   and no_endoso		= a_no_endoso
					   and no_unidad		= a_unidad
					   and cod_cober_reas	= ls_cober_reas
					   and orden			= li_orden;
				end if
			end if
		end foreach
	end if
end foreach

return 0;
end
end procedure;