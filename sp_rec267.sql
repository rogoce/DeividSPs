-- Proceso de Verificación de Reserva de Siniestros en Tramite (221) y Reserva de Siniestros Monto Recuperable(222) Acumuladas para un mes especifico
-- Creado    : 09/05/2016 - Autor: Román Gordón
--execute procedure sp_rec267('001','001','2016-04','*')


drop procedure sp_rec267;
create procedure 'informix'.sp_rec267(
a_compania	char(3),
a_agencia	char(3),
a_periodo	char(7),
a_cod_ramo		varchar(255)	default '*')
returning	char(3)		as Cuenta,
			varchar(50)	as Nombre_Cuenta,
			char(18)	as Reclamo,
			dec(16,2)	as mes_ant,
			dec(16,2)	as mov_mes,
			dec(16,2)	as mes_act,
			dec(16,2)	as diferencia,
			varchar(50)	as nom_compania;

define v_filtros			varchar(255);
define _nom_cuenta_221		varchar(50);
define _nom_cuenta_222		varchar(50);
define _nom_compania		varchar(50);
define _error_desc			varchar(50);
define _no_cuenta			char(30);
define _numrecla			char(18);
define _cod_ramo			char(3);
define _periodo_desde		char(7);
define _estatus_reclamo		char(1);
define _diferencia_221		dec(16,2);
define _diferencia_222		dec(16,2);
define _monto_contable		dec(16,2);
define _mes_ant221			dec(16,2);
define _mov_mes221			dec(16,2);
define _mes_act221			dec(16,2);
define _mes_ant222			dec(16,2);
define _mov_mes222			dec(16,2);
define _mes_act222			dec(16,2);
define _monto_221			dec(16,2);
define _monto_222			dec(16,2);
define _error_isam			smallint;
define _error				smallint;
define _flag				smallint;
define _anio				smallint;
define _mes					smallint;
define _fecha_periodo		date;

set isolation to dirty read;

begin

on exception set _error,_error_isam,_error_desc
	return '','',_error_desc,_error,0.00,0.00,0.00,'';
end exception

drop table if exists tmp_sinis;
drop table if exists tmp_mes_act;
drop table if exists tmp_mes_ant;
drop table if exists tmp_mov_mes;

create temp table tmp_mov_mes(
numrecla		char(18),
variacion221	dec(16,2),
variacion222	dec(16,2),
primary key (numrecla)) with no log;

-- cargar la reserva del periodo a evaluar
call sp_rec02(
a_compania, 
a_agencia, 
a_periodo,
'*',
'*',
'*',
a_cod_ramo,
'*') returning v_filtros; 

select numrecla,
	   reserva_bruto,
	   reserva_bruto - reserva_neto as cta222
  from tmp_sinis
 where seleccionado = 1
  into temp tmp_mes_act;

drop table if exists tmp_sinis;

let _mes = a_periodo[6,7];
let _anio = a_periodo[1,4];

let _fecha_periodo = mdy(_mes,1,_anio);
let _fecha_periodo = _fecha_periodo - 1 units day;

let _periodo_desde = sp_sis39(_fecha_periodo);

-- cargar la reserva del periodo a evaluar
call sp_rec02(
a_compania, 
a_agencia, 
_periodo_desde,
'*',
'*',
'*',
a_cod_ramo,
'*') returning v_filtros; 

--let _tipo = sp_sis04(a_cod_ramo);

let _nom_compania = sp_sis01(a_compania);

select numrecla,
	   reserva_bruto,
	   reserva_bruto - reserva_neto as cta222
  from tmp_sinis
 where seleccionado = 1
  into temp tmp_mes_ant;

select cta_nombre
  into _nom_cuenta_221
  from cglcuentas
 where cta_cuenta = '221';

-- Se reemplaza la cuenta 222 por la cuenta 149 según contabilidad -- Amado 03-09-2024

select cta_nombre
  into _nom_cuenta_222
  from cglcuentas
 where cta_cuenta = '149';

let _flag = 0;

foreach
	select m.numrecla,
		   a.cuenta,
		   sum(a.debito + a.credito)
	  into _numrecla,
		   _no_cuenta,
		   _monto_contable
	  from rectrmae m, recasien a
	 where m.no_tranrec = a.no_tranrec
	   and (a.cuenta like '221%' or a.cuenta like '149%')
	   and a.periodo = a_periodo
	 group by 1,2
	 order by 1,2

	let _monto_221 = 0.00;
	let _monto_222 = 0.00;

	if _no_cuenta[1,3] = '221' then
		let _monto_221 = _monto_contable;
	elif _no_cuenta[1,3] = '149' then
		let _monto_222 = _monto_contable;
	end if

	begin
		on exception in(-239)
			update tmp_mov_mes
			   set variacion221 = variacion221 + _monto_221,
				   variacion222 = variacion222 + _monto_222
			 where numrecla = _numrecla;
		end exception
		
		insert into tmp_mov_mes (numrecla,variacion221,variacion222)
		values (_numrecla,_monto_221,_monto_222);
	end
end foreach

foreach
	select caso,
		   sum(mes_ant221),
		   sum(mov_mes221),
		   sum(mes_act221),
		   sum(mes_ant222),
		   sum(mov_mes222),
		   sum(mes_act222)		   
	  into _numrecla,
		   _mes_ant221,
		   _mov_mes221,
		   _mes_act221,
		   _mes_ant222,
		   _mov_mes222,
		   _mes_act222
	  from (select numrecla as caso , 0 as mes_ant221, variacion221 as mov_mes221, 0 as mes_act221, 0 as mes_ant222, variacion222 as mov_mes222, 0 as mes_act222 from tmp_mov_mes
	 union select numrecla as caso, reserva_bruto as mes_ant221, 0 as  mov_mes221 , 0 as mes_act221, cta222 as mes_ant222, 0 as  mov_mes222 , 0 as mes_act222  from tmp_mes_ant
	 union select numrecla as caso, 0 as mes_ant221, 0 as  mov_mes221  , reserva_bruto as mes_act221, 0 as mes_ant222, 0 as  mov_mes222  , cta222 as mes_act222 from tmp_mes_act)
	 group by caso

	let _diferencia_221 = (_mes_ant221 - _mov_mes221) - _mes_act221;
	let _diferencia_222 = (_mes_ant222 + _mov_mes222) - _mes_act222;

	if abs(_diferencia_221) > 0.1 then
		let _flag = 1;
		return '221',_nom_cuenta_221,_numrecla,_mes_ant221,_mov_mes221,_mes_act221,_diferencia_221,_nom_compania with resume;
	end if

	if abs(_diferencia_222) > 0.1 then
		let _flag = 1;
		return '149',_nom_cuenta_222,_numrecla,_mes_ant222,_mov_mes222,_mes_act222,_diferencia_222,_nom_compania with resume;
	end if
end foreach

drop table if exists tmp_sinis;
drop table if exists tmp_mes_act;
drop table if exists tmp_mes_ant;
drop table if exists tmp_mov_mes;

if _flag = 0 then
	return '','','',0.00,0.00,0.00,0.00,_nom_compania;
end if

end
end procedure;                                               