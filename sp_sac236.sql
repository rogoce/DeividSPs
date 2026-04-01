-- Generacion de Registros Contables de Reaseguro

-- Creado    : 04/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

--drop procedure sp_sac236;

create procedure "informix".sp_sac236(a_no_registro char(10))
returning char(10),
          char(3),
		  char(5),
		  smallint,
		  char(3),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _tipo_registro		smallint;
define _cant_reaseguro  	smallint;  
define _orden				smallint;
define _traspaso			smallint;
define _tipo_contrato   	smallint;
define _tiene_comis_rea		smallint;
define _bouquet			 	smallint;
define _renglon				smallint;
define _tipo_comp       	smallint;
define _es_terremoto       	smallint;
define _cantidad	       	smallint;
define _no_cambio	       	smallint;
define _tipo_transaccion	smallint;

define _debito          	dec(16,2);
define _credito         	dec(16,2);
define _prima_suscrita		dec(16,2);
define _prima_neta			dec(16,2);
define _monto				dec(16,2);
define _monto2				dec(16,2);
define _monto3				dec(16,2);
define _fac_comision		dec(16,2);
define _fac_impuesto		dec(16,2);
define _monto_reas		 	dec(16,2);
define _monto_reas_cob	 	dec(16,2);
define _prima			 	dec(16,2);
define _coas_por_pagar	 	dec(16,2);
define _suma_comision	 	dec(16,2);
define _suma_impuesto	 	dec(16,2);

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

--set debug file to "sp_sac236.trc";
--trace on;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	drop table tmp_reas;
--	return _error, _error_desc;
end exception

create temp table tmp_reas(
no_unidad		char(5),
cod_cober_reas	char(3),
cod_contrato	char(5),
prima_tot		dec(16,2),
prima_rea		dec(16,2),
es_terremoto   	smallint,
bouquet			smallint,
orden			smallint
) with no log;

create index idx_tmp_reas_1 on tmp_reas(no_unidad, cod_contrato, es_terremoto);
create index idx_tmp_reas_2 on tmp_reas(no_unidad, cod_contrato, cod_cober_reas);
create index idx_tmp_reas_3 on tmp_reas(bouquet);

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

if _tipo_registro = 1 then -- Produccion

	select prima_suscrita,
	       no_factura
	  into _prima_suscrita,
	       _no_factura
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	-- Centro de Costo

	call sp_sac93(_no_poliza, 1) returning _error, _error_desc, _centro_costo;

	if _error <> 0 then
		drop table tmp_reas;
		let _error_desc = "Error en sp_sac93" || " Poliza " || _no_poliza || " Endoso " || _no_endoso;
--		return _error, _error_desc;
	end if

	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
	       _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	-- Tipo de Comprobante

	if _cod_ramo in ("001", "003") then		
		let _tipo_comp = 10;				-- Incendio
	elif _cod_ramo in ("002", "020", "023") then	
		let _tipo_comp = 11;				-- Autos
	elif _cod_ramo in ("008") then			
		let _tipo_comp = 12;				-- Fianzas
	elif _cod_ramo in ("004", "016", "018", "019") then	
		let _tipo_comp = 13;				-- Personas
	else
		let _tipo_comp = 14;				-- Patrimoniales
	end if

	select count(*)
	  into _cant_reaseguro
	  from emifacon
	 where no_poliza = _no_poliza
	   and no_endoso = _no_endoso;

	if _cant_reaseguro = 0     and
	   _prima_suscrita <> 0.00 Then

		drop table tmp_reas;
--		return 1, "No Existe Distribucion de Reaseguro Para Factura: " || _no_factura;

	end if

	delete from tmp_reas;

	if _cod_ramo in ("001", "003") then

		foreach
		 select cod_contrato,
		        cod_cober_reas,
				sum(prima),
				no_unidad
		   into	_cod_contrato,
		        _cod_cober_reas,
				_prima,
				_no_unidad
		   from emifacon
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
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
			values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1);

		end foreach

		-- Cuando el Contrato Es Bouquet

		let _bouquet = 1;

		foreach
		 select no_unidad,
		        cod_contrato,
		        sum(prima_tot)
		   into _no_unidad,
		        _cod_contrato,
		        _prima
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
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1);

			end if

			update tmp_reas
			   set prima_rea    = _prima * .70
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
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1);

			end if

			update tmp_reas
			   set prima_rea    = _prima * .30
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
			  into _prima
			  from emifacon
			 where no_poliza      = _no_poliza
			   and no_endoso      = _no_endoso
			   and no_unidad      = _no_unidad
			   and cod_cober_reas = _cod_cober_reas
			   and cod_contrato   = _cod_contrato;

			update tmp_reas
			   set prima_rea      = _prima
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
		        _prima,
				_cod_cober_reas,
				_no_unidad,
				_orden
		   from emifacon
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso

			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, _prima, 0, 0, _orden);

		end foreach
	end if

	-- Generacion del Asiento

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
			        porc_impuesto,
					porc_comis_fac,
					cod_coasegur,
					monto_comision,
					monto_impuesto
			   into _monto,
					_factor_impuesto,
			   		_porc_comis_agt,
					_cod_coasegur,
					_fac_comision,
					_fac_impuesto
			   from emifafac
			  where no_poliza      = _no_poliza
			    and no_endoso      = _no_endoso
				and no_unidad      = _no_unidad
				and cod_cober_reas = _cod_cober_reas

--				and orden		   = _orden   se quito por que generaba error para los facultativos 22/04/2010 Armando/Demetrio
				
				select cod_origen
				  into _cod_origen_aseg
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

				-- Reaseguro Cedido

				let _monto = _monto;

				-- Comision Ganada

				let _monto2 = _fac_comision;
						  						  
				-- Impuesto Recuperado

				let _monto2 = _fac_impuesto;

				-- Reaseguro por Pagar

				let _monto3  = _monto - _fac_comision - _fac_impuesto;
				
				return _no_unidad, 
				       _cod_cober_reas,
					   _cod_contrato,
					   _bouquet,
					   _cod_coasegur,
					   _monto,
					   _fac_comision,
					   _fac_impuesto,
					   _monto3
					   with resume;

			end foreach

		else -- Otros Contratos

			Select porc_impuesto,
			       porc_comision,
				   cod_coasegur,
				   tiene_comision,
				   bouquet
			  Into _factor_impuesto,
				   _porc_comis_agt,
				   _cod_coasegur,
				   _tiene_comis_rea,
				   _bouquet
			  From reacocob
			 Where cod_contrato   = _cod_contrato
			   And cod_cober_reas = _cod_cober_reas;
			
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
					   _aux_bouquet
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

				-- Reaseguro Cedido
				
				let _monto_reas = _monto * _porc_cont_partic / 100;
				let _monto3     = _monto_reas;

				-- Comision Ganada

				Let _fac_comision = _monto_reas * _porc_comis_agt / 100;

				-- Impuesto Recuperado

				Let _fac_impuesto = _monto_reas * _factor_impuesto / 100;

				-- Reaseguro por Pagar

				let _monto3  = _monto_reas - _fac_comision - _fac_impuesto;
				
				return _no_unidad, 
				       _cod_cober_reas,
					   _cod_contrato,
					   _bouquet,
					   _cod_coasegur,
					   _monto_reas,
					   _fac_comision,
					   _fac_impuesto,
					   _monto3
					   with resume;

			end foreach

		End If

	End Foreach

end if

drop table tmp_reas;

end

--return 0, "Actualizacion Exitosa";

end procedure
