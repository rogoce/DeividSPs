-- Procedure que verifica la produccion 2008 y 2009 del Bouquet

-- Creado    : 21/01/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_rea006;

create procedure sp_rea006(a_periodo1 char(7), a_periodo2 char(7)) 
returning char(20),
          char(10),
		  char(5),
		  dec(16,2),
		  dec(5,2),
		  dec(16,2),
		  char(10),
		  char(5),
		  dec(5,2),
		  dec(16,2),
		  dec(16,2),
		  char(3),
		  char(50),
		  char(5),
		  char(50),
		  char(3),
		  char(3),
		  char(50);

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
define _bouquet				smallint;
define _nombre				char(50);
define _nombre_contrato		char(50);

define _prima				dec(16,2);
define _factor_impuesto	 	dec(5,2);
define _porc_comis_agt   	dec(5,2);
define _tiene_comis_rea	 	smallint;
define _porc_cont_partic 	dec(5,2);
define _porc_comis_ase   	dec(5,2);
define _monto_reas		 	dec(16,2);
define _por_pagar		 	dec(16,2);
define _comision		 	dec(16,2);
define _impuesto		 	dec(16,2);
define _es_terremoto		smallint;
define _cantidad			smallint;

set isolation to dirty read;

create temp table tmp_reas(
no_unidad		char(5),
cod_cober_reas	char(3),
cod_contrato	char(5),
prima_tot		dec(16,2),
prima_rea		dec(16,2),
es_terremoto   	smallint
) with no log;

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
--	and no_factura  = "01-705929"

	select no_documento,
	       cod_ramo
	  into _no_documento,
	       _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo not in ("001", "003") then
		continue foreach;
	end if

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

--	if _cod_ramo in ("001", "003") then

		delete from tmp_reas;

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
		 select sum(prima_rea),
				no_unidad,
				cod_contrato
		   into	_prima,
				_no_unidad,
				_cod_contrato
		   from tmp_reas
		  group by no_unidad, cod_contrato

				select sum(prima)
				  into _monto_reas
				  from emifacon
				 where no_poliza      = _no_poliza
				   and no_endoso      = _no_endoso
				   and no_unidad      = _no_unidad
				   and cod_contrato   = _cod_contrato;
			
				select nombre
				  into _nombre_contrato
				  from reacomae
				 where cod_contrato = _cod_contrato;

				if abs (_prima - _monto_reas) > 0.01 then

				return _no_documento,
				       _no_factura,
					   _no_unidad,
					   _prima,
					   0,
					   _monto_reas,
					   _no_poliza,
					   _no_endoso,
					   0,
					   0,
					   0,
					   "",
					   "",
					   _cod_contrato,
					   _nombre_contrato,
					   "",
					   _cod_ramo,
					   _nombre_ramo
					   with resume;

				end if
					

{
			select porc_impuesto,
			       porc_comision,
				   tiene_comision
			  into _factor_impuesto,
				   _porc_comis_agt,
				   _tiene_comis_rea
			  from reacocob
			 where cod_contrato   = _cod_contrato
			   and cod_cober_reas = _cod_cober_reas;

			select nombre
			  into _nombre_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;
	
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

				select nombre
				  into _nombre
				  from emicoase
				 where cod_coasegur = _cod_coasegur;
				
--				if _cod_coasegur = "089" then


				return _no_documento,
				       _no_factura,
					   _no_unidad,
					   _prima,
					   _porc_cont_partic,
					   _monto_reas,
					   _porc_comis_agt,
					   _comision,
					   _factor_impuesto,
					   _impuesto,
					   _por_pagar,
					   _cod_coasegur,
					   _nombre,
					   _cod_contrato,
					   _nombre_contrato,
					   _cod_cober_reas,
					   _cod_ramo,
					   _nombre_ramo
					   with resume;

--				end if

			end foreach
}

		end foreach

--	else

{
		foreach
		 select cod_contrato,
		        cod_cober_reas,
				prima,
				no_unidad
		   into	_cod_contrato,
		        _cod_cober_reas,
				_prima,
				_no_unidad
		   from emifacon
		  where no_poliza = _no_poliza
		    and no_endoso = _no_endoso
			and prima     <> 0.00

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

			select nombre
			  into _nombre_contrato
			  from reacomae
			 where cod_contrato = _cod_contrato;
	
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

				select nombre
				  into _nombre
				  from emicoase
				 where cod_coasegur = _cod_coasegur;

--				if _cod_coasegur = "089" then

				return _no_documento,
				       _no_factura,
					   _no_unidad,
					   _prima,
					   _porc_cont_partic,
					   _monto_reas,
					   _porc_comis_agt,
					   _comision,
					   _factor_impuesto,
					   _impuesto,
					   _por_pagar,
					   _cod_coasegur,
					   _nombre,
					   _cod_contrato,
					   _nombre_contrato,
					   _cod_cober_reas,
					   _cod_ramo,
					   _nombre_ramo
					   with resume;

--				end if

			end foreach

		end foreach
}

--	end if

end foreach

return "0",
       "0",
	   "0",
	   0,
	   0,
	   0,
	   "0",
	   "0",
	   0,
	   0,
	   0,
	   "",
	   "",
	   "0",
	   "0",
	   "",
	   "",
	   ""
	   with resume;

drop table tmp_reas;

end procedure
