-- Reporte de Presupuesto de Gastos
-- Creado    : 17/01/2011 
-- Autor : Henry Giron
drop procedure sp_sac220;
create procedure "informix".sp_sac220(
a_ano 	  char(4), 
a_mes 	  smallint,
a_nivel	  smallint,
a_db	  char(18),
a_cta_gts char(12),
a_ccosto  char(3)
)

define _cuenta		char(12);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _saldo		dec(16,2);
define _pres_monto	dec(16,2);
define _nombre		char(50);
define _referencia	char(20);

define _saldo_ant	dec(16,2);
define _saldo_act	dec(16,2);

define _mes_ant		smallint;
define _ano_ant		char(4);
define _ano_int		smallint;
define _recibe		char(1);
define _nivel		char(1);

define _det_tipo	char(2);
define _det_ccosto	char(3);

define _imp_delmes	dec(16,2);
define _porc_delmes dec(16,2);
define _saldo_almes dec(16,2);
define _pres_almes	dec(16,2);
define _imp_almes	dec(16,2);
define _porc_almes	dec(16,2);
define _pres_alanio dec(16,2);
define _imp_alanio	dec(16,2);
define _porc_alanio	dec(16,2);

define _debito_ant	    dec(16,2);
define _credito_ant	    dec(16,2);
define _saldo_anterior	dec(16,2);
define _pres_monto_ant	dec(16,2);

define _rubro			smallint;
define _tipo			char(12);
define _nombre_tipo		char(50);
define _nombre_rubro	char(50);
define _orden_rubro		smallint;	

--set debug file to "sp_sac220.trc";
--trace on;

let _ano_int = a_ano;
let _mes_ant = a_mes;

if a_mes = 1 then
	let _ano_int = _ano_int - 1;
	let _mes_ant = 14;
else
	let _mes_ant = _mes_ant - 1;
end if

let _ano_ant = _ano_int;

if a_nivel = 1 then
	let _recibe = "*";
	let _nivel  = "1";
else
	let _recibe = "S";
	let _nivel  = "*";
end if
let _porc_alanio = 0;
let _porc_almes = 0;
let _det_tipo   = "*";
let _det_ccosto	= "*";
let a_ccosto = "*";

--  let _det_ccosto	= trim(a_ccosto);

if a_db = "sac" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
		and cta_cuenta like (a_cta_gts)
	  order by 1

	   foreach
		select distinct sldet_ccosto
		  into _det_ccosto
		  from sac:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes
		   and sldet_ccosto  matches a_ccosto

			select sum(sldet_debtop),
				   sum(sldet_cretop),
				   sum(sldet_saldop)
			  into _debito,
				   _credito,
				   _saldo_act
			  from sac:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo = a_mes
			   and sldet_ccosto  matches _det_ccosto;

			select sum(sldet_saldop)
			  into _saldo_ant
			  from sac:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant
			   and sldet_ccosto  matches _det_ccosto;

			if _debito is null then
				let _debito = 0;
			end if

			if _credito is null then
				let _credito = 0;
			end if

			if _saldo_act is null then
				let _saldo_act = 0;
			end if

			if _saldo_ant is null then
				let _saldo_ant = 0;
			end if

			if _debito    = 0 and 
			   _credito   = 0 and
			   _saldo_act = 0 and 
			   _saldo_ant = 0 then
--				continue foreach;
			end if

			let _saldo = _debito + _credito;

		   select sum(pre2_montomes) 
		     into _pres_monto
			 from sac:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	= a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto is null then
				let _pres_monto = 0;
			end if

--          Muestren todas las cuentas 6000%
--			if _pres_monto    = 0  then
--				continue foreach;
--			end if

			let _imp_delmes = _pres_monto - _saldo;

			if 	_pres_monto <> 0 then
				let _porc_delmes = 	(_pres_monto - _saldo)/_pres_monto;
			else
				let _porc_delmes = 0;
			end if

			select sum(sldet_debtop),
				   sum(sldet_cretop)
			  into _debito_ant,
				   _credito_ant
			  from sac:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo < a_mes
			   and sldet_ccosto  matches _det_ccosto;

			if _debito_ant is null then
				let _debito_ant = 0;
			end if

			if _credito_ant is null then
				let _credito_ant = 0;
			end if

			let _saldo_anterior = _debito_ant + _credito_ant;

		   select sum(pre2_montomes) 
		     into _pres_monto_ant
			 from sac:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	< a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto_ant is null then
				let _pres_monto_ant = 0;
			end if

			let _saldo_almes = _saldo + _saldo_anterior;
			let _pres_almes  = _pres_monto + _pres_monto_ant;									
																								
			let _imp_almes = _pres_almes - _saldo_almes;

			if 	_pres_almes <> 0 then
				let _porc_almes = 	(_pres_almes - _saldo_almes)/_pres_almes;
			else
				let _porc_almes = 0;
			end if

		   select sum(pre2_montomes) 
		     into _pres_alanio
			 from sac:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_alanio is null then
				let _pres_alanio = 0;
			end if

			let _imp_alanio = _pres_alanio - _saldo_almes;

			if 	_pres_alanio <> 0 then
				let _porc_alanio = 	(_pres_alanio - _saldo_almes)/_pres_alanio;
			else
				let _porc_almes = 0;
			end if


			select cod_tipo 
			  into _tipo 
			  from sac:cglcuentas 
			 where cta_cuenta = _cuenta; 

			   if  _tipo is null then
				   let _rubro = 0;
				   let _tipo  = _cuenta;			
				   let _nombre_tipo  = _nombre;		
				   let _nombre_rubro = "";	
				   let _orden_rubro  = 0;		
			 else

				select rubro,nombre 
				  into _rubro,_nombre_tipo 
				  from sac:cgltigas
				 where cod_tipo = _tipo; 

					if _rubro = '1' then
						let _nombre_rubro = "TOTAL DE GASTOS DE PERSONAL";
					end if
					if _rubro = '2' then
						let _nombre_rubro = "TOTAL DE GASTOS ADMINISTRATIVOS";
					end if
					if _rubro = '3' then
						let _nombre_rubro = "TOTAL DE GASTOS COMERCIALES";
					end if
					if _rubro = '4' then
						let _nombre_rubro = "TOTAL DE GASTOS PUBLICIDAD";
					end if
					if _rubro = '5' then
						let _nombre_rubro = "TOTAL GASTOS GENERALES";
					end if

			end if

			insert into tmp_gtsprea(
			cuenta,
			nombre,
			debito,
			credito,
			saldo,
			saldo_ant,
			saldo_act,
			referencia,
			pres_monto,
			imp_delmes,	
			porc_delmes,
			saldo_almes,
			pres_almes,	
			imp_almes,	
			porc_almes,	
			pres_alanio, 
			imp_alanio,	
			porc_alanio,
			ccosto,
			rubro,		
			tipo,		
			nombre_tipo,
			nombre_rubro
			)
			values(
			_cuenta,		
			_nombre,		
			_debito,		
			_credito,		
			_saldo,			
			_saldo_ant,		
			_saldo_act,		
			_referencia,	
			_pres_monto,	
			_imp_delmes,	
			_porc_delmes,	
			_saldo_almes,	
			_pres_almes,	
			_imp_almes,		
			_porc_almes,	
			_pres_alanio, 	
			_imp_alanio,	
			_porc_alanio,
			_det_ccosto,
			_rubro,		
			_tipo,		
			_nombre_tipo,
			_nombre_rubro   
			);

		end foreach
	end foreach

elif a_db = "sac001" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac001:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
		and cta_cuenta like (a_cta_gts)
	  order by 1

	   foreach
		select distinct sldet_ccosto
		  into _det_ccosto
		  from sac001:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes
		   and sldet_ccosto  matches a_ccosto

			select sum(sldet_debtop),
				   sum(sldet_cretop),
				   sum(sldet_saldop)
			  into _debito,
				   _credito,
				   _saldo_act
			  from sac001:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo = a_mes
			   and sldet_ccosto  matches _det_ccosto;

			select sum(sldet_saldop)
			  into _saldo_ant
			  from sac001:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant
			   and sldet_ccosto  matches _det_ccosto;

			if _debito is null then
				let _debito = 0;
			end if

			if _credito is null then
				let _credito = 0;
			end if

			if _saldo_act is null then
				let _saldo_act = 0;
			end if

			if _saldo_ant is null then
				let _saldo_ant = 0;
			end if

			if _debito    = 0 and 
			   _credito   = 0 and
			   _saldo_act = 0 and 
			   _saldo_ant = 0 then
				continue foreach;
			end if

			let _saldo = _debito + _credito;

		   select pre2_montomes 
		     into _pres_monto
			 from sac001:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	= a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto is null then
				let _pres_monto = 0;
			end if

			let _imp_delmes = _pres_monto - _saldo;

			if 	_pres_monto <> 0 then
				let _porc_delmes = 	(_pres_monto - _saldo)/_pres_monto;
			else
				let _porc_delmes = 0;
			end if

			select sum(sldet_debtop),
				   sum(sldet_cretop)
			  into _debito_ant,
				   _credito_ant
			  from sac001:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo < a_mes
			   and sldet_ccosto  matches _det_ccosto;

			if _debito_ant is null then
				let _debito_ant = 0;
			end if

			if _credito_ant is null then
				let _credito_ant = 0;
			end if

			let _saldo_anterior = _debito_ant + _credito_ant;

		   select pre2_montomes 
		     into _pres_monto_ant
			 from sac001:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	< a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto_ant is null then
				let _pres_monto_ant = 0;
			end if

			let _saldo_almes = _saldo + _saldo_anterior;
			let _pres_almes  = _pres_monto + _pres_monto_ant;

			let _imp_almes = _pres_almes - _saldo_almes;

			if 	_pres_almes <> 0 then
				let _porc_almes = 	(_pres_almes - _saldo_almes)/_pres_almes;
			else
				let _porc_almes = 0;
			end if

		   select pre2_montomes 
		     into _pres_alanio
			 from sac001:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_alanio is null then
				let _pres_alanio = 0;
			end if

			let _imp_alanio = _pres_alanio - _saldo_almes;
			let _porc_alanio = 	(_pres_alanio - _saldo_almes)/_pres_alanio;

			insert into tmp_gtsprea(
			cuenta,
			nombre,
			debito,
			credito,
			saldo,
			saldo_ant,
			saldo_act,
			referencia,
			pres_monto,
			imp_delmes,	
			porc_delmes,
			saldo_almes,
			pres_almes,	
			imp_almes,	
			porc_almes,	
			pres_alanio, 
			imp_alanio,	
			porc_alanio,
			ccosto
			)
			values(
			_cuenta,		
			_nombre,		
			_debito,		
			_credito,		
			_saldo,			
			_saldo_ant,		
			_saldo_act,		
			_referencia,	
			_pres_monto,	
			_imp_delmes,	
			_porc_delmes,	
			_saldo_almes,	
			_pres_almes,	
			_imp_almes,		
			_porc_almes,	
			_pres_alanio, 	
			_imp_alanio,	
			_porc_alanio,
			_det_ccosto	
			);

		end foreach

	end foreach

elif a_db = "sac002" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac002:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
		and cta_cuenta like (a_cta_gts)
	  order by 1

	   foreach
		select distinct sldet_ccosto
		  into _det_ccosto
		  from sac002:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes
		   and sldet_ccosto  matches a_ccosto

			select sum(sldet_debtop),
				   sum(sldet_cretop),
				   sum(sldet_saldop)
			  into _debito,
				   _credito,
				   _saldo_act
			  from sac002:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo = a_mes
			   and sldet_ccosto  matches _det_ccosto;

			select sum(sldet_saldop)
			  into _saldo_ant
			  from sac002:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant
			   and sldet_ccosto  matches _det_ccosto;

			if _debito is null then
				let _debito = 0;
			end if

			if _credito is null then
				let _credito = 0;
			end if

			if _saldo_act is null then
				let _saldo_act = 0;
			end if

			if _saldo_ant is null then
				let _saldo_ant = 0;
			end if

			if _debito    = 0 and 
			   _credito   = 0 and
			   _saldo_act = 0 and 
			   _saldo_ant = 0 then
				continue foreach;
			end if

			let _saldo = _debito + _credito;

		   select pre2_montomes 
		     into _pres_monto
			 from sac002:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	= a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto is null then
				let _pres_monto = 0;
			end if

			let _imp_delmes = _pres_monto - _saldo;
			let _porc_delmes = 	(_pres_monto - _saldo)/_pres_monto;

			select sum(sldet_debtop),
				   sum(sldet_cretop)
			  into _debito_ant,
				   _credito_ant
			  from sac002:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo < a_mes
			   and sldet_ccosto  matches _det_ccosto;

			if _debito_ant is null then
				let _debito_ant = 0;
			end if

			if _credito_ant is null then
				let _credito_ant = 0;
			end if

			let _saldo_anterior = _debito_ant + _credito_ant;

		   select pre2_montomes 
		     into _pres_monto_ant
			 from sac002:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	< a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto_ant is null then
				let _pres_monto_ant = 0;
			end if

			let _saldo_almes = _saldo + _saldo_anterior;
			let _pres_almes  = _pres_monto + _pres_monto_ant;

			let _imp_almes = _pres_almes - _saldo_almes;
			let _porc_almes = 	(_pres_almes - _saldo_almes)/_pres_almes;

		   select pre2_montomes 
		     into _pres_alanio
			 from sac002:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_alanio is null then
				let _pres_alanio = 0;
			end if

			let _imp_alanio = _pres_alanio - _saldo_almes;
			let _porc_alanio = 	(_pres_alanio - _saldo_almes)/_pres_alanio;

			insert into tmp_gtsprea(
			cuenta,
			nombre,
			debito,
			credito,
			saldo,
			saldo_ant,
			saldo_act,
			referencia,
			pres_monto,
			imp_delmes,	
			porc_delmes,
			saldo_almes,
			pres_almes,	
			imp_almes,	
			porc_almes,	
			pres_alanio, 
			imp_alanio,	
			porc_alanio,
			ccosto
			)
			values(
			_cuenta,		
			_nombre,		
			_debito,		
			_credito,		
			_saldo,			
			_saldo_ant,		
			_saldo_act,		
			_referencia,	
			_pres_monto,	
			_imp_delmes,	
			_porc_delmes,	
			_saldo_almes,	
			_pres_almes,	
			_imp_almes,		
			_porc_almes,	
			_pres_alanio, 	
			_imp_alanio,	
			_porc_alanio,
			_det_ccosto	
			);

		end foreach

	end foreach

elif a_db = "sac003" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac003:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
		and cta_cuenta like (a_cta_gts)
	  order by 1

	   foreach
		select distinct sldet_ccosto
		  into _det_ccosto
		  from sac003:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes
		   and sldet_ccosto  matches a_ccosto


			select sum(sldet_debtop),
				   sum(sldet_cretop),
				   sum(sldet_saldop)
			  into _debito,
				   _credito,
				   _saldo_act
			  from sac003:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo = a_mes
			   and sldet_ccosto  matches _det_ccosto;

			select sum(sldet_saldop)
			  into _saldo_ant
			  from sac003:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant
			   and sldet_ccosto  matches _det_ccosto;

			if _debito is null then
				let _debito = 0;
			end if

			if _credito is null then
				let _credito = 0;
			end if

			if _saldo_act is null then
				let _saldo_act = 0;
			end if

			if _saldo_ant is null then
				let _saldo_ant = 0;
			end if

			if _debito    = 0 and 
			   _credito   = 0 and
			   _saldo_act = 0 and 
			   _saldo_ant = 0 then
				continue foreach;
			end if

			let _saldo = _debito + _credito;

		   select pre2_montomes 
		     into _pres_monto
			 from sac003:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	= a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto is null then
				let _pres_monto = 0;
			end if

			let _imp_delmes = _pres_monto - _saldo;
			let _porc_delmes = 	(_pres_monto - _saldo)/_pres_monto;

			select sum(sldet_debtop),
				   sum(sldet_cretop)
			  into _debito_ant,
				   _credito_ant
			  from sac003:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo < a_mes
			   and sldet_ccosto  matches _det_ccosto;

			if _debito_ant is null then
				let _debito_ant = 0;
			end if

			if _credito_ant is null then
				let _credito_ant = 0;
			end if

			let _saldo_anterior = _debito_ant + _credito_ant;

		   select pre2_montomes 
		     into _pres_monto_ant
			 from sac003:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	< a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto_ant is null then
				let _pres_monto_ant = 0;
			end if

			let _saldo_almes = _saldo + _saldo_anterior;
			let _pres_almes  = _pres_monto + _pres_monto_ant;

			let _imp_almes = _pres_almes - _saldo_almes;
			let _porc_almes = 	(_pres_almes - _saldo_almes)/_pres_almes;

		   select pre2_montomes 
		     into _pres_alanio
			 from sac003:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_alanio is null then
				let _pres_alanio = 0;
			end if

			let _imp_alanio = _pres_alanio - _saldo_almes;
			let _porc_alanio = 	(_pres_alanio - _saldo_almes)/_pres_alanio;

			insert into tmp_gtsprea(
			cuenta,
			nombre,
			debito,
			credito,
			saldo,
			saldo_ant,
			saldo_act,
			referencia,
			pres_monto,
			imp_delmes,	
			porc_delmes,
			saldo_almes,
			pres_almes,	
			imp_almes,	
			porc_almes,	
			pres_alanio, 
			imp_alanio,	
			porc_alanio,
			ccosto
			)
			values(
			_cuenta,		
			_nombre,		
			_debito,		
			_credito,		
			_saldo,			
			_saldo_ant,		
			_saldo_act,		
			_referencia,	
			_pres_monto,	
			_imp_delmes,	
			_porc_delmes,	
			_saldo_almes,	
			_pres_almes,	
			_imp_almes,		
			_porc_almes,	
			_pres_alanio, 	
			_imp_alanio,	
			_porc_alanio,
			_det_ccosto	
			);

		end foreach

	end foreach


elif a_db = "sac004" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac004:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
		and cta_cuenta like (a_cta_gts)
	  order by 1

	   foreach
		select distinct sldet_ccosto
		  into _det_ccosto
		  from sac004:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes
		   and sldet_ccosto  matches a_ccosto

			select sum(sldet_debtop),
				   sum(sldet_cretop),
				   sum(sldet_saldop)
			  into _debito,
				   _credito,
				   _saldo_act
			  from sac004:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo = a_mes
			   and sldet_ccosto  matches _det_ccosto;

			select sum(sldet_saldop)
			  into _saldo_ant
			  from sac004:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant
			   and sldet_ccosto  matches _det_ccosto;

			if _debito is null then
				let _debito = 0;
			end if

			if _credito is null then
				let _credito = 0;
			end if

			if _saldo_act is null then
				let _saldo_act = 0;
			end if

			if _saldo_ant is null then
				let _saldo_ant = 0;
			end if

			if _debito    = 0 and 
			   _credito   = 0 and
			   _saldo_act = 0 and 
			   _saldo_ant = 0 then
				continue foreach;
			end if

			let _saldo = _debito + _credito;

		   select pre2_montomes 
		     into _pres_monto
			 from sac004:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	= a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto is null then
				let _pres_monto = 0;
			end if

			let _imp_delmes = _pres_monto - _saldo;
			let _porc_delmes = 	(_pres_monto - _saldo)/_pres_monto;

			select sum(sldet_debtop),
				   sum(sldet_cretop)
			  into _debito_ant,
				   _credito_ant
			  from sac004:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo < a_mes
			   and sldet_ccosto  matches _det_ccosto;

			if _debito_ant is null then
				let _debito_ant = 0;
			end if

			if _credito_ant is null then
				let _credito_ant = 0;
			end if

			let _saldo_anterior = _debito_ant + _credito_ant;

		   select pre2_montomes 
		     into _pres_monto_ant
			 from sac004:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	< a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto_ant is null then
				let _pres_monto_ant = 0;
			end if

			let _saldo_almes = _saldo + _saldo_anterior;
			let _pres_almes  = _pres_monto + _pres_monto_ant;

			let _imp_almes = _pres_almes - _saldo_almes;
			let _porc_almes = 	(_pres_almes - _saldo_almes)/_pres_almes;

		   select pre2_montomes 
		     into _pres_alanio
			 from sac004:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_alanio is null then
				let _pres_alanio = 0;
			end if

			let _imp_alanio = _pres_alanio - _saldo_almes;
			let _porc_alanio = 	(_pres_alanio - _saldo_almes)/_pres_alanio;

			insert into tmp_gtsprea(
			cuenta,
			nombre,
			debito,
			credito,
			saldo,
			saldo_ant,
			saldo_act,
			referencia,
			pres_monto,
			imp_delmes,	
			porc_delmes,
			saldo_almes,
			pres_almes,	
			imp_almes,	
			porc_almes,	
			pres_alanio, 
			imp_alanio,	
			porc_alanio,
			ccosto
			)
			values(
			_cuenta,		
			_nombre,		
			_debito,		
			_credito,		
			_saldo,			
			_saldo_ant,		
			_saldo_act,		
			_referencia,	
			_pres_monto,	
			_imp_delmes,	
			_porc_delmes,	
			_saldo_almes,	
			_pres_almes,	
			_imp_almes,		
			_porc_almes,	
			_pres_alanio, 	
			_imp_alanio,	
			_porc_alanio,
			_det_ccosto	
			);

		end foreach

	end foreach


elif a_db = "sac005" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac005:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
		and cta_cuenta like (a_cta_gts)
	  order by 1

	   foreach
		select distinct sldet_ccosto
		  into _det_ccosto
		  from sac005:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes
		   and sldet_ccosto  matches a_ccosto

			select sum(sldet_debtop),
				   sum(sldet_cretop),
				   sum(sldet_saldop)
			  into _debito,
				   _credito,
				   _saldo_act
			  from sac005:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo = a_mes
			   and sldet_ccosto  matches _det_ccosto;

			select sum(sldet_saldop)
			  into _saldo_ant
			  from sac005:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant
			   and sldet_ccosto  matches _det_ccosto;

			if _debito is null then
				let _debito = 0;
			end if

			if _credito is null then
				let _credito = 0;
			end if

			if _saldo_act is null then
				let _saldo_act = 0;
			end if

			if _saldo_ant is null then
				let _saldo_ant = 0;
			end if

			if _debito    = 0 and 
			   _credito   = 0 and
			   _saldo_act = 0 and 
			   _saldo_ant = 0 then
				continue foreach;
			end if

			let _saldo = _debito + _credito;

		   select pre2_montomes 
		     into _pres_monto
			 from sac005:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	= a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto is null then
				let _pres_monto = 0;
			end if

			let _imp_delmes = _pres_monto - _saldo;
			let _porc_delmes = 	(_pres_monto - _saldo)/_pres_monto;

			select sum(sldet_debtop),
				   sum(sldet_cretop)
			  into _debito_ant,
				   _credito_ant
			  from sac005:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo < a_mes
			   and sldet_ccosto  matches _det_ccosto;

			if _debito_ant is null then
				let _debito_ant = 0;
			end if

			if _credito_ant is null then
				let _credito_ant = 0;
			end if

			let _saldo_anterior = _debito_ant + _credito_ant;

		   select pre2_montomes 
		     into _pres_monto_ant
			 from sac005:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	< a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto_ant is null then
				let _pres_monto_ant = 0;
			end if

			let _saldo_almes = _saldo + _saldo_anterior;
			let _pres_almes  = _pres_monto + _pres_monto_ant;

			let _imp_almes = _pres_almes - _saldo_almes;
			let _porc_almes = 	(_pres_almes - _saldo_almes)/_pres_almes;

		   select pre2_montomes 
		     into _pres_alanio
			 from sac005:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_alanio is null then
				let _pres_alanio = 0;
			end if

			let _imp_alanio = _pres_alanio - _saldo_almes;
			let _porc_alanio = 	(_pres_alanio - _saldo_almes)/_pres_alanio;

			insert into tmp_gtsprea(
			cuenta,
			nombre,
			debito,
			credito,
			saldo,
			saldo_ant,
			saldo_act,
			referencia,
			pres_monto,
			imp_delmes,	
			porc_delmes,
			saldo_almes,
			pres_almes,	
			imp_almes,	
			porc_almes,	
			pres_alanio, 
			imp_alanio,	
			porc_alanio,
			ccosto
			)
			values(
			_cuenta,		
			_nombre,		
			_debito,		
			_credito,		
			_saldo,			
			_saldo_ant,		
			_saldo_act,		
			_referencia,	
			_pres_monto,	
			_imp_delmes,	
			_porc_delmes,	
			_saldo_almes,	
			_pres_almes,	
			_imp_almes,		
			_porc_almes,	
			_pres_alanio, 	
			_imp_alanio,	
			_porc_alanio,
			_det_ccosto	
			);

		end foreach

	end foreach

elif a_db = "sac006" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac006:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
		and cta_cuenta like (a_cta_gts)
	  order by 1

	   foreach
		select distinct sldet_ccosto
		  into _det_ccosto
		  from sac006:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes
		   and sldet_ccosto  matches a_ccosto

			select sum(sldet_debtop),
				   sum(sldet_cretop),
				   sum(sldet_saldop)
			  into _debito,
				   _credito,
				   _saldo_act
			  from sac006:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo = a_mes
			   and sldet_ccosto  matches _det_ccosto;

			select sum(sldet_saldop)
			  into _saldo_ant
			  from sac006:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant
			   and sldet_ccosto  matches _det_ccosto;

			if _debito is null then
				let _debito = 0;
			end if

			if _credito is null then
				let _credito = 0;
			end if

			if _saldo_act is null then
				let _saldo_act = 0;
			end if

			if _saldo_ant is null then
				let _saldo_ant = 0;
			end if

			if _debito    = 0 and 
			   _credito   = 0 and
			   _saldo_act = 0 and 
			   _saldo_ant = 0 then
				continue foreach;
			end if

			let _saldo = _debito + _credito;

		   select pre2_montomes 
		     into _pres_monto
			 from sac006:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	= a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto is null then
				let _pres_monto = 0;
			end if

			let _imp_delmes = _pres_monto - _saldo;
			let _porc_delmes = 	(_pres_monto - _saldo)/_pres_monto;

			select sum(sldet_debtop),
				   sum(sldet_cretop)
			  into _debito_ant,
				   _credito_ant
			  from sac006:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo < a_mes
			   and sldet_ccosto  matches _det_ccosto;

			if _debito_ant is null then
				let _debito_ant = 0;
			end if

			if _credito_ant is null then
				let _credito_ant = 0;
			end if

			let _saldo_anterior = _debito_ant + _credito_ant;

		   select pre2_montomes 
		     into _pres_monto_ant
			 from sac006:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	< a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto_ant is null then
				let _pres_monto_ant = 0;
			end if

			let _saldo_almes = _saldo + _saldo_anterior;
			let _pres_almes  = _pres_monto + _pres_monto_ant;

			let _imp_almes = _pres_almes - _saldo_almes;
			let _porc_almes = 	(_pres_almes - _saldo_almes)/_pres_almes;

		   select pre2_montomes 
		     into _pres_alanio
			 from sac006:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_alanio is null then
				let _pres_alanio = 0;
			end if

			let _imp_alanio = _pres_alanio - _saldo_almes;
			let _porc_alanio = 	(_pres_alanio - _saldo_almes)/_pres_alanio;

			insert into tmp_gtsprea(
			cuenta,
			nombre,
			debito,
			credito,
			saldo,
			saldo_ant,
			saldo_act,
			referencia,
			pres_monto,
			imp_delmes,	
			porc_delmes,
			saldo_almes,
			pres_almes,	
			imp_almes,	
			porc_almes,	
			pres_alanio, 
			imp_alanio,	
			porc_alanio,
			ccosto
			)
			values(
			_cuenta,		
			_nombre,		
			_debito,		
			_credito,		
			_saldo,			
			_saldo_ant,		
			_saldo_act,		
			_referencia,	
			_pres_monto,	
			_imp_delmes,	
			_porc_delmes,	
			_saldo_almes,	
			_pres_almes,	
			_imp_almes,		
			_porc_almes,	
			_pres_alanio, 	
			_imp_alanio,	
			_porc_alanio,
			_det_ccosto	
			);

		end foreach

	end foreach

elif a_db = "sac007" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac007:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
		and cta_cuenta like (a_cta_gts)
	  order by 1

	   foreach
		select distinct sldet_ccosto
		  into _det_ccosto
		  from sac007:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes
		   and sldet_ccosto  matches a_ccosto

			select sum(sldet_debtop),
				   sum(sldet_cretop),
				   sum(sldet_saldop)
			  into _debito,
				   _credito,
				   _saldo_act
			  from sac007:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo = a_mes
			   and sldet_ccosto  matches _det_ccosto;

			select sum(sldet_saldop)
			  into _saldo_ant
			  from sac007:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant
			   and sldet_ccosto  matches _det_ccosto;

			if _debito is null then
				let _debito = 0;
			end if

			if _credito is null then
				let _credito = 0;
			end if

			if _saldo_act is null then
				let _saldo_act = 0;
			end if

			if _saldo_ant is null then
				let _saldo_ant = 0;
			end if

			if _debito    = 0 and 
			   _credito   = 0 and
			   _saldo_act = 0 and 
			   _saldo_ant = 0 then
				continue foreach;
			end if

			let _saldo = _debito + _credito;

		   select pre2_montomes 
		     into _pres_monto
			 from sac007:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	= a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto is null then
				let _pres_monto = 0;
			end if

			let _imp_delmes = _pres_monto - _saldo;
			let _porc_delmes = 	(_pres_monto - _saldo)/_pres_monto;

			select sum(sldet_debtop),
				   sum(sldet_cretop)
			  into _debito_ant,
				   _credito_ant
			  from sac007:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo < a_mes
			   and sldet_ccosto  matches _det_ccosto;

			if _debito_ant is null then
				let _debito_ant = 0;
			end if

			if _credito_ant is null then
				let _credito_ant = 0;
			end if

			let _saldo_anterior = _debito_ant + _credito_ant;

		   select pre2_montomes 
		     into _pres_monto_ant
			 from sac007:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	< a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto_ant is null then
				let _pres_monto_ant = 0;
			end if

			let _saldo_almes = _saldo + _saldo_anterior;
			let _pres_almes  = _pres_monto + _pres_monto_ant;

			let _imp_almes = _pres_almes - _saldo_almes;
			let _porc_almes = 	(_pres_almes - _saldo_almes)/_pres_almes;

		   select pre2_montomes 
		     into _pres_alanio
			 from sac007:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_alanio is null then
				let _pres_alanio = 0;
			end if

			let _imp_alanio = _pres_alanio - _saldo_almes;
			let _porc_alanio = 	(_pres_alanio - _saldo_almes)/_pres_alanio;

			insert into tmp_gtsprea(
			cuenta,
			nombre,
			debito,
			credito,
			saldo,
			saldo_ant,
			saldo_act,
			referencia,
			pres_monto,
			imp_delmes,	
			porc_delmes,
			saldo_almes,
			pres_almes,	
			imp_almes,	
			porc_almes,	
			pres_alanio, 
			imp_alanio,	
			porc_alanio,
			ccosto
			)
			values(
			_cuenta,		
			_nombre,		
			_debito,		
			_credito,		
			_saldo,			
			_saldo_ant,		
			_saldo_act,		
			_referencia,	
			_pres_monto,	
			_imp_delmes,	
			_porc_delmes,	
			_saldo_almes,	
			_pres_almes,	
			_imp_almes,		
			_porc_almes,	
			_pres_alanio, 	
			_imp_alanio,	
			_porc_alanio,
			_det_ccosto	
			);

		end foreach

	end foreach

elif a_db = "sac008" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac008:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
		and cta_cuenta like (a_cta_gts)
	  order by 1

	   foreach
		select distinct sldet_ccosto
		  into _det_ccosto
		  from sac008:cglsaldodet
		 where sldet_cuenta  = _cuenta
		   and sldet_ano     = a_ano
		   and sldet_periodo = a_mes
		   and sldet_ccosto  matches a_ccosto

			select sum(sldet_debtop),
				   sum(sldet_cretop),
				   sum(sldet_saldop)
			  into _debito,
				   _credito,
				   _saldo_act
			  from sac008:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo = a_mes
			   and sldet_ccosto  matches _det_ccosto;

			select sum(sldet_saldop)
			  into _saldo_ant
			  from sac008:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant
			   and sldet_ccosto  matches _det_ccosto;

			if _debito is null then
				let _debito = 0;
			end if

			if _credito is null then
				let _credito = 0;
			end if

			if _saldo_act is null then
				let _saldo_act = 0;
			end if

			if _saldo_ant is null then
				let _saldo_ant = 0;
			end if

			if _debito    = 0 and 
			   _credito   = 0 and
			   _saldo_act = 0 and 
			   _saldo_ant = 0 then
				continue foreach;
			end if

			let _saldo = _debito + _credito;

		   select pre2_montomes 
		     into _pres_monto
			 from sac008:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	= a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto is null then
				let _pres_monto = 0;
			end if

			let _imp_delmes = _pres_monto - _saldo;
			let _porc_delmes = 	(_pres_monto - _saldo)/_pres_monto;

			select sum(sldet_debtop),
				   sum(sldet_cretop)
			  into _debito_ant,
				   _credito_ant
			  from sac008:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   and sldet_periodo < a_mes
			   and sldet_ccosto  matches _det_ccosto;

			if _debito_ant is null then
				let _debito_ant = 0;
			end if

			if _credito_ant is null then
				let _credito_ant = 0;
			end if

			let _saldo_anterior = _debito_ant + _credito_ant;

		   select pre2_montomes 
		     into _pres_monto_ant
			 from sac008:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_periodo	< a_mes
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_monto_ant is null then
				let _pres_monto_ant = 0;
			end if

			let _saldo_almes = _saldo + _saldo_anterior;
			let _pres_almes  = _pres_monto + _pres_monto_ant;

			let _imp_almes = _pres_almes - _saldo_almes;
			let _porc_almes = 	(_pres_almes - _saldo_almes)/_pres_almes;

		   select pre2_montomes 
		     into _pres_alanio
			 from sac008:cglpre02 
			where pre2_cuenta	= _cuenta
			  and pre2_ano		= a_ano
			  and pre2_ccosto   matches _det_ccosto;

			if _pres_alanio is null then
				let _pres_alanio = 0;
			end if

			let _imp_alanio = _pres_alanio - _saldo_almes;
			let _porc_alanio = 	(_pres_alanio - _saldo_almes)/_pres_alanio;

			insert into tmp_gtsprea(
			cuenta,
			nombre,
			debito,
			credito,
			saldo,
			saldo_ant,
			saldo_act,
			referencia,
			pres_monto,
			imp_delmes,	
			porc_delmes,
			saldo_almes,
			pres_almes,	
			imp_almes,	
			porc_almes,	
			pres_alanio, 
			imp_alanio,	
			porc_alanio,
			ccosto
			)
			values(
			_cuenta,		
			_nombre,		
			_debito,		
			_credito,		
			_saldo,			
			_saldo_ant,		
			_saldo_act,		
			_referencia,	
			_pres_monto,	
			_imp_delmes,	
			_porc_delmes,	
			_saldo_almes,	
			_pres_almes,	
			_imp_almes,		
			_porc_almes,	
			_pres_alanio, 	
			_imp_alanio,	
			_porc_alanio,
			_det_ccosto	
			);

		end foreach

	end foreach

end if

-- Actualizar el Centro de Costo de las cuentas que tienen
-- Centros de costos definidos en el catalogo de cuentas

foreach
 select	cuenta
   into _cuenta
   from	tmp_gtsprea
  group by cuenta
  order by cuenta 

	 select	centro_costo
	   into	_det_ccosto
	   from cglcuentas
	  where cta_cuenta = _cuenta;

	if _det_ccosto is not null then

		update tmp_gtsprea
		   set ccosto = _det_ccosto
		 where cuenta = _cuenta;

	end if

end foreach
    
end procedure

  