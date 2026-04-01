-- Mayor General

-- Creado    : 13/02/2007 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sac56;

create procedure "informix".sp_sac56(
a_ano 	char(4), 
a_mes 	smallint,
a_db	char(18)
)

define _fechatrx	date;
define _comprobante	char(8);
define _notrx		integer;
define _fechacap	date;
define _fechaact	date;
define _descripcion	char(50);
define _cuenta		char(12);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _nombre		char(50);
define _saldo_ini	dec(16,2);
define _saldo_db	dec(16,2);
define _saldo_cr	dec(16,2);
define _saldo_fin	dec(16,2);

define _per_status 	char(1);
define _per_status3 char(1);
define _per_status4	char(1);
define _mes_13		smallint;
define _mes_14		smallint;

define _det_tipo	char(2);
define _det_ccosto	char(3);
define _cantidad	integer;

let _det_tipo = "*";
let _mes_13   = 13;
let _mes_14   = 14;

set isolation to dirty read;

-- Compania a procesar

select cia_comp
  into _det_ccosto
  from sigman02
 where cia_bda_codigo = a_db;

if a_db = "sac" then

	-- Verifica los estatus de los periodos

	select per_status
	  into _per_status
	  from sac:cglperiodo
	 where per_ano = a_ano
	   and per_mes = a_mes;

	select per_status
	  into _per_status3
	  from sac:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_13;

	select per_status
	  into _per_status4
	  from sac:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_14;

	-- Movimientos y Saldos

   foreach	
	select cta_cuenta,
	       cta_nombre
   	  into _cuenta,
   	       _nombre
      from sac:cglcuentas
     where cta_recibe = "S"

	select sldet_debtop,
		   sldet_cretop,
		   sldet_saldop
	  into _saldo_db,
		   _saldo_cr,
		   _saldo_fin
	  from sac:cglsaldodet
	 where sldet_tipo    matches _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
	   and sldet_ano     = a_ano
	   and sldet_periodo = a_mes;

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		let _saldo_ini = _saldo_fin - _saldo_db - _saldo_cr;

		if a_mes = 12 then

			if _per_status = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_13;

			end if

			if _per_status3 = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_14;

			end if

		end if

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		select count(*)
		  into _cantidad
	      from sac:cglresumen
	     where year(res_fechatrx)  = a_ano
	       and month(res_fechatrx) = a_mes
		   and res_cuenta          = _cuenta;

		if _cantidad = 0 then

			let _cantidad = 1;
			 
			if _saldo_ini = 0.00 and
			   _saldo_fin = 0.00 then
			   let _cantidad = 0;
			end if

			if _cantidad = 1 then

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				null,
				null,
				null,
				null,
				null,
				null,
				_cuenta,
				null,
				null,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end if

		else

			foreach	
			 select res_fechatrx,
				    res_comprobante,
				    res_notrx,
				    res_fechacap,
				    res_fechaact,
				    res_descripcion,
				    res_cuenta,
				    res_debito,
				    res_credito
			   into _fechatrx,
				    _comprobante,
				    _notrx,
				    _fechacap,
				    _fechaact,
				    _descripcion,
				    _cuenta,
				    _debito,
				    _credito
			   from sac:cglresumen
			  where year(res_fechatrx)  = a_ano
			    and month(res_fechatrx) = a_mes
			    and res_cuenta          = _cuenta

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				_fechatrx,
				_comprobante,
				_notrx,
				_fechacap,
				_fechaact,
				_descripcion,
				_cuenta,
				_debito,
				_credito,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end foreach

		end if

	end foreach

elif a_db = "sac001" then

	-- Verifica los estatus de los periodos

	select per_status
	  into _per_status
	  from sac001:cglperiodo
	 where per_ano = a_ano
	   and per_mes = a_mes;

	select per_status
	  into _per_status3
	  from sac001:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_13;

	select per_status
	  into _per_status4
	  from sac001:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_14;

	-- Movimientos y Saldos

   foreach	
	select cta_cuenta,
	       cta_nombre
   	  into _cuenta,
   	       _nombre
      from sac001:cglcuentas
     where cta_recibe = "S"

	select sldet_debtop,
		   sldet_cretop,
		   sldet_saldop
	  into _saldo_db,
		   _saldo_cr,
		   _saldo_fin
	  from sac001:cglsaldodet
	 where sldet_tipo    matches _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
	   and sldet_ano     = a_ano
	   and sldet_periodo = a_mes;

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		let _saldo_ini = _saldo_fin - _saldo_db - _saldo_cr;

		if a_mes = 12 then

			if _per_status = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac001:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_13;

			end if

			if _per_status3 = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac001:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_14;

			end if

		end if

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		select count(*)
		  into _cantidad
	      from sac001:cglresumen
	     where year(res_fechatrx)  = a_ano
	       and month(res_fechatrx) = a_mes
		   and res_cuenta          = _cuenta;

		if _cantidad = 0 then

			let _cantidad = 1;
			 
			if _saldo_ini = 0.00 and
			   _saldo_fin = 0.00 then
			   let _cantidad = 0;
			end if

			if _cantidad = 1 then

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				null,
				null,
				null,
				null,
				null,
				null,
				_cuenta,
				null,
				null,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end if

		else

			foreach	
			 select res_fechatrx,
				    res_comprobante,
				    res_notrx,
				    res_fechacap,
				    res_fechaact,
				    res_descripcion,
				    res_cuenta,
				    res_debito,
				    res_credito
			   into _fechatrx,
				    _comprobante,
				    _notrx,
				    _fechacap,
				    _fechaact,
				    _descripcion,
				    _cuenta,
				    _debito,
				    _credito
			   from sac001:cglresumen
			  where year(res_fechatrx)  = a_ano
			    and month(res_fechatrx) = a_mes
			    and res_cuenta          = _cuenta

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				_fechatrx,
				_comprobante,
				_notrx,
				_fechacap,
				_fechaact,
				_descripcion,
				_cuenta,
				_debito,
				_credito,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end foreach

		end if

	end foreach

elif a_db = "sac002" then

	-- Verifica los estatus de los periodos

	select per_status
	  into _per_status
	  from sac002:cglperiodo
	 where per_ano = a_ano
	   and per_mes = a_mes;

	select per_status
	  into _per_status3
	  from sac002:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_13;

	select per_status
	  into _per_status4
	  from sac002:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_14;

	-- Movimientos y Saldos

   foreach	
	select cta_cuenta,
	       cta_nombre
   	  into _cuenta,
   	       _nombre
      from sac002:cglcuentas
     where cta_recibe = "S"

	select sldet_debtop,
		   sldet_cretop,
		   sldet_saldop
	  into _saldo_db,
		   _saldo_cr,
		   _saldo_fin
	  from sac002:cglsaldodet
	 where sldet_tipo    matches _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
	   and sldet_ano     = a_ano
	   and sldet_periodo = a_mes;

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		let _saldo_ini = _saldo_fin - _saldo_db - _saldo_cr;

		if a_mes = 12 then

			if _per_status = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac002:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_13;

			end if

			if _per_status3 = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac002:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_14;

			end if

		end if

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		select count(*)
		  into _cantidad
	      from sac002:cglresumen
	     where year(res_fechatrx)  = a_ano
	       and month(res_fechatrx) = a_mes
		   and res_cuenta          = _cuenta;

		if _cantidad = 0 then

			let _cantidad = 1;
			 
			if _saldo_ini = 0.00 and
			   _saldo_fin = 0.00 then
			   let _cantidad = 0;
			end if

			if _cantidad = 1 then

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				null,
				null,
				null,
				null,
				null,
				null,
				_cuenta,
				null,
				null,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end if

		else

			foreach	
			 select res_fechatrx,
				    res_comprobante,
				    res_notrx,
				    res_fechacap,
				    res_fechaact,
				    res_descripcion,
				    res_cuenta,
				    res_debito,
				    res_credito
			   into _fechatrx,
				    _comprobante,
				    _notrx,
				    _fechacap,
				    _fechaact,
				    _descripcion,
				    _cuenta,
				    _debito,
				    _credito
			   from sac002:cglresumen
			  where year(res_fechatrx)  = a_ano
			    and month(res_fechatrx) = a_mes
			    and res_cuenta          = _cuenta

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				_fechatrx,
				_comprobante,
				_notrx,
				_fechacap,
				_fechaact,
				_descripcion,
				_cuenta,
				_debito,
				_credito,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end foreach

		end if

	end foreach

elif a_db = "sac003" then

	-- Verifica los estatus de los periodos

	select per_status
	  into _per_status
	  from sac003:cglperiodo
	 where per_ano = a_ano
	   and per_mes = a_mes;

	select per_status
	  into _per_status3
	  from sac003:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_13;

	select per_status
	  into _per_status4
	  from sac003:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_14;

	-- Movimientos y Saldos

   foreach	
	select cta_cuenta,
	       cta_nombre
   	  into _cuenta,
   	       _nombre
      from sac003:cglcuentas
     where cta_recibe = "S"

	select sldet_debtop,
		   sldet_cretop,
		   sldet_saldop
	  into _saldo_db,
		   _saldo_cr,
		   _saldo_fin
	  from sac003:cglsaldodet
	 where sldet_tipo    matches _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
	   and sldet_ano     = a_ano
	   and sldet_periodo = a_mes;

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		let _saldo_ini = _saldo_fin - _saldo_db - _saldo_cr;

		if a_mes = 12 then

			if _per_status = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac003:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_13;

			end if

			if _per_status3 = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac003:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_14;

			end if

		end if

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		select count(*)
		  into _cantidad
	      from sac003:cglresumen
	     where year(res_fechatrx)  = a_ano
	       and month(res_fechatrx) = a_mes
		   and res_cuenta          = _cuenta;

		if _cantidad = 0 then

			let _cantidad = 1;
			 
			if _saldo_ini = 0.00 and
			   _saldo_fin = 0.00 then
			   let _cantidad = 0;
			end if

			if _cantidad = 1 then

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				null,
				null,
				null,
				null,
				null,
				null,
				_cuenta,
				null,
				null,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end if

		else

			foreach	
			 select res_fechatrx,
				    res_comprobante,
				    res_notrx,
				    res_fechacap,
				    res_fechaact,
				    res_descripcion,
				    res_cuenta,
				    res_debito,
				    res_credito
			   into _fechatrx,
				    _comprobante,
				    _notrx,
				    _fechacap,
				    _fechaact,
				    _descripcion,
				    _cuenta,
				    _debito,
				    _credito
			   from sac003:cglresumen
			  where year(res_fechatrx)  = a_ano
			    and month(res_fechatrx) = a_mes
			    and res_cuenta          = _cuenta

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				_fechatrx,
				_comprobante,
				_notrx,
				_fechacap,
				_fechaact,
				_descripcion,
				_cuenta,
				_debito,
				_credito,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end foreach

		end if

	end foreach

elif a_db = "sac004" then

	-- Verifica los estatus de los periodos

	select per_status
	  into _per_status
	  from sac004:cglperiodo
	 where per_ano = a_ano
	   and per_mes = a_mes;

	select per_status
	  into _per_status3
	  from sac004:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_13;

	select per_status
	  into _per_status4
	  from sac004:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_14;

	-- Movimientos y Saldos

   foreach	
	select cta_cuenta,
	       cta_nombre
   	  into _cuenta,
   	       _nombre
      from sac004:cglcuentas
     where cta_recibe = "S"

	select sldet_debtop,
		   sldet_cretop,
		   sldet_saldop
	  into _saldo_db,
		   _saldo_cr,
		   _saldo_fin
	  from sac004:cglsaldodet
	 where sldet_tipo    matches _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
	   and sldet_ano     = a_ano
	   and sldet_periodo = a_mes;

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		let _saldo_ini = _saldo_fin - _saldo_db - _saldo_cr;

		if a_mes = 12 then

			if _per_status = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac004:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_13;

			end if

			if _per_status3 = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac004:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_14;

			end if

		end if

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		select count(*)
		  into _cantidad
	      from sac004:cglresumen
	     where year(res_fechatrx)  = a_ano
	       and month(res_fechatrx) = a_mes
		   and res_cuenta          = _cuenta;

		if _cantidad = 0 then

			let _cantidad = 1;
			 
			if _saldo_ini = 0.00 and
			   _saldo_fin = 0.00 then
			   let _cantidad = 0;
			end if

			if _cantidad = 1 then

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				null,
				null,
				null,
				null,
				null,
				null,
				_cuenta,
				null,
				null,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end if

		else

			foreach	
			 select res_fechatrx,
				    res_comprobante,
				    res_notrx,
				    res_fechacap,
				    res_fechaact,
				    res_descripcion,
				    res_cuenta,
				    res_debito,
				    res_credito
			   into _fechatrx,
				    _comprobante,
				    _notrx,
				    _fechacap,
				    _fechaact,
				    _descripcion,
				    _cuenta,
				    _debito,
				    _credito
			   from sac004:cglresumen
			  where year(res_fechatrx)  = a_ano
			    and month(res_fechatrx) = a_mes
			    and res_cuenta          = _cuenta

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				_fechatrx,
				_comprobante,
				_notrx,
				_fechacap,
				_fechaact,
				_descripcion,
				_cuenta,
				_debito,
				_credito,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end foreach

		end if

	end foreach

elif a_db = "sac005" then

	-- Verifica los estatus de los periodos

	select per_status
	  into _per_status
	  from sac005:cglperiodo
	 where per_ano = a_ano
	   and per_mes = a_mes;

	select per_status
	  into _per_status3
	  from sac005:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_13;

	select per_status
	  into _per_status4
	  from sac005:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_14;

	-- Movimientos y Saldos

   foreach	
	select cta_cuenta,
	       cta_nombre
   	  into _cuenta,
   	       _nombre
      from sac005:cglcuentas
     where cta_recibe = "S"

	select sldet_debtop,
		   sldet_cretop,
		   sldet_saldop
	  into _saldo_db,
		   _saldo_cr,
		   _saldo_fin
	  from sac005:cglsaldodet
	 where sldet_tipo    matches _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
	   and sldet_ano     = a_ano
	   and sldet_periodo = a_mes;

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		let _saldo_ini = _saldo_fin - _saldo_db - _saldo_cr;

		if a_mes = 12 then

			if _per_status = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac005:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_13;

			end if

			if _per_status3 = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac005:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_14;

			end if

		end if

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		select count(*)
		  into _cantidad
	      from sac005:cglresumen
	     where year(res_fechatrx)  = a_ano
	       and month(res_fechatrx) = a_mes
		   and res_cuenta          = _cuenta;

		if _cantidad = 0 then

			let _cantidad = 1;
			 
			if _saldo_ini = 0.00 and
			   _saldo_fin = 0.00 then
			   let _cantidad = 0;
			end if

			if _cantidad = 1 then

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				null,
				null,
				null,
				null,
				null,
				null,
				_cuenta,
				null,
				null,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end if

		else

			foreach	
			 select res_fechatrx,
				    res_comprobante,
				    res_notrx,
				    res_fechacap,
				    res_fechaact,
				    res_descripcion,
				    res_cuenta,
				    res_debito,
				    res_credito
			   into _fechatrx,
				    _comprobante,
				    _notrx,
				    _fechacap,
				    _fechaact,
				    _descripcion,
				    _cuenta,
				    _debito,
				    _credito
			   from sac005:cglresumen
			  where year(res_fechatrx)  = a_ano
			    and month(res_fechatrx) = a_mes
			    and res_cuenta          = _cuenta

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				_fechatrx,
				_comprobante,
				_notrx,
				_fechacap,
				_fechaact,
				_descripcion,
				_cuenta,
				_debito,
				_credito,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end foreach

		end if

	end foreach

elif a_db = "sac006" then

	-- Verifica los estatus de los periodos

	select per_status
	  into _per_status
	  from sac006:cglperiodo
	 where per_ano = a_ano
	   and per_mes = a_mes;

	select per_status
	  into _per_status3
	  from sac006:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_13;

	select per_status
	  into _per_status4
	  from sac006:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_14;

	-- Movimientos y Saldos

   foreach	
	select cta_cuenta,
	       cta_nombre
   	  into _cuenta,
   	       _nombre
      from sac006:cglcuentas
     where cta_recibe = "S"

	select sldet_debtop,
		   sldet_cretop,
		   sldet_saldop
	  into _saldo_db,
		   _saldo_cr,
		   _saldo_fin
	  from sac006:cglsaldodet
	 where sldet_tipo    matches _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
	   and sldet_ano     = a_ano
	   and sldet_periodo = a_mes;

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		let _saldo_ini = _saldo_fin - _saldo_db - _saldo_cr;

		if a_mes = 12 then

			if _per_status = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac006:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_13;

			end if

			if _per_status3 = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac006:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_14;

			end if

		end if

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		select count(*)
		  into _cantidad
	      from sac006:cglresumen
	     where year(res_fechatrx)  = a_ano
	       and month(res_fechatrx) = a_mes
		   and res_cuenta          = _cuenta;

		if _cantidad = 0 then

			let _cantidad = 1;
			 
			if _saldo_ini = 0.00 and
			   _saldo_fin = 0.00 then
			   let _cantidad = 0;
			end if

			if _cantidad = 1 then

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				null,
				null,
				null,
				null,
				null,
				null,
				_cuenta,
				null,
				null,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end if

		else

			foreach	
			 select res_fechatrx,
				    res_comprobante,
				    res_notrx,
				    res_fechacap,
				    res_fechaact,
				    res_descripcion,
				    res_cuenta,
				    res_debito,
				    res_credito
			   into _fechatrx,
				    _comprobante,
				    _notrx,
				    _fechacap,
				    _fechaact,
				    _descripcion,
				    _cuenta,
				    _debito,
				    _credito
			   from sac006:cglresumen
			  where year(res_fechatrx)  = a_ano
			    and month(res_fechatrx) = a_mes
			    and res_cuenta          = _cuenta

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				_fechatrx,
				_comprobante,
				_notrx,
				_fechacap,
				_fechaact,
				_descripcion,
				_cuenta,
				_debito,
				_credito,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end foreach

		end if

	end foreach

elif a_db = "sac007" then

	-- Verifica los estatus de los periodos

	select per_status
	  into _per_status
	  from sac007:cglperiodo
	 where per_ano = a_ano
	   and per_mes = a_mes;

	select per_status
	  into _per_status3
	  from sac007:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_13;

	select per_status
	  into _per_status4
	  from sac007:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_14;

	-- Movimientos y Saldos

   foreach	
	select cta_cuenta,
	       cta_nombre
   	  into _cuenta,
   	       _nombre
      from sac007:cglcuentas
     where cta_recibe = "S"

	select sldet_debtop,
		   sldet_cretop,
		   sldet_saldop
	  into _saldo_db,
		   _saldo_cr,
		   _saldo_fin
	  from sac007:cglsaldodet
	 where sldet_tipo    matches _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
	   and sldet_ano     = a_ano
	   and sldet_periodo = a_mes;

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		let _saldo_ini = _saldo_fin - _saldo_db - _saldo_cr;

		if a_mes = 12 then

			if _per_status = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac007:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_13;

			end if

			if _per_status3 = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac007:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_14;

			end if

		end if

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		select count(*)
		  into _cantidad
	      from sac007:cglresumen
	     where year(res_fechatrx)  = a_ano
	       and month(res_fechatrx) = a_mes
		   and res_cuenta          = _cuenta;

		if _cantidad = 0 then

			let _cantidad = 1;
			 
			if _saldo_ini = 0.00 and
			   _saldo_fin = 0.00 then
			   let _cantidad = 0;
			end if

			if _cantidad = 1 then

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				null,
				null,
				null,
				null,
				null,
				null,
				_cuenta,
				null,
				null,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end if

		else

			foreach	
			 select res_fechatrx,
				    res_comprobante,
				    res_notrx,
				    res_fechacap,
				    res_fechaact,
				    res_descripcion,
				    res_cuenta,
				    res_debito,
				    res_credito
			   into _fechatrx,
				    _comprobante,
				    _notrx,
				    _fechacap,
				    _fechaact,
				    _descripcion,
				    _cuenta,
				    _debito,
				    _credito
			   from sac007:cglresumen
			  where year(res_fechatrx)  = a_ano
			    and month(res_fechatrx) = a_mes
			    and res_cuenta          = _cuenta

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				_fechatrx,
				_comprobante,
				_notrx,
				_fechacap,
				_fechaact,
				_descripcion,
				_cuenta,
				_debito,
				_credito,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end foreach

		end if

	end foreach

elif a_db = "sac008" then

	-- Verifica los estatus de los periodos

	select per_status
	  into _per_status
	  from sac008:cglperiodo
	 where per_ano = a_ano
	   and per_mes = a_mes;

	select per_status
	  into _per_status3
	  from sac008:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_13;

	select per_status
	  into _per_status4
	  from sac008:cglperiodo
	 where per_ano = a_ano
	   and per_mes = _mes_14;

	-- Movimientos y Saldos

   foreach	
	select cta_cuenta,
	       cta_nombre
   	  into _cuenta,
   	       _nombre
      from sac008:cglcuentas
     where cta_recibe = "S"

	select sldet_debtop,
		   sldet_cretop,
		   sldet_saldop
	  into _saldo_db,
		   _saldo_cr,
		   _saldo_fin
	  from sac008:cglsaldodet
	 where sldet_tipo    matches _det_tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _det_ccosto
	   and sldet_ano     = a_ano
	   and sldet_periodo = a_mes;

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		let _saldo_ini = _saldo_fin - _saldo_db - _saldo_cr;

		if a_mes = 12 then

			if _per_status = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac008:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_13;

			end if

			if _per_status3 = "C" then

				select sldet_saldop
				  into _saldo_fin
				  from sac008:cglsaldodet
				 where sldet_tipo    matches _det_tipo
				   and sldet_cuenta  = _cuenta
				   and sldet_ccosto  = _det_ccosto
				   and sldet_ano     = a_ano
				   and sldet_periodo = _mes_14;

			end if

		end if

		if _saldo_fin is null then
			let _saldo_fin = 0.00;
			let _saldo_db  = 0.00;
			let _saldo_cr  = 0.00;
		end if

		select count(*)
		  into _cantidad
	      from sac008:cglresumen
	     where year(res_fechatrx)  = a_ano
	       and month(res_fechatrx) = a_mes
		   and res_cuenta          = _cuenta;

		if _cantidad = 0 then

			let _cantidad = 1;
			 
			if _saldo_ini = 0.00 and
			   _saldo_fin = 0.00 then
			   let _cantidad = 0;
			end if

			if _cantidad = 1 then

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				null,
				null,
				null,
				null,
				null,
				null,
				_cuenta,
				null,
				null,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end if

		else

			foreach	
			 select res_fechatrx,
				    res_comprobante,
				    res_notrx,
				    res_fechacap,
				    res_fechaact,
				    res_descripcion,
				    res_cuenta,
				    res_debito,
				    res_credito
			   into _fechatrx,
				    _comprobante,
				    _notrx,
				    _fechacap,
				    _fechaact,
				    _descripcion,
				    _cuenta,
				    _debito,
				    _credito
			   from sac008:cglresumen
			  where year(res_fechatrx)  = a_ano
			    and month(res_fechatrx) = a_mes
			    and res_cuenta          = _cuenta

				insert into tmp_cglresumen(
				res_fechatrx,
				res_comprobante,
				res_notrx,
				res_fechacap,
				res_fechaact,
				res_descripcion,
				res_cuenta,
				res_debito,
				res_credito,
				res_nombre,
				res_saldo_ini,
				res_saldo_fin
				)
				values(
				_fechatrx,
				_comprobante,
				_notrx,
				_fechacap,
				_fechaact,
				_descripcion,
				_cuenta,
				_debito,
				_credito,
				_nombre,
				_saldo_ini,
				_saldo_fin
				);

			end foreach

		end if

	end foreach

end if

end procedure