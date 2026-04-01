-- Procedimiento para actualizar los valores de emifacon por unidad
-- f_emision_cargar_reaseguro
--
-- Creado:     05/01/2000 - Autor Edgar E. Cano G.
-- Modificado: 05/01/2000 - Autor Edgar E. Cano G.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe04_vida_r;
create procedure sp_proe04_vida_r(a_poliza char(10),a_unidad char(5),a_ruta char(5) default "",a_suma dec(16,2),a_cia char(3))
returning	integer;

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
define li_return,li_return1		 	integer;
define li_orden				integer;
define li_meses				integer;
define _error,_excedente,_facultativo		integer;
define li_uno,_tipo_contrato				integer;
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
define ld_descuento,_prima_neta		   	dec(16,2);
define ld_impuesto1		   	dec(16,2);
define ld_imp_total       	dec(16,2);
define ld_impuesto,_limite_maximo,_limite_acum		   	dec(16,2);
define ld_suma_dif,_valor_suma			dec(16,2);
define ld_suscrita,_prima_contrato       	dec(16,2);
define ld_retenida       	dec(16,2);
define ld_recargo		   	dec(16,2);
define ld_prima		   		dec(16,2);
define _porc_partic_suma,_porc_partic_prima,_porc_dif dec(9,6);
define ld_letra,ld_prima_acum				dec(16,2);
define ld_suma,_suma_queda	dec(16,2); 
define _prima_dif        	dec(16,2);
define _suma_dif,_porc_riesgo          dec(16,2);
define _suma_aseg_emif      dec(16,2);
define ld_porc_impuesto		dec(16,4);
define ld_porc_coaseg	dec(16,4);
define _vigencia_inic		date;
define _vigencia_final		date;
define _mensaje         varchar(150);
define _tasa_adelanto   dec(5,4);
define _suma_unidad,_suma_adelanto,_valor_recargo dec(16,4);
define _porc_rercargo  dec(5,2);

begin

on exception set _error,_error_isam,_error_desc
    if _error = -530 then
		let _error = 341;
	end if
 	return _error;
end exception

set isolation to dirty read;

--set debug file to "sp_proe04_vida.trc";
--trace on;

let _porc_partic_suma  = 0.00;
let _porc_partic_prima = 0.00;
let _prima_contrato    = 0.00;

if a_poliza in("3032718","2975572") then   --Esto es temporal, mientras se define como se precedera.
	let _cant = sp_proe04(a_poliza,a_unidad	,a_suma	,a_cia);
	return _cant;
end if

--****BUSQUEDA DE QX Y TASA(ADELANTO DE 0.9360)*****
call sp_sis264(a_poliza) returning li_return1,_mensaje,_porc_riesgo,_tasa_adelanto;

select cod_tipoprod,
	   cod_ramo,
	   vigencia_inic,
	   vigencia_final
  into ls_tipopro,
	   ls_ramo,
	   _vigencia_inic,
	   _vigencia_final
  from emipomae
 where no_poliza = a_poliza;
 
let _prima_neta = 0.00;

select prima_neta
  into _prima_neta
  from emipouni
 where no_poliza = a_poliza
   and no_unidad = a_unidad;
   
if _prima_neta = 0.00 then
	return 0;
end if	
--Buscar si tiene recargo***************
let _porc_rercargo = 0;
let _valor_recargo = 0;
foreach
	select porc_recargo
	  into _porc_rercargo
	  from emiunire
	 where no_poliza = a_poliza
       and no_unidad = a_unidad
	exit foreach;
end foreach
if _porc_rercargo <> 0 then
	let _valor_recargo = 1 + _porc_rercargo/100;
end if

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

delete from emifacon
 where no_poliza   = a_poliza
   and no_endoso  = '00000'
   and no_unidad  = a_unidad;

let ld_suma 	  = 0.00;
let ld_porc_suma  = 0.00;

let ls_ruta = null;
foreach
	select emigloco.cod_ruta
	  into ls_ruta
	  from emigloco
	 where emigloco.no_poliza = a_poliza
	   and emigloco.no_endoso = '00000'
	exit foreach;
end foreach
--En caso de que no exista emigloco.
if ls_ruta is null then
	foreach
		select cod_ruta
		  into ls_ruta
		  from rearumae
		 where cod_ramo = ls_ramo
		   and _vigencia_inic between vig_inic and vig_final
		   and activo = 1
		exit foreach;
	end foreach
end if

if a_ruta <> "" then
	let ls_ruta = a_ruta;
end if

--***SE GUARDA VALOR ORIGINAL DE LA SUMA DE LA UNIDAD
let _suma_unidad   = 0;
let _suma_adelanto = 0;
let _suma_unidad = a_suma;
let _suma_adelanto = a_suma * 35/100;

foreach
	select c.cod_cober_reas,
		   sum(e.prima_neta)
	  into ls_cober_reas,
	  	   ld_letra
	  from emipocob e, prdcober c 
      where e.no_poliza = a_poliza
        and e.no_unidad = a_unidad
        and c.cod_cobertura = e.cod_cobertura
      group by c.cod_cober_reas
	  
	let ls_cober_reas = ls_cober_reas;
	let ls_ruta       = ls_ruta;
	let _prima_neta   = ld_letra;
	  
	select count(*)
	  into li_orden
	  from rearucon
	 where cod_ruta       = ls_ruta
	   and cod_cober_reas = ls_cober_reas;

	if li_orden = 0 then  --No hay contrato en la ruta para esa cobertura
		return 1;
	end if
	let _suma_queda = 0.00;
	let _excedente   = 0;
	let _facultativo = 0;
	let _limite_acum = 0;
	let _valor_suma = 0.00;
	if ls_cober_reas in('020','051') then
		foreach
			select r.porc_partic_suma,
				   w.tipo_contrato,
				   c.limite_maximo
			  into _porc_partic_suma,
				   _tipo_contrato,
				   _limite_maximo
			from rearucon r, reacomae w, reacocob c
		   where r.cod_contrato = w.cod_contrato
			 and r.cod_contrato = c.cod_contrato
			 and r.cod_cober_reas = c.cod_cober_reas
			 and r.cod_ruta       = ls_ruta
			 and r.cod_cober_reas = ls_cober_reas
			 and c.limite_maximo > 0
			
			if ls_cober_reas = '051' then
				let a_suma = _suma_adelanto;
			end if
			if ls_cober_reas = '020' then
				let a_suma = _suma_unidad;
			end if
			
			if _tipo_contrato = 1 then	--Retencion
				let _limite_acum = _limite_acum + _limite_maximo;
			elif _tipo_contrato = 5 then	--Cuota parte
				let _limite_acum = _limite_acum + _limite_maximo;
				let _valor_suma = a_suma * _porc_partic_suma /100;
				if _valor_suma <= _limite_maximo then
					let _excedente = 0;	--no lleva Excedente
					exit foreach;
				else
					let _excedente = 1;	--lleva Excedente
				end if
			elif _tipo_contrato = 7 then	--Excedente
				if (a_suma - _limite_acum) <= _limite_maximo then
					let _facultativo = 0;	--no lleva Facultativo
				else
					let _facultativo = 1;	--lleva Facultativo
					let _limite_acum = _limite_acum + _limite_maximo;
				end if
			end if
		end foreach
	end if
	let ld_prima_acum = 0.00;
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
		 
		select tipo_contrato
          into _tipo_contrato
          from reacomae
         where cod_contrato = ls_contrato;		  
		 
		select limite_maximo
		  into _limite_maximo
		  from reacocob
		 where cod_contrato   = ls_contrato
		   and cod_cober_reas = ls_cober_reas;
		   
		let ld_suma  = 0.00;
		let ld_prima = 0.00;
		if ls_cober_reas in('020','051') then
			if _excedente = 0 then
				if _tipo_contrato in(3,7) then
					continue foreach;
				end if
				let ld_suma = (a_suma * ld_porc_suma) / 100;
			else
				if _facultativo = 0 then --No lleva fac.
					if _tipo_contrato = 1 then --Retencion
						let ld_suma  = _limite_maximo;
						let _suma_queda = a_suma - _limite_maximo;
						let ld_porc_suma = (ld_suma / a_suma)  * 100;
					elif _tipo_contrato = 5 then --Cuota P.
						let ld_suma  = _limite_maximo;
						let _suma_queda = a_suma - _limite_maximo;
						let ld_porc_suma = (ld_suma / a_suma)  * 100;
					elif _tipo_contrato = 7 then --Excedente.
						let ld_suma  = a_suma - _limite_acum;
						let ld_porc_suma = (ld_suma / a_suma)  * 100;
					end if
				else --lleva fac.
					if _tipo_contrato = 1 then --Retencion
						let ld_suma  = _limite_maximo;
						let _suma_queda = a_suma - _limite_maximo;
						let ld_porc_suma = (ld_suma / a_suma)  * 100;
					elif _tipo_contrato = 5 then --Cuota P.
						let ld_suma  = _limite_maximo;
						let _suma_queda = a_suma - _limite_maximo;
						let ld_porc_suma = (ld_suma / a_suma)  * 100;
					elif _tipo_contrato = 7 then --Excedente.
						let ld_suma = _limite_maximo;
						let _suma_queda = a_suma - _limite_maximo;					
						let ld_porc_suma = (ld_suma / a_suma)  * 100;
					elif _tipo_contrato = 3 then --Fac.
						let ld_suma  = a_suma - _limite_acum;
						let ld_porc_suma = (ld_suma / a_suma)  * 100;
					end if
				end if
			end if
		end if	

		if ld_porc_coaseg > 0 then
			let ld_suma = (ld_suma * ld_porc_coaseg) / 100;
		end if
		
		if ls_cober_reas = '020' then
			let ld_prima = (ld_suma * _porc_riesgo) / 1000;
			--CALCULO DEL RECARGO A LA PRIMA
			if _valor_recargo <> 0 then
				let ld_prima = ld_prima * _valor_recargo;
			end if
		elif ls_cober_reas = '051' then
			let ld_prima = (ld_suma * _tasa_adelanto) / 1000;
			--CALCULO DEL RECARGO A LA PRIMA
			if _valor_recargo <> 0 then
				let ld_prima = ld_prima * _valor_recargo;
			end if
		else
			let ld_prima = _prima_neta;
		end if
		if ld_porc_coaseg > 0 then
			let ld_prima = (ld_prima * ld_porc_coaseg) / 100;
		end if		
		if _prima_neta <> 0 then
			let ld_porc_prima = (ld_prima / _prima_neta) * 100;
		end if	
		
		select count(*)
		  into li_return
		  from emifacon
		 where emifacon.no_poliza		= a_poliza
		   and emifacon.no_endoso		= '00000'
		   and emifacon.no_unidad		= a_unidad
		   and emifacon.cod_cober_reas	= ls_cober_reas
		   and emifacon.orden			= li_orden;
		
		if ls_cober_reas in('020','051') then
			let ld_prima_acum = ld_prima_acum + ld_prima;
			if _tipo_contrato = 1 then	--Retencion no debe acumular prima, se actualiza al final.
				let ld_prima_acum = 0.00;
			end if
			if ld_prima_acum > _prima_neta then
				return 341;
			end if
		end if
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
	select sum(e.prima_neta)
	  into _ld_prima_neta_t
	  from emipocob e, prdcober c
	 where e.no_poliza = a_poliza
	   and e.no_unidad = a_unidad
	   and c.cod_cobertura = e.cod_cobertura
	   and c.cod_cober_reas not in('050');
	   
    select orden
	  into li_orden
	  from emifacon e, reacomae r
	 where e.cod_contrato = r.cod_contrato
	   and e.no_poliza = a_poliza
	   and e.no_endoso = '00000'
	   and e.no_unidad = a_unidad
   	   and e.cod_cober_reas = '020'
	   and r.tipo_contrato = 1 --Ret.
	   and e.cod_cober_reas not in('050');
	   
	select sum(prima)
	  into _prima_contrato
	  from emifacon e, reacomae r
	 where e.cod_contrato = r.cod_contrato
	   and e.no_poliza = a_poliza
	   and e.no_endoso = '00000'
	   and e.no_unidad = a_unidad
	   and r.tipo_contrato <> 1;
	
	if ls_cober_reas in('020','051') then
		update emifacon
		   set prima			= _ld_prima_neta_t - _prima_contrato,
			   porc_partic_prima = (_ld_prima_neta_t - _prima_contrato) / _ld_prima_neta_t * 100
		 where no_poliza		= a_poliza
		   and no_endoso		= '00000'
		   and no_unidad		= a_unidad
		   and cod_cober_reas	= ls_cober_reas
		   and orden			= li_orden;
	end if

	select sum(prima),
		   sum(suma_asegurada)
	  into _prima_neta_emif,
		   _suma_aseg_emif
	  from emifacon
	 where no_poliza = a_poliza
	   and no_endoso =	'00000'
	   and cod_cober_reas <> '050'
	   and no_unidad =	a_unidad;
	   
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
	--*******************************************************************
	select sum(porc_partic_suma),
		   sum(porc_partic_prima)
	  into _porc_partic_suma,
           _porc_partic_prima	  
	  from emifacon
	 where no_poliza = a_poliza
	   and no_endoso =	'00000'
	   and cod_cober_reas = ls_cober_reas
	   and cod_cober_reas <> '050'
	   and no_unidad = a_unidad;
	   
	let _porc_dif = 0;
	let _porc_dif = 100 - _porc_partic_suma;
	if _porc_dif <> 0 and abs(_porc_dif) <= 0.03 then

		update emifacon
		   set porc_partic_suma	= porc_partic_suma + _porc_dif
		 where no_poliza		= a_poliza
		   and no_endoso		= '00000'
		   and no_unidad		= a_unidad
		   and cod_cober_reas	= ls_cober_reas
		   and orden			= li_orden;
		
	end if
	let _porc_dif = 0.00;
	let _porc_dif = 100 - _porc_partic_prima;
	
	if _porc_dif <> 0 and abs(_porc_dif) <= 0.03 then
		
		update emifacon
		   set porc_partic_prima	= porc_partic_prima + _porc_dif
		 where no_poliza		= a_poliza
		   and no_endoso		= '00000'
		   and no_unidad		= a_unidad
		   and cod_cober_reas	= ls_cober_reas
		   and orden			= li_orden;
		
	end if	
	--*************************************************************************
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

delete from emifacon
 where no_poliza         = a_poliza
   and no_endoso		 = '00000'
   and no_unidad		 = a_unidad
   and porc_partic_suma  = 0
   and porc_partic_prima = 0;

let _prima_neta_emif = 0.00;
   
select sum(r.prima)
  into _prima_neta_emif
 from emifacon r, reacomae t
where r.cod_contrato = t.cod_contrato
and r.no_poliza = a_poliza
and r.no_endoso = '00000'
and t.tipo_contrato = 1;

update endedmae
   set prima_retenida = _prima_neta_emif
 where no_poliza = a_poliza
   and no_endoso = '00000';
   
update endedhis
   set prima_retenida = _prima_neta_emif
 where no_poliza = a_poliza
   and no_endoso = '00000';
  
return 0;
end
end procedure;