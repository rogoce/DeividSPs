-- procedimiento trae endoso segun mes de emision
-- Creado    : 16/11/2021 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	 execute procedure sp_pro4967('1816-00106-01','29/04/2016')

drop procedure sp_pro4967;
create procedure sp_pro4967(a_no_documento char(20),a_fecha_emitio date)
returning	char(7)	as	Periodo,
			char(10)	as	Factura,
			dec(16,2)	as	Prima_Neta,
			date	as	Fecha_Emision,
			date	as	Fecha_Efectividad,
			char(20)	as	no_documento,
			char(10)	as	no_poliza,
			char(5)	as	no_endoso,
			char(3)	as	cod_endomov,
			date	as	vigencia_final,
			char(100)	as	nombre;


define _min_vig_inic		date;
define _mensaje				varchar(100);
define _error_isam			integer;
define _error				integer;
define 	_Periodo	char(7);
define 	_Factura	char(10);
define 	_Prima_Neta 	dec(16,2);
define 	_Fecha_Emision	date;
define 	_Fecha_Efectividad	date;
define 	_no_documento	char(20);
define 	_no_poliza	char(10);
define 	_no_endoso	char(5);
define 	_cod_endomov	char(3);
define 	_vigencia_final	date;
define 	_nombre	char(100);


set isolation to dirty read;
SET DEBUG FILE TO "sp_pro4967.trc";      
TRACE ON;  
begin
on exception set _error,_error_isam,_mensaje
	return null,null,_error,'01/01/1990','01/01/1990',null,null,null,null,'01/01/1990',_mensaje;
end exception

select min(vigencia_inic)
  into _min_vig_inic
  from emipomae
 where no_documento = a_no_documento;
 
 {
 if _min_vig_inic <> a_fecha_emitio  then 
	let a_fecha_emitio = _min_vig_inic;
 end if
}

drop table if exists tmp_pro4967;
create temp table tmp_pro4967(
	Periodo	char(7),
	Factura	char(10),
	Prima_Neta 	dec(16,2),
	Fecha_Emision	date,
	Fecha_Efectividad	date,
	no_documento	char(20),
	no_poliza	char(10),
	no_endoso	char(5),
	cod_endomov	char(3),
	vigencia_final	date,
	nombre	char(100),
primary key(no_documento,no_poliza,no_endoso,cod_endomov)) with no log;
--create index itmp_con1 on tmp_pro4967(no_poliza,no_endoso);

let _Prima_Neta = 0.00;


foreach
  SELECT  a.periodo,
         a.no_factura,
         a.prima_neta,
         a.fecha_emision,
         a.vigencia_inic,
		 a.no_documento,
         a.no_poliza,
         a.no_endoso,
         a.cod_endomov,
         a.vigencia_final,        		 
         b.nombre
	into _Periodo,
		_Factura,
		_Prima_Neta,
		_Fecha_Emision,
		_Fecha_Efectividad,
		_no_documento,
		_no_poliza,
		_no_endoso,
		_cod_endomov,
		_vigencia_final,
		_nombre
    FROM endedmae a,
         endtimov b
   WHERE ( b.cod_endomov = a.cod_endomov ) and
         ( a.cod_endomov in ('011', '014') ) AND
         ( a.actualizado = 1 ) AND
         ( a.no_documento = a_no_documento)  and
         month(a.vigencia_inic) = month(a_fecha_emitio)
	   and a.activa = 1
	 order by a.fecha_emision desc 		 

		insert into tmp_pro4967(
					Periodo,	
					Factura,
					Prima_Neta,
					Fecha_Emision,
					Fecha_Efectividad,
					no_documento,
					no_poliza,
					no_endoso,
					cod_endomov,
					vigencia_final,
					nombre
					)
			values(	_Periodo,
					_Factura,
					_Prima_Neta ,
					_Fecha_Emision,
					_Fecha_Efectividad,
					_no_documento,
					_no_poliza,
					_no_endoso,
					_cod_endomov,
					_vigencia_final,
					_nombre);

end foreach

foreach
  SELECT  Periodo,	
		Factura,
		Prima_Neta,
		Fecha_Emision,
		Fecha_Efectividad,
		no_documento,
		no_poliza,
		no_endoso,
		cod_endomov,
		vigencia_final,
		nombre
	into _Periodo,
		_Factura,
		_Prima_Neta ,
		_Fecha_Emision,
		_Fecha_Efectividad,
		_no_documento,
		_no_poliza,
		_no_endoso,
		_cod_endomov,
		_vigencia_final,
		_nombre
    FROM tmp_pro4967
	order by periodo asc
	
	return 	_Periodo,
			_Factura,
			_Prima_Neta ,
			_Fecha_Emision,
			_Fecha_Efectividad,
			_no_documento,
			_no_poliza,
			_no_endoso,
			_cod_endomov,
			_vigencia_final,
			_nombre   WITH RESUME; 
	end foreach
end
end procedure;