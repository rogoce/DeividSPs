-- Reporte para estadistica de las aprobaciones o rechazo del proyecto Control Firma Emision

-- Creado    : 29/11/2011 - Autor: Armando Moreno

drop procedure sp_pro211;

create procedure sp_pro211()
 returning datetime year to fraction(5),
		   datetime year to fraction(5),
		   varchar(255),
		   char(22),
		   char(20),
		   char(12),
		   char(3),
		   char(3),
		   char(10),
		   char(1),
		   integer,
		   interval day to day,
		   interval hour to minute;
		   
define _fecha_entro		datetime year to fraction(5);
define _fecha_rechazo	datetime year to fraction(5);
define _observacion		varchar(255);
define _user_rechazo	char(22);
define _no_documento   	char(20);
define _tipo			char(12);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _cod_contratante	char(10);
define _status			char(1);
define _incidente		integer;
define _dias            interval day to day;
define _time            interval day to minute;
define _time2			interval hour to minute;

SET ISOLATION TO DIRTY READ;

foreach
 select	fecha_entro,
		fecha_rechazo,
		observacion,
		user_rechazo,
		no_documento,
		tipo,
		cod_ramo,
		cod_subramo,
		cod_contratante,
		status,
		incidente
   into	_fecha_entro,
		_fecha_rechazo,
		_observacion,
		_user_rechazo,
		_no_documento,
		_tipo,
		_cod_ramo,
		_cod_subramo,
		_cod_contratante,
		_status,
		_incidente
   from	wfcferec
  order by fecha_entro

  let _time  = _fecha_rechazo - _fecha_entro;
  let _dias  = _time;
  let _time2 = _time;

  return _fecha_entro,
		 _fecha_rechazo,
		 _observacion,
		 _user_rechazo,
		 _no_documento,
		 _tipo,
		 _cod_ramo,
		 _cod_subramo,
		 _cod_contratante,
		 _status,
		 _incidente,
		 _dias,
		 _time2
		 with resume;

end foreach

end procedure
