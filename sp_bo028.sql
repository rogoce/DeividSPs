-- Analisis de Productividad del Departamento de Computo

-- Creado    : 25/04/2006 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo028;

create procedure sp_bo028()
returning integer,
          char(50);

define _no_caso			char(10);
define _user			char(10);
define _cantidad		smallint;
define _fecha			datetime year to minute;
define _fecha_inicio	datetime year to minute;
define _fecha_solucion	datetime year to minute;
define _prioridad		char(10);
define _ano				smallint;
define _mes				smallint;
define _completado		smallint;

define _fecha_desde		datetime year to minute;
define _fecha_hasta		datetime year to minute;
define _tiempo_usado   	interval day(3) to minute;
define _tiempo_char		char(10);

define _dias_usados		dec(16,2);
define _hora_usados		dec(16,2);
define _minu_usados		dec(16,2);
define _temp_usados		dec(16,2);
define _tiempo_total	dec(16,2);

define _medida_tiempo	smallint;
define _medida_estimada	char(10);
define _medida_usada	char(10);

define _productividad	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_bo028.trc";

let _prioridad = "Alta";

delete from deivid_bo:bohelpdesk;

foreach
 select	no_caso,
        fecha,
	fecha_inicio,
	fecha_solucion,
	user_solucion,
	medida_tiempo
   into	_no_caso,
        _fecha,
	_fecha_inicio,
	_fecha_solucion,
	_user,
	_medida_tiempo
   from helpdesk
  order by no_caso
--  where no_caso = "00617"

	if  _user is null then
		let _completado = 0;
		let _ano = year(_fecha);
		let _mes = month(_fecha);
		let _fecha_inicio = _fecha;
		let _fecha_solucion = today;
		let _user = "Pendiente";
	else
		let _completado = 1;
		let _ano = year(_fecha_inicio);
		let _mes = month(_fecha_inicio);
	end if

	select count(*)
	  into _cantidad
	  from helpdesk2
	 where no_caso = _no_caso;

	let _cantidad = 0;

	if _cantidad = 0 then

		-- Convierte la diferencia en tiempos en campos integer

		let _fecha_desde  = _fecha_inicio;
		let _fecha_hasta  = _fecha_solucion;

		let _tiempo_usado = (_fecha_hasta - _fecha_desde);
		let _tiempo_char  = _tiempo_usado;
		let _dias_usados  = _tiempo_char[1,4];
		let _hora_usados  = _tiempo_char[6,7];
		let _minu_usados  = _tiempo_char[9,10];

	else

	end if

if _dias_usados = 0 and 
   _hora_usados = 0 and
   _minu_usados = 0 then
	let _hora_usados = 24;
end if

if _medida_tiempo is null then
	if _dias_usados <> 0 then
		let _medida_tiempo = 1;
	elif _hora_usados <> 0 then
		let _medida_tiempo = 2;
	elif _minu_usados <> 0 then
		let _medida_tiempo = 3;
	end if
end if

if _medida_tiempo = 1 then -- Dias

	let _temp_usados  = _minu_usados / 60; -- Minutos a hora
	let _hora_usados  = _hora_usados + _temp_usados;
	let _temp_usados  = _hora_usados / 24; -- Horas a Dias
	let _dias_usados  = _dias_usados + _temp_usados;	
	let _tiempo_total = _dias_usados;
	let _medida_usada = "Dias";

elif _medida_tiempo = 2 then -- Horas

	let _temp_usados  = _minu_usados / 60; -- Minutos a hora
	let _hora_usados  = _hora_usados + _temp_usados;
	let _temp_usados  = _dias_usados * 24; -- Dias a horas
	let _hora_usados  = _hora_usados + _temp_usados;
	let _tiempo_total = _hora_usados;
	let _medida_usada = "Horas";
	
elif _medida_tiempo = 3 then -- Minutos

	let _temp_usados  = _dias_usados * 24; -- Dias a horas
	let _hora_usados  = _hora_usados + _temp_usados;
	let _temp_usados  = _hora_usados * 60; -- Horas a minutos
	let _minu_usados  = _minu_usados + _temp_usados;
	let _tiempo_total = _minu_usados;
	let _medida_usada = "Minutos";

end if


	let _productividad = _tiempo_total / _tiempo_total * 100;
--	let _productividad = 100;

	if _completado = 0 then
		let _tiempo_total = 0;
	end if

	insert into deivid_bo:bohelpdesk
	values(
	_no_caso, 
	_fecha_inicio, 
	_fecha_solucion, 
	_user, 
	_prioridad, 
	_tiempo_total, 
	_medida_usada, 
	_tiempo_total, 
	_medida_usada,
	_productividad,
	_ano,
	_mes,
	_completado
	);

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure


