drop procedure sp_rec02e;
create procedure 'informix'.sp_rec02e(
a_compania	char(3),
a_agencia	char(3),
a_periodo	char(7),
a_cod_ramo		varchar(255)	default '*')
returning	char(3)		as Cuenta,
			char(18)	as Reclamo,
			dec(16,2)	as mes_ant,
			dec(16,2)	as mov_mes,
			dec(16,2)	as mes_act,
			dec(16,2)	as diferencia;

define v_filtros			varchar(255);
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
define _anio				smallint;
define _mes					smallint;
define _fecha_periodo		date;

set isolation to dirty read;

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

select numrecla,
	   reserva_bruto,
	   reserva_bruto - reserva_neto as cta222
  from tmp_sinis
 where seleccionado = 1
  into temp tmp_mes_ant;

foreach
	select m.numrecla,
		   a.cuenta,
		   sum(a.debito + a.credito)
	  into _numrecla,
		   _no_cuenta,
		   _monto_contable
	  from rectrmae m, recasien a
	 where m.no_tranrec = a.no_tranrec
	   and (a.cuenta like '221%' or a.cuenta like '222%')
	   and a.periodo = '2016-04'
	 group by 1,2
	 order by 1,2

	let _monto_221 = 0.00;
	let _monto_222 = 0.00;

	if _no_cuenta[1,3] = '221' then
		let _monto_221 = _monto_contable;
	elif _no_cuenta[1,3] = '222' then
		let _monto_222 = _monto_contable;
	end if

	begin
		on exception in(-239)
			update tmp_mov_mes
			   set variacion221 = _monto_221,
				   variacion222 = _monto_222
			 where numrecla = _numrecla;
		end exception
		
		insert into tmp_mov_mes (no_reclamo,variacion221,variacion222)
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
	 union select reclamo as caso, reserva_bruto as mes_ant221, 0 as  mov_mes221 , 0 as mes_act221, cta222 as mes_ant222, 0 as  mov_mes222 , 0 as mes_act222  from tmp_mes_ant
	 union select reclamo as caso, 0 as mes_ant221, 0 as  mov_mes221  , reserva_bruto as mes_act221, 0 as mes_ant222, 0 as  mov_mes222  , cta222 as mes_act222 from tmp_mes_act)
	 group by caso

	let _diferencia_221 = (_mes_ant221 + _mov_mes221) - _mes_act221;
	let _diferencia_222 = (_mes_ant222 + _mov_mes222) - _mes_act222;

	if _diferencia_221 <> 0 then
		return '221',_numrecla,_mes_ant221,_mov_mes221,_mes_act221,_diferencia_221 with resume;
	end if

	if _diferencia_222 <> 0 then
		return '222',_numrecla,_mes_ant222,_mov_mes222,_mes_act222,_diferencia_222 with resume;
	end if
end foreach

drop table if exists tmp_sinis;
--drop table if exists tmp_mes_act;
--drop table if exists tmp_mes_ant;
--drop table if exists tmp_mov_mes;

return '','',0.00,0.00,0.00,0.00;
end procedure;                                               