
drop procedure sp_pro222;
create procedure 'informix'.sp_pro222(
a_poliza		char(10),
a_unidad		char(5),
a_suma			dec(16,2),
a_cia			char(3),
a_opcion		integer default 0)
returning   integer   -- _error


define _mensaje				varchar(100);
define ls_contrato			char(5);
define ls_ruta				char(5);
define ls_cober_reas		char(3);
define ls_ase_lider			char(3);
define ls_impuesto			char(3);
define ls_perpago			char(3);
define ls_tipopro			char(3);
define ls_ramo				char(3);
define ld_porc_impuesto		dec(16,4);
define ld_porc_coaseg		dec(16,4);
define ld_suma_asegurada	dec(16,2);
define ld_prima_anual		dec(16,2);
define ld_prima_bruta		dec(16,2);
define ld_prima_total		dec(16,2);
define ld_prima_neta		dec(16,2);
define ld_descuento			dec(16,2);
define ld_imp_total			dec(16,2);
define ld_impuesto1			dec(16,2);
define ld_impuesto			dec(16,2);
define ld_suscrita			dec(16,2);
define ld_retenida			dec(16,2);
define ld_recargo			dec(16,2);
define ld_suma				dec(16,2); 
define ld_letra				dec(16,2);
define ld_prima				dec(16,2);
define ld_porc_prima		dec(10,4);
define ld_porc_suma			dec(10,4);
define _porc_proporcion		dec(9,6);
define li_tipo_ramo			integer;
define li_tipopro			integer;
define ll_rea_glo			integer;
define li_return			integer;
define li_orden				integer;
define li_meses				integer;
define _error				integer;
define li_uno				integer;
define _vigencia_inic		date;

begin
on exception set _error 
 	return _error;         
end exception

set isolation to dirty read;

if a_poliza = '1154410' then
--set debug file to "sp_pro222.trc"; 
--trace on;
end if
drop table if exists tmp_dist_rea;
return 0;


-- Buscar Tipo de Ramo, Periodo de Pago y Tipo de Produccion
select cod_tipoprod,
	   vigencia_inic
  into ls_tipopro,
	   _vigencia_inic
  from emireaut
 where no_poliza = a_poliza
   and no_unidad = a_unidad;

select cod_ramo
  into ls_ramo
  from emipomae
 where no_poliza = a_poliza;

select tipo_produccion
  into li_tipopro
  from emitipro
 where cod_tipoprod = ls_tipopro;

delete from emireglo
 where no_poliza = a_poliza;

select cod_ruta
  into ls_ruta
  from rearumae
 where cod_ramo = ls_ramo
   and activo = 1
   and _vigencia_inic between vig_inic and vig_final
   and nombre not like '%FACULT%';

let ld_porc_coaseg = 0.00;

foreach
	select orden,
		   cod_contrato,
		   porc_partic_prima,
		   porc_partic_suma
	  into li_orden,
		   ls_contrato,
		   ld_porc_prima,
		   ld_porc_suma
	  from rearucon
	 where cod_ruta = ls_ruta

	insert into emireglo(
			no_poliza,
			no_endoso,
			orden,
			cod_contrato,
			porc_partic_prima,
			porc_partic_suma,
			suma_asegurada,
			prima,
			cod_ruta)
	values(	a_poliza,
			'00000',
			li_orden,
			ls_contrato,
			ld_porc_prima,
			ld_porc_suma,
			0.00,
			0.00,
			ls_ruta);
end foreach

if li_tipopro = 2 then
	-- La suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros campo - Aseguradora Lider

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

foreach
	select cod_ruta
	  into ls_ruta
	  from emireglo
	 where no_poliza = a_poliza
	   and no_endoso = '00000'
	exit foreach;
end foreach

delete from emirerea
 where no_poliza   = a_poliza
   and no_endoso  = '00000'
   and no_unidad  = a_unidad;
	
let ld_porc_suma = 0.00;
let ld_suma = 0.00;

select cod_ramo
  into ls_ramo 
  from emipomae
 where no_poliza = a_poliza;

if ls_ramo = '002' then
	call sp_sis188(a_poliza) returning _error,_mensaje;
end if

foreach
	select p.cod_cober_reas,
		   sum(e.prima_neta_o)
	   into ls_cober_reas,
			ld_letra
	   from emireau2 e, prdcober p 
	  where p.cod_cobertura = e.cod_cobertura
		and e.no_poliza = a_poliza
		and e.no_unidad = a_unidad
	  group by p.cod_cober_reas

	foreach
		select cod_contrato,
			   porc_partic_suma,
			   porc_partic_prima,
			   orden
		  into ls_contrato,
			   ld_porc_suma,
			   ld_porc_prima,
			   li_orden
		  from rearucon
		 where cod_ruta = ls_ruta
		   and cod_cober_reas = ls_cober_reas
		 order by orden

		let ld_suma  = 0.00;
		let ld_prima = 0.00;			
		let ld_suma = (a_suma * ld_porc_suma) / 100;

		if ls_ramo = '002' then
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
			values(	a_poliza,
					'00000',
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

drop table if exists tmp_dist_rea;

end
end procedure                                                                                                                                                                                                 
