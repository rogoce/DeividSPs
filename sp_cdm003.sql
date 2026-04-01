-- Analisis de la Ruta de Un Cobrador por Dia


-- Creado    : 17/10/2006 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

create procedure sp_cdm003(a_cod_cobrador char(3), a_fecha date)

define _dia			smallint;
define _mes 		smallint;
define _ano 		smallint;

define _cod_cliente	char(10);
define _nombre		char(50);
define _total		dec(16,2);
define _id_abandono	smallint;
define _fecha_ini	date;
define _fecha_fin	date;
define _id_usuario	

define _motiv_aban	char(50);

define _nombre_ruta	char(50);


let _dia = day(a_fecha);
let _mes = month(a_fecha);
let _ano = year(a_fecha);

foreach
 select id_cliente,
        nombre_cliente,
		total,
		id_motivo_abandono,
		fecha_inicio,
		fecha_final,
		id_usuario
   into	_cod_cliente,
        _nombre,
		_total,
		_id_abandono,
		_fecha_ini,
		_fecha_fin
   from cdmtransaccionesbk
  where year(fecha_inicio)  = _ano
    and month(fecha_inicio) = _mes
	and day(fecha_inicio)   = _dia
  order by 
		select nombre
		  into _motiv_aban
		  from cdmmotivoabandono
		 where id_motivo_abandono = _id_abandono;
		 
		  	
		return 		


end foreach



end procedure