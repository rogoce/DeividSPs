-- Procedimiento que determina los reclamos promedios de los ultimos tres meses solo automovil

-- Creado    : 13/05/2013 - Autor:  Roman Gordon

drop procedure sp_rec160c;

create procedure sp_rec160c(a_periodo1 char(7)) 
returning	char(50), 
		 	integer,
		 	dec(16,2),
		 	dec(16,2),
		 	integer,
		 	dec(16,2),
		 	dec(16,2),
		 	integer,
		 	dec(16,2),
		 	dec(16,2),
		 	integer,
		 	dec(16,2),
		 	dec(16,2);

define _nombre_icd			char(50);
define _error_desc			char(50);
define _n_evento        	char(50);
define _numrecla			char(20);
define _no_tranrec			char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _cod_icd				char(10);
define _periodo1_ant		char(7);
define _periodo_2			char(7);
define _periodo_3			char(7);
define _periodo_4			char(7);
define _vperiodo			char(7);
define _cod_evento   		char(3);
define _cod_ramo			char(3);
define _monto_prom_mes1_ac	dec(16,2);
define _monto_prom_mes_ac	dec(16,2);
define _monto_prom_mes1		dec(16,2);
define _monto_prom_mes		dec(16,2);
define _monto_mes1_ac		dec(16,2);
define _monto_mes_ac		dec(16,2);
define _monto_mes1			dec(16,2);
define _monto_mes			dec(16,2);
define _reserva				dec(16,2);
define _monto				dec(16,2);
define _cantidad_mes1_ac	smallint;
define _cantidad_mes_ac		smallint;
define _cantidad_mes1		smallint;
define _cantidad_mes		smallint;
define _perd_total			smallint;
define _cantidad			smallint;
define _cnt_for				smallint;
define _ano2				smallint;
define _ano					smallint;
define _mes					smallint;
define _cnt					smallint;
define _error_isam			integer;
define _error				integer;

let _ano = a_periodo1[1,4];
let _mes = a_periodo1[6,7];

begin
{on exception set _error,_error_isam
	drop table tmp_promedio;
	drop table tmp_periodo;
	drop table tmp_resultado;
end exception}

create temp table tmp_periodo(
periodo		char(7),

primary key (periodo)
) with no log;

-- Periodo 2

let _ano2 = _ano - 1;
let _cnt = _mes - 1;

if _mes < 10 then
	let _periodo1_ant = _ano2 || "-0" || _mes;
else
	let _periodo1_ant = _ano2 || "-" || _mes;
end if

--Periodo Enviado por Parametro
insert into tmp_periodo
values (a_periodo1);

--Periodo Enviado por Parametro del año anterior
insert into tmp_periodo
values (_periodo1_ant);

if _mes > 1 then
	--Periodos anteriores al periodo Enviado por Parametro
	for _cnt_for = 1 to _cnt 
		if _cnt_for < 10 then
			let _periodo_2 = _ano || "-0" || _cnt_for;
		else
			let _periodo_2 = _ano || "-" || _cnt_for;
		end if
		
		insert into tmp_periodo
		values (_periodo_2);
		
		if _cnt_for < 10 then
			let _periodo_2 = _ano2 || "-0" || _cnt_for;
		else
			let _periodo_2 = _ano2 || "-" || _cnt_for;
		end if
		
		insert into tmp_periodo
		values (_periodo_2);	
	end for
end if

-- Periodo Reclamo

create temp table tmp_promedio(
numrecla		char(20),
cod_ramo		char(3),
cod_evento		char(3),
monto			dec(16,2),
periodo         char(7),
primary key (numrecla,cod_evento)
) with no log;

create temp table tmp_resultado(
nom_evento			char(50),
cantidad_mes		integer,
monto_mes			dec(16,2),
monto_prom_mes		dec(16,2),
cantidad_mes1		integer,
monto_mes1			dec(16,2),
monto_prom_mes1		dec(16,2),
cantidad_mes_ac		integer,
monto_mes_ac		dec(16,2),
monto_prom_mes_ac	dec(16,2),
cantidad_mes1_ac	integer,
monto_mes1_ac		dec(16,2),
monto_prom_mes1_ac	dec(16,2)
--primary key (nom_evento)
) with no log;


foreach 
	select no_reclamo,
		   periodo,
		   sum(monto)
	  into _no_reclamo,
		   _vperiodo,
		   _monto
	  from rectrmae
	 where cod_compania	= '001'
	   and actualizado	= 1
	   and cod_tipotran	in (4,5,6,7)
	   and periodo		in (select periodo from tmp_periodo)
	 group by no_reclamo,periodo
	having sum(monto) <> 0


	select no_poliza,
	       cod_evento,
		   numrecla
	  into _no_poliza,
	       _cod_evento,
		   _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo <> '002' then
		continue foreach;
	end if

	select count(*)
	  into _cantidad
	  from tmp_promedio
	 where numrecla      = _numrecla
	   and cod_evento    = _cod_evento;

	if _cantidad = 0 then
		insert into tmp_promedio
		values (_numrecla, _cod_ramo,_cod_evento, _monto,_vperiodo);
	else
		update tmp_promedio
		   set monto      = monto + _monto
		 where numrecla   = _numrecla
		   and cod_evento = _cod_evento;
	end if
end foreach

foreach
	select cod_ramo,
		   cod_evento,
		   periodo,
		   count(*),
		   sum(monto)
	  into _cod_ramo,
		   _cod_evento,
		   _vperiodo,
		   _cantidad,
		   _monto
	  from tmp_promedio
	 group by 1,2,3
	 order by 1,2,3

	let _reserva = _monto / _cantidad;
	
	select nombre
	  into _n_evento
	  from recevent
	 where cod_evento = _cod_evento;

	let _cantidad_mes1_ac = 0;
	let _cantidad_mes_ac = 0;
	let _cantidad_mes1 = 0;
	let _cantidad_mes = 0;
	let _monto_prom_mes1_ac = 0.00;
	let _monto_prom_mes_ac = 0.00;
	let _monto_prom_mes1 = 0.00;
	let _monto_prom_mes = 0.00;
	let _monto_mes1_ac = 0.00;
	let _monto_mes_ac = 0.00;
	let _monto_mes1 = 0.00;
	let _monto_mes = 0.00;
	 
	if _vperiodo = a_periodo1 then
		let _monto_prom_mes = _reserva;
		let _cantidad_mes	= _cantidad;
		let _monto_mes		= _monto;
	elif _vperiodo = _periodo1_ant then
		let _monto_prom_mes1	= _reserva;
		let _cantidad_mes1		= _cantidad;
		let _monto_mes1			= _monto;
	elif _vperiodo[1,4] = _ano then
		let _monto_prom_mes_ac	= _reserva;
		let _cantidad_mes_ac	= _cantidad;
		let _monto_mes_ac		= _monto;
	else
		let _monto_prom_mes1_ac	= _reserva;
		let _cantidad_mes1_ac	= _cantidad;
		let _monto_mes1_ac		= _monto;
	end if
	
	insert into tmp_resultado(
			nom_evento,
			cantidad_mes,
			monto_mes,
			monto_prom_mes,
			cantidad_mes1,
			monto_mes1,
			monto_prom_mes1,
			cantidad_mes_ac,
			monto_mes_ac,
			monto_prom_mes_ac,
			cantidad_mes1_ac,
			monto_mes1_ac,
			monto_prom_mes1_ac)
	values	(_n_evento,
			_cantidad_mes,
			_monto_mes,
			_monto_prom_mes,
			_cantidad_mes1,
			_monto_mes1,
			_monto_prom_mes1,
			_cantidad_mes_ac,
			_monto_mes_ac,
			_monto_prom_mes_ac,
			_cantidad_mes1_ac,
			_monto_mes1_ac,
			_monto_prom_mes1_ac);
end foreach

foreach
	select nom_evento,
		   sum(cantidad_mes),
		   sum(monto_mes),
		   sum(monto_prom_mes),
		   sum(cantidad_mes1),
		   sum(monto_mes1),
		   sum(monto_prom_mes1),
		   sum(cantidad_mes_ac),
		   sum(monto_mes_ac),
		   sum(monto_prom_mes_ac),
		   sum(cantidad_mes1_ac),
		   sum(monto_mes1_ac),
		   sum(monto_prom_mes1_ac)
	  into _n_evento,
		   _cantidad_mes,
		   _monto_mes,
		   _monto_prom_mes,
		   _cantidad_mes1,
		   _monto_mes1,
		   _monto_prom_mes1,
		   _cantidad_mes_ac,
		   _monto_mes_ac,
		   _monto_prom_mes_ac,
		   _cantidad_mes1_ac,
		   _monto_mes1_ac,
		   _monto_prom_mes1_ac
	  from tmp_resultado
	 group by 1
	 order by 1

	return _n_evento,
		   _cantidad_mes,
		   _monto_mes,
		   _monto_prom_mes,
		   _cantidad_mes1,
		   _monto_mes1,
		   _monto_prom_mes1,
		   _cantidad_mes_ac,
		   _monto_mes_ac,
		   _monto_prom_mes_ac,
		   _cantidad_mes1_ac,
		   _monto_mes1_ac,
		   _monto_prom_mes1_ac with resume;
end foreach

drop table tmp_promedio;
drop table tmp_periodo;
drop table tmp_resultado;

end
end procedure

