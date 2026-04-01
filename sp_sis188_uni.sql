

drop procedure sp_sis188_uni;
create procedure sp_sis188_uni(a_no_poliza char(10),a_no_unidad char(5))
returning integer, char(250);

define _mensaje				char(250);
define _no_documento		char(21);
define _cod_tipoprod        char(3);
define _cod_ramo			char(5);
define _no_unidad			char(5);
define ls_cober_reas,_cod_no_renov char(3);
define _porc_cober_reas		dec(9,6);
define _limite_2,_limite_1,_suma_tot	dec(16,2);
define _contador_ret		smallint;
define _ramo_sis			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _flag                integer;
define _cnt                 integer;
define _porc_coas_ancon		dec(5,2);

set isolation to dirty read;

{if a_no_poliza = '1409115' then
	SET DEBUG FILE TO "sp_sis188.trc";
	trace on;
end if}
--set debug file to "sp_sis188.trc";
--trace on;

begin
on exception set _error,_error_isam,_mensaje
 	return _error,_mensaje;
end exception

-- Lectura de la DistribuciÃ³n de Reaseguro de la PÃ³liza
select no_documento,
	   cod_ramo,
	   cod_no_renov,
	   cod_tipoprod
  into _no_documento,
	   _cod_ramo,
	   _cod_no_renov,
	   _cod_tipoprod
  from emipomae
 where no_poliza = a_no_poliza;
 
select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;

if _ramo_sis <> 1 then
	return 0,"";
end if

drop table if exists tmp_dist_rea_u;
create temp table tmp_dist_rea_u(
no_poliza		char(10),
cod_cober_reas	char(3),
suma_cob_reas   dec(16,2)) with no log;
	
let _suma_tot = 0;
let ls_cober_reas = null;
   
foreach
	select c.cod_cober_reas
	  into ls_cober_reas
	  from emipocob e, prdcober c 
	  where e.no_poliza = a_no_poliza
		and e.no_unidad = a_no_unidad
		and c.cod_cobertura = e.cod_cobertura
	  group by c.cod_cober_reas
	  order by c.cod_cober_reas
	
	let _suma_tot = 0;
	foreach
		select max(limite_1), max(limite_2)
		  into _limite_1,_limite_2
		  from emipocob e, prdcober c
		 where e.no_poliza = a_no_poliza
		   and e.no_unidad = a_no_unidad
		   and c.cod_cober_reas = ls_cober_reas
		   and c.cod_cobertura = e.cod_cobertura
		 group by c.cod_cober_reas,e.cod_cobertura
		 
		if ls_cober_reas in('002','033') then	--rc
			if _limite_2 > _limite_1 then
				let _suma_tot = _suma_tot + _limite_2;
			elif _limite_1 > _limite_2 then
				let _suma_tot = _suma_tot + _limite_1;
			end if
		elif ls_cober_reas in('031','034') then	--casco
			let _suma_tot = _limite_1;
			exit foreach;
		elif ls_cober_reas in('045','047') then	--Varios
			let _suma_tot = _limite_2;
			exit foreach;
		elif ls_cober_reas in('044','046') then	--Otros
			if _limite_2 > _limite_1 then
				let _suma_tot = _suma_tot + _limite_2;
			elif _limite_1 > _limite_2 then
				let _suma_tot = _suma_tot + _limite_1;
			end if
		else
			let _suma_tot = 0;
		end if
	end foreach
	
	insert into tmp_dist_rea_u(
			no_poliza,
			cod_cober_reas,
			suma_cob_reas)
	values	(a_no_poliza,
			ls_cober_reas,
			_suma_tot);
			
	let _suma_tot = 0;			
end foreach
let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;

end
end procedure 
                                                                                                                                                       
