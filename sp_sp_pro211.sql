-- Reporte para estadistica de las aprobaciones o rechazo del proyecto Control Firma Emision

-- Creado    : 29/11/2011 - Autor: Armando Moreno

--drop procedure sp_pro211;

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
		   integer,
		   integer;
		   
define _fecha_entro		datetime year to fraction(5)
define _fecha_rechazo	datetime year to fraction(5)
define _observacion		varchar(255)
define _user_rechazo	char(22)
define _no_documento   	char(20)
define _tipo			char(12)
define _cod_ramo		char(3)
define _cod_subramo		char(3)
define _cod_contratante	char(10)
define _status			char(1)
define _incidente		integer
define _dias            integer;

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

  let _dias = date(_fecha_rechazo) - date(_fecha_entro);

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
		 _dias
		 with resume;

end foreach

end procedure
