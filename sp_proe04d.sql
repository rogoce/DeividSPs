-- Procedimiento para actualizar los valores de emifacon por unidad para las pólizas de Coaseg. Min. del Estado
--
-- Creado:     28/04/2016 - Autor Román Gordón
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_proe04d;
create procedure 'informix'.sp_proe04d(
a_no_poliza				char(10),
a_no_unidad				char(5),
a_suma_asegurada		dec(16,2),
a_cod_compania			char(3))
returning	integer			as error,
			varchar(100)	as descr_erorr;

define _mensaje             varchar(100);
define _error_desc			varchar(100);
define _cod_contrato		char(5);
define _cod_ruta			char(5);
define _cod_cober_reas     	char(3);
define _cod_tripopord		char(3);
define _cod_ramo			char(3);
define _porc_partic_coas	dec(7,4);
define _porc_partic_prima  	dec(9,6);
define _porc_proporcion		dec(9,6);
define _porc_partic_suma	dec(9,6);
define _monto_cobertura		dec(16,2);
define _prima_neta_emif    	dec(16,2);
define _suma_aseg_emif      dec(16,2);
define _suma_asegurada		dec(16,2); 
define ld_suma_plenos		dec(16,2);
define _prima_neta			dec(16,2);
define ld_suma_dif			dec(16,2);
define _prima		   		dec(16,2);
define _prima_dif        	dec(16,2);
define _suma_dif            dec(16,2);
define _tipo_produccion		integer;
define _tipo_contrato		integer;
define _cant_plenos			integer;
define _mult_plenos			integer;
define _error_isam			integer;
define _tipo_ramo			integer;
define _orden				integer;
define _error				integer;
define _cnt_contratos		smallint;
define _cnt_emigloco		smallint;
define _cnt_emifacon		smallint;
define _cant				smallint;
define _vigencia_inic		date;
define _vigencia_final		date;

begin

on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc;
end exception

set isolation to dirty read;

let _porc_proporcion = 0.00;

--if a_no_poliza = '980834' then
--set debug file to 'sp_proe04.trc';
--trace on;
--end if

-- buscar tipo de ramo, periodo de pago y tipo de produccion
select cod_tipoprod,
	   cod_ramo,
	   vigencia_inic,
	   vigencia_final
  into _cod_tripopord,
	   _cod_ramo,
	   _vigencia_inic,
	   _vigencia_final
  from emipomae
 where no_poliza = a_no_poliza;

select tipo_produccion 
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tripopord;

let _porc_partic_coas = 0.00;

-- la suscrita = neta por el porcentaje coaseguro ancon de la tabla de parametros
-- campo - aseguradora lider
if _tipo_produccion = 2 then

	select e.porc_partic_coas 					  
	  into _porc_partic_coas
	  from parparam p, emicoama e
	 where p.cod_compania = a_cod_compania
	   and e.no_poliza    = a_no_poliza
	   and e.cod_coasegur = p.par_ase_lider;

	if _porc_partic_coas is null then
		let _porc_partic_coas = 0.00;
	end if
end if

-- verificar si hay datos en reaseguro global
select count(*) 
  into _cnt_emigloco
  from emigloco
 where emigloco.no_poliza = a_no_poliza;

if _cnt_emigloco is null then
   let _cnt_emigloco = 0;
end if

delete from emifacon
 where no_poliza   = a_no_poliza
   and no_endoso  = '00000'
   and no_unidad  = a_no_unidad;

{delete from emireaco
 where no_poliza   = a_no_poliza
   and no_unidad  = a_no_unidad
   and no_cambio  = 0;

delete from emireama
 where no_poliza   = a_no_poliza
   and no_unidad  = a_no_unidad
   and no_cambio  = 0;
}	
let _suma_asegurada 	  = 0.00;
let _porc_partic_suma  = 0.00;


foreach
	select emigloco.cod_ruta
	  into _cod_ruta
	  from emigloco
	 where emigloco.no_poliza = a_no_poliza
	   and emigloco.no_endoso = '00000'
	exit foreach;
end foreach

select mult_plenos
  into _mult_plenos
  from rearumae
 where cod_ruta = _cod_ruta;

if _cod_ramo in('002','023') then
	call sp_sis188(a_no_poliza) returning _error,_mensaje;
end if

foreach
	select c.cod_cober_reas,
		   sum(e.prima_neta)
	  into _cod_cober_reas,
	  	   _monto_cobertura
	  from emipocob e, prdcober c 
      where e.no_poliza = a_no_poliza
        and e.no_unidad = a_no_unidad
        and c.cod_cobertura = e.cod_cobertura
      group by c.cod_cober_reas

	select count(*)
	  into _orden
	  from rearucon
	 where cod_ruta       = _cod_ruta
	   and cod_cober_reas = _cod_cober_reas;

	if _orden = 0 then  --No hay contrato en la ruta para esa cobertura
		return 1, 'No existen contratos para la Cobertura de Reaseguro de la Póliza.';
	end if

	let _porc_proporcion = 0.00;
	
	if _mult_plenos > 0 then
		{let ld_suma_dif = a_suma_asegurada;

		foreach
			select cant_plenos,
				   orden,
				   cod_contrato
			  into _cant_plenos,
			  	   _orden,
			  	   _cod_contrato
			  from rearucon
			 where cod_ruta = _cod_ruta
			 order by orden

			let ld_suma_plenos = 0.00;

			if _cant_plenos > 0 then 
				let ld_suma_plenos	= _cant_plenos * _mult_plenos;
				
				if ld_suma_plenos > ld_suma_dif then
					let _suma_asegurada = ld_suma_dif;
				else
					let _suma_asegurada 	= ld_suma_plenos;
					let ld_suma_dif	= ld_suma_dif - ld_suma_plenos;
				end if
			else
				let _suma_asegurada	= ld_suma_dif;				
			end if

			let _porc_partic_prima = (_suma_asegurada / a_suma_asegurada) * 100;
			let _prima = (_monto_cobertura * _porc_partic_prima) / 100;

			if _porc_partic_coas > 0 then
				let _prima = (_prima * _porc_partic_coas) / 100;
			end if

			select count(*)
	       	  into _cnt_emifacon
			  from emifacon
			 where no_poliza = a_no_poliza
			   and no_endoso = '00000'
			   and no_unidad = a_no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and orden = _orden;

			If _cnt_emifacon = 0 or _cnt_emifacon is null then
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
				values(	a_no_poliza,
						'00000',
						a_no_unidad,
						_cod_cober_reas,
						_orden,
						_cod_contrato,
						_porc_partic_prima,
						_porc_partic_prima,
						_suma_asegurada,
						_prima,
						_cod_ruta);
			else
				if _prima > 0 then
					update emifacon
					   set prima			= prima + _prima,
						   suma_asegurada	= suma_asegurada + _suma_asegurada
					 where no_poliza 		= a_no_poliza
					   and no_endoso		= '00000'
					   and no_unidad 		= a_no_unidad
					   and cod_cober_reas	= _cod_cober_reas
					   and orden			= _orden;
				end if
			end if									
		end foreach	}
	else
		foreach
			select orden,
				   cod_contrato,
				   porc_partic_suma,
				   porc_partic_prima
			  into _orden,
			  	   _cod_contrato,
				   _porc_partic_suma,
				   _porc_partic_prima
			  from rearucon
			 where cod_ruta       = _cod_ruta
			   and cod_cober_reas = _cod_cober_reas
			 order by orden

			let _suma_asegurada  = 0.00;
			let _prima = 0.00;
			let _suma_asegurada = (a_suma_asegurada * _porc_partic_suma) / 100;

			select tipo_contrato
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			--No debe insertar contratos facultativos
			if _tipo_contrato = 3 then
				continue foreach;
			end if

			if _porc_partic_prima = 0.00 then
				select count(*)
				  into _cnt_contratos
				  from rearucon r, reacomae m
				 where r.cod_contrato = m.cod_contrato
				   and r.cod_ruta = _cod_ruta
				   and r.cod_cober_reas = _cod_cober_reas
				   and m.tipo_contrato <> 3;

				if _cnt_contratos = 1 then
					let _porc_partic_prima = 100;
					let _porc_partic_suma = 100;
				else
					if _cod_ramo in ('001','003') then
						if _cod_cober_reas in ('001','021') then
							if _tipo_contrato = 1 then
								let _porc_partic_prima = 70;
								let _porc_partic_suma = 70;
							elif _tipo_contrato in (5,7) then
								let _porc_partic_prima = 30;
								let _porc_partic_suma = 30;
							end if
						elif _cod_cober_reas in ('003','022') then
							if _tipo_contrato = 1 then
								let _porc_partic_prima = 90;
								let _porc_partic_suma = 90;
							elif _tipo_contrato in (5,7) then
								let _porc_partic_prima = 10;
								let _porc_partic_suma = 10;
							end if
						end if
					else
						if a_suma_asegurada = 0.00 then
							if _tipo_contrato = 1 then
								let _porc_partic_prima = 100;
								let _porc_partic_suma = 100;
							else
								continue foreach;
							end if
						end if
					end if
				end if
			end if

			if _cod_ramo in('002','023') then
				select porc_cober_reas
				  into _porc_proporcion
				  from tmp_dist_rea
				 where cod_cober_reas = _cod_cober_reas;

				let _suma_asegurada = (a_suma_asegurada * _porc_partic_suma / 100) * _porc_proporcion / 100;
			end if

			if _porc_partic_coas > 0 then
				let _suma_asegurada = (_suma_asegurada * _porc_partic_coas) / 100;
			end if

			let _prima = (_monto_cobertura * _porc_partic_prima) / 100;
			
			if _porc_partic_coas > 0 then
				let _prima = (_prima * _porc_partic_coas) / 100;
			end if

			select count(*)
			  into _cnt_emifacon
			  from emifacon
			 where no_poliza		= a_no_poliza
			   and no_endoso		= '00000'
			   and no_unidad		= a_no_unidad
			   and cod_cober_reas	= _cod_cober_reas
			   and orden			= _orden;

			if _cnt_emifacon = 0 Or _cnt_emifacon is null then
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
				Values(	a_no_poliza,
						'00000',
						a_no_unidad,
						_cod_cober_reas,
						_orden,
						_cod_contrato,
						_porc_partic_suma,
						_porc_partic_prima,
						_suma_asegurada,
						_prima,
						_cod_ruta);
		   	else
				if _prima > 0 then
					update emifacon
					   set prima			= prima + _prima,
						   suma_asegurada	= suma_asegurada + _suma_asegurada
					 where no_poliza		= a_no_poliza
					   and no_endoso		= '00000'
					   and no_unidad		= a_no_unidad
					   and cod_cober_reas	= _cod_cober_reas
					   and orden			= _orden;
				end if
			end if
		end foreach

		---Verificacion de centavos diferencia
		select sum(e.prima_neta)
		  into _prima_neta
		  from emipocob e, prdcober c
	     where e.no_poliza = a_no_poliza
	       and e.no_unidad = a_no_unidad
	       and c.cod_cobertura = e.cod_cobertura;

		select sum(prima),
		       sum(suma_asegurada)
		  into _prima_neta_emif,
		       _suma_aseg_emif
		  from emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso =	'00000'
		   and no_unidad =	a_no_unidad;

		let _prima_dif = 0;
        let _prima_dif = _prima_neta - _prima_neta_emif;
        if _prima_dif <> 0 and abs(_prima_dif) <= 0.03 then

			update emifacon
			   set prima			= prima + _prima_dif
			 where no_poliza		= a_no_poliza
			   and no_endoso		= '00000'
			   and no_unidad		= a_no_unidad
			   and cod_cober_reas	= _cod_cober_reas
			   and orden			= _orden;
			
        end if

		let _suma_dif = 0;
        let _suma_dif = a_suma_asegurada - _suma_aseg_emif;
		
        if _suma_dif <> 0 and abs(_suma_dif) <= 0.03 then
			update emifacon
			   set suma_asegurada   = suma_asegurada + _suma_dif
			 where no_poliza		= a_no_poliza
			   and no_endoso		= '00000'
			   and no_unidad		= a_no_unidad
			   and cod_cober_reas	= _cod_cober_reas
			   and orden			= _orden;			
        end if
	end if
end foreach

-- Se agrega este segmento porque en las polizas de salud al insertar una unidad despues que la poliza esta actualizada no insertaba en emireaco -- Amado 07/10/2013

{FOREACH
 SELECT	cod_cober_reas
   INTO	_cod_cober_reas
   FROM	emifacon
  WHERE	no_poliza = a_no_poliza
    AND no_endoso = '00000'
	AND no_unidad = a_no_unidad
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
	a_no_poliza, 
	a_no_unidad,
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
a_no_poliza, 
a_no_unidad,
0,
cod_cober_reas,
orden,
cod_contrato,
porc_partic_suma,
porc_partic_prima
FROM emifacon
WHERE no_poliza = a_no_poliza
  AND no_endoso = '00000'
  AND no_unidad	= a_no_unidad;
}
drop table if exists tmp_dist_rea;

return 0,'Actualización Exitosa.';
end
end procedure;