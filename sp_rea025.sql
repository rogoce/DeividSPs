-- Validacion para el auxiliar de contabilidad vs el borderaux

-- Creado    : 14/03/2012 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_rea025;

create procedure "informix".sp_rea025()
returning char(10),
          char(5),
		  char(10),
		  integer,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(10);

define a_no_registro		char(10);
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

define _cuenta          	char(25);

define _fecha				date;
define _fecha_anulado		date;

define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, "", "", 0, 0, 0, 0, "";
end exception

select par_ase_lider
  into _cod_lider
  from parparam
 where cod_compania = "001";

foreach
 select tipo_registro,
	    no_poliza,	
	    no_endoso,	
	    no_remesa,	
	    renglon,		
	    no_tranrec,
	    fecha,	
	    periodo,
		no_registro
   into _tipo_registro,
	    _no_poliza,	
	    _no_endoso,	
	    _no_remesa,	
	    _renglon,		
	    _no_tranrec,
	    _fecha_anulado,	
	    _periodo,
		a_no_registro
   from sac999:reacomp
  where tipo_registro = 2
    and periodo       = "2011-11"

	let _bouquet = 0;

	select cod_ramo,
	       cod_subramo
	  into _cod_ramo,
	       _cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo not in ("001", "003") then
		continue foreach;
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

	--{
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
	--}
	--{
	--delete from tmp_reas;

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
			
			let _prima = _prima_suscrita * _porc_partic_prima / 100;

			return _no_poliza,	
			       _no_endoso,	
			       _no_remesa,	
			       _renglon,		
				   _prima_neta, 
				   _prima_suscrita,
				   _prima,
				   a_no_registro
				   with resume;

			{
			select es_terremoto
			  into _es_terremoto
			  from reacobre
			 where cod_cober_reas = _cod_cober_reas;

			let _prima = _prima_suscrita * _porc_partic_prima / 100;

			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1);
			}
		end if

	end foreach

	--}
	{
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

	else

		update tmp_reas
		   set prima_rea = prima_tot;

	end if
	}
	{
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

				-- Provision por Reasegurador Bouquet

				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0 then
					let _debito  = _monto;
				else
					let _credito = _monto * -1;
				end if

				let _cuenta = sp_sis15("PPPRXPB", '03');
				call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
				call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

				-- Reaseguro por Pagar Bouquet

				let _debito  = 0.00;
				let _credito = 0.00;

				if _monto > 0 then
					let _credito = _monto;
				else
					let _debito  = _monto * -1;
				end if

				let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   
				call sp_par297(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _periodo, _centro_costo, _fecha);
				call sp_par298(a_no_registro, _cuenta, _debito, _credito, _tipo_comp, _cod_auxiliar, _periodo, _centro_costo, _fecha);

			end if

		end foreach

	end foreach
	}


end foreach

end

end procedure