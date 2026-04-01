-- Procedimiento que verifica el cuadre contable con las cuentas tecnicas de producción, cobros y reclamos
-- Creado    : 28/12/2015 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac246;
create procedure informix.sp_sac246(
a_compania  char(3), 
a_agencia   char(3), 
a_periodo1  char(7), 
a_periodo2  char(7), 
a_cuenta    varchar(100))
returning	integer,
			varchar(100);

define _error_desc          varchar(100);
define v_compania_nombre	varchar(50);
define _nom_cuenta			varchar(50);
define _cuenta				char(18);
define _res_comprobante		char(15);
define _no_tranrec			char(10);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _no_endoso           char(10);
define _res_origen			char(3);
define _tipo				char(1);
define _prima_suscrita		dec(16,2);
define _saldo_contable		dec(16,2);
define _mto_endasien        dec(16,2);
define _mto_cobasien		dec(16,2);
define _mto_recasien		dec(16,2);
define _res_db				dec(16,2);
define _res_cr				dec(16,2);
define _monto				dec(16,2);
define _dif					dec(16,2);
define _db					dec(16,2);
define _cr					dec(16,2);
define _error_isam			integer;
define _res_notrx			integer;
define _renglon				integer;
define _error				integer;
define _fecha1				date;
define _fecha2				date;

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	drop table if exists tmp_contable;
	return _error, _error_desc;
end exception

--set debug file to "sp_sac246.trc";
--trace on;

let v_compania_nombre = sp_sis01(a_compania);
drop table if exists tmp_contable;

let _monto = 0;
let _mto_cobasien = 0;
let _mto_recasien = 0;
let _mto_endasien = 0;
let _db           = 0;
let _cr           = 0;
let _res_db	      = 0;
let _res_cr       = 0;
let _dif          = 0;

create temp table tmp_contable(
cuenta			char(18),
no_remesa		char(10),
renglon			integer,
db				dec(16,2),
cr				dec(16,2),
monto_tecnico	dec(16,2),
sac_notrx		integer,
comprobante		char(15),
no_tranrec		char(10),
origen			char(3),
no_poliza		char(10),
no_endoso		char(10),
descripcion		varchar(255)) with no log;

let _fecha1 = sp_sis36bk(a_periodo1); --retorna 01/11/2015 si el periodo es 2015-11
let _fecha2 = sp_sis36(a_periodo1);   --retorna 30/11/2015 si el periodo es 2015-11

--Filtro por Cuentas
if a_cuenta <> "*" then
	let _tipo = sp_sis04(a_cuenta); -- separa los valores del string
end if

foreach
	select res_cuenta,
		   res_notrx,
	       res_origen,
		   sum(res_debito-res_credito)
	  into _cuenta,
		   _res_notrx,
	       _res_origen,
		   _monto
	from cglresumen
	where res_cuenta in (select codigo from tmp_codigos) 
	  and res_fechatrx >= _fecha1
	  and res_fechatrx <= _fecha2
	group by 1,2,3
	order by 3,2,1 

	let _dif = 0;
	if _res_origen = 'COB' then
		select sum(debito-credito)
		  into _mto_cobasien
		  from cobasien
		 where sac_notrx = _res_notrx
           and cuenta    = _cuenta
		   and periodo   = a_periodo1;

		let _dif = _monto - _mto_cobasien;

		if _dif = 0 then
			continue foreach;
		else
			foreach
				select no_remesa,
					   renglon,
					   debito,
					   credito
				  into _no_remesa,
					   _renglon,
					   _db,
					   _cr
				  from cobasien
				 where sac_notrx = _res_notrx
				   and cuenta    = _cuenta
				   and periodo   = a_periodo1
			   
				insert into tmp_contable(
						cuenta,
						no_remesa,
						renglon,
						db,
						cr,
						sac_notrx,
						origen,
						descripcion)
				values(	_cuenta,
						_no_remesa,
						_renglon,
						_db,
						_cr,
						_res_notrx,
						_res_origen,
						'DIFERENCIA ENTRE REMESA Y COMPROBANTE');
			end foreach			
		end if
	elif _res_origen = 'REC' then
		select sum(debito+credito)
		  into _mto_recasien
		  from recasien
		 where sac_notrx = _res_notrx
           and cuenta    = _cuenta
		   and periodo   = a_periodo1;
		   
		let _dif = _monto - _mto_recasien;
		if  _dif = 0 then
			continue foreach;
		else
		    foreach
				select no_tranrec,
					   debito,
					   credito
				  into _no_tranrec,
					   _db,
					   _cr
				  from recasien
				 where sac_notrx = _res_notrx
				   and cuenta    = _cuenta
				   and periodo   = a_periodo1
			   
				insert into tmp_contable(
						cuenta,
						no_tranrec,
						db,
						cr,
						sac_notrx,
						origen,
						descripcion)
				values(	_cuenta,
						_no_tranrec,
						_db,
						_cr,
						_res_notrx,
						_res_origen,
						'DIFERENCIA ENTRE TRANSACCION Y COMPROBANTE');
			end foreach		
		end if
	elif _res_origen = 'PRO' then
		select sum(debito+credito)
		  into _mto_endasien
		  from endasien
		 where sac_notrx = _res_notrx
           and cuenta    = _cuenta
		   and periodo   = a_periodo1;
		   
		let _dif = _monto - _mto_endasien;
		if  _dif = 0 then
			foreach
				select no_poliza,
				       no_endoso,
					   debito,
					   credito
				  into _no_poliza,
				       _no_endoso,
					   _db,
					   _cr
				  from endasien
				 where sac_notrx = _res_notrx
				   and cuenta    = _cuenta
				   and periodo   = a_periodo1

				select prima_suscrita
				  into _prima_suscrita
				  from endedmae
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;

				if ((_prima_suscrita) <> ((_db + _cr) * -1 )) then
					insert into tmp_contable(
							cuenta,
							no_poliza,
							no_endoso,
							db,
							cr,
							sac_notrx,
							origen,
							monto_tecnico,
							descripcion)
					values(	_cuenta,
							_no_poliza,
							_no_endoso,
							_db,
							_cr,
							_res_notrx,
							_res_origen,
							_prima_suscrita,
							'DIFERENCIA ENTRE PBS Y ASIENTOS DE PRODUCCION');
				else
					continue foreach;
				end if
			end foreach
		else
		    foreach
				select no_poliza,
				       no_endoso,
					   debito,
					   credito
				  into _no_poliza,
				       _no_endoso,
					   _db,
					   _cr
				  from endasien
				 where sac_notrx = _res_notrx
				   and cuenta    = _cuenta
				   and periodo   = a_periodo1

				insert into tmp_contable(
						cuenta,
						no_poliza,
						no_endoso,
						db,
						cr,
						sac_notrx,
						origen,
						descripcion)
				values(	_cuenta,
						_no_poliza,
						_no_endoso,
						_db,
						_cr,
						_res_notrx,
						_res_origen,
						'DIFERENCIA ENTRE ASIENTOS DE PRODUCCION Y COMPROBANTE');
			end foreach		
		end if
	elif _res_origen = 'CGL' then
		foreach
			select res_comprobante,
			       res_debito,
				   res_credito
			  into _res_comprobante,
                   _res_db,
                   _res_cr
              from cglresumen
             where res_cuenta = _cuenta
			   and res_fechatrx >= _fecha1
			   and res_fechatrx <= _fecha2
			   and res_origen = 'CGL'
			   and res_notrx  = _res_notrx
			  
   			insert into tmp_contable(
					cuenta,
					origen,
					db,
					cr,
					sac_notrx,
					comprobante,
					descripcion)
			values(	_cuenta,
					_res_origen,
					_res_db,
					_res_cr,
					_res_notrx,
					_res_comprobante,
					'COMPROBANTES MANUALES');
		end foreach			
	end if
end foreach

foreach
	select c.res_cuenta,
		   c.res_notrx,
	       c.res_origen,
		   c.res_debito,
		   c.res_credito,
		   c.res_comprobante,
		   a.no_remesa,
		   a.renglon
	  into _cuenta,
		   _res_notrx,
	       _res_origen,
		   _res_db,
		   _res_cr,		   
		   _res_comprobante,
		   _no_remesa,
		   _renglon
	 from cglresumen c, cobasien a, cobredet d
	where c.res_notrx = a.sac_notrx
	  and c.res_cuenta = a.cuenta
	  and a.no_remesa  = d.no_remesa
	  and a.renglon = d.renglon
	  and res_cuenta in (select codigo from tmp_codigos) 
	  and res_fechatrx >= _fecha1
	  and res_fechatrx <= _fecha2
	  and d.tipo_mov = 'M'
	order by 1,3,2

	insert into tmp_contable(
			cuenta,
			origen,
			no_remesa,
			renglon,
			db,
			cr,
			sac_notrx,
			comprobante,
			descripcion)
	values(	_cuenta,
			_res_origen,
			_no_remesa,
			_renglon,
			_res_db,
			_res_cr,
			_res_notrx,
			_res_comprobante,
			'AFECTACION DE CATALOGO');
end foreach

{foreach
	select sldet_cuenta,sum(sldet_saldop)
	  into _cuenta,_saldo_contable
	  from cglsaldodet
	 where sldet_periodo = a_periodo1[6,7]
	   and sldet_ano = a_periodo1[1,4]
	   and sldet_cuenta in (select codigo from tmp_codigos)
	 group by sldet_cuenta

	if _saldo_contable is null then
		let _saldo_contable = 0.00;
	end if

	select sum(res_debito),
		   sum(res_credito),
		   sum(res_debito-res_credito)
	  into _res_db,
		   _res_cr,
		   _monto
	  from cglresumen
	 where res_cuenta = _cuenta
	   and res_fechatrx >= _fecha1
	   and res_fechatrx <= _fecha2;

	if (_monto - _saldo_contable) <> 0 then
		insert into tmp_contable(
			cuenta,
			origen,
			no_tranrec,
			no_remesa,
			db,
			cr,
			sac_notrx,
			monto_tecnico,
			descripcion)
	values(	_cuenta,
			'',
			'SALDODET',
			'SALDODET',
			_res_db,
			_res_cr,
			'',
			_saldo_contable,
			'DIFERENCIAS ENTRE COMPROBANTE Y SALDO CONTABLE');
	end if
end foreach}

drop table if exists tmp_codigos;

return 0, 'Carga Exitosa';
end
end procedure;