-- Procedimiento para actualizar los valores de emifacon por unidad
-- f_emision_cargar_reaseguro
--
-- Creado:     05/01/2000 - Autor Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe04cam;
create procedure "informix".sp_proe04cam(a_poliza char(10), a_unidad char(5), a_suma decimal(16,2), a_cia char(3))
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
define _mensaje             varchar(100);
define _no_cambio           smallint;

define _porc_proporcion		dec(9,6);
define _ld_prima_neta_t		decimal(16,2);
define _prima_neta_emif    	decimal(16,2);
define _prima_dif        	decimal(16,2);
define _suma_dif            decimal(16,2);
define _suma_aseg_emif      decimal(16,2);

define _vigencia_inic		date;
define _vigencia_final		date;
define _cod_cober_reas     	char(3);

begin

on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

let _porc_proporcion = 0.00;

--set debug file to "sp_proe04.trc";
--trace on;

-- buscar tipo de ramo, periodo de pago y tipo de produccion
select cod_tipoprod,cod_ramo, vigencia_inic, vigencia_final
  into ls_tipopro,ls_ramo, _vigencia_inic, _vigencia_final
  from emipomae
 where no_poliza = a_poliza;

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
	 where parparam.cod_compania = a_cia
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
   and no_endoso  = '00000'
   and no_unidad  = a_unidad;

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

foreach
	select prdcober.cod_cober_reas,
		   sum(emipocob.prima_neta)
	  into ls_cober_reas,
	  	   ld_letra
	  from emipocob, prdcober  
      where emipocob.no_poliza = a_poliza
        and emipocob.no_unidad = a_unidad
        and prdcober.cod_cobertura = emipocob.cod_cobertura
      group by prdcober.cod_cober_reas

	let _porc_proporcion = 0.00;
	

		foreach

			select orden,
				   cod_contrato,
				   100,
				   100
			  into li_orden,
			  	   ls_contrato,
				   ld_porc_suma,
				   ld_porc_prima
			  from rearucon
			 where cod_ruta       = ls_ruta
			   and cod_cober_reas = ls_cober_reas
			   and cod_contrato   = '00621'
			 order by orden

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
			  from emifacon
			 where emifacon.no_poliza		= a_poliza
			   and emifacon.no_endoso		= '00000'
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
							  		  "00000",
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
					   set prima			= prima + ld_prima,
						   suma_asegurada	= suma_asegurada + ld_suma
					 where no_poliza		= a_poliza
					   and no_endoso		= '00000'
					   and no_unidad		= a_unidad
					   and cod_cober_reas	= ls_cober_reas
					   and orden			= li_orden;
				end if
			end if

		end foreach
			---Verificacion de centavos diferencia

		select sum(emipocob.prima_neta)
		  into _ld_prima_neta_t
		  from emipocob, prdcober
	     where emipocob.no_poliza = a_poliza
	       and emipocob.no_unidad = a_unidad
	       and prdcober.cod_cobertura = emipocob.cod_cobertura;

		select sum(prima),
		       sum(suma_asegurada)
		  into _prima_neta_emif,
		       _suma_aseg_emif
		  from emifacon
		 where emifacon.no_poliza = a_poliza
		   and emifacon.no_endoso =	'00000'
		   and emifacon.no_unidad =	a_unidad;

		let _prima_dif = 0;
        let _prima_dif = _ld_prima_neta_t - _prima_neta_emif;
        if _prima_dif <> 0 and abs(_prima_dif) <= 0.03 then

			update emifacon
			   set prima			= prima + _prima_dif
			 where no_poliza		= a_poliza
			   and no_endoso		= '00000'
			   and no_unidad		= a_unidad
			   and cod_cober_reas	= ls_cober_reas
			   and orden			= li_orden;
			
        end if

		let _suma_dif = 0;
        let _suma_dif = a_suma - _suma_aseg_emif;
        if _suma_dif <> 0 and abs(_suma_dif) <= 0.03 then

			update emifacon
			   set suma_asegurada   = suma_asegurada + _suma_dif
			 where no_poliza		= a_poliza
			   and no_endoso		= '00000'
			   and no_unidad		= a_unidad
			   and cod_cober_reas	= ls_cober_reas
			   and orden			= li_orden;
			
        end if 


end foreach

-- Se agrega este segmento porque en las polizas de salud al insertar una unidad despues que la poliza esta actualizada no insertaba en emireaco -- Amado 07/10/2013

select max(no_cambio)
  into _no_cambio
  from emireama
  WHERE	no_poliza = a_poliza
	AND no_unidad = a_unidad;

 let _no_cambio = _no_cambio + 1;

FOREACH
 SELECT	cod_cober_reas
   INTO	_cod_cober_reas
   FROM	emifacon
  WHERE	no_poliza = a_poliza
    AND no_endoso = "00000"
	AND no_unidad = a_unidad
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
	a_unidad,
	_no_cambio,
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
a_unidad,
_no_cambio,
cod_cober_reas,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
FROM emifacon
WHERE no_poliza = a_poliza
  AND no_endoso = '00000'
  AND no_unidad	= a_unidad;

return 0;
end
end procedure;