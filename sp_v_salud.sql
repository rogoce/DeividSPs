drop procedure sp_v_salud;
create procedure sp_v_salud(a_periodo char(7))
	returning integer,varchar(250);

BEGIN

define _no_reclamo			char(10);
define _no_poliza			char(10);
define _no_tranrec			char(10);
define _renglon				integer;
define _contador            integer;
define _cod                 smallint;

set isolation to dirty read;

let _no_poliza  = null;
let _no_reclamo = null;
let _no_tranrec = null;

drop table if exists tmp_regi;
create temp table tmp_regi(
codigo	smallint) with no log;

insert into tmp_regi(codigo)
values(1);

foreach
	select codigo
	  into _cod
	  from tmp_regi
	  
	--produccion
	foreach with hold
		select t.no_poliza
		  into _no_poliza
		  from endedmae e, emifacon t
		 where e.no_poliza = t.no_poliza
		   and e.no_endoso = t.no_endoso
		   and e.actualizado = 1
		   and e.periodo = a_periodo
		   and e.no_documento[1,2] = '18'
		   and t.porc_partic_prima not in(30,70)
	end foreach
	
	if _no_poliza is null then
		return 0,"(1)- No hay registros a procesar" with resume;
	else
		let _renglon = sp_arregla_emifacon_salud(a_periodo);
		return 1,"(1)- Actualizacion Exitosa" with resume;
	end if
	--reclamos
	foreach with hold
		select c.no_reclamo
		  into _no_reclamo
		  from recrcmae r, recreaco c
		 where r.no_reclamo = c.no_reclamo
		   and r.actualizado = 1
		   and r.periodo = a_periodo
		   and r.numrecla[1,2] = '18'
		   and c.porc_partic_prima not in(30,70)
	end foreach
	
	if _no_reclamo is null then
		return 0,"(2)- No hay registros a procesar" with resume;
	else
		let _renglon = sp_arregla_recreaco_salud(a_periodo);
		return 1,"(2)- Actualizacion Exitosa" with resume;
	end if
	--transacciones de reclamos
	foreach with hold
		select c.no_tranrec
		  into _no_tranrec
		  from rectrmae r, rectrrea c
		 where r.no_tranrec = c.no_tranrec
		   and r.actualizado = 1
		   and r.periodo = a_periodo
		   and r.numrecla[1,2] = '18'
		   and c.porc_partic_prima not in(30,70)
	end foreach
	if _no_tranrec is null then
		return 0,"(3)- No hay registros a procesar" with resume;
	else
		let _renglon = sp_arregla_rectrrea_salud(a_periodo);
		return 1,"(3)- Actualizacion Exitosa" with resume;
	end if
	
end foreach
end
end procedure;