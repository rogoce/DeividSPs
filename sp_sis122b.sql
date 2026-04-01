-- verificar % para descuento buena exp
--
-- creado    : 20/03/2014 - Autor: Roman Gordon
-- sis v.2.0

drop procedure sp_sis122b;
create procedure "informix".sp_sis122b(a_no_poliza char(10), a_no_endoso char(5))
returning	integer,
			char(100);


define _error_desc			char(100);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_subramo			char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _prima_tot			dec(16,2);
define _porc_inc			dec(16,2);
define _porc_ter			dec(16,2);
define _prima				dec(16,2);
define _es_terremoto		smallint;
define _cnt_existe			smallint;
define _cantidad			smallint;
define _bouquet				smallint;
define _serie				smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;

begin
on exception set _error,_error_isam,_error_desc	
	drop table tmp_reas;
	return _error,_error_desc;
end exception

set isolation to dirty read;

--set debug file to "sp_sis122.trc"; 
--trace on;			

drop table if exists tmp_unidad;
drop table if exists tmp_reas;

create temp table tmp_reas(
no_poliza		char(10),
no_endoso		char(5),
no_unidad		char(5),
cod_cober_reas	char(3),
cod_contrato	char(5),
prima_tot		dec(16,2),
prima_rea		dec(16,2),
es_terremoto   	smallint,
bouquet			smallint,
orden			smallint,
porc_partic_prima	dec(9,6)) with no log;

create temp table tmp_unidad(
no_unidad		char(5),
prima_tot		dec(16,2)	default 0.00,
primary key (no_unidad)) with no log;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

let _prima_tot = 0.00;

if _cod_ramo in ('001','003') then
	foreach
		select cod_contrato,
			   cod_cober_reas,
			   sum(prima),
			   no_unidad,
			   porc_partic_prima
		  into _cod_contrato,
			   _cod_cober_reas,
			   _prima,
			   _no_unidad,
			   _porc_partic_prima
		  from emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso
		 group by no_unidad, cod_contrato, cod_cober_reas,porc_partic_prima

		select bouquet
		  into _bouquet
		  from reacocob
		 where cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;

		select es_terremoto
		  into _es_terremoto
		  from reacobre
		 where cod_cober_reas = _cod_cober_reas;

		begin
			on exception in(-239,-268)
				update tmp_unidad
				   set prima_tot = prima_tot + _prima
				 where no_unidad = _no_unidad;
			end exception
			insert into tmp_unidad(no_unidad,prima_tot)
			values(	_no_unidad,_prima);
		end

		insert into tmp_reas
		values (a_no_poliza,a_no_endoso,_no_unidad, _cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);
	end foreach

	-- Cuando el Contrato Es Bouquet

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
		 order by no_unidad, cod_contrato,porc_partic_prima

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

		select serie
		  into _serie
		  from reacomae
		 where cod_contrato = _cod_contrato;

		if _cod_ramo = '003' then
			if _serie < 2015 then
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
			foreach
				select cod_cober_reas,
					   es_terremoto
				  into _cod_cober_reas,
					   _es_terremoto
				  from reacobre
				 where cod_ramo     = _cod_ramo
				   and es_terremoto = 0
				 order by 1
				exit foreach;
			end foreach

			insert into tmp_reas
			values (a_no_poliza,a_no_endoso,_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);
		end if

		update tmp_reas
		   set prima_rea    = prima_rea + (_prima_tot * _porc_inc) * (_porc_partic_prima/100)
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
			values (a_no_poliza,a_no_endoso,_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

		end if

		update tmp_reas
		   set prima_rea    = prima_rea + (_prima_tot * _porc_ter) * (_porc_partic_prima/100)
		 where no_unidad    = _no_unidad
		   and cod_contrato = _cod_contrato
		   and porc_partic_prima = _porc_partic_prima
		   and es_terremoto = 1;
	end foreach

	-- Cuando el Contrato No Es Bouquet
	{foreach
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
		 where no_poliza      = a_no_poliza
		   and no_endoso      = a_no_endoso
		   and no_unidad      = _no_unidad
		   and cod_cober_reas = _cod_cober_reas
		   and cod_contrato   = _cod_contrato;

		update tmp_reas
		   set prima_rea      = _prima
		 where no_unidad      = _no_unidad
		   and cod_contrato   = _cod_contrato
		   and cod_cober_reas = _cod_cober_reas;
	end foreach}
else
	foreach
		select cod_contrato,
			   prima,
			   cod_cober_reas,
			   no_unidad,
			   orden,
			   porc_partic_prima
		  into _cod_contrato,
			   _prima,
			   _cod_cober_reas,
			   _no_unidad,
			   _orden,
			   _porc_partic_prima
		  from emifacon
		 where no_poliza = a_no_poliza
		   and no_endoso = a_no_endoso

		insert into tmp_reas
		values (a_no_poliza,a_no_endoso,_no_unidad, _cod_cober_reas, _cod_contrato, _prima, _prima, 0, 0, _orden,_porc_partic_prima);
	end foreach
end if

return 0,'Inserción Exitosa';
end
end procedure 