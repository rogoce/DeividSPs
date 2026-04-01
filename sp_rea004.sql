-- Procedure que verifica la produccion 2008 y 2009 del Bouquet

-- Creado    : 21/01/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_rea004;

create procedure sp_rea004(a_periodo1 char(7), a_periodo2 char(7)) 
returning char(3),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(3),
		  char(50),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2);

define _no_poliza			char(10);
define _no_endoso			char(5);
define _no_documento		char(20);
define _no_factura			char(10);
define _no_unidad			char(5);
define _cod_ramo			char(3);
define _nombre_ramo			char(50);

define _cod_contrato		char(5);
define _cod_cober_reas		char(3);
define _cod_coasegur 		char(3);
define _cod_lider	 		char(3);
define _bouquet				smallint;
define _nombre				char(50);
define _nombre_contrato		char(50);

define _prima				dec(16,2);
define _prima_neta			dec(16,2);
define _prima_suscrita		dec(16,2);
define _factor_impuesto	 	dec(5,2);
define _porc_comis_agt   	dec(5,2);
define _tiene_comis_rea	 	smallint;
define _porc_cont_partic 	dec(5,2);
define _porc_comis_ase   	dec(5,2);
define _monto_reas		 	dec(16,2);
define _cobros			 	dec(16,2);
define _por_pagar		 	dec(16,2);
define _comision		 	dec(16,2);
define _impuesto		 	dec(16,2);
define _es_terremoto		smallint;
define _cantidad			smallint;

define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _cod_cobertura		char(5);
define _monto				dec(16,2);
define _diferencia			dec(16,2);
define _porc_partic_prima	dec(9,6);
define _porc_partic_coas    dec(7,4);
define _no_cambio	       	smallint;

set isolation to dirty read;

create temp table tmp_reas(
no_unidad		char(5),
cod_cober_reas	char(3),
cod_contrato	char(5),
prima_tot		dec(16,2),
prima_rea		dec(16,2),
es_terremoto   	smallint
) with no log;

create temp table tmp_ramo(
cod_coasegur	char(3),
cod_ramo		char(3),
monto_reas		dec(16,2),
comision		dec(16,2),
impuesto		dec(16,2),
por_pagar		dec(16,2),
siniestros		dec(16,2),
cobros			dec(16,2) default 0.00
) with no log;

-- Cobros

select par_ase_lider
  into _cod_lider
  from parparam
 where cod_compania = "001";

foreach
 select no_poliza,
        prima_neta
   into _no_poliza,
        _prima_neta
   from cobredet
  where periodo      >= a_periodo1
    and periodo      <= a_periodo2
	and actualizado  = 1           -- and doc_remesa = '0109-00461-01'
	and tipo_mov	 in ("P", "N")

	delete from tmp_reas;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select porc_partic_coas
	  into _porc_partic_coas
	  from emicoama
	 where no_poliza    = _no_poliza
	   and cod_coasegur = _cod_lider;
	
	if _porc_partic_coas is null then
		let _porc_partic_coas = 100;
	end if

	let _prima_suscrita = _prima_neta * _porc_partic_coas / 100;

	select max(no_cambio)
	  into _no_cambio
	  from emireaco
	 where no_poliza = _no_poliza;

	select min(no_unidad)
	  into _no_unidad
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_cambio = _no_cambio;
	   
	select min(cod_cober_reas)
	  into _cod_cober_reas
	  from emireaco
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and no_cambio = _no_cambio;

	foreach
	 select cod_contrato,
	        porc_partic_prima
	   into _cod_contrato,
	        _porc_partic_prima
	   from emireaco
	  where no_poliza      = _no_poliza
	    and no_unidad      = _no_unidad
	    and no_cambio      = _no_cambio
		and cod_cober_reas = _cod_cober_reas

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		if _bouquet = 1 then

			select es_terremoto
			  into _es_terremoto
			  from reacobre
			 where cod_cober_reas = _cod_cober_reas;

			let _prima = _prima_suscrita * _porc_partic_prima / 100;

			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto);

		end if

	end foreach

	if _cod_ramo in ("001", "003") then

		let _bouquet = 1;

		foreach
		 select no_unidad,
		        cod_contrato,
		        sum(prima_tot)
		   into _no_unidad,
		        _cod_contrato,
		        _prima
		   from tmp_reas
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
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto);

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
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto);

			end if

			update tmp_reas
			   set prima_rea    = _prima * .30
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and es_terremoto = 1;

		end foreach

	else

		update tmp_reas
		   set prima_rea    = prima_tot;

	end if

	foreach
	 select cod_contrato,
	        cod_cober_reas,
			prima_rea,
			no_unidad
	   into	_cod_contrato,
	        _cod_cober_reas,
			_prima,
			_no_unidad
	   from tmp_reas

		select porc_impuesto,
		       porc_comision,
			   tiene_comision
		  into _factor_impuesto,
			   _porc_comis_agt,
			   _tiene_comis_rea
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

			-- La comision se calcula por reasegurador

			if _tiene_comis_rea = 2 then 
				let _porc_comis_agt = _porc_comis_ase;
			end if

			let _monto_reas = _prima      * _porc_cont_partic / 100;
			let _comision   = _monto_reas * _porc_comis_agt   / 100;
			let _impuesto   = _monto_reas * _factor_impuesto  / 100;
			let _por_pagar  = _monto_reas - _comision - _impuesto;

			insert into tmp_ramo
			values (_cod_coasegur, _cod_ramo, 0.00, 0.00, 000, 0.00, 0.00, _por_pagar);

		end foreach

	end foreach

end foreach

-- Siniestros
--{
foreach
 select no_tranrec,
        monto,
		no_reclamo
   into _no_tranrec,
        _monto,
		_no_reclamo
   from rectrmae
  where periodo      >= a_periodo1
    and periodo      <= a_periodo2
	and actualizado  = 1
	and cod_tipotran = "004"

	select no_poliza
	  into _no_poliza
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	foreach
	 select cod_cobertura
	   into _cod_cobertura
	   from rectrcob
	  where no_tranrec = _no_tranrec
	    and monto      <> 0
		exit foreach;
	end foreach

	select cod_cober_reas
	  into _cod_cober_reas
	  from prdcober
	 where cod_cobertura = _cod_cobertura;
	
	foreach
	 select cod_contrato,
	        porc_partic_prima
	   into _cod_contrato,
	        _porc_partic_prima
	   from rectrrea
	  where no_tranrec = _no_tranrec

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		if _bouquet = 0 then
			continue foreach;
		end if

		let _prima = _monto * _porc_partic_prima / 100;

		foreach
		 select cod_coasegur,
		        porc_cont_partic
		   into _cod_coasegur,
		        _porc_cont_partic
		   from reacoase
	      where cod_contrato   = _cod_contrato
	        and cod_cober_reas = _cod_cober_reas

			let _monto_reas = _prima * _porc_cont_partic / 100;

			insert into tmp_ramo
			values (_cod_coasegur, _cod_ramo, 0.00, 0.00, 0.00, 0.00, _monto_reas, 0.00);

		end foreach

	end foreach

end foreach
--}

foreach
 select no_poliza,
        no_endoso,
		no_factura
   into _no_poliza,
        _no_endoso,
		_no_factura
   from endedmae
  where periodo     >= a_periodo1
    and periodo     <= a_periodo2
	and actualizado = 1

	select no_documento,
	       cod_ramo
	  into _no_documento,
	       _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo in ("001", "003") then

		delete from tmp_reas;

		foreach
		 select f.cod_contrato,
		        f.cod_cober_reas,
				sum(f.prima),
				f.no_unidad
		   into	_cod_contrato,
		        _cod_cober_reas,
				_prima,
				_no_unidad
		   from emifacon f, endeduni u
		  where u.no_poliza = _no_poliza
		    and u.no_endoso = _no_endoso
			and f.no_poliza = u.no_poliza
		    and f.no_endoso = u.no_endoso
		    and f.no_unidad = u.no_unidad
		  group by f.no_unidad, f.cod_contrato, f.cod_cober_reas

			select bouquet
			  into _bouquet
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			if _bouquet = 0 then
				continue foreach;
			end if

			select es_terremoto
			  into _es_terremoto
			  from reacobre
			 where cod_cober_reas = _cod_cober_reas;

			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto);

		end foreach

		foreach
		 select no_unidad,
		        cod_contrato,
		        sum(prima_tot)
		   into _no_unidad,
		        _cod_contrato,
		        _prima
		   from tmp_reas
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
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto);

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
				values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto);

			end if

			update tmp_reas
			   set prima_rea    = _prima * .30
			 where no_unidad    = _no_unidad
			   and cod_contrato = _cod_contrato
			   and es_terremoto = 1;

		end foreach

		foreach
		 select cod_contrato,
		        cod_cober_reas,
				prima_rea,
				no_unidad
		   into	_cod_contrato,
		        _cod_cober_reas,
				_prima,
				_no_unidad
		   from tmp_reas

			select porc_impuesto,
			       porc_comision,
				   tiene_comision
			  into _factor_impuesto,
				   _porc_comis_agt,
				   _tiene_comis_rea
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

				-- La comision se calcula por reasegurador

				if _tiene_comis_rea = 2 then 
					let _porc_comis_agt = _porc_comis_ase;
				end if

				let _monto_reas = _prima      * _porc_cont_partic / 100;
				let _comision   = _monto_reas * _porc_comis_agt   / 100;
				let _impuesto   = _monto_reas * _factor_impuesto  / 100;
				let _por_pagar  = _monto_reas - _comision - _impuesto;

				insert into tmp_ramo
				values (_cod_coasegur, _cod_ramo, _monto_reas, _comision, _impuesto, _por_pagar, 0.00, 0.00);

			end foreach

		end foreach

	else

		foreach
		 select f.cod_contrato,
		        f.cod_cober_reas,
				f.prima,
				f.no_unidad
		   into	_cod_contrato,
		        _cod_cober_reas,
				_prima,
				_no_unidad
		   from emifacon f, endeduni u
		  where u.no_poliza = _no_poliza
		    and u.no_endoso = _no_endoso
			and f.no_poliza = u.no_poliza
		    and f.no_endoso = u.no_endoso
		    and f.no_unidad = u.no_unidad
			and f.prima     <> 0.00

			select porc_impuesto,
			       porc_comision,
				   tiene_comision,
				   bouquet
			  into _factor_impuesto,
				   _porc_comis_agt,
				   _tiene_comis_rea,
				   _bouquet
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			if _bouquet = 0 then
				continue foreach;
			end if

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

				-- La comision se calcula por reasegurador

				if _tiene_comis_rea = 2 then 
					let _porc_comis_agt = _porc_comis_ase;
				end if

				let _monto_reas = _prima      * _porc_cont_partic / 100;
				let _comision   = _monto_reas * _porc_comis_agt   / 100;
				let _impuesto   = _monto_reas * _factor_impuesto  / 100;
				let _por_pagar  = _monto_reas - _comision - _impuesto;

				insert into tmp_ramo
				values (_cod_coasegur, _cod_ramo, _monto_reas, _comision, _impuesto, _por_pagar, 0.00, 0.00);

			end foreach

		end foreach

	end if

end foreach

foreach
 select cod_coasegur,
        cod_ramo,
		sum(monto_reas),
		sum(comision),
		sum(impuesto),
		sum(por_pagar),
		sum(siniestros),
		sum(cobros)
   into _cod_coasegur,
        _cod_ramo,
		_monto_reas,
		_comision,
		_impuesto,
		_por_pagar,
		_monto,
		_cobros
   from tmp_ramo
  group by 1, 2
  order by 1, 2

	select nombre
	  into _nombre
	  from emicoase
	 where cod_coasegur = _cod_coasegur;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	let _diferencia = _por_pagar - _monto;

	return _cod_ramo,
	       _nombre_ramo,
		   _monto_reas,
		   _comision,
		   _impuesto,
		   _por_pagar,
		   _cod_coasegur,
		   _nombre,
		   _monto,
		   _diferencia,
		   _cobros
		   with resume;

end foreach

drop table tmp_reas;
drop table tmp_ramo;

end procedure
