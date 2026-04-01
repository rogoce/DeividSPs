-- Procedimiento de Verificación de las Cuentas de Reclamos para el cierre mensual (cuentas 221, 222, 553, 541 y 419)
-- Creado    : 22/12/2015- Autor: Román Gordón
-- Modificacion: 04/06/2024 Autor: Amado Perez Mendoza (cuentas 221, 149  por 222, 553 reserva bruto, 554 y 419) 

drop procedure sp_rec01b3;
create procedure informix.sp_rec01b3(
a_compania  char(3), 
a_agencia   char(3), 
a_periodo1  char(7), 
a_periodo2  char(7), 
a_nivel		smallint,
a_db		char(18))
returning	varchar(50)	as compania,
			varchar(50)	as nom_cuenta,
			char(18)	as cuenta,			
			char(3)		as cod_ramo,
			varchar(50)	as nom_ramo,
			dec(16,2)	as monto_tecnico,
			dec(16,2)	as saldo,
			dec(16,2)	as diferencia;

define _tri					varchar(255);
define v_ramo_nombre		varchar(50);
define _nom_cuenta			varchar(50);
define v_compania_nombre	varchar(50);
define _cuenta				char(18);
define _no_poliza			char(10);
define _ano					char(4);
define _cod_ramo			char(3);
define v_incurrido_bruto	dec(16,2);
define v_recupero_bruto		dec(16,2);
define v_pagado_bruto1		dec(16,2);
define v_reserva_recup		dec(16,2);
define v_reserva_bruto		dec(16,2);
define v_incurrido_bru		dec(16,2);
define v_pagado_total		dec(16,2);
define v_pagado_bruto		dec(16,2);
define v_reserva_neto		dec(16,2);
define v_pagado_neto		dec(16,2);
define v_salv_bruto			dec(16,2);
define _monto_total			dec(16,2);
define _diferencia			dec(16,2);
define v_dec_bruto			dec(16,2);
define _saldo				dec(16,2);
define _ramo_sis			smallint;
define _mes					smallint;

let v_compania_nombre = sp_sis01(a_compania);

drop table if exists tmp_balance;
drop table if exists tmp_saldos;
drop table if exists tmp_sinis;

create temp table tmp_balance(
cuenta		char(12),
cod_ramo	char(3)   not null,
monto_total	dec(16,2) not null,
saldo		dec(16,2),
diferencia	dec(16,2),
primary key (cuenta,cod_ramo)) with no log;

create temp table tmp_saldos(
cuenta		char(12),
nombre		char(50),
debito		dec(16,2),
credito		dec(16,2),
saldo		dec(16,2),
saldo_ant	dec(16,2),
saldo_act	dec(16,2),
referencia	char(20)) with no log;

let _tri = sp_rec01d(a_compania, a_agencia, a_periodo1, a_periodo2);

let _ano = a_periodo1[1,4];
let _mes = a_periodo1[6,7];

execute procedure sp_sac42(_ano, _mes, a_nivel, a_db); --Busca los saldos de cglsaldodet

foreach
	select tmp.no_poliza,
		   tmp.cod_ramo,
		   sum(tmp.incurrido_bruto),
		   sum(tmp.pagado_bruto),
		   sum(tmp.reserva_bruto),
		   sum(tmp.reserva_neto),
		   sum(tmp.pagado_bruto1),
		   sum(tmp.salvamento_bruto),
		   sum(tmp.recupero_bruto),
		   sum(tmp.deducible_bruto)
	  into _no_poliza,
		   _cod_ramo,			
		   v_incurrido_bru,
		   v_pagado_bruto,
		   v_reserva_bruto,
		   v_reserva_neto,
		   v_pagado_bruto1,
		   v_salv_bruto,
		   v_recupero_bruto,
		   v_dec_bruto
	  from tmp_sinis tmp
	 inner join rectrmae trx on trx.no_tranrec = tmp.no_tranrec
	 where tmp.seleccionado = 1
	   and trx.fecha < today
	 group by tmp.no_poliza, tmp.cod_ramo
	 order by tmp.no_poliza, tmp.cod_ramo

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _ramo_sis = 1 then -- Soda y Flota pasa a Auto
		let _cod_ramo = '002';
	end if

	if _cod_ramo in ('003') then -- Multiriesgo Pasa a Incendio
		let _cod_ramo = '001';
	elif _cod_ramo in ('010','011','012','013','014','022') then --Ramos Tecnicos	
		let _cod_ramo = '099';
	end if

	let _saldo = 0.00;

	-- Reserva de Siniestros en Tramite Cuenta 149 antes 222
	
	if v_reserva_bruto is null then
		let v_reserva_bruto = 0.00;
	end if
	
	if v_reserva_neto is null then
		let v_reserva_neto = 0.00;
	end if
	
	if (v_reserva_bruto - v_reserva_neto) <> 0.00 then

		let _cuenta = sp_sis15('NIIFPRSMR', '01', _no_poliza);

		select saldo
		  into _saldo
		  from tmp_saldos
		 where cuenta = _cuenta;

		if _saldo is null then
			let _saldo = 0.00;
		end if

		begin
			on exception in(-239,-268)
				update tmp_balance
				   set monto_total = monto_total + (v_reserva_bruto - v_reserva_neto),
				       diferencia = diferencia - (v_reserva_bruto - v_reserva_neto)
				 where trim(cuenta) = _cuenta
				   and cod_ramo = _cod_ramo;

			end exception
			insert into tmp_balance(
					cuenta,
					cod_ramo,
					monto_total,
					saldo,
					diferencia)
			values(	_cuenta,
					_cod_ramo,
					(v_reserva_bruto - v_reserva_neto),
					_saldo,
					_saldo - (v_reserva_bruto - v_reserva_neto));
		end
	end if

	-- Reserva de Siniestros Monto Recuperable --Cuenta 221
	let _saldo = 0.00;
	
	if v_reserva_bruto is null then
		let v_reserva_bruto = 0.00;
	end if

	if v_reserva_bruto <> 0.00 then
		let _cuenta    = sp_sis15('RPRDSET', '01', _no_poliza);
		
		select saldo
		  into _saldo
		  from tmp_saldos
		 where cuenta = _cuenta;

		if _saldo is null then
			let _saldo = 0.00;
		end if

		begin
			on exception in(-239,-268)
				update tmp_balance
				   set monto_total = monto_total + v_reserva_bruto,
					   diferencia = diferencia + v_reserva_bruto
				 where trim(cuenta) = _cuenta
				   and cod_ramo = _cod_ramo;

			end exception
			insert into tmp_balance(
					cuenta,
					cod_ramo,
					monto_total,
					saldo,
					diferencia)
			values(	_cuenta,
					_cod_ramo,
					v_reserva_bruto,
					_saldo,
					_saldo + v_reserva_bruto);
		end
	end if

	-- Aumento/Disminucion de Reserva	Cuenta 553 ahora es reserva bruto
	let _saldo = 0.00;
	
	if v_reserva_bruto is null then
		let v_reserva_bruto = 0.00;
	end if

	if v_reserva_bruto <> 0.00 then
		let _cuenta    = sp_sis15('RGADRST', '01', _no_poliza);
		
		select saldo
		  into _saldo
		  from tmp_saldos
		 where cuenta = _cuenta;

		if _saldo is null then
			let _saldo = 0.00;
		end if

		begin
			on exception in(-239,-268)
				update tmp_balance
				   set monto_total = monto_total + v_reserva_bruto,
					   diferencia = diferencia - v_reserva_bruto
				 where trim(cuenta) = _cuenta
				   and cod_ramo = _cod_ramo;

			end exception
			insert into tmp_balance(
					cuenta,
					cod_ramo,
					monto_total,
					saldo,
					diferencia)
			values(	_cuenta,
					_cod_ramo,
					v_reserva_bruto,
					_saldo,
					_saldo - v_reserva_bruto);
		end
	end if
	
	-- Aumento/Disminucion de Reserva	Cuenta 554 ahora es reserva bruto nueva cuenta
	if v_reserva_bruto is null then
		let v_reserva_bruto = 0.00;
	end if
	
	if v_reserva_neto is null then
		let v_reserva_neto = 0.00;
	end if
	
	if (v_reserva_bruto - v_reserva_neto) <> 0.00 then
		let _cuenta    = sp_sis15('RGADRSTRE', '01', _no_poliza);
		
		select saldo
		  into _saldo
		  from tmp_saldos
		 where cuenta = _cuenta;

		if _saldo is null then
			let _saldo = 0.00;
		end if

		begin
			on exception in(-239,-268)
				update tmp_balance
				   set monto_total = monto_total + (v_reserva_bruto - v_reserva_neto),
				       diferencia = diferencia + (v_reserva_bruto - v_reserva_neto)
				 where trim(cuenta) = _cuenta
				   and cod_ramo = _cod_ramo;

			end exception
			insert into tmp_balance(
					cuenta,
					cod_ramo,
					monto_total,
					saldo,
					diferencia)
			values(	_cuenta,
					_cod_ramo,
					(v_reserva_bruto - v_reserva_neto),
					_saldo,
					_saldo + (v_reserva_bruto - v_reserva_neto));
		end
	end if
	

	-- Siniestros Pagados Cuenta 541
	let _saldo = 0.00;

	if v_pagado_bruto1 is null then
		let v_pagado_bruto1 = 0.00;
	end if

	if v_dec_bruto is null then
		let v_dec_bruto = 0.00;
	end if
	
	if (v_pagado_bruto1 + v_dec_bruto) <> 0.00 then
		let _cuenta    = sp_sis15('RGSP', '01', _no_poliza);
		
		select saldo
		  into _saldo
		  from tmp_saldos
		 where cuenta = _cuenta;

		if _saldo is null then
			let _saldo = 0.00;
		end if
		
		begin
			on exception in(-239,-268)
				update tmp_balance
				   set monto_total = monto_total + (v_pagado_bruto1 + v_dec_bruto),
					   diferencia = diferencia - (v_pagado_bruto1 + v_dec_bruto)
				 where trim(cuenta) = _cuenta
				   and cod_ramo = _cod_ramo;

			end exception
			insert into tmp_balance(
					cuenta,
					cod_ramo,
					monto_total,
					saldo,
					diferencia)
			values(	_cuenta,
					_cod_ramo,
					v_pagado_bruto1 + v_dec_bruto,
					_saldo,
					_saldo - (v_pagado_bruto1 + v_dec_bruto));
		end
	end if

	-- Salvamentos y Recupero Cuenta 419
	let _saldo = 0.00;

	if v_recupero_bruto is null then
		let v_recupero_bruto = 0.00;
	end if
	
	if v_salv_bruto is null then
		let v_salv_bruto = 0.00;
	end if
	
	if (v_recupero_bruto + v_salv_bruto) <> 0.00 then		
		let _cuenta    = sp_sis15('SISAL', '01', _no_poliza);
		
		select saldo
		  into _saldo
		  from tmp_saldos
		 where cuenta = _cuenta;

		if _saldo is null then
			let _saldo = 0.00;
		end if		

		begin
			on exception in(-239,-268)
				update tmp_balance
				   set monto_total = monto_total + (v_recupero_bruto + v_salv_bruto),
					   diferencia = diferencia - (v_recupero_bruto + v_salv_bruto)
				 where trim(cuenta) = _cuenta
				   and cod_ramo = _cod_ramo;

			end exception
			insert into tmp_balance(
					cuenta,
					cod_ramo,
					monto_total,
					saldo,
					diferencia)
			values(	_cuenta,
					_cod_ramo,
					(v_recupero_bruto + v_salv_bruto),
					_saldo,
					_saldo - (v_recupero_bruto + v_salv_bruto));
		end
	end if
end foreach

foreach
	select cuenta,
		   cod_ramo,
		   monto_total,
		   saldo,
		   diferencia
	  into _cuenta,
		   _cod_ramo,
		   _monto_total,
		   _saldo,
		   _diferencia
	  from tmp_balance

	if _cod_ramo = '099' then
		let v_ramo_nombre = 'RAMOS TECNICOS';
	else
		select nombre
		  into v_ramo_nombre
		  from prdramo
		 where cod_ramo = _cod_ramo;
	end if

	select nombre
	  into _nom_cuenta
	  from tmp_saldos
	 where cuenta = _cuenta;

	return	v_compania_nombre,
			_nom_cuenta,
			_cuenta,
			_cod_ramo,
			v_ramo_nombre,
			_monto_total,
			_saldo,
			_diferencia with resume;
end foreach

drop table if exists tmp_balance;
drop table if exists tmp_saldos;
drop table if exists tmp_sinis;
end procedure;