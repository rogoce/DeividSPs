-- Generacion de Registros Contables de Reaseguro

-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_par296_prueba;
create procedure "informix".sp_par296_prueba(a_no_registro char(10))
returning decimal(16,2),
		  char(100);

define _tipo_transaccion	smallint;
define _tiene_comis_rea		smallint;
define _cant_reaseguro  	smallint;  
define _tipo_contrato   	smallint;
define _tipo_registro		smallint;
define _es_terremoto       	smallint;
define _cnt_existe	       	smallint;
define _tipo_comp       	smallint;
define _no_cambio	       	smallint;
define _traspaso			smallint;
define _cantidad	       	smallint;
define _bouquet			 	smallint;
define _renglon				smallint;
define _orden				smallint;

define _prima_suscrita		dec(16,2);
define _monto_reas_cob	 	dec(16,2);
define _coas_por_pagar	 	dec(16,2);
define _suma_comision	 	dec(16,2);
define _suma_impuesto	 	dec(16,2);
define _fac_comision		dec(16,2);
define _fac_impuesto		dec(16,2);
define _prima_neta			dec(16,2);
define _monto_reas		 	dec(16,2);
define _prima_tot		 	dec(16,2);
define _porc_ter          	dec(16,2);
define _porc_inc          	dec(16,2);
define _credito         	dec(16,2);
define _debito          	dec(16,2);
define _monto2				dec(16,2);
define _monto3				dec(16,2);
define _monto				dec(16,2);
define _prima			 	dec(16,2);

define _porc_partic_prima	dec(9,6);

define _porc_partic_coas    dec(7,4);

define _factor_impuesto		dec(5,2);
define _porc_comis_agt  	dec(5,2);
define _porc_cont_partic	dec(5,2);
define _porc_comis_ase   	dec(5,2);
define _porc_proporcion   	dec(5,2);

define _tipo_mov         	char(1);  

define _cod_ramo        	char(3);
define _cod_subramo     	char(3);
define _cod_cober_reas  	char(3);
define _cod_coasegur		char(3);
define _cod_origen_aseg		char(3);
define _centro_costo		char(3);
define _cod_lider			char(3);
define _cod_tipotran		char(3);

define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_traspaso		char(5);
define _cod_auxiliar		char(5);
define _aux_bouquet		 	char(5);
define _no_endoso			char(5);
define _cod_cobertura	  	char(5);

define _periodo				char(7);
define _periodo2			char(7);

define _no_poliza			char(10);
define _no_remesa			char(10);
define _no_tranrec			char(10);
define _no_factura			char(10);
define _no_reclamo			char(10);

define _no_documento		char(20);

define _cuenta          	char(25);

define _fecha				date;
define _fecha_anulado		date;

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

------------------------------------------------------------------------------
--                          Tipos de Comprobantes
------------------------------------------------------------------------------
-- 1.	Comprobante de Reaseguro Cajas y Comprobantes

-- 2.	Comprobante de Reaseguro Reclamos Pagos
-- 3.	Comprobante de Reaseguro Reclamos Salvamentos
-- 4.	Comprobante de Reaseguro Reclamos Recuperos
-- 5.	Comprobante de Reaseguro Reclamos Deducibles

-- 10.Comprobante de Reaseguro Produccion Incendio
-- 11.Comprobante de Reaseguro Produccion Automovil
-- 12.Comprobante de Reaseguro Produccion Fianzas
-- 13.Comprobante de Reaseguro Produccion Personas
-- 14.Comprobante de Reaseguro Produccion Patrimoniales

-- 15	Comprobante de Reaseguro Cheques Pagados  Devolucion Primas
-- 16	Comprobante de Reaseguro Cheques Anulados Devolucion Primas
 
------------------------------------------------------------------------------

--set debug file to "sp_par296.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	drop table tmp_reas;
	return _error, _error_desc;
end exception

drop table if exists tmp_reas;
create temp table tmp_reas(
no_unidad			char(5),
cod_cober_reas		char(3),
cod_contrato		char(5),
prima_tot			dec(16,2),
prima_rea			dec(16,2),
es_terremoto   		smallint,
bouquet				smallint,
orden				smallint,
porc_partic_prima	dec(9,6),
porc_comision		dec(9,6), 
porc_impuesto		dec(9,6), 
comision			dec(16,2), 
impuesto			dec(16,2),
porc_proporcion	    dec(16,2),
porc_inc			dec(16,2),
porc_ter			dec(16,2)
) with no log;

create index idx_tmp_reas_1 on tmp_reas(no_unidad, cod_contrato, es_terremoto);
create index idx_tmp_reas_2 on tmp_reas(no_unidad, cod_contrato, cod_cober_reas);
create index idx_tmp_reas_3 on tmp_reas(bouquet);

drop table if exists tmp_unidad;

create temp table tmp_unidad(
no_unidad		char(5),
prima_tot		dec(16,2)	default 0.00,
primary key (no_unidad)) with no log;


select par_ase_lider
  into _cod_lider
  from parparam
 where cod_compania = "001";

select tipo_registro,
	   no_poliza,	
	   no_endoso,	
	   no_remesa,	
	   renglon,		
	   no_tranrec,
	   fecha,	
	   periodo
  into _tipo_registro,
	   _no_poliza,	
	   _no_endoso,	
	   _no_remesa,	
	   _renglon,		
	   _no_tranrec,
	   _fecha_anulado,	
	   _periodo
  from sac999:reacomp
 where no_registro = a_no_registro;

-- Fecha de la Transaccion

let _periodo2 = sp_sis39(_fecha_anulado);

if _periodo = _periodo2 then
	let _fecha = _fecha_anulado;
elif _periodo > _periodo2 then
	let _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);
elif _periodo < _periodo2 then
	let _fecha = sp_sis36(_periodo);
end if

if _tipo_registro = 2 then -- Cobros

	let _tipo_comp = 1;
    let _no_unidad = "00001";

	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
	       _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Centro de Costo

	call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

	if _error <> 0 then
		drop table tmp_reas;
		let _error_desc = "Error en sp_sac93" || " Poliza " || _no_poliza;
		return _error, _error_desc;
	end if

	select prima_neta,
	       tipo_mov
	  into _prima_neta,
	       _tipo_mov
	  from cobredet
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	select porc_partic_coas
	  into _porc_partic_coas
	  from emicoama
	 where no_poliza    = _no_poliza
	   and cod_coasegur = _cod_lider;

	if _porc_partic_coas is null then
		let _porc_partic_coas = 100;
	end if

	let _prima_suscrita = _prima_neta * _porc_partic_coas / 100;

	delete from tmp_reas;
	delete from tmp_unidad;
	
	foreach
		select cod_contrato,
			   cod_cober_reas,
			   porc_partic_prima,
			   porc_proporcion
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima,
			   _porc_proporcion
		  from cobreaco
		 where no_remesa = _no_remesa
		   and renglon   = _renglon

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		let _prima = _prima_suscrita * (_porc_partic_prima / 100) * (_porc_proporcion / 100);
		   
		if _bouquet = 1 then
			if _porc_proporcion = 0 then		
				return 1, "% Proporcion es cero para la Rem: " || _no_remesa || " Rengl: " || _renglon;				 
			end if

			select es_terremoto
			  into _es_terremoto
			  from reacobre
			 where cod_cober_reas = _cod_cober_reas;
			
			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima,0,0,0,0,_porc_proporcion,0,0);
		end if
		
		begin
			on exception in(-239,-268)
				update tmp_unidad
				   set prima_tot = prima_tot + _prima
				 where no_unidad = _no_unidad;
			end exception
			insert into tmp_unidad(no_unidad,prima_tot)
			values(	_no_unidad,_prima);
		end
	end foreach

	if _cod_ramo in ("001", "003") then

		let _bouquet = 1;
		
		if _cod_ramo = '001' then
			let _porc_inc = .70;
			let _porc_ter = .30;		
		else
			let _porc_inc = .90;
			let _porc_ter = .10;
		end if

		foreach
			select distinct no_unidad,
				   cod_contrato,
				   porc_partic_prima
			  into _no_unidad,
				   _cod_contrato,
				   _porc_partic_prima
			  from tmp_reas
			 order by no_unidad,cod_contrato,porc_partic_prima

			select prima_tot
			  into _prima_tot
			  from tmp_unidad
			 where no_unidad = _no_unidad;

			select count(*)
			  into _cnt_existe
			  from reacocob c, reacobre r
			 where c.cod_cober_reas = r.cod_cober_reas
			   and c.cod_contrato = _cod_contrato
			   and r.cod_ramo = _cod_ramo
			   and es_terremoto = 1;

			if _cnt_existe is null then
				let _cnt_existe = 0;
			end if

			--Debe ser 70/30 para serie menores a 2014
			if _cnt_existe > 0 then
				if _cod_ramo = '001' then
					let _porc_inc = .70;
					let _porc_ter = .30;		
				else
					let _porc_inc = .90;
					let _porc_ter = .10;
				end if
			end if

			select count(*)
			  into _cantidad
			  from tmp_reas
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and es_terremoto = 0;

			if _cantidad = 0 then

				select cod_cober_reas,
				       es_terremoto
				  into _cod_cober_reas,
				       _es_terremoto
				  from reacobre
				 where cod_ramo     = _cod_ramo
				   and es_terremoto = 0;

				insert into tmp_reas
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima,0,0,0,0,_porc_proporcion,_porc_inc,_porc_ter);

			end if

			update tmp_reas
			   set prima_rea = prima_rea + (_prima_tot * _porc_inc) * (_porc_partic_prima/100),
			       porc_inc  = _porc_inc
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and porc_partic_prima = _porc_partic_prima
			   and es_terremoto = 0;

			select count(*)
			  into _cantidad
			  from tmp_reas
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and es_terremoto = 1;

			if _cantidad = 0 and _cnt_existe > 0 then

				select cod_cober_reas,
				       es_terremoto
				  into _cod_cober_reas,
				       _es_terremoto
				  from reacobre
				 where cod_ramo     = _cod_ramo
				   and es_terremoto = 1;

				insert into tmp_reas
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima,0,0,0,0,_porc_proporcion,_porc_inc,_porc_ter);

			end if

			update tmp_reas
			   set prima_rea = prima_rea + (_prima_tot * _porc_ter) * (_porc_partic_prima/100),
			       porc_ter  = _porc_ter
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and porc_partic_prima = _porc_partic_prima
			   and es_terremoto = 1;
		end foreach
	else
		update tmp_reas  
		   set prima_rea = prima_tot;
	end if

	foreach
		select cod_contrato,
			   prima_rea,
			   cod_cober_reas,
			   no_unidad,
			   orden
		  into _cod_contrato,
		       _prima,
		       _cod_cober_reas,
		       _no_unidad,
		       _orden
		  from tmp_reas

		select porc_impuesto,
		       porc_comision,
			   cod_coasegur,
			   tiene_comision,
			   bouquet
		  into _factor_impuesto,
			   _porc_comis_agt,
			   _cod_coasegur,
			   _tiene_comis_rea,
			   _bouquet
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		foreach
			 select cod_coasegur,
					porc_cont_partic,
					porc_comision
			   into _cod_coasegur,
					_porc_cont_partic,
					_porc_comis_ase
			   from reacoase
			  where cod_contrato   = _cod_contrato
				and cod_cober_reas = _cod_cober_reas
				and contrato_xl    = 0

			-- La comision se calcula por reasegurador

			if _tiene_comis_rea = 2 then 
				let _porc_comis_agt = _porc_comis_ase;
			end if

			select cod_origen,
				   aux_bouquet
			  into _cod_origen_aseg,
				   _cod_auxiliar
			  from emicoase
			 where cod_coasegur = _cod_coasegur;

			-- Reaseguro Cedido
			
			let _monto_reas    = _prima      * _porc_cont_partic / 100;
			let _suma_comision = _monto_reas * _porc_comis_agt   / 100;
			let _suma_impuesto = _monto_reas * _factor_impuesto  / 100;

			let _monto = _monto_reas - _suma_comision - _suma_impuesto;

			if _monto <> 0.00 Then
			
			update tmp_reas  
			   set porc_comision = _porc_comis_agt ,porc_impuesto = _factor_impuesto,comision = _suma_comision,impuesto = _suma_impuesto
			   where cod_contrato = _cod_contrato and cod_cober_reas = _cod_cober_reas;

				-- Provision por Reasegurador Bouquet

				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0 then
					let _debito  = _monto;
				else
					let _credito = _monto * -1;
				end if

				let _cuenta = sp_sis15("PPPRXPB", '03');
				--call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
				--call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

				-- Reaseguro por Pagar Bouquet

				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0 then
					let _credito = _monto;
				else
					let _debito  = _monto * -1;
				end if

				let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
				--call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
				--call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);
				return _monto,_cod_auxiliar with resume;
			end if

		end foreach

	end foreach
end if
--drop table tmp_reas;
--drop table tmp_unidad;
end
return 0, "Actualizacion Exitosa";
end procedure
