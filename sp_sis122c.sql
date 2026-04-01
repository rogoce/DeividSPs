-- verificar % para descuento buena exp
-- execute procedure sp_sis122c('','')
-- creado    : 20/03/2014 - Autor: Roman Gordon
-- sis v.2.0

drop procedure sp_sis122c;
create procedure sp_sis122c(a_no_poliza char(10), a_no_unidad char(5))
returning	integer,
			char(100);


define _error_desc			char(100);
define _cod_contrato		char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_endomov			char(3);
define _cod_ramo			char(3);
define _porc_partic_prima	dec(9,6);
define _prima_tot			dec(16,2);
define _porc_inc			dec(16,2);
define _porc_ter			dec(16,2);
define _prima				dec(16,2);
define _es_terremoto		smallint;
define _cnt_existe			smallint;
define _no_cambio			smallint;
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

--set debug file to "sp_sis122c.trc"; 
--trace on;			
drop table if exists tmp_reas;
drop table if exists tmp_unidad;


create temp table tmp_reas(
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

select max(no_cambio)
  into _no_cambio
  from emireaco
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

if _no_cambio is null then
	let _no_cambio = 0;
end if

if _cod_ramo in ('001','003') then
	foreach
		select cod_contrato,
			   cod_cober_reas,
			   no_unidad,
			   porc_partic_prima
		  into _cod_contrato,
			   _cod_cober_reas,
			   _no_unidad,
			   _porc_partic_prima
		  from emireaco
		 where no_poliza = a_no_poliza
		   and no_unidad = a_no_unidad
		   and no_cambio = _no_cambio

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
		values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);
	end foreach

	--Cuando el Contrato Es Bouquet
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
		  into _cnt_existe
		  from reacocob c, reacobre r
		 where c.cod_cober_reas = r.cod_cober_reas
		   and c.cod_contrato = _cod_contrato
		   and r.cod_ramo = _cod_ramo
		   and es_terremoto = 1;

		if _cnt_existe is null then
			let _cnt_existe = 0;
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
			values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);
		end if

		select count(*)
		  into _cantidad
		  from tmp_reas
		 where no_unidad    = _no_unidad
		   and cod_contrato = _cod_contrato
		   and es_terremoto = 1;

	   	if _cantidad = 0 and _cnt_existe > 0 then
			if _serie >= 2015 then
				let _porc_partic_prima = 100;
			end if

			foreach
				select cod_cober_reas,
					   es_terremoto
				  into _cod_cober_reas,
					   _es_terremoto
				  from reacobre
				 where cod_ramo     = _cod_ramo
				   and es_terremoto = 1
				exit foreach;
			end foreach

			insert into tmp_reas
			values (_no_unidad, _cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima);

		end if
	end foreach
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
		values (_no_unidad, _cod_cober_reas, _cod_contrato, _prima, _prima, 0, 0, _orden,_porc_partic_prima);
	end foreach
end if

if a_no_poliza = '1118817' then
	delete from tmp_reas
	 where cod_cober_reas <> '001'
	   and cod_contrato <> '00663';
end if

return 0,'Inserción Exitosa';
end
end procedure 