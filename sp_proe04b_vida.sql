
drop procedure sp_proe04b_vida;
create procedure sp_proe04b_vida(a_poliza char(10), a_unidad char(5), a_suma dec(16,2), a_no_endoso char(5),a_ruta char(5) default "")
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
define ld_recargo,_suma_endoso		   	dec(16,2);
define _prima_dif,_prima_neta_ori           dec(16,2);
define _suma_dif,_prima_contrato            dec(16,2);
define ld_prima,_prima_neta		   		dec(16,2);
define ld_letra,ld_prima_acum				dec(16,2);
define _porc_partic_suma,_porc_partic_prima,_porc_dif dec(9,6);
define ld_suma,_valor_suma				dec(16,2); 
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
define li_meses,_tipo_contrato				integer;
define _error,_excedente,_facultativo				integer;
define li_uno,li_return1	integer;
define _vigencia_inic		date;
define _cod_producto        char(5);
define _porc_riesgo         dec(16,2);
define _suma_queda,_limite_maximo,_limite_acum          dec(16,2);
define _tasa_adelanto dec(5,4);
define _suma_adelanto,_suma_unidad,_valor_recargo dec(16,2);
define _porc_rercargo       dec(5,2);


iF a_poliza = '3009315' and a_no_endoso = '00001' and a_unidad = '00001' then
	set debug file to "sp_proe04b_vida.trc";
	trace on;
end if

begin
on exception set _error,_error_isam,_error_desc 
 	return _error;
end exception

set isolation to dirty read;

call sp_sis264(a_poliza) returning li_return1,_mensaje,_porc_riesgo,_tasa_adelanto;

let _prima_neta  = 0.00;
let ld_retenida  = 0.00;
let _suma_endoso = 0;

select cod_endomov
  into _cod_endomov
  from endedmae
 where no_poliza = a_poliza
   and no_endoso = a_no_endoso;
   
select prima_neta,
       suma_asegurada
  into _prima_neta,
       _suma_endoso
  from endeduni
 where no_poliza = a_poliza
   and no_endoso = a_no_endoso
   and no_unidad = a_unidad;
   
select prima_neta
  into _prima_neta_ori
  from endeduni
 where no_poliza = a_poliza
   and no_endoso = '00000'
   and no_unidad = a_unidad;

--Buscar si tiene recargo el endoso***************
let _porc_rercargo = 0;
let _valor_recargo = 0;
foreach
	select porc_recargo
	  into _porc_rercargo
	  from endunire
	 where no_poliza = a_poliza
	   and no_endoso = a_no_endoso
       and no_unidad = a_unidad
	exit foreach;
end foreach

if _porc_rercargo <> 0 then
	let _valor_recargo = 1 + _porc_rercargo/100;
end if
--**************************************
   
if _cod_endomov in('002','003') then	--ENDOSO DE CANCELACION, REHABILITACION
   select * from emifacon
	where no_poliza = a_poliza
      and no_endoso = '00000'
      and no_unidad = a_unidad
	 into temp emi_temp;
	  
    update emi_temp
	   set no_endoso = a_no_endoso,
		   prima = _prima_neta * porc_partic_prima /100,
		   suma_asegurada = _suma_endoso * porc_partic_suma /100
     where no_poliza = a_poliza
	   and no_endoso = "00000"
	   and no_unidad = a_unidad;
		 
	delete from emifacon
	 where no_poliza  = a_poliza
       and no_endoso  = a_no_endoso
       and no_unidad  = a_unidad;
	   
	insert into emifacon
    select * from emi_temp;

	drop table emi_temp;
	
	select sum(prima)
	  into ld_retenida
	  from emifacon e, reacomae r
	 where e.cod_contrato = r.cod_contrato
	   and e.no_poliza = a_poliza
	   and e.no_endoso = a_no_endoso
	   and e.no_unidad = a_unidad
	   and r.tipo_contrato = 1;
	   
	update endedmae
	   set prima_retenida = ld_retenida
	 where no_poliza = a_poliza
	   and no_endoso = a_no_endoso;
	   
	update endedhis
	   set prima_retenida = ld_retenida
	 where no_poliza = a_poliza
	   and no_endoso = a_no_endoso;
	   
	let _prima_neta = 0.00; --para que salga
	   
elif _cod_endomov = '006' And _suma_endoso = 0 then
    select e.*
	  from emifacon e, reacomae r
	 where e.cod_contrato = r.cod_contrato
	   and e.no_poliza = a_poliza
	   and e.no_endoso = '00000'
	   and e.no_unidad = a_unidad
	   and r.tipo_contrato = 1
	  into temp emi_temp;
	  
    update emi_temp
	   set no_endoso = a_no_endoso,
		   prima     = _prima_neta,
		   suma_asegurada = 0,
		   porc_partic_suma = 100,
		   porc_partic_prima = 100
     where no_poliza = a_poliza
	   and no_endoso = '00000'
	   and no_unidad = a_unidad;
		 
	delete from emifacon
	 where no_poliza  = a_poliza
       and no_endoso  = a_no_endoso
       and no_unidad  = a_unidad;
	   
	insert into emifacon
    select * from emi_temp;

	drop table emi_temp;
	
	update endedmae
	   set prima_retenida = _prima_neta
	 where no_poliza = a_poliza
	   and no_endoso = a_no_endoso;
	   
	update endedhis
	   set prima_retenida = _prima_neta
	 where no_poliza = a_poliza
	   and no_endoso = a_no_endoso;
	   
	let _prima_neta = 0.00; --para que salga

end if

if _prima_neta = 0.00 then
	return 0;
end if

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

select cod_endomov
  into _cod_endomov
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
 
--*********************************************
let ls_ruta = null;
foreach
	select cod_ruta
	  into ls_ruta
	  from emigloco
	 where no_poliza = a_poliza
	   and no_endoso = a_no_endoso
	exit foreach;
end foreach

if a_ruta <> "" then
	let ls_ruta = a_ruta;
end if
--**********************************************
if ls_ruta = "" or ls_ruta is null then --Para cuando no hay emigloco
	select cod_ruta
	  into ls_ruta
	  from rearumae
	 where cod_ramo = ls_ramo
	   and activo   = 1
	   and _vigencia_inic between vig_inic and vig_final
	   and nombre not like '%FACULT%'; --Poner en Comentario

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
--***SE GUARDA VALOR ORIGINAL DE LA SUMA DE LA UNIDAD
let _suma_unidad   = 0;
let _suma_adelanto = 0;
let _suma_unidad   = a_suma;
let _suma_adelanto = a_suma * 35/100;
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
	 
	let _prima_neta = ld_letra;

	select count(*)
	  into li_orden
	  from rearucon
	 where cod_ruta       = ls_ruta
	   and cod_cober_reas = ls_cober_reas;

	if li_orden = 0 then  --No hay contrato en la ruta para esa cobertura
		drop table if exists tmp_dist_rea;
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
		   and emifacon.no_endoso		= a_no_endoso
		   and emifacon.no_unidad		= a_unidad
		   and emifacon.cod_cober_reas	= ls_cober_reas
		   and emifacon.orden			= li_orden;
		   
		if ls_cober_reas in('020','051') then
			let ld_prima_acum = ld_prima_acum + ld_prima;
			if _tipo_contrato = 1 then	--Retencion no debe acumular prima, se actualiza al final.
				let ld_prima_acum = 0.00;
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
				   set prima			= prima + ld_prima,
					   suma_asegurada	= suma_asegurada + ld_suma
				 where no_poliza		= a_poliza
				   and no_endoso		= a_no_endoso
				   and no_unidad		= a_unidad
				   and cod_cober_reas	= ls_cober_reas
				   and orden			= li_orden;
			end if
		end if
	end foreach
		
	---Verificacion de centavos diferencia		   
	select sum(e.prima_neta)
	  into _ld_prima_neta_t
	  from endedcob e, prdcober c
	 where c.cod_cobertura = e.cod_cobertura
	   and e.no_poliza = a_poliza
	   and e.no_endoso = a_no_endoso
	   and e.no_unidad = a_unidad
	   and c.cod_cober_reas = ls_cober_reas
	   and c.cod_cober_reas not in('050');

	select orden
	  into li_orden
	  from emifacon e, reacomae r
	 where e.cod_contrato = r.cod_contrato
	   and e.no_poliza = a_poliza
	   and e.no_endoso = a_no_endoso
	   and e.no_unidad = a_unidad
	   and e.cod_cober_reas = ls_cober_reas
	   and r.tipo_contrato = 1 --Ret.
	   and e.cod_cober_reas not in('050');
	   
	select sum(prima)
	  into _prima_contrato
	  from emifacon e, reacomae r
	 where e.cod_contrato = r.cod_contrato
	   and e.no_poliza = a_poliza
	   and e.no_endoso = a_no_endoso
	   and e.cod_cober_reas = ls_cober_reas
	   and e.no_unidad = a_unidad
	   and r.tipo_contrato <> 1;
	
	if ls_cober_reas in('020','051') then
		update emifacon
		   set prima			= _ld_prima_neta_t - _prima_contrato,
			   porc_partic_prima = (_ld_prima_neta_t - _prima_contrato) / _ld_prima_neta_t * 100
		 where no_poliza		= a_poliza
		   and no_endoso		= a_no_endoso
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
	   and no_endoso =	a_no_endoso
	   and cod_cober_reas = ls_cober_reas
	   and cod_cober_reas <> '050'
	   and no_unidad =	a_unidad;
	   
	let _prima_dif = 0;
	let _prima_dif = _ld_prima_neta_t - _prima_neta_emif;
	if _prima_dif <> 0 and abs(_prima_dif) <= 0.03 then

		update emifacon
		   set prima			= prima + _prima_dif
		 where no_poliza		= a_poliza
		   and no_endoso		= a_no_endoso
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
	   and no_endoso = a_no_endoso
	   and cod_cober_reas = ls_cober_reas
	   and cod_cober_reas <> '050'
	   and no_unidad = a_unidad;
	   
	let _porc_dif = 0;
	let _porc_dif = 100 - _porc_partic_suma;
	if _porc_dif <> 0 and abs(_porc_dif) <= 0.03 then

		update emifacon
		   set porc_partic_suma	= porc_partic_suma + _porc_dif
		 where no_poliza		= a_poliza
		   and no_endoso		= a_no_endoso
		   and no_unidad		= a_unidad
		   and cod_cober_reas	= ls_cober_reas
		   and orden			= li_orden;
		
	end if
	let _porc_dif = 0.00;
	let  _porc_dif = 100 - _porc_partic_prima;
	if _porc_dif <> 0 and abs(_porc_dif) <= 0.03 then
		
		update emifacon
		   set porc_partic_prima	= porc_partic_prima + _porc_dif
		 where no_poliza		= a_poliza
		   and no_endoso		= a_no_endoso
		   and no_unidad		= a_unidad
		   and cod_cober_reas	= ls_cober_reas
		   and orden			= li_orden;
		
	end if	
	--*************************************************************************

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

select sum(r.prima)
  into _prima_neta_emif
  from emifacon r, reacomae t
 where r.cod_contrato = t.cod_contrato
   and r.no_poliza = a_poliza
   and r.no_endoso = a_no_endoso
   and t.tipo_contrato = 1;

update endedmae
   set prima_retenida = _prima_neta_emif
 where no_poliza = a_poliza
   and no_endoso = a_no_endoso;
   
update endedhis
   set prima_retenida = _prima_neta_emif
 where no_poliza = a_poliza
   and no_endoso = a_no_endoso;

return 0;
end
end procedure 
                                                                                                                                                   
