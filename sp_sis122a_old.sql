-- verificar % para descuento buena exp
--
-- creado    : 20/03/2014 - Autor: Roman Gordon
-- sis v.2.0

drop procedure sp_sis122a;

create procedure "informix".sp_sis122a(a_no_remesa char(10), a_renglon integer)
returning	integer,
			char(100);

define _error_desc				char(100);
define _no_poliza				char(10);
define _cod_contrato			char(5);
define _cod_cober_reas			char(3);
define _cod_ramo				char(3);
define _sum_porc_proporcion		dec(9,6);
define _sum_porc_part_prima		dec(9,6);
define _porc_partic_prima		dec(9,6);
define _porc_proporcion			dec(9,6);
define _prima_tot				dec(16,2);
define _prima					dec(16,2);
define _es_terremoto			smallint;
define _cantidad				smallint;
define _bouquet					smallint;
define _orden					smallint;
define _cnt						smallint;
define _error_isam				integer;
define _error					integer;

begin
on exception set _error,_error_isam,_error_desc	
	--drop table tmp_reas;
	return _error,_error_desc;
end exception

set isolation to dirty read;

--set debug file to "sp_sis122.trc"; 
--trace on;			

create temp table tmp_reas(
cod_cober_reas	char(3),
cod_contrato	char(5),
prima_tot		dec(16,2),
prima_rea		dec(16,2),
es_terremoto   	smallint,
bouquet			smallint,
orden			smallint,
porc_partic_prima	dec(9,6),
porc_proporcion		dec(9,6)
) with no log;

select no_poliza,
	   prima_neta
  into _no_poliza,
	   _prima
  from cobredet
 where no_remesa = a_no_remesa
   and renglon   = a_renglon;
   
select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = _no_poliza;


let _cantidad = 0;
let _prima_tot = _prima;

if _cod_ramo in ('001','003') then
	foreach
		select cod_contrato,
			   cod_cober_reas,
			   porc_partic_prima
		  into _cod_contrato,
			   _cod_cober_reas,
			   _porc_partic_prima
		  from cobreaco
		 where no_remesa = a_no_remesa
		   and renglon = a_renglon
		 group by cod_contrato, cod_cober_reas,porc_partic_prima
		
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
		values (_cod_cober_reas, _cod_contrato, _prima, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima,0);
		
		let _prima = 0.00;
	end foreach

	-- Cuando el Contrato Es Bouquet

	let _bouquet = 1;
	
	select count(*)
	  into _cnt
	  from tmp_reas;
	
	update tmp_reas
	   set prima_tot = _prima_tot/_cnt;
	
	let _prima_tot = 0;
	
	foreach
		select cod_contrato,
			   porc_partic_prima,
			   sum(prima_tot)
		  into _cod_contrato,
			   _porc_partic_prima,
			   _prima
		  from tmp_reas
		-- where bouquet = 1
		 group by cod_contrato,porc_partic_prima
		 order by cod_contrato,porc_partic_prima

		select count(*)
		  into _cantidad
		  from tmp_reas
		 where cod_contrato = _cod_contrato
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
			values (_cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima,0);

		end if

		update tmp_reas
		   set prima_rea    = _prima * .70
		 where cod_contrato = _cod_contrato
		   and es_terremoto = 0;

		select count(*)
		  into _cantidad
		  from tmp_reas
		 where cod_contrato = _cod_contrato
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
			values (_cod_cober_reas, _cod_contrato, 0.00, 0.00, _es_terremoto, _bouquet, 1,_porc_partic_prima,0);

		end if

		update tmp_reas
		   set prima_rea    = _prima * .30
		 where cod_contrato = _cod_contrato
		   and es_terremoto = 1;

	end foreach
	
	select sum(prima_rea)
	  into _prima_tot
	  from tmp_reas;
	
	foreach
		select cod_cober_reas,
			   sum(prima_rea)
		  into _cod_cober_reas,
			   _prima
		  from tmp_reas
		 group by 1
	--	 where bouquet = 0
		
		let _porc_proporcion = _prima / _prima_tot * 100;
		
		update tmp_reas
		   set porc_proporcion      = _porc_proporcion
		 where cod_cober_reas = _cod_cober_reas;
	end foreach
else
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
		 where no_remesa = a_no_remesa
		   and renglon = a_renglon
		
		insert into tmp_reas
		values (_cod_cober_reas, _cod_contrato, 0.00, 0.00, 0, 0, 1,_porc_partic_prima,_porc_proporcion);
	end foreach
end if

let _sum_porc_proporcion = 0.00;
foreach
	select cod_cober_reas,
		   porc_proporcion
	  into _cod_cober_reas,
		   _porc_proporcion
	  from tmp_reas
	 group by 1,2
--	 where bouquet = 0
	
	let _sum_porc_proporcion = _sum_porc_proporcion +_porc_proporcion;
end foreach

if _sum_porc_proporcion > 100 then
	select sum(porc_partic_prima)
	  into _sum_porc_part_prima
	  from tmp_reas;
	  
	foreach
		select cod_cober_reas,
			   sum(porc_partic_prima)
		  into _cod_cober_reas,
			   _porc_partic_prima
		  from tmp_reas
		 group by 1
		
		let _porc_proporcion = _porc_partic_prima/_sum_porc_part_prima * 100;
		
		update tmp_reas
		   set porc_proporcion = _porc_proporcion
		 where cod_cober_reas = _cod_cober_reas;
	end foreach
end if

return 0,'InserciÃ³n Exitosa';
end
end procedure;