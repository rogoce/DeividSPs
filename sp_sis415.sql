-- Procedimiento que genera la información de Reaseguro, Comisión e Impuesto para el proceso NIIF
-- Creado    : 29/07/2013 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis415;

create procedure sp_sis415(a_no_poliza char(10), a_no_endoso char(5))
returning integer,
	      char(100);

define _error_desc			char(100);
define _no_factura			char(10);
define _cod_traspaso		char(5);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur		char(3);
define _cod_ramo			char(3);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _porc_comis_ase		dec(5,2);
define _porc_impuesto		dec(5,2);
define _porc_cont_partic	dec(9,6);
define _factor_impuesto		dec(9,6);
define _prima_suscrita		dec(16,2);
define _impuesto_rea		dec(16,2);
define _monto_reas			dec(16,2);
define _comis_agt			dec(16,2);
define _comis_rea			dec(16,2);
define _impuesto			dec(16,2);
define _monto				dec(16,2);
define _tiene_comis_rea		smallint;
define _tipo_contrato		smallint;
define _es_terremoto		smallint;
define _porc_imp			smallint;
define _cantidad			smallint;
define _traspaso			smallint;
define _cnt_reas			smallint;
define _bouquet				smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;

set isolation to dirty read;

--set debug file to "sp_pro398.trc";
--trace on;

begin

on exception set _error,_error_isam,_error_desc
  rollback work;	
  return _error,_error_desc;
end exception

create temp table tmp_info_reas
   (no_poliza		char(10),
	no_endoso		char(10),
	prima_suscrita	dec(16,2),
	impuesto		dec(16,2),
	prima_rea		dec(16,2),
	imp_reas		dec(16,2),
	comis_rea		dec(16,2),
	comis_agt		dec(16,2),
primary key(no_poliza,no_endoso)) with no log;

create temp table tmp_reas(
	no_unidad		char(5),
	cod_cober_reas	char(3),
	cod_contrato	char(5),
	prima_tot		dec(16,2),
	prima_rea		dec(16,2),
	es_terremoto   	smallint,
	bouquet			smallint,
	orden			smallint) with no log;
create index idx_tmp_reas_1 on tmp_reas(no_unidad, cod_contrato, es_terremoto);
create index idx_tmp_reas_2 on tmp_reas(no_unidad, cod_contrato, cod_cober_reas);
create index idx_tmp_reas_3 on tmp_reas(bouquet);

let _porc_imp = 2;
let _porc_impuesto = _porc_imp /100;

select prima_suscrita,
	   no_factura
  into _prima_suscrita,
	   _no_factura
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

let _impuesto = _prima_suscrita * _porc_impuesto;

begin
	on exception in(-239)
		update tmp_info_reas
		   set prima_suscrita	= prima_suscrita + _prima_suscrita,
			   impuesto			= impuesto	+ _impuesto
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso;
	end exception 	

	insert into tmp_info_reas
	values(	a_no_poliza,
			a_no_endoso,
			_prima_suscrita,
			_impuesto,
			0,
			0,
			0,
			0);
end

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

select count(*)
  into _cnt_reas
  from emifacon
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

if _cnt_reas = 0 and _prima_suscrita <> 0.00 Then
	drop table tmp_reas;
	return 1, "No Existe Distribucion de Reaseguro Para Factura: " || _no_factura;
end if

if _cod_ramo in ("001", "003") then
	foreach
		select cod_contrato,
			   cod_cober_reas,
			   sum(prima),
			   no_unidad
		  into _cod_contrato,
			   _cod_cober_reas,
			   _monto_reas,
			   _no_unidad
		  from emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		 group by no_unidad, cod_contrato, cod_cober_reas

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		select es_terremoto
		  into _es_terremoto
		  from reacobre
		 where cod_cober_reas = _cod_cober_reas;

		insert into tmp_reas
		values(	_no_unidad,
				_cod_cober_reas,
				_cod_contrato,
				_monto_reas,
				0.00,
				_es_terremoto,
				_bouquet,
				1);
	end foreach

	-- Cuando el Contrato Es Bouquet
	let _bouquet = 1;

	foreach
		select no_unidad,
			   cod_contrato,
			   sum(prima_tot)
		  into _no_unidad,
			   _cod_contrato,
			   _monto_reas
		  from tmp_reas
		 where bouquet = 1
		 group by no_unidad, cod_contrato
		 order by no_unidad, cod_contrato

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
			values(	_no_unidad,
					_cod_cober_reas,
					_cod_contrato,
					0.00,
					0.00,
					_es_terremoto,
					_bouquet,
					1);
		end if

		update tmp_reas
		   set prima_rea    = _monto_reas * .70
		 where no_unidad    = _no_unidad
		   and cod_contrato = _cod_contrato
		   and es_terremoto = 0;

		select count(*)
		  into _cantidad
		  from tmp_reas
		 where no_unidad    = _no_unidad
		   and cod_contrato = _cod_contrato
		   and es_terremoto = 1;

		if _cantidad = 0 then
			select cod_cober_reas,
				   es_terremoto
			  into _cod_cober_reas,
				   _es_terremoto
			  from reacobre
			 where cod_ramo     = _cod_ramo
			   and es_terremoto = 1;

			insert into tmp_reas
			values(	_no_unidad,
					_cod_cober_reas,
					_cod_contrato,
					0.00,
					0.00,
					_es_terremoto,
					_bouquet,
					1);
		end if

		update tmp_reas
		   set prima_rea    = _monto_reas * .30
		 where no_unidad    = _no_unidad
		   and cod_contrato = _cod_contrato
		   and es_terremoto = 1;
	end foreach

		-- Cuando el Contrato No Es Bouquet
	foreach
		select no_unidad,
			   cod_cober_reas,
			   cod_contrato
		  into _no_unidad,
			   _cod_cober_reas,
			   _cod_contrato
		  from tmp_reas
		 where bouquet = 0

		select prima
		  into _monto_reas
		  from emifacon
		 where no_poliza      = a_no_poliza
		   and no_endoso      = a_no_endoso
		   and no_unidad      = _no_unidad
		   and cod_cober_reas = _cod_cober_reas
		   and cod_contrato   = _cod_contrato;

		update tmp_reas
		   set prima_rea      = _monto_reas
		 where no_unidad      = _no_unidad
		   and cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;
	end foreach
else	
	foreach
		select cod_contrato,
			   prima,
			   cod_cober_reas,
			   no_unidad,
			   orden
		  into _cod_contrato,
			   _monto_reas,
			   _cod_cober_reas,
			   _no_unidad,
			   _orden
		  from emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso

		insert into tmp_reas
		values(	_no_unidad,
				_cod_cober_reas,
				_cod_contrato,
				_monto_reas,
				_monto_reas,
				0,
				0,
				_orden);
	end foreach
end if

let _monto_reas = 0.00;

-- Calculo de los Campos de Reseguro Cedido, Impuesto Reaseguro y Comision Reaseguro
foreach
	select cod_contrato,
		   prima_rea,
		   cod_cober_reas,
		   no_unidad,
		   orden
	  into _cod_contrato,
		   _monto,
		   _cod_cober_reas,
		   _no_unidad,
		   _orden
	  from tmp_reas

	select traspaso
	  into _traspaso
	  from reacocob
	 where cod_contrato   = _cod_contrato
	   and cod_cober_reas = _cod_cober_reas;

	select tipo_contrato,
		   porc_impuesto,
		   cod_traspaso
	  into _tipo_contrato,
		   _factor_impuesto,
		   _cod_traspaso
	  from reacomae
	 where cod_contrato = _cod_contrato;

	if _traspaso = 1 then
		let _cod_contrato = _cod_traspaso;

		select tipo_contrato,
			   porc_impuesto
		  into _tipo_contrato,
			   _factor_impuesto
		  from reacomae
		 where cod_contrato = _cod_contrato;
	end if

	if _tipo_contrato = 1 Then -- Retencion
		continue foreach;
	elif _tipo_contrato = 3 Then -- Contratos Facultativos
		foreach
			select prima,
				   monto_comision
			  into _monto,
				   _comis_rea
			  from emifafac
			 where no_poliza      = a_no_poliza
			   and no_endoso      = a_no_endoso
			   and no_unidad      = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			
			let _impuesto_rea = 0;
			let _impuesto_rea = _monto * _porc_impuesto;
			
			update tmp_info_reas
			   set prima_rea	= prima_rea + _monto,
				   imp_reas		= imp_reas	+ _impuesto_rea,
				   comis_rea	= comis_rea	+  _comis_rea
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso;
		end foreach
	else -- Otros Contratos
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
			
			-- Reaseguro Cedido
			let _monto_reas = _monto * _porc_cont_partic / 100;
			
			-- Comision Ganada
			let _comis_rea = _monto_reas * _porc_comis_agt / 100;
			
			--Impuesto del Reaseguro
			let _impuesto_rea = _monto_reas * _porc_impuesto;

			update tmp_info_reas
			   set prima_rea	= prima_rea	+ _monto_reas,
				   imp_reas		= imp_reas	+ _impuesto_rea,
				   comis_rea	= comis_rea	+  _comis_rea
			 where no_poliza = a_no_poliza
			   and no_endoso = a_no_endoso;
		end foreach
	end if
end foreach
drop table tmp_reas;

let _porc_partic_agt	= 0.00;
let _porc_comis_agt		= 0.00;
let _comis_agt			= 0.00;

--Calculo del campo de  Comision Corredor
foreach
	select porc_partic_agt,
		   porc_comis_agt
	  into _porc_partic_agt,
		   _porc_comis_agt
	  from endmoage
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	  
	let _comis_agt = _prima_suscrita * (_porc_partic_agt / 100) * (_porc_comis_agt / 100);
	
	update tmp_info_reas
	   set comis_agt	= comis_agt + _comis_agt
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso;	
end foreach

return 0,'Calculo Exitoso';
end
end procedure 