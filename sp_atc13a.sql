-- Retorna la diferencia en minutos entre dos fecha

-- Creado    : 25/07/2011 - Autor: Roman Gordon

drop procedure sp_atc13a;

create procedure sp_atc13a()
 returning datetime year to fraction(5),
		   datetime year to fraction(5),
		   smallint,
		   smallint,
		   smallint;
		   
define _fecha_inicio	datetime year to fraction(5);
define _fecha_fin		datetime year to fraction(5);
define _minutos_char	char(15);
define _horas_char		char(15);
define _time_char		char(15);
define _cod_operativo	char(10);
define _time			interval hour to minute;
define _hora			interval hour to hour;
define _minuto			interval minute to minute;
define _minuto_interv	smallint;
define _hora_int		smallint;
define _min_int			smallint;
define _minutos_pas		smallint;
define _duracion		smallint;
define _cont			smallint;

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_atc13.trc"; 
--trace on;

foreach
	select cod_operativo,
		   fecha_inicio,
		   fecha_fin,
		   duracion
	  into _cod_operativo,
	  	   _fecha_inicio,
		   _fecha_fin,
		   _duracion
	  from atcopera
	 where fecha_inicio > date('01/01/2000') and fecha_fin > date('01/01/2000')
	   --and duracion > 180
	 order by fecha_inicio

	call sp_sis390(_fecha_inicio,_fecha_fin) returning _time;
	let _minutos_pas 	= 0;
	let _time_char		= _time;
	let _hora 			= _time;
	let _horas_char		= _hora;
	let _horas_char		= trim(_horas_char);
	let _hora_int 		= _horas_char;

	if _hora_int > 0 then
		let _minutos_char	= _time_char[5,6];
		let _minutos_pas	= _hora_int * 60;		
	else		
		let _minuto 		= _time;
		let _minutos_char	= _minuto; 		
	end if	
	
	let _min_int 		= _minutos_char;
	
	if _min_int = 0 then
		let _min_int = 1;
	end if

	let _minuto_interv	= _min_int + _minutos_pas;

	update atcopera set duracion = _minuto_interv where cod_operativo = _cod_operativo; 

   	--let _minuto_interv = _minuto + (_hora * 60);
	--let _minutos_pas = cast(_minuto_interv as integer);

	return _fecha_inicio,
		   _fecha_fin,
		   _hora_int,
		   _min_int,
		   _minuto_interv with resume;
end foreach
end procedure; 
