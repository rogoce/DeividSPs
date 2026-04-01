-- Distribucion de Reaseguro para el Cambio de Coaseguro

-- Creado    : 23/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/01/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado: 06/01/2003 - Autor Amado Perez - Se valida cuando el tipo contrato de reaseguro es facultativo
--                                              se inserte en la tabla emifafac, cuando tipo_produccion es
--                                              igual a "2", ya que salia el error en el sp_pro43:
--    								   'Sumatoria de Porcentajes de Facultativos Diferente de 100, Por Favor Verifique ...'
--
-- SIS v.2.0 - uo_prod_endoso (ue_salvar) - DEIVID, S.A.

drop procedure sp_pro89;

create procedure sp_pro89(
a_no_poliza	char(10),
a_no_endoso	char(5)
) returning smallint,
			char(100);

define _no_endoso			char(5);
define _no_unidad			char(5);
define _suma_total			dec(16,2);
define _prima_total			dec(16,2);
define _suma_reas			dec(16,2);
define _prima_reas			dec(16,2);
define _suma_dist			dec(16,2);
define _prima_dist			dec(16,2);
define _suma_cont			dec(16,2);
define _prima_cont			dec(16,2);
define _prima_ret			dec(16,2);
define _suma				dec(16,2);

define _no_cambio			smallint;
define _cod_cober_reas		char(3);
define _orden				smallint;
define _cod_contrato		char(5);
define _porc_partic_suma	dec(9,6);
define _porc_partic_prima	dec(9,6);
define _porc_coas			dec(7,4);
define _cod_ruta			char(5);

define _error				smallint;
define _tipo_produccion		smallint;
define _cod_tipoprod		char(3);
define _tipo_contrato       smallint;
define _cant_reg			smallint;

define _coas_madre			char(3);
define _cia_madre			char(3);

define _cod_coasegur        char(3);
define _orden_fa            smallint;
define _porc_partic_reas	dec(9,6);
define _porc_partic_coas	dec(7,4);
define _porc_comis_fac		dec(5,2);
define _porc_impuesto       dec(5,2);

define _suma_cont_fa 		dec(16,2);
define _prima_cont_fa		dec(16,2);
define _factor_vigencia		dec(16,3);


--SET DEBUG FILE TO "sp_pro89.trc";
--trace on;

begin

on exception set _error 
 	return _error, "Error al Actualizar Distribucion de Reaseguro";         
end exception

-- Eliminacion de la Distribucion Existente

delete from emifafac
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from emifacon
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from endeduni
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

delete from endcoama
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

-- Seleccion de Datos Actuales

let _cod_ruta = NULL;

select cod_tipoprod,
	   cod_compania
  into _cod_tipoprod,
	   _cia_madre
  from emipomae
 where no_poliza = a_no_poliza;

select tipo_produccion
  into _tipo_produccion
  from emitipro
 where cod_tipoprod = _cod_tipoprod;

select par_ase_lider
  into _coas_madre
  from parparam
 where cod_compania = _cia_madre;

select factor_vigencia
  into _factor_vigencia
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _factor_vigencia = 0 then
	let _factor_vigencia = 1;
end if

--let _tipo_produccion = 2;

select count(*)
  into _cant_reg
  from endcamco
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cant_reg is null then
	LET _cant_reg = 0;
end if

-- Seleccion de las Unidades de la Poliza

INSERT INTO endeduni(
no_poliza,
no_endoso,
no_unidad,
cod_ruta,
cod_producto,
cod_cliente,
suma_asegurada,
prima,
descuento,
recargo,
prima_neta,
impuesto,
prima_bruta,
reasegurada,
vigencia_inic,
vigencia_final,
beneficio_max,
desc_unidad,
prima_suscrita,
prima_retenida,
suma_aseg_adic
)
SELECT
a_no_poliza,
a_no_endoso,
no_unidad,
cod_ruta,
cod_producto,
cod_asegurado,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
0.00,
1,
vigencia_inic,
vigencia_final,
0.00,
desc_unidad,
0.00,
0.00,
0.00
FROM emipouni
WHERE no_poliza = a_no_poliza;

select porc_partic_coas
  into _porc_coas
  from endcamco
 where no_poliza    = a_no_poliza
   and no_endoso    = a_no_endoso
   and cod_coasegur = _coas_madre;

foreach
 select no_unidad,
        suma_asegurada
   into _no_unidad,
        _suma_total
   from emipouni
  where no_poliza = a_no_poliza
  order by no_unidad

	let _suma_reas = 0.00;

	-- Seleccion de la Distribucion Actual

	select max(no_cambio)
	  into _no_cambio
	  from emireama
	 where no_poliza = a_no_poliza
	   and no_unidad = _no_unidad;

	-- Prima Neta Total	(Por cobertura de reaseguro)
		
	foreach
	 select c.cod_cober_reas,
	 		sum(u.prima_neta)
	   into _cod_cober_reas,
			_prima_total
	   from endedcob u, endedmae e, prdcober c
	  where u.no_poliza     = e.no_poliza
	    and u.no_endoso     = e.no_endoso
		and e.actualizado   = 1
		and u.no_poliza     = a_no_poliza
		and u.no_unidad     = _no_unidad
		and u.cod_cobertura = c.cod_cobertura
	  group by c.cod_cober_reas
	  order by c.cod_cober_reas

		-- Prima y Suma reasegurada 

		select sum(r.prima), 
		       sum(r.suma_asegurada) 
		  into _prima_reas, 
		       _suma_reas 
		  from emifacon r, endedmae e 
		 where r.no_poliza      = a_no_poliza 
		   and r.no_unidad      = _no_unidad 
		   and r.cod_cober_reas = _cod_cober_reas 
		   and r.no_poliza      = e.no_poliza 
		   and r.no_endoso      = e.no_endoso 
		   and e.actualizado    = 1; 

		-- Suma y Prima a distribuir 

		let _suma_dist  = (_suma_total  * _porc_coas / 100) - _suma_reas; 
		let _prima_dist = (_prima_total * _porc_coas / 100) - _prima_reas; 
		let _prima_dist = _prima_dist   * _factor_vigencia; 

		foreach 
		 select orden,
				cod_contrato,
				porc_partic_suma,
				porc_partic_prima
		   into _orden,
				_cod_contrato,
				_porc_partic_suma,
				_porc_partic_prima
		   from emireaco
		  where no_poliza      = a_no_poliza
		    and no_unidad      = _no_unidad
			and no_cambio      = _no_cambio
		    and cod_cober_reas = _cod_cober_reas

			let _suma_cont  = _suma_dist  * _porc_partic_suma / 100;
			let _prima_cont = _prima_dist * _porc_partic_prima / 100;

			insert into emifacon(
			no_poliza,
			no_endoso,
			no_unidad,
			cod_cober_reas,
			orden,
			cod_contrato,
			cod_ruta,
			porc_partic_suma,
			porc_partic_prima,
			suma_asegurada,
			prima
			)
			values(
			a_no_poliza,
			a_no_endoso,
			_no_unidad,
			_cod_cober_reas,
			_orden,
			_cod_contrato,
			_cod_ruta,
			_porc_partic_suma,
			_porc_partic_prima,
			_suma_cont,
			_prima_cont
			);

			select tipo_contrato
			  into _tipo_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;

			if _tipo_contrato = 3 then

				foreach
				 select orden,
				        cod_coasegur,
						porc_partic_reas,
						porc_comis_fac,	
						porc_impuesto   
				   into _orden_fa,
						_cod_coasegur,
						_porc_partic_reas,
						_porc_comis_fac,
						_porc_impuesto 
				   from emireafa
				  where no_poliza      = a_no_poliza
				    and no_unidad      = _no_unidad
					and no_cambio      = _no_cambio
					and cod_contrato   = _cod_contrato 
                 	and cod_cober_reas = _cod_cober_reas

				    let _suma_cont_fa  = _suma_cont  * _porc_partic_reas / 100;
					let _prima_cont_fa = _prima_cont * _porc_partic_reas / 100;		--armando

					insert into emifafac(
					no_poliza,
					no_endoso,
					no_unidad,
					cod_cober_reas,
					orden,
					cod_contrato,
					cod_coasegur,
					porc_partic_reas,
					porc_comis_fac,
					porc_impuesto,
					suma_asegurada,
					prima
					)
					values(
					a_no_poliza,
					a_no_endoso,
					_no_unidad,
					_cod_cober_reas,
					_orden_fa,
					_cod_contrato,
					_cod_coasegur,
					_porc_partic_reas,
					_porc_comis_fac,
					_porc_impuesto, 
					_suma_cont_fa,
					_prima_cont_fa
					);
				end foreach
			end if
		end foreach
	end foreach

	-- Actualizacion de Suscrita y Retenida por Unidad

	select sum(emifacon.prima) 
	  into _prima_ret
	  from emifacon, reacomae
	 where emifacon.no_poliza     = a_no_poliza
	   and emifacon.no_endoso     = a_no_endoso
	   and emifacon.no_unidad	  = _no_unidad	
	   and emifacon.cod_contrato  = reacomae.cod_contrato
	   and reacomae.tipo_contrato = "1";

	select sum(emifacon.prima) 
	  into _prima_dist
	  from emifacon
	 where emifacon.no_poliza     = a_no_poliza
	   and emifacon.no_endoso     = a_no_endoso
	   and emifacon.no_unidad	  = _no_unidad;	

	if _prima_ret is null Then
	  let _prima_ret = 0.00;
	end if

	if _prima_dist is null Then
	  let _prima_dist = 0.00;
	end if

	update endeduni
	   set prima_retenida = _prima_ret,
	       prima_suscrita = _prima_dist
     where no_poliza      = a_no_poliza
       and no_endoso      = a_no_endoso
	   and no_unidad      = _no_unidad;

end foreach

-- Distribucion de la Suma entre las companias coaseguradoras

select sum(suma_asegurada),
       sum(prima_neta)
  into _suma_total,
       _prima_total
  from emipouni
 where no_poliza = a_no_poliza;

foreach	
select cod_coasegur,
       porc_partic_coas
  into _cod_coasegur,
       _porc_coas
  from endcamco
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso

	select sum(r.suma),
	       sum(r.prima)
	  into _suma_reas,
		   _prima_reas
	  from endcoama r, endedmae e
	 where r.no_poliza    = a_no_poliza
	   and r.no_poliza    = e.no_poliza
	   and r.no_endoso    = e.no_endoso
	   and e.actualizado  = 1
	   and r.cod_coasegur = _cod_coasegur;  	

	if _suma_reas is null then
		let _suma_reas = 0.00;
	end if

	if _prima_reas is null then
		let _prima_reas = 0.00;
	end if

	let _suma_dist  = (_suma_total  * _porc_coas / 100) - _suma_reas;	
	let _prima_dist = (_prima_total * _porc_coas / 100) - _prima_reas;	
	let _prima_dist = _prima_dist   * _factor_vigencia;

	insert into endcoama(
	no_poliza,
	no_endoso,
	cod_coasegur,
	porc_partic_coas,
	porc_gastos,
	prima,
	suma
	)
	values(
	a_no_poliza,
	a_no_endoso,
	_cod_coasegur,
	_porc_coas,
	0.00,
	_prima_dist,
	_suma_dist
	);

end foreach

select sum(emifacon.prima) 
  into _prima_ret
  from emifacon, reacomae
 where emifacon.no_poliza     = a_no_poliza
   and emifacon.no_endoso     = a_no_endoso
   and emifacon.cod_contrato  = reacomae.cod_contrato
   and reacomae.tipo_contrato = "1";

if _prima_ret is null Then
  let _prima_ret = 0.00;
end if

select sum(emifacon.prima) 
  into _prima_dist
  from emifacon
 where emifacon.no_poliza = a_no_poliza
   and emifacon.no_endoso = a_no_endoso;

if _prima_dist is null Then
  let _prima_dist = 0.00;
end if

update endedmae
   set prima_retenida = _prima_ret,
       prima_suscrita = _prima_dist
 where no_poliza      = a_no_poliza
   and no_endoso      = a_no_endoso;

end

return 0, "Actualizacion Exitosa ...";

end procedure