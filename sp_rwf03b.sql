-- WorkFlow - Busqueda por Tercero

-- Creado    : 14/07/2005 - Autor: Amado Perez  
			    
drop procedure sp_rwf03b;

create procedure "informix".sp_rwf03b(a_tipo char(1), a_valor varchar(100))
returning char(20),
          date,
		  date,
		  date,
		  char(20),
		  char(5),
		  char(10),
		  char(50),
		  char(100),
		  char(100),
		  char(20),
		  char(8),
		  char(10),
		  int,
		  char(100),
		  char(10);

define _no_reclamo 			char(10);
define _numrecla   			char(20);
define _fecha_siniestro		date;
define _fecha_tramite      	date;
define _fecha_reclamo      	date;
define _no_documento		char(20);
define _no_unidad			char(5);
define _no_tramite			char(10);
define _cod_ajustador      	char(10);
define _cod_asegurado      	char(10);
define _cod_conductor      	char(10);
define _nombre_asegurado   	char(100);
define _nombre_ajustador  	char(100);
define _nombre_conductor  	char(100);
define _nombre_tercero      char(100);
define _fecha				date;
define _user_windows		char(20);
define _user_deivid			char(8);
define _incidente           int;
define _cod_tercero         char(10);

create temp table tmp_filtro(
	no_reclamo	char(10)
	) with no log;

create temp table tmp_reclamo(
	numrecla        char(20),
	fecha_siniestro date,
	fecha_tramite   date,
	fecha_reclamo	date,
	no_documento	char(20),
	no_unidad		char(5),
	no_tramite		char(10),
	cod_ajustador	char(3),
	cod_asegurado   char(10),
	cod_conductor	char(10),
	no_reclamo		char(10),
	incidente		integer,
	cod_tercero     char(10)
	) with no log;

SET ISOLATION TO DIRTY READ;

if a_tipo = "1" then -- Por Fecha del Siniestro

	let _fecha = date(a_valor);

	foreach
	 select no_reclamo
	   into _no_reclamo
	   from recrcmae
	  where fecha_siniestro = _fecha
        and actualizado     = 1

		insert into tmp_filtro
		values (_no_reclamo);

	end foreach

elif  a_tipo = "2" THEN -- Por Nombre del Conductor

	let a_valor = "%" || a_valor || "%";

	foreach
	 select r.no_reclamo
	   into _no_reclamo
	   from recrcmae r, cliclien c
	  where r.cod_conductor = c.cod_cliente
        and actualizado     = 1
		and c.nombre        like a_valor

		insert into tmp_filtro
		values (_no_reclamo);

	end foreach

elif  a_tipo = "3" THEN -- Por Parte Policivo

	foreach
	 select no_reclamo
	   into _no_reclamo
	   from recrcmae
	  where parte_policivo  = a_valor
        and actualizado     = 1

		insert into tmp_filtro
		values (_no_reclamo);

	end foreach

elif  a_tipo = "4" THEN -- Por Placa

	foreach
	 select r.no_reclamo
	   into _no_reclamo
	   from recrcmae r, emivehic v
	  where r.no_motor      = v.no_motor
        and r.actualizado   = 1
		and (v.placa		= a_valor or
		     v.placa_taxi   = a_valor)			  

		insert into tmp_filtro
		values (_no_reclamo);

	end foreach

elif  a_tipo = "5" THEN -- Por Numero de Resolucion

	foreach
	 select no_reclamo
	   into _no_reclamo
	   from recrcmae
	  where no_resolucion   = a_valor
        and actualizado     = 1

		insert into tmp_filtro
		values (_no_reclamo);

	end foreach

elif  a_tipo = "6" THEN -- Por Fecha de Audiencia

	let _fecha = date(a_valor);

	foreach
	 select no_reclamo
	   into _no_reclamo
	   from recrcmae
	  where fecha_audiencia = _fecha
        and actualizado     = 1

		insert into tmp_filtro
		values (_no_reclamo);

	end foreach
elif  a_tipo = "7" THEN -- Por Asegurado

	let a_valor = "%" || a_valor || "%";

	foreach
	 select r.no_reclamo
	   into _no_reclamo
	   from recrcmae r, cliclien c
	  where r.cod_asegurado = c.cod_cliente
        and actualizado     = 1
		and c.nombre        like a_valor

		insert into tmp_filtro
		values (_no_reclamo);

	end foreach

end if

foreach
 select no_reclamo
   into _no_reclamo
   from tmp_filtro

	foreach  
	select a.numrecla,
	       a.fecha_siniestro,
		   a.fecha_tramite,
		   a.fecha_reclamo,
		   a.no_documento,
		   a.no_unidad,
		   a.no_tramite,
		   a.ajust_interno,
		   a.cod_asegurado,
		   a.cod_conductor,
		   b.no_incidente,
		   b.cod_tercero
	  into _numrecla,
	       _fecha_siniestro,
		   _fecha_tramite,
		   _fecha_reclamo,
		   _no_documento,
		   _no_unidad,
		   _no_tramite,
		   _cod_ajustador,
		   _cod_asegurado,
		   _cod_conductor,
		   _incidente,
		   _cod_tercero
	  from recrcmae	a, recterce b
	 where a.no_reclamo = _no_reclamo
	   and b.no_reclamo = a.no_reclamo
--	   and b.no_incidente IS NOT NULL
--	   and b.no_incidente <> 0

	insert into tmp_reclamo
	values(
	_numrecla,
	_fecha_siniestro,
	_fecha_tramite,
	_fecha_reclamo,
	_no_documento,
	_no_unidad,
	_no_tramite,
	_cod_ajustador,
	_cod_asegurado,
	_cod_conductor,
	_no_reclamo,
	_incidente,
	_cod_tercero
	);
	end foreach

end foreach

foreach
 select numrecla,
		fecha_siniestro,
		fecha_tramite,
		fecha_reclamo,
		no_documento,
		no_unidad,
		no_tramite,
		cod_ajustador,
		cod_asegurado,
		cod_conductor,
		no_reclamo,
		incidente,
		cod_tercero
   into _numrecla,
		_fecha_siniestro,
		_fecha_tramite,
		_fecha_reclamo,
		_no_documento,
		_no_unidad,
		_no_tramite,
		_cod_ajustador,
		_cod_asegurado,
		_cod_conductor,
		_no_reclamo,
		_incidente,
		_cod_tercero
   from tmp_reclamo
  order by fecha_siniestro, numrecla

	select nombre
	  into _nombre_asegurado
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	select nombre
	  into _nombre_conductor
	  from cliclien
	 where cod_cliente = _cod_conductor;

	select nombre
	  into _nombre_tercero
	  from cliclien
	 where cod_cliente = _cod_tercero;

	select nombre,
		   usuario	
	  into _nombre_ajustador,
	       _user_deivid
	  from recajust
	 where cod_ajustador = _cod_ajustador;

	select windows_user
	  into _user_windows
	  from insuser
	 where usuario = _user_deivid;

	return _numrecla,
		   _fecha_siniestro,
		   _fecha_tramite,
		   _fecha_reclamo,
		   _no_documento,
		   _no_unidad,
		   _no_tramite,
		   _nombre_ajustador,
		   _nombre_asegurado,
		   _nombre_conductor,
		   _user_windows,
		   _user_deivid,
		   _no_reclamo,
		   _incidente,
		   _nombre_tercero,
		   _cod_tercero
		   with resume;

end foreach

drop table tmp_filtro;
drop table tmp_reclamo;

end procedure;
