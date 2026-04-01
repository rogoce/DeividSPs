-- Procedimiento que Determina el Reaseguro de una unidad con respecto a la prima total de la póliza
-- Creado    : 27/08/2015 - Autor: Román Gordon

drop procedure sp_sis188e;
create procedure sp_sis188e(a_no_poliza char(10), a_no_unidad char(5))
returning integer, char(250);

define _mensaje				char(250);
define _no_documento		char(21);
define _cod_ramo			char(5);
define _no_unidad			char(5);
define _cod_cober_reas		char(3);
define _cod_no_renov		char(3);
define _porc_cober_reas		dec(9,6);
define _porc_proporcion		dec(9,6);
define _proporcion			dec(9,6);
define _prima_cober_reas	dec(16,2);
define _prima_total			dec(16,2);
define _contador_ret		smallint;
define _ramo_sis			smallint;
define _orden				smallint;
define _error_isam			integer;
define _error				integer;
define _flag                integer;
define _cnt                 integer;

set isolation to dirty read;

--set debug file to "sp_sis188.trc";
--trace on;

begin

on exception set _error,_error_isam,_mensaje
 	return _error,_mensaje;
end exception

drop table if exists tmp_dist_rea;
create temp table tmp_dist_rea(
no_poliza		char(10),
no_unidad		char(5),
cod_cober_reas	char(3),
porc_cober_reas	dec(9,6)) with no log;

-- Lectura de la Distribución de Reaseguro de la Póliza
select no_documento,
	   cod_ramo,
	   cod_no_renov
  into _no_documento,
	   _cod_ramo,
	   _cod_no_renov
  from emipomae
 where no_poliza = a_no_poliza;

select ramo_sis
  into _ramo_sis
  from prdramo
 where cod_ramo = _cod_ramo;
 
let _prima_total = 0;

select sum(prima_neta)
  into _prima_total
  from emipocob
 where no_poliza = a_no_poliza
   and no_unidad = a_no_unidad;

let _cod_cober_reas = null;
   
foreach
	select p.cod_cober_reas,
		   sum(e.prima_neta)
	  into _cod_cober_reas,
		   _prima_cober_reas
	  from emipocob e, prdcober p
	 where e.no_poliza = a_no_poliza
	   and e.no_unidad = a_no_unidad
	   and p.cod_cobertura = e.cod_cobertura
	 group by p.cod_cober_reas
	
	let _proporcion = 0.00;
	if _prima_total is null then
		let _prima_total = 0.00;
	end if			
	
	if _prima_total <> 0 then
		let _proporcion = (_prima_cober_reas/_prima_total) * 100;
	else
		select sum(e.prima_neta)
		  into _prima_total
		  from endedcob e, endedmae t
		 where e.no_poliza = t.no_poliza
		   and e.no_endoso = t.no_endoso
		   and t.no_poliza = a_no_poliza
		   and e.no_unidad = a_no_unidad
		   and t.actualizado = 1;

		if _prima_total is null then
			let _prima_total = 0.00;
		end if

		if _prima_total <> 0 then
			select sum(e.prima_neta)
			  into _prima_cober_reas
			  from endedcob e, prdcober p, endedmae t
			 where e.no_poliza = t.no_poliza
               and e.no_endoso = t.no_endoso
               and p.cod_cobertura = e.cod_cobertura
               and t.actualizado = 1
               and e.no_poliza = a_no_poliza
			   and e.no_unidad = a_no_unidad
			   and p.cod_cober_reas = _cod_cober_reas
		     group by p.cod_cober_reas;

			let _proporcion = (_prima_cober_reas/_prima_total) * 100;
		end if
		let _prima_total = 0.00;
	end if

	if _proporcion is null then
		let _proporcion = 0.00;
	end if

	insert into tmp_dist_rea(
			no_poliza,
			no_unidad,
			cod_cober_reas,
			porc_cober_reas)
	values	(a_no_poliza,
			a_no_unidad,
			_cod_cober_reas,
			_proporcion);			
end foreach

if _cod_cober_reas is null then
	foreach
		select p.cod_cober_reas,
			   sum(e.prima_neta)
		  into _cod_cober_reas,
			   _prima_cober_reas
		  from endedcob e, prdcober p
		 where e.no_poliza = a_no_poliza
		   and e.no_unidad = a_no_unidad
		   and e.no_endoso = '00000'
		   and p.cod_cobertura = e.cod_cobertura
		 group by p.cod_cober_reas
		
		let _proporcion = 0.00;
		
		if _prima_total <> 0 then
			let _proporcion = (_prima_cober_reas/_prima_total) * 100;
		end if
		
		insert into tmp_dist_rea(
				no_poliza,
				no_unidad,
				cod_cober_reas,
				porc_cober_reas)
		values	(a_no_poliza,
				a_no_unidad,
				_cod_cober_reas,
				_proporcion);			
	end foreach
end if

foreach
	select sum(porc_cober_reas),
		   cod_cober_reas
	  into _porc_cober_reas,
		   _cod_cober_reas
	  from tmp_dist_rea
	 where no_poliza = a_no_poliza
	   and no_unidad = a_no_unidad
	 group by cod_cober_reas
    having sum(porc_cober_reas) = 0
	 
	if _porc_cober_reas = 0 then

		select sum(e.prima_neta)
		  into _prima_cober_reas
		  from endedcob e, prdcober p, endedmae t
		 where e.no_poliza = t.no_poliza
           and e.no_endoso = t.no_endoso
           and p.cod_cobertura  = e.cod_cobertura
           and t.actualizado = 1
           and e.no_poliza = a_no_poliza
		   and e.no_unidad = a_no_unidad
		   and p.cod_cober_reas = _cod_cober_reas
	     group by p.cod_cober_reas;

		if _prima_cober_reas = 0 then
			--if _cod_ramo not in ('001','003') then
			update tmp_dist_rea
			   set porc_cober_reas = 100
			 where no_poliza       = a_no_poliza
			   and cod_cober_reas  = _cod_cober_reas;
			{else
				delete from tmp_dist_rea
				 where no_poliza       = a_no_poliza
				   and cod_cober_reas  = _cod_cober_reas;
			end if}
		end if
	end if
end foreach
let _cnt = 0;
select count(*)
  into _cnt
  from deivid_cob:provrea_poliza
 where no_poliza = a_no_poliza;
 
if _cnt is null then
	let _cnt = 0;
end if 
  
if _cod_no_renov = '039' or _cnt > 0 then
						 
	update tmp_dist_rea
	   set porc_cober_reas    = 100
	 where no_poliza    = a_no_poliza
	   and cod_cober_reas in ('002','033');

	delete from tmp_dist_rea
	 where cod_cober_reas not in ('002','033');
end if

if a_no_poliza in ('1163548') then
	delete from tmp_dist_rea
	 where cod_cober_reas in ('021');
end if

if _cod_ramo in ('001','003') then
	select sum(porc_cober_reas)
	  into _porc_proporcion
	  from tmp_dist_rea
	 where no_poliza = a_no_poliza;

	if _porc_proporcion <> 100 then
		update tmp_dist_rea
		   set porc_cober_reas    = 70
		 where no_poliza    = a_no_poliza
		   and cod_cober_reas in ('001','003');

		update tmp_dist_rea
		   set porc_cober_reas    = 30
		 where no_poliza    = a_no_poliza
		   and cod_cober_reas in ('021','022');
	end if
end if

if a_no_poliza in ('1369754','1052307','1005958','1162825','1162789','1163463','1052507','960014','1006004','1005927','1005985','1005991','1005987','1005947','1005985','957768',
'1036019','1011079','1011217','1011415','1011418','1011529','1021351','1030452','1030457','1030458','1030463','1030467','1030471','1030472','1030473','1030474','1163655','1163655',	
'1162851','1163461','1163233','1163588','1163586','1052945','1177412','1163725','1163025','1052599','1162726','1163661','1052550','1163531','1163723','1052305','1149361','1163017',
'1163345','1109618','1163719','1162890','1163529',	'1128052','1162857','1162775','1162748','1152040','479312','1149361','1161754','726412','1128731','1155320','1157346','1197627',
'1144792','1005929','1005932','1011251','1011378','1052402','1052534','1052604','1052686','1052692','1053212','1065590','1128052','1162725','1162754','1162779','1162791','1162865',
'1162888','1162894','1162901','1163007','1163054','1163092','1163106','1163169','1163217','1163297','1163300','1163301','1163347','1163401','1163509','1163571','1163574','1188060',
'1188062','1188069','1163662','1162787','1163302','1163400','1279212','1279507','1279621','1279627','1279620','1279454','1279256','1279868','1279801','1279651','1279466','1163069',
'1420589','1307634','1295763','1005988','1356700','1005988','1356700','1420050','1475917','1280198','1354356') then
	delete from tmp_dist_rea
	 where cod_cober_reas not in ('002','033');
end if

let _mensaje = 'Actualizacion Exitosa ...';
return 0, _mensaje;
end
end procedure;
