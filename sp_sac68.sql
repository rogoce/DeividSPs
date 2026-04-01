-- Procedure que verifica que cuadre cglresumen vs cglresumen1

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac68;

create procedure sp_sac68()
returning integer,
          char(25),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  date,
		  char(10),
		  date,
		  integer,
		  smallint;

define _no_registro		integer;
define _cuenta			char(25);
define _cta_auxiliar	char(1);
define _fecha_trx		date;
define _comprobante		char(10);
define _fecha_cap		date;
define _no_trx			integer;
define _cantidad		smallint;
define _tipcomp			char(3);

define _debito1			dec(16,2);
define _credito1		dec(16,2);
define _debito2			dec(16,2);
define _credito2		dec(16,2);

define _ano_eval		char(4);
define _ano_int			smallint;
define _periodo_eval	char(7);
define _fecha_eval		date;

define _error_monto1	dec(16,2);
define _error_monto2	dec(16,2);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

begin 
on exception set _error, _error_isam, _error_desc

	return _error,
	       _error_desc,
		   0,
		   0,
		   0,
		   0,
		   null,
		   "",
		   null,
		   _error_isam,
		   0
		   with resume;

end exception

set isolation to dirty read;

create temp table tmp_comp021(
fecha		date,
comprobante	char(10),
cuenta		char(25),
monto1		dec(16,2),
monto2		dec(16,2)
) with no log;

call sp_sac104() returning _ano_int, _periodo_eval, _fecha_eval;

--let _ano_int  = 2000;

let _ano_eval = _ano_int;

--{
foreach
 select res1_noregistro,
  	    sum(res1_debito),
		sum(res1_credito),
		count(*)
   into _no_registro,
		_debito2,
		_credito2,
		_cantidad
   from cglresumen1
  group by 1

	select res_cuenta,
		   res_debito,
		   res_credito,
		   res_fechatrx,
		   res_comprobante,
		   res_fechacap,
		   res_notrx,
		   res_tipcomp
      into _cuenta,
		   _debito1,
		   _credito1,
		   _fecha_trx,
		   _comprobante,
		   _fecha_cap,
		   _no_trx,
		   _tipcomp
	  from cglresumen
	 where res_noregistro = _no_registro;

		if _tipcomp = "021" then
			continue foreach;
		end if
				
		if _debito1 is null then 
			let _debito1 = 0;
		end if
		   
		if _credito1 is null then 
			let _credito1 = 0;
		end if

		if _debito1  <> _debito2  or
		   _credito1 <> _credito2 then

			return _no_registro,
			       _cuenta,
				   _debito1,
				   _credito1,
				   _debito2,
				   _credito2,
				   _fecha_trx,
				   _comprobante,
				   _fecha_cap,
				   _no_trx,
				   _cantidad
				   with resume;

		end if		

end foreach
--}

--{
foreach
 select res_noregistro,
        res_cuenta,
		res_debito,
		res_credito,
		res_fechatrx,
		res_comprobante,
		res_fechacap,
		res_notrx
   into _no_registro,
        _cuenta,
		_debito1,
		_credito1,
		_fecha_trx,
		_comprobante,
		_fecha_cap,
		_no_trx
   from cglresumen
  where year(res_fechatrx)  >= _ano_int
    and res_tipcomp         <> "021"
--	and month(res_fechatrx) = 12
--	and res_cuenta      	like "139%"
--	and res_comprobante     like "PRO%"
--  and res_noregistro      = 78302
--  and res_tipcomp         = "014"
--  and res_noregistro      = 144384
  order by res_comprobante, res_fechatrx

	select cta_auxiliar
	  into _cta_auxiliar
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	if _cta_auxiliar = "S" then

		select count(*)
		  into _cantidad
		  from cglresumen1
		 where res1_noregistro = _no_registro
		   and res1_cuenta     = _cuenta;

		select sum(res1_debito),
		       sum(res1_credito)
		  into _debito2,
		       _credito2
		  from cglresumen1
		 where res1_noregistro = _no_registro
		   and res1_cuenta     = _cuenta;

		if _debito2 is null then 
			let _debito2 = 0;
		end if
		   
		if _credito2 is null then 
			let _credito2 = 0;
		end if

		if _debito1  <> _debito2  or
		   _credito1 <> _credito2 then

--			if _debito1 = 0 then

--				update cglresumen1
--				   set res1_debito     = _debito1
--				 where res1_noregistro = _no_registro
--				   and res1_cuenta     = _cuenta;

--			end if

--			if _credito1 = 0 then

--				update cglresumen1
--				   set res1_credito    = _credito1
--				 where res1_noregistro = _no_registro
--				   and res1_cuenta     = _cuenta;

--			end if

--			delete from cglresumen1
--			 where res1_noregistro = _no_registro
--			   and res1_cuenta     = _cuenta;

--			call sp_sac69(_no_registro) returning _error, _error_monto1, _error_monto2, _error_desc;

			-- Proceso para crear el auxiliar 
			-- Cuenta que se cambio de sin auxiliar a con auxiliar
			-- Hecho por Demetrio (Lo deje por si se necesita en el futuro)
			-- 05 Enero 2012

--			if _cuenta = "266200171" then
		
--				insert into cglresumen1
--				select res_noregistro,
--				       1, 
--					   res_tipo_resumen,
--					   res_comprobante,
--					   res_cuenta,
--					   "G0001",
--					   res_debito,
--					   res_credito,
--					   res_origen,
--					   "",
--					   1
--				  from cglresumen
--				 where res_noregistro = _no_registro;

--			end if

			return _no_registro,
			       _cuenta,
				   _debito1,
				   _credito1,
				   _debito2,
				   _credito2,
				   _fecha_trx,
				   _comprobante,
				   _fecha_cap,
				   _no_trx,
				   _cantidad
				   with resume;

		end if		
		
	end if

end foreach
--}

foreach
 select res_noregistro,
        res_cuenta,
		res_debito,
		res_credito,
		res_fechatrx,
		res_comprobante,
		res_fechacap,
		res_notrx
   into _no_registro,
        _cuenta,
		_debito1,
		_credito1,
		_fecha_trx,
		_comprobante,
		_fecha_cap,
		_no_trx
   from cglresumen
  where year(res_fechatrx)  >= _ano_int
    and res_tipcomp          = "021"
  order by res_comprobante, res_fechatrx

	select cta_auxiliar
	  into _cta_auxiliar
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	if _cta_auxiliar = "S" then

		insert into tmp_comp021
		values (_fecha_trx, _comprobante, _cuenta, _debito1 - _credito1, 0);

		select count(*)
		  into _cantidad
		  from cglresumen1
		 where res1_noregistro = _no_registro
		   and res1_cuenta     = _cuenta;

		select sum(res1_debito),
		       sum(res1_credito)
		  into _debito2,
		       _credito2
		  from cglresumen1
		 where res1_noregistro = _no_registro
		   and res1_cuenta     = _cuenta;

		if _debito2 is null then 
			let _debito2 = 0;
		end if
		   
		if _credito2 is null then 
			let _credito2 = 0;
		end if

		insert into tmp_comp021
		values (_fecha_trx, _comprobante, _cuenta, 0, _debito2 - _credito2);

		if (_debito1 - _credito1) <> (_debito2 - _credito2) then

--			delete from cglresumen1
--			 where res1_noregistro = _no_registro
--			   and res1_cuenta     = _cuenta;

--			call sp_sac69(_no_registro) returning _error, _error_monto1, _error_monto2, _error_desc;

--			return _no_registro,
--			       _cuenta,
--				   _debito1,
--				   _credito1,
--				   _debito2,
--				   _credito2,
--				   _fecha_trx,
--				   _comprobante,
--				   _fecha_cap,
--				   _no_trx,
--				   _cantidad
--				   with resume;

		end if		
		
	end if

end foreach

foreach
 select fecha,
        comprobante,
		cuenta,
		sum(monto1),
		sum(monto2)
   into _fecha_trx,
		_comprobante,
		_cuenta,
		_debito1,
		_debito2
   from tmp_comp021
  group by 1, 2, 3

	if _debito1 <> _debito2 then

		return 0,
		       _cuenta,
			   _debito1,
			   0,
			   _debito2,
			   0,
			   _fecha_trx,
			   _comprobante,
			   _fecha_trx,
			   0,
			   0
			   with resume;

	end if

end foreach

end

drop table tmp_comp021;

return 0,
       "",
	   0,
	   0,
	   0,
	   0,
	   null,
	   "",
	   null,
	   0,
	   0
	   with resume;

end procedure