-- Procedimiento para actualizar los valores de emifacon por unidad
-- f_emision_cargar_reaseguro
--
-- Creado:     05/01/2000 - Autor Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure ap_proe04;
create procedure "informix".ap_proe04(
a_poliza	char(10),
a_cia		char(3))
returning	integer	-- _error
					--char(100);

define _mensaje             varchar(100);
define _error_desc			char(100);
define ls_contrato			char(5);
define ls_ruta				char(5);
define _cod_cober_reas     	char(3);
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
define _porc_proporcion		dec(9,6);
define ld_porc_prima  		dec(10,4);
define ld_porc_suma			dec(10,4);
define ld_suma_asegurada	dec(16,2);
define _ld_prima_neta_t		dec(16,2);
define _prima_neta_emif    	dec(16,2);
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
define ld_prima		   		dec(16,2);
define ld_letra				dec(16,2);
define ld_suma				dec(16,2); 
define _prima_dif        	dec(16,2);
define _suma_dif            dec(16,2);
define _suma_aseg_emif      dec(16,2);
define ld_porc_impuesto		dec(16,4);
define ld_porc_coaseg		dec(16,4);
define _vigencia_inic		date;
define _vigencia_final		date;
define _cod_subramo         char(3);
define _no_unidad           char(5);
define _suma_asegurada      dec(16,2);

begin

on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

let _porc_proporcion = 0.00;

--if a_poliza = '1101757' then
--set debug file to "sp_proe04.trc";
--trace on;
--end if

-- buscar tipo de ramo, periodo de pago y tipo de produccion

select cod_tipoprod,
	   cod_ramo,
	   cod_subramo,
	   vigencia_inic,
	   vigencia_final
  into ls_tipopro,
	   ls_ramo,
	   _cod_subramo,
	   _vigencia_inic,
	   _vigencia_final
  from emipomae
 where no_poliza = a_poliza;

select tipo_produccion 
  into li_tipopro
  from emitipro
 where cod_tipoprod = ls_tipopro;

let ld_porc_coaseg = 0.00;

-- la suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
-- campo - aseguradora lider
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

-- verificar si hay datos en reaseguro global
select count(*) 
  into ll_rea_glo
  from emigloco
 where emigloco.no_poliza = a_poliza;

if ll_rea_glo is null then
   let ll_rea_glo = 0;
end if

foreach
select no_unidad,
       suma_asegurada
  into _no_unidad,
       _suma_asegurada
  from emipouni
 where no_poliza = a_poliza
 

	delete from emifacon
	 where no_poliza   = a_poliza
	   and no_endoso  = '00000'
	   and no_unidad  = _no_unidad;

	{delete from emireaco
	 where no_poliza   = a_poliza
	   and no_unidad  = _no_unidad
	   and no_cambio  = 0;

	delete from emireama
	 where no_poliza   = a_poliza
	   and no_unidad  = _no_unidad
	   and no_cambio  = 0;
	}	
	let ld_suma 	  = 0.00;
	let ld_porc_suma  = 0.00;


	foreach
		select emigloco.cod_ruta
		  into ls_ruta
		  from emigloco
		 where emigloco.no_poliza = a_poliza
		   and emigloco.no_endoso = '00000'
		exit foreach;
	end foreach

	select mult_plenos
	  into _mult_plenos
	  from rearumae
	 where cod_ruta = ls_ruta;

	if ls_ramo in('002','023') then
		call sp_sis188(a_poliza) returning _error,_mensaje;
	end if

	foreach
		select c.cod_cober_reas,
			   sum(e.prima_neta)
		  into ls_cober_reas,
			   ld_letra
		  from emipocob e, prdcober c 
		  where e.no_poliza = a_poliza
			and e.no_unidad = _no_unidad
			and c.cod_cobertura = e.cod_cobertura
		  group by c.cod_cober_reas
		  
		  LET ls_cober_reas = ls_cober_reas;
		  LET ls_ruta = ls_ruta;

		select count(*)
		  into li_orden
		  from rearucon
		 where cod_ruta       = ls_ruta
		   and cod_cober_reas = ls_cober_reas;

		if li_orden = 0 then  --No hay contrato en la ruta para esa cobertura
			return 1;
		end if

		let _porc_proporcion = 0.00;
		
		if _mult_plenos > 0 then
			let ld_suma_dif = _suma_asegurada;

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

				let ld_porc_prima = (ld_suma / _suma_asegurada) * 100;
				let ld_prima = (ld_letra * ld_porc_prima) / 100;

				if ld_porc_coaseg > 0 then
					let ld_prima = (ld_prima * ld_porc_coaseg) / 100;
				end if

				select count(*)
				  into li_return
				  from emifacon
				 where emifacon.no_poliza = a_poliza
				   and emifacon.no_endoso = '00000'
				   and emifacon.no_unidad = _no_unidad
				   and emifacon.cod_cober_reas = ls_cober_reas
				   and emifacon.orden = li_orden;

				If li_return = 0 or li_return is null then
					insert into emifacon (
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
					values(	a_poliza,
							"00000",
							_no_unidad,
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
						   and no_unidad 		= _no_unidad
						   and cod_cober_reas	= ls_cober_reas
						   and orden			= li_orden;
					end if
				end if									
			end foreach	
		else
			if ls_ramo = '016' and _cod_subramo = '003' THEN --Colectivo, Agencia de seguridad
				foreach
					select a.orden,
						   a.cod_contrato,
						   100,
						   100
					  into li_orden,
						   ls_contrato,
						   ld_porc_suma,
						   ld_porc_prima
					  from rearucon a, reacomae b
					 where a.cod_contrato   = b.cod_contrato
					   and a.cod_ruta       = ls_ruta
					   and a.cod_cober_reas = ls_cober_reas
					   and b.tipo_contrato  = 1
					 order by a.orden

					let ld_suma  = 0.00;
					let ld_prima = 0.00;
					let ld_suma = (_suma_asegurada * ld_porc_suma) / 100;

{					if ls_ramo in('002','023') then
						select porc_cober_reas
						  into _porc_proporcion
						  from tmp_dist_rea
						 where cod_cober_reas = ls_cober_reas;

						let ld_suma = (_suma_asegurada * ld_porc_suma / 100) * _porc_proporcion / 100;
					end if
}
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
					   and emifacon.no_endoso		= '00000'
					   and emifacon.no_unidad		= _no_unidad
					   and emifacon.cod_cober_reas	= ls_cober_reas
					   and emifacon.orden			= li_orden;

					if li_return = 0 Or li_return is null then
						Insert Into emifacon (
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
						Values(	a_poliza,
								"00000",
								_no_unidad,
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
							update emifacon
							   set prima			= prima + ld_prima,
								   suma_asegurada	= suma_asegurada + ld_suma
							 where no_poliza		= a_poliza
							   and no_endoso		= '00000'
							   and no_unidad		= _no_unidad
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
					let ld_suma = (_suma_asegurada * ld_porc_suma) / 100;

					if ls_ramo in('002','023') then
						select porc_cober_reas
						  into _porc_proporcion
						  from tmp_dist_rea
						 where cod_cober_reas = ls_cober_reas;

						let ld_suma = (_suma_asegurada * ld_porc_suma / 100) * _porc_proporcion / 100;
					end if

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
					   and emifacon.no_endoso		= '00000'
					   and emifacon.no_unidad		= _no_unidad
					   and emifacon.cod_cober_reas	= ls_cober_reas
					   and emifacon.orden			= li_orden;

					if li_return = 0 Or li_return is null then
						Insert Into emifacon (
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
						Values(	a_poliza,
								"00000",
								_no_unidad,
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
							update emifacon
							   set prima			= prima + ld_prima,
								   suma_asegurada	= suma_asegurada + ld_suma
							 where no_poliza		= a_poliza
							   and no_endoso		= '00000'
							   and no_unidad		= _no_unidad
							   and cod_cober_reas	= ls_cober_reas
							   and orden			= li_orden;
						end if
					end if
				end foreach
			end if

			---Verificacion de centavos diferencia
			select sum(e.prima_neta)
			  into _ld_prima_neta_t
			  from emipocob e, prdcober c
			 where e.no_poliza = a_poliza
			   and e.no_unidad = _no_unidad
			   and c.cod_cobertura = e.cod_cobertura;

			select sum(prima),
				   sum(suma_asegurada)
			  into _prima_neta_emif,
				   _suma_aseg_emif
			  from emifacon
			 where no_poliza = a_poliza
			   and no_endoso =	'00000'
			   and no_unidad =	_no_unidad;

			let _prima_dif = 0;
			let _prima_dif = _ld_prima_neta_t - _prima_neta_emif;
			if _prima_dif <> 0 and abs(_prima_dif) <= 0.03 then

				update emifacon
				   set prima			= prima + _prima_dif
				 where no_poliza		= a_poliza
				   and no_endoso		= '00000'
				   and no_unidad		= _no_unidad
				   and cod_cober_reas	= ls_cober_reas
				   and orden			= li_orden;
				
			end if

			let _suma_dif = 0;
			let _suma_dif = _suma_asegurada - _suma_aseg_emif;
			
			if _suma_dif <> 0 and abs(_suma_dif) <= 0.03 then

				update emifacon
				   set suma_asegurada   = suma_asegurada + _suma_dif
				 where no_poliza		= a_poliza
				   and no_endoso		= '00000'
				   and no_unidad		= _no_unidad
				   and cod_cober_reas	= ls_cober_reas
				   and orden			= li_orden;
				
			end if
		end if
	end foreach

	delete from emifacon --Amado 21/03/2018
	 where no_poliza         = a_poliza
	   and no_endoso		 = '00000'
	   and no_unidad		 = _no_unidad
	   and porc_partic_suma  = 0
	   and porc_partic_prima = 0;
	  
	-- Se agrega este segmento porque en las polizas de salud al insertar una unidad despues que la poliza esta actualizada no insertaba en emireaco -- Amado 07/10/2013

	{FOREACH
	 SELECT	cod_cober_reas
	   INTO	_cod_cober_reas
	   FROM	emifacon
	  WHERE	no_poliza = a_poliza
		AND no_endoso = "00000"
		AND no_unidad = _no_unidad
	  GROUP BY no_unidad, cod_cober_reas

		INSERT INTO emireama(
		no_poliza,
		no_unidad,
		no_cambio,
		cod_cober_reas,
		vigencia_inic,
		vigencia_final
		)
		VALUES(
		a_poliza, 
		_no_unidad,
		0,
		_cod_cober_reas,
		_vigencia_inic,
		_vigencia_final
		);

	END FOREACH


	INSERT INTO emireaco(
	no_poliza,
	no_unidad,
	no_cambio,
	cod_cober_reas,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima
	)
	SELECT 
	a_poliza, 
	_no_unidad,
	0,
	cod_cober_reas,
	orden,
	cod_contrato,
	porc_partic_suma,
	porc_partic_prima
	FROM emifacon
	WHERE no_poliza = a_poliza
	  AND no_endoso = '00000'
	  AND no_unidad	= _no_unidad;
	}
end foreach
--drop table if exists tmp_dist_rea;

return 0;
end
end procedure;