-- Reporte para estadistica de las aprobaciones o rechazo del proyecto Control Firma Emision

-- Creado    : 29/11/2011 - Autor: Armando Moreno

drop procedure sp_atc13;

create procedure sp_atc13(a_fecha_desde	datetime year to fraction(5),a_fecha_hasta	datetime year to fraction(5))

 returning smallint;
		   
define _fecha_inicio	datetime year to fraction(5);
define _fecha_fin		datetime year to fraction(5);
define _minutos_char	char(15);
define _horas_char		char(15);
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

call sp_sis390(a_fecha_desde,a_fecha_hasta) returning _time;
let _minutos_pas = 0;
let _hora 		 = _time;
let _horas_char	 = _hora;
let _hora_int 	 = _horas_char;

if _hora_int > 0 then
	let _minutos_char	= _horas_char[3,4];
	let _minutos_pas	= _hora_int * 60;
else		
	let _minuto 		= _time;
	let _minutos_char	= _minuto;
end if	

let _min_int 		= _minutos_char;
let _minuto_interv	= _min_int + _minutos_pas;


return _minuto_interv;
end procedure; 
