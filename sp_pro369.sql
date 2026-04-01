-- Procedimiento que arma la modificacion del warning de los campos con excepciones en el Programa de Emision Electronica
--
-- creado    : 28/08/2012 - Autor: Roman Gordon
-- Modificado: 25/09/2012 - Autor: Roman Gordon	--Eliminar el flag cuando ya encontro la equivalencia y borrarlo de la tabla de errores.
-- sis v.2.0 - deivid, s.a.

drop procedure sp_pro369;
create procedure "informix".sp_pro369(a_cod_agente char(5), a_num_carga char(10), a_campo char(30))
returning   smallint,
			varchar(255),
			varchar(255);   -- _sentencia

define _transparencia	varchar(255);
define _sentencia		varchar(255);
define _renglones		varchar(255);
define _error_desc		char(50);
define _color_warning	char(10);
define _renglon_char	char(3);
define _tran_warning	char(2);
define _importancia		smallint;
define _error_isam		smallint;
define _renglon1		smallint;
define _renglon			smallint;
define _error			smallint;

on exception set _error,_error_isam,_error_desc 
 	return _error,_error_desc,'';         
end exception

set isolation to dirty read;

--set debug file to "sp_pro369.trc";      
--trace on;

let _color_warning	= '65535';
let _tran_warning	= '60';
{foreach
	
			   renglon	
	  into _importancia,
		   _renglon1	
	  from equierror
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and campo		= a_campo

	let _renglon_char	= cast(_renglon1 as char(3));
	exit foreach;
end foreach

if _importancia = 2 then
	let _color_warning	= '65535';
	let _tran_warning	= '60';
elif _importancia = 3 then
	let _color_warning = '255';
	let _tran_warning	= '40';
end if }

let _renglones = "'0~tif(renglon in (";

foreach
	select renglon,
		   importancia	
	  into _renglon,
		   _importancia	
	  from equierror
	 where cod_agente	= a_cod_agente
	   and num_carga	= a_num_carga
	   and campo		= a_campo

	if _importancia = 2 then
		let _color_warning	= '65535';
		let _tran_warning	= '60';
	elif _importancia = 3 then
		let _color_warning	= '255';
		let _tran_warning	= '40';
	elif _importancia = 0 then
		continue foreach;	
	end if		

	let _renglon_char	= cast(_renglon as char(3));
	let _renglones		= trim(_renglones) || trim(_renglon_char) || ',';
end foreach

let _renglones		= trim(_renglones) || '0';
let _sentencia		= trim(_renglones) || ")," || trim(_color_warning) || ",16777215)'";
let _transparencia	= trim(_renglones) || ")," || trim(_tran_warning) || ",0)'";

delete from equierror
  where cod_agente	= a_cod_agente	
    and num_carga	= a_num_carga
    and campo		= a_campo
    and importancia	= 0;   

return 0,_sentencia,_transparencia;
end procedure
