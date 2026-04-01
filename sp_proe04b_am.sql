-- Procedimiento para actualizar los valores de emifacon por unidad
-- f_emision_cargar_reaseguro
--
-- Creado:     05/01/2000 - Autor Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe04b_am;
create procedure sp_proe04b_am(a_poliza char(10), a_unidad char(5), a_suma dec(16,2), a_no_endoso char(5))
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
define _porc_proporcion		dec(16,6);
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
define _vigencia_inic,_fecha_emision		date;
define _cod_producto        char(5);

if a_poliza = '0001642968' and a_no_endoso = '00014' and a_unidad = '00005' then
	set debug file to "sp_proe04b.trc";
	trace on;
end if

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

select tipo_produccion
  into li_tipopro
  from emitipro
 where cod_tipoprod = ls_tipopro;

let ld_porc_coaseg = 0.00;

if li_tipopro = 2 then
-- la suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
-- campo - aseguradora lider

	select e.porc_partic_coas 					  
	  into ld_porc_coaseg
	  from parparam p, emicoama e
	 where p.cod_compania = '001'
	   and e.no_poliza    = a_poliza
	   and e.cod_coasegur = p.par_ase_lider;

	if ld_porc_coaseg is null then
		let ld_porc_coaseg = 0.00;
	end if
end if

delete from emifacon
 where no_poliza  = a_poliza
   and no_endoso  = a_no_endoso
   and no_unidad  = a_unidad;

let ld_porc_suma = 0.00;
let ld_suma = 0.00;

delete from emigloco
where no_poliza = a_poliza
  and no_endoso = a_no_endoso;

select count(*) 
  into ll_rea_glo
  from emigloco
 where no_poliza = a_poliza
   and no_endoso = a_no_endoso;

if ll_rea_glo is null then
   let ll_rea_glo = 0;
end if

select cod_endomov,
       fecha_emision
  into _cod_endomov,
       _fecha_emision
  from endedmae
 where no_poliza = a_poliza
   and no_endoso = a_no_endoso;
   
select cod_producto
  into _cod_producto
  from endeduni
 where no_poliza = a_poliza
   and no_endoso = a_no_endoso
   and no_unidad = a_unidad;
   
select vigencia_inic
  into _vigencia_inic
  from emipomae
 where no_poliza = a_poliza;

select tipo_mov
  into _tipo_mov
  from endtimov
 where cod_endomov = _cod_endomov;

if ll_rea_glo = 0 then --Para cuando no hay emigloco
		let _vigencia_inic = _fecha_emision;
		
		select cod_ruta
		  into ls_ruta
		  from rearumae
		 where cod_ramo = ls_ramo
		   and activo   = 1
		   and _vigencia_inic between vig_inic and vig_final
		   and nombre not like '%FACULT%'; --Poner en Comentario

		IF a_poliza = '0002140614' and a_no_endoso = '00002' and a_unidad = '00001' then
			LET ls_ruta = '00843';
		end if
		
		IF a_poliza = '2132150' and a_no_endoso = '00002' and a_unidad = '00001' then
			LET ls_ruta = '00843';
		end if
	   
	select * 
	  from rearucon
	 where cod_ruta = ls_ruta
	   and porc_partic_prima <> 0
	   and porc_partic_suma <> 0
	  into temp prueba;

	insert into emigloco(
			no_poliza,
			no_endoso,
			orden,
			cod_contrato,
			cod_ruta,
			porc_partic_prima,
			porc_partic_suma,
			suma_asegurada,
			prima)
	select	a_poliza,
			a_no_endoso,
			orden,
			cod_contrato,
	        cod_ruta,
			porc_partic_prima,
			porc_partic_suma,
	       	0,0
	  from prueba;

	drop table prueba;
end if
--*********************************************
--*********************************************
foreach
	select cod_ruta
	  into ls_ruta
	  from emigloco
	 where no_poliza = a_poliza
	   and no_endoso = a_no_endoso
	exit foreach;
end foreach

select mult_plenos
  into _mult_plenos
  from rearumae
 where cod_ruta = ls_ruta;

if ls_ramo = '002' or ls_ramo = '023' then
    drop table if exists tmp_dist_rea;
	call sp_sis188b(a_poliza,a_no_endoso,a_unidad) returning _error,_mensaje;
end if

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

	select count(*)
	  into li_orden
	  from rearucon
	 where cod_ruta       = ls_ruta
	   and cod_cober_reas = ls_cober_reas;

	if li_orden = 0 then  --No hay contrato en la ruta para esa cobertura
		drop table if exists tmp_dist_rea;
		return 1;
	end if

		if _tipo_mov = 4 then
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
					--   and porc_partic_prima <> 0
					--   and porc_partic_suma <> 0
					 order by orden

					let ld_suma  = 0.00;
					let ld_prima = 0.00;
					let ld_suma  = (a_suma * ld_porc_suma) / 100;

					if ls_ramo = '002' or ls_ramo = '023' then
						select porc_cober_reas
						  into _porc_proporcion
						  from tmp_dist_rea
						 where cod_cober_reas = ls_cober_reas;

						let ld_suma = (a_suma * ld_porc_suma / 100) * _porc_proporcion / 100;
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
					 where no_poliza = a_poliza
					   and no_endoso = a_no_endoso
					   and no_unidad = a_unidad
					   and cod_cober_reas = ls_cober_reas
					   and orden = li_orden;
					   
					
					if li_return = 0 or li_return is null then
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
								a_no_endoso,
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
							update emifacon
							   set prima = prima + ld_prima,
								   suma_asegurada = suma_asegurada + ld_suma
							 where no_poliza = a_poliza
							   and no_endoso = a_no_endoso
							   and no_unidad = a_unidad
							   and cod_cober_reas = ls_cober_reas
							   and orden = li_orden;
						end if
					end if
				end foreach
		else
			select max(no_cambio)
			  into _max_no_cambio
			  from emireaco
			 where no_poliza = a_poliza
			   and no_unidad = a_unidad;

			foreach
				select orden,
					   cod_contrato,
					   porc_partic_suma,
					   porc_partic_prima
				  into li_orden,
					   ls_contrato,
					   ld_porc_suma,
					   ld_porc_prima
				  from emireaco
				 where no_poliza      = a_poliza
				   and no_unidad      = a_unidad
				   and cod_cober_reas = ls_cober_reas
				   and no_cambio      = _max_no_cambio
				 order by orden

				let ld_suma  = 0.00;
				let ld_prima = 0.00;
				let ld_suma  = (a_suma * ld_porc_suma) / 100;

				if ls_ramo = '002' or ls_ramo = '023' then
					select porc_cober_reas
					  into _porc_proporcion
					  from tmp_dist_rea
					 where cod_cober_reas = ls_cober_reas;
					 
					if _porc_proporcion = 0 then
						let _porc_proporcion = 100;
					end if

					let ld_suma = (a_suma * ld_porc_suma / 100) * _porc_proporcion / 100;
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
				 where no_poliza = a_poliza
				   and no_endoso = a_no_endoso
				   and no_unidad = a_unidad
				   and cod_cober_reas = ls_cober_reas
				   and orden = li_orden;

				if li_return = 0 or li_return is null then
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
							a_no_endoso,
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
						update emifacon
						   set prima = prima + ld_prima,
							   suma_asegurada = suma_asegurada + ld_suma
						 where no_poliza = a_poliza
						   and no_endoso = a_no_endoso
						   and no_unidad = a_unidad
						   and cod_cober_reas = ls_cober_reas
						   and orden = li_orden;
					end if
				end if
			end foreach
		end if
		
		---Verificacion de centavos diferencia		   
		select sum(e.prima_neta)
		  into _ld_prima_neta_t
		  from endedcob e, prdcober c
		 where c.cod_cobertura = e.cod_cobertura
		   and e.no_poliza = a_poliza
		   and e.no_endoso = a_no_endoso
		   and e.no_unidad = a_unidad;

		select sum(prima),
		       sum(suma_asegurada)
		  into _prima_neta_emif,
		       _suma_aseg_emif
		  from emifacon
		 where no_poliza = a_poliza
		   and no_endoso =	a_no_endoso
		   and no_unidad =	a_unidad;

		let _prima_dif = 0;
        let _prima_dif = _ld_prima_neta_t - _prima_neta_emif;

        if _prima_dif <> 0 and abs(_prima_dif) <= 0.03 then

			update emifacon
			   set prima = prima + _prima_dif
			 where no_poliza = a_poliza
			   and no_endoso = a_no_endoso
			   and no_unidad = a_unidad
			   and cod_cober_reas = ls_cober_reas
			   and orden = li_orden;			
        end if

		let _suma_dif = 0;
        let _suma_dif = a_suma - _suma_aseg_emif;
		
        if _suma_dif <> 0 and abs(_suma_dif) <= 0.03 then

			update emifacon
			   set suma_asegurada = suma_asegurada + _suma_dif
			 where no_poliza = a_poliza
			   and no_endoso = a_no_endoso
			   and no_unidad = a_unidad
			   and cod_cober_reas = ls_cober_reas
			   and orden = li_orden;			
        end if		
end foreach

if ls_ramo = '002' or ls_ramo = '023' then
	drop table tmp_dist_rea;
end if

return 0;
end
end procedure 