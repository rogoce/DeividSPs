-- Cumulos por Ubicacion
-- Creado    : 25/09/2001 - Autor: Amado Perez 
-- Modificado: 23/04/2002 - Autor: Amado Perez - Se cambia para que lea de la tabla de "endcuend"
-- SIS v.2.0 - d_prod_sp_cob77_dw1 - DEIVID, S.A.

drop procedure sp_pro77b;
create procedure "informix".sp_pro77b(a_compania char(03), a_terremoto smallint, a_fecha date) 
returning   char(50),  -- ubicacion
            integer,       -- cnt. poliza
			dec(16,2), -- suma asegurada
			dec(16,2), -- retencion ancon
			integer,
			dec(16,2), -- 1er excedente
			integer,
			dec(16,2), -- facultativo
			integer,
			dec(16,2), -- prima suscrita terremoto
			char(50);  -- compania
--			char(255); -- filtros

define v_filtros			varchar(255);
define v_ubicacion			varchar(50);
define v_compania_nombre	varchar(50);
define v_nodocumento		char(20);
define _no_poliza			char(10);
define _periodo				char(7);
define _no_unidad			char(5);
define _mal_porc			char(5);
define _no_endoso			char(5);
define _ano_contable		char(4);
define _cod_ubica			char(3);
define _mes_contable		char(2);
define _porc_partic_suma	dec(9,6);
define _porcentaje			dec(9,6);
define _suma_facultativo	dec(16,2);
define v_suma_asegurada		dec(16,2);
define _suma_excedente		dec(16,2);
define _suma_retencion		dec(16,2);
define v_facultativo		dec(16,2);
define v_retencion			dec(16,2);
define v_excedente			dec(16,2);
define v_prima				dec(16,2);
define _prima				dec(16,2);
define _suma				dec(16,2);
define _prima_cobrada       dec(16,2);
define v_cnt_poliza			integer; 
define _cant_ret			integer;
define _cant_fac			integer;
define _cant_exe			integer;
define _tipo_contrato		smallint;
define _es_terremoto		smallint;
define _no_cambio			smallint;
define _orden				smallint;
define _fecha_cancelacion	date;
define _fecha_emision		date;

--set debug file to "\\nemesis\ancon\store procedures\debug\sp_cob03c.trc";

create temp table temp_ubica(
cod_ubica			char(3),
no_poliza			char(10),
no_documento		char(20),
cantidad			integer,
suma_asegurada		dec(16,2),
mal_porc			char(5),
retencion			dec(16,2),
cant_ret			integer,
primer_excedente	dec(16,2),
cant_exe			integer,
facultativo			dec(16,2),
cant_fac			integer,
prima_terremoto		dec(16,2),
orden				smallint,
primary key (no_poliza)) with no log;

--set debug file to "sp_pro77.trc";
--trace on;

-- nombre de la compania
set isolation to dirty read;

let  v_compania_nombre = sp_sis01(a_compania); 

let _ano_contable = year(a_fecha);

{if month(a_fecha) < 10 then
	let _mes_contable = '0' || month(a_fecha);
else
	let _mes_contable = month(a_fecha);
end if

let _periodo = _ano_contable || '-' || _mes_contable;}

let _periodo = sp_sis39(a_fecha);

foreach
	select d.no_poliza,
		   e.no_endoso,
		   d.no_documento,
		   d.fecha_cancelacion
	  into _no_poliza,
		   _no_endoso,
		   v_nodocumento,
		   _fecha_cancelacion
	  from emipomae d, endedmae e
	 where e.no_poliza = d.no_poliza
	   and d.cod_compania = a_compania
	   and d.cod_ramo in ('001','003')
	   and (d.vigencia_final >= a_fecha 
	   or d.vigencia_final is null)
	   and d.fecha_suscripcion <= a_fecha
	   and e.fecha_emision <= a_fecha
	   and d.vigencia_inic < a_fecha
	   and e.periodo <= _periodo
	   and d.actualizado = 1
	   and e.actualizado = 1
--	  and d.no_poliza = '576237'

	let _fecha_emision = null;

	if _fecha_cancelacion <= a_fecha then
		foreach
			select fecha_emision
			  into _fecha_emision
			  from endedmae
			 where no_poliza = _no_poliza
			   and cod_endomov = '002'
			   and vigencia_inic = _fecha_cancelacion
		end foreach

		if  _fecha_emision <= a_fecha then
			continue foreach;
		end if
	end if
	
	let _prima_cobrada = 0;
	
	{let _prima_cobrada = sp_sis424(v_nodocumento); -->buscando la prima cobrada en terremoto

	if  _prima_cobrada <= 0 then
		continue foreach;
	end if}
	
	let _cant_ret = 0;
	let _cant_exe = 0;
	let _cant_fac = 0;
	let _mal_porc = '';

	--FOREACH
		--SELECT no_unidad
		  --INTO _no_unidad
		  --FROM emipouni
		 --WHERE no_poliza = _no_poliza

	if a_terremoto = 1 then
		foreach
			select cod_ubica, 
				   no_unidad,
				   suma_terremoto, 
				   prima_terremoto 
			  into _cod_ubica,
				   _no_unidad, 
				   _suma, 
				   _prima 
			  from endcuend
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso

			let _suma_facultativo = 0; 
			let _suma_retencion   = 0;
			let _suma_excedente   = 0;
			let _es_terremoto     = 0;
			let _porcentaje       = 0;

			foreach
				select no_cambio
				  into _no_cambio
				  from emireama
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and vigencia_inic   <= a_fecha
				   and (vigencia_final >= a_fecha or vigencia_final is null)
				 order by no_cambio desc
				exit foreach;
			end foreach

			foreach
				select x.porc_partic_suma,
					   y.tipo_contrato,
					   z.es_terremoto
				  into _porc_partic_suma,
					   _tipo_contrato,
					   _es_terremoto
				  from emireaco x, reacomae y, reacobre z
				 where x.no_poliza = _no_poliza
				   and x.no_unidad = _no_unidad
				   and x.no_cambio = _no_cambio
				   and y.cod_contrato = x.cod_contrato
				   and z.cod_cober_reas = x.cod_cober_reas
				   and z.es_terremoto = 1
					
				if _tipo_contrato = 1 then
					let _suma_retencion = _suma * _porc_partic_suma / 100;
					let _cant_ret = 1;
				elif _tipo_contrato = 3 then
					let _suma_facultativo = _suma * _porc_partic_suma / 100;
					let _cant_fac = 1;
				else
					let _suma_excedente = _suma * _porc_partic_suma / 100;
					let _cant_exe = 1;
				end if

				let _porcentaje =  _porcentaje + _porc_partic_suma;

				if _porcentaje > 100.5 or _porcentaje < 99.5 then
				   let _mal_porc = _no_unidad;
				else
				   let _mal_porc = '';
				end if
			end foreach

			if _es_terremoto = 1 then

				let _orden = sp_sis184(_cod_ubica);	  --sacar el orden para el reporte

				begin
					on exception in(-239)
						update temp_ubica			   
						   set suma_asegurada   = suma_asegurada + _suma,
							   mal_porc         = _mal_porc,
							   retencion        = retencion + _suma_retencion,
							   cant_ret			= _cant_ret,
							   primer_excedente = primer_excedente + _suma_excedente,
							   cant_exe			= _cant_exe,
							   facultativo      = facultativo + _suma_facultativo,
							   cant_fac			= _cant_fac
							   --prima_terremoto  = prima_terremoto + _prima_cobrada
						 where no_poliza = _no_poliza;
					end exception

					insert into temp_ubica
					   values(_cod_ubica,
							  _no_poliza,
							  v_nodocumento,
							  1,
							  _suma,  
							  _mal_porc,
							  _suma_retencion,
							  _cant_ret,
							  _suma_excedente,
							  _cant_exe,
							  _suma_facultativo,
							  _cant_fac,
							  _prima_cobrada,
							  _orden);
				end
			end if 
		end foreach
	else -- No es Terremoto
		foreach
			select cod_ubica, 
				   no_unidad,
				   suma_incendio, 
				   prima_incendio 
			  into _cod_ubica,
				   _no_unidad,
				   _suma,
				   _prima 
			  from endcuend
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso

			let _suma_facultativo = 0; 
			let _suma_retencion = 0;
			let _suma_excedente = 0;
			let _es_terremoto = 1;
			let _porcentaje = 0;

			foreach
				select no_cambio
				  into _no_cambio
				  from emireama
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and vigencia_inic <= a_fecha
				   and (vigencia_final >= a_fecha or vigencia_final is null)
				 order by no_cambio desc
				exit foreach;
			end foreach

			foreach
				select x.porc_partic_suma,
					   y.tipo_contrato,
					   z.es_terremoto
				  into _porc_partic_suma,
					   _tipo_contrato,
					   _es_terremoto
				  from emireaco x, reacomae y, reacobre z
				 where y.cod_contrato = x.cod_contrato
				   and x.no_poliza = _no_poliza
				   and x.no_unidad = _no_unidad
				   and x.no_cambio = _no_cambio
				   and z.cod_cober_reas = x.cod_cober_reas
				   and z.es_terremoto = 0
				   
				if _tipo_contrato = 1 then
					let _suma_retencion = _suma * _porc_partic_suma / 100;
					let _cant_ret = 1;
				elif _tipo_contrato = 3 then
					let _suma_facultativo = _suma * _porc_partic_suma / 100;
					let _cant_fac = 1;
				else
					let _suma_excedente = _suma * _porc_partic_suma / 100;
					let _cant_exe = 1;
				end if

				let _porcentaje =  _porcentaje + _porc_partic_suma;

				if _porcentaje > 100.5 or _porcentaje < 99.5 then
				   let _mal_porc = _no_unidad;
				else
				   let _mal_porc = '';
				end if
			end foreach

			if _es_terremoto = 0 then

				let _orden = sp_sis184(_cod_ubica);	  --sacar el orden para el reporte

				begin
					on exception in(-239)
						update temp_ubica			   
						   set suma_asegurada   = suma_asegurada + _suma,
							   mal_porc         = _mal_porc,
							   retencion        = retencion + _suma_retencion,
							   cant_ret			= _cant_ret,
							   primer_excedente = primer_excedente + _suma_excedente,
							   cant_exe			= _cant_exe,
							   facultativo      = facultativo + _suma_facultativo,
							   cant_fac			= _cant_fac
							   --prima_terremoto  = prima_terremoto + _prima_cobrada
						 where no_poliza = _no_poliza;
					end exception
					
					insert into temp_ubica
					values(	_cod_ubica,
							_no_poliza,
							v_nodocumento,
							1,
							_suma,  
							_mal_porc,
							_suma_retencion,
							_cant_ret,
							_suma_excedente,
							_cant_exe,
							_suma_facultativo,
							_cant_fac,
							_prima_cobrada,
							_orden);
				end
			end if
		end foreach
	end if 
end foreach

foreach with hold
	select cod_ubica,
		   orden,
		   sum(cantidad),
		   sum(suma_asegurada),
		   sum(retencion),
		   sum(cant_ret),
		   sum(primer_excedente),
		   sum(cant_exe),
		   sum(facultativo),
		   sum(cant_fac),
		   sum(prima_terremoto)
	  into _cod_ubica,
		   _orden,
		   v_cnt_poliza,
		   v_suma_asegurada,
		   v_retencion,
		   _cant_ret,
		   v_excedente,
		   _cant_exe,
		   v_facultativo,
		   _cant_fac,
		   v_prima
	  from temp_ubica
	 group by cod_ubica,orden
	 order by orden

	select nombre
	  into v_ubicacion
	  from emiubica
	 where cod_ubica = _cod_ubica;

	return v_ubicacion,
		   v_cnt_poliza,    	
		   v_suma_asegurada/1000,	
		   v_retencion/1000,  	
		   _cant_ret,	
		   v_excedente/1000,	
		   _cant_exe,      	
		   v_facultativo/1000,   	
		   _cant_fac,	
		   v_prima,	
		   v_compania_nombre with resume;
end foreach

drop table temp_ubica;

end procedure;