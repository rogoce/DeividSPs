-- Procedimiento que Carga el Incurridos netos de los Reclamos 
-- en un Periodo Dado
--
-- Creado    : 10/06/2014 - Autor: ANGEL TELLO
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec01b5;
create procedure informix.sp_rec01b5(
a_compania  char(3), 
a_agencia   char(3), 
a_periodo1  char(7), 
a_periodo2  char(7), 
a_cuenta    char(18))
returning	varchar(50)	as compania,
			varchar(50)	as nom_cuenta,
			char(18)	as cuenta,			
			char(3)		as origen,
			dec(16,2)	as db,
			dec(16,2)	as cr,
			dec(16,2)	as monto_tecnico,
			integer		as sac_notrx,
			char(10)	as no_remesa,
			integer     as renglon,
			char(10)	as transaccion;

define _nom_cuenta			varchar(50);
define v_compania_nombre	varchar(50);
define _cuenta				char(18);
define _res_notrx           integer;
define _res_origen          char(3);
define _monto				dec(16,2);
define _fecha1				date;
define _fecha2				date;
define _mto_cobasien		dec(16,2);
define _db					dec(16,2);
define _cr					dec(16,2);
define _no_reclamo          char(10);
define _renglon				integer;
define _mto_recasien		dec(16,2);
define _dif					dec(16,2);
define _no_tranrec			char(10);
define _res_comprobante		char(15);
define _res_db				dec(16,2);
define _res_cr				dec(16,2);
define _tri					varchar(255);
define _cnt                 integer;
define _cod_tipotran        char(3);
define _no_remesa           char(10);
define _prima_suscrita      dec(16,2);
define _transaccion         char(10);


let v_compania_nombre = sp_sis01(a_compania);
--drop table if exists tmp_salida;

let _monto        = 0;
let _mto_cobasien = 0;
let _mto_recasien = 0;
let _db           = 0;
let _cr           = 0;
let _res_db	      = 0;
let _res_cr       = 0;
let _dif          = 0;
let _prima_suscrita = 0;

create temp table tmp_salida(
no_tranrec  char(10),
cod_tipotran char(3),
no_reclamo   char(10)
) with no log;

create temp table tmp_contable(
cuenta			char(18),
no_remesa		char(10),
renglon			integer,
db				dec(16,2),
cr				dec(16,2),
monto_tecnico	dec(16,2),
sac_notrx		integer,
no_tranrec		char(10),
origen			char(3),
no_reclamo		char(10)) with no log;

--let _fecha1 = sp_sis36bk(a_periodo1); --retorna 01/11/2015 si el periodo es 2015-11
--let _fecha2 = sp_sis36(a_periodo1);   --retorna 30/11/2015 si el periodo es   2015-11

let _tri = sp_rec01d(a_compania, a_agencia, a_periodo1, a_periodo2);

foreach
	select no_reclamo
	  into _no_reclamo
	  from tmp_sinis 
	 group by no_reclamo
	 order by no_reclamo

	FOREACH

	 SELECT no_tranrec,cod_tipotran,monto
	   INTO _no_tranrec,_cod_tipotran,_monto
		FROM rectrmae
	  WHERE cod_compania = a_compania
		AND actualizado  = 1
		AND cod_tipotran IN ('004','005','006','007')
		AND periodo      >= a_periodo1 
		AND periodo      <= a_periodo2
		AND no_reclamo   = _no_reclamo
		AND monto        <> 0

				insert into tmp_salida(
						no_tranrec,
						cod_tipotran,
						no_reclamo,
						monto
						)
				values(	_no_tranrec,
						_cod_tipotran,
						_no_reclamo,
						_monto
						);
	end foreach			
end foreach

foreach
	select no_tranrec,
		   cod_tipotran,
		   no_reclamo,
		   monto
	  into _no_tranrec,
		   _cod_tipotran,
		   _no_reclamo,
		   _monto
	  from tmp_salida
	 order by 1

	 select count(*)
       into _cnt
       from recasien
      where no_tranrec = _no_tranrec;

     if _cnt is null then
		let _cnt = 0;
	 end if
	  
	if _cnt = 0 then
	   foreach
		select no_remesa,
			   renglon
		  into _no_remesa,
               _renglon		  
		  from cobredet
         where actualizado = 1
		   and no_reclamo = _no_reclamo
		   
		select count(*)
          into _cnt
          from cobasien
         where no_remesa = _no_remesa
           and renglon   = _renglon;
		   
        if _cnt is null then
			let _cnt = 0;
		end if
	  
		if _cnt = 0 then
			insert into tmp_contable(
					cuenta,
					no_tranrec,
					no_reclamo,
					db,
					cr,
					sac_notrx,
					origen,
					monto_tecnico,
					no_remesa,
					renglon)
			values(	a_cuenta,
					_no_tranrec,
					_no_reclamo,
					0.00,
					0.00,
					'',
					'',
					_monto,
					_no_remesa,
					_renglon);
		end if
		
	   end foreach
    end if  
end foreach

foreach

	select cuenta,
		   no_remesa,
		   renglon,
		   db,
		   cr, 
		   sac_notrx,
		   origen,
		   monto_tecnico,
		   no_tranrec,
		   no_reclamo
	  into _cuenta,
	       _no_remesa,
		   _renglon,
		   _db,
		   _cr,
		   _res_notrx,
		   _res_origen,
		   _prima_suscrita,
		   _no_tranrec,
		   _no_reclamo
	  from tmp_contable
	 order by cuenta,origen,sac_notrx

	select transaccion
	  into _transaccion
	  from rectrmae
	 where no_tranrec = _no_tranrec;

	select cta_nombre
	  into _nom_cuenta
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	return	v_compania_nombre,
			_nom_cuenta,
			_cuenta,
			_res_origen,
			_db,
			_cr,
			_prima_suscrita,
			_res_notrx,
			_no_remesa,
			_renglon,
			_transaccion
			with resume;
end foreach
drop table tmp_sinis;
drop table tmp_salida;
drop table tmp_contable;
end procedure;