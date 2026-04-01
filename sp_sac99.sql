-- Procedure que verifica que cuadre cglresumen vs cglsaldodet

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac99;

create procedure sp_sac99()
returning char(2),
		  char(25),
		  char(3),
		  char(4),
		  smallint,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(10);

define _tipo			char(2);
define _cuenta			char(25);
define _ccosto			char(3);
define _ano				char(4);
define _mes				smallint;
define _tipcomp			char(3);
define _fecha_trx		date;

define _debito1			dec(16,2);
define _credito1		dec(16,2);
define _debito2			dec(16,2);
define _credito2		dec(16,2);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _error_monto1	dec(16,2);
define _error_monto2	dec(16,2);

define _ano_eval		char(4);
define _ano_int			smallint;
define _periodo_eval	char(7);
define _fecha_eval		date;

define _cta_recibe		char(1);

define _validar			char(10);

--set debug file to "sp_sac99.trc";
--trace on;

begin 
on exception set _error, _error_isam, _error_desc

	return "",
	       _error_desc,
		   "",
		   "",
		   _error,
		   0,
		   0,
		   0,
		   0,
		   ""
		   with resume;

end exception

set isolation to dirty read;

call sp_sac104() returning _ano_int, _periodo_eval, _fecha_eval;

--let _fecha_eval = '01-01-2024';

let _ano_eval = _ano_int;
let _validar  = "cglresumen";
 
-- Periodos 1 al 12

--{
foreach	
 select res_tipo_resumen,
        res_cuenta,
		res_ccosto,
        year(res_fechatrx),
	    month(res_fechatrx),
		sum(res_debito),
		sum(res_credito)
   into _tipo,
        _cuenta,
        _ccosto,
        _ano,
        _mes,
		_debito1,
		_credito1
   from cglresumen
  where res_fechatrx >= _fecha_eval
    and res_tipcomp        not in ("020", "021")
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

--    and (res_tipcomp       <> "020" or
--         res_tipcomp       <> "021" )

	let _credito1 = _credito1 * -1;

	select sum(sldet_debtop),
	       sum(sldet_cretop)
	  into _debito2,
	       _credito2
	  from cglsaldodet
	 where sldet_tipo    = _tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _ccosto
	   and sldet_ano     = _ano
	   and sldet_periodo = _mes;

	if _debito2 is null then 
		let _debito2 = 0;
	end if
	   
	if _credito2 is null then 
		let _credito2 = 0;
	end if

	if _debito1  <> _debito2  or
	   _credito1 <> _credito2 then

		return _tipo,
		       _cuenta,
			   _ccosto,
			   _ano,
			   _mes,
			   _debito1,
			   _credito1,
			   _debito2,
			   _credito2,
			   _validar
			   with resume;

	end if

end foreach
--}

-- Periodo 13

--{
foreach	
 select res_tipo_resumen,
        res_cuenta,
		res_ccosto,
        year(res_fechatrx),
	    month(res_fechatrx),
		sum(res_debito),
		sum(res_credito)
   into _tipo,
        _cuenta,
        _ccosto,
        _ano,
        _mes,
		_debito1,
		_credito1
   from cglresumen
  where res_fechatrx >= _fecha_eval
    and res_tipcomp         = "020"
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	let _credito1 = _credito1 * -1;

	select sum(sldet_debtop),
	       sum(sldet_cretop)
	  into _debito2,
	       _credito2
	  from cglsaldodet
	 where sldet_tipo    = _tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _ccosto
	   and sldet_ano     = _ano
	   and sldet_periodo = 13;

	if _debito2 is null then 
		let _debito2 = 0;
	end if
	   
	if _credito2 is null then 
		let _credito2 = 0;
	end if

	if _debito1  <> _debito2  or
	   _credito1 <> _credito2 then

		return _tipo,
		       _cuenta,
			   _ccosto,
			   _ano,
			   13,
			   _debito1,
			   _credito1,
			   _debito2,
			   _credito2,
			   _validar
			   with resume;

	end if

end foreach
--}

-- Periodo 14

--{
--let _fecha_eval = '01/01/2015';
foreach	
 select res_tipo_resumen,
        res_cuenta,
		res_ccosto,
        year(res_fechatrx),
	    month(res_fechatrx),
		sum(res_debito),
		sum(res_credito)
   into _tipo,
        _cuenta,
        _ccosto,
        _ano,
        _mes,
		_debito1,
		_credito1
   from cglresumen
  where res_fechatrx >= _fecha_eval
    and res_tipcomp         = "021"
  group by 1, 2, 3, 4, 5
  order by 1, 2, 3, 4, 5

	let _credito1 = _credito1 * -1;

	select sum(sldet_debtop),
	       sum(sldet_cretop)
	  into _debito2,
	       _credito2
	  from cglsaldodet
	 where sldet_tipo    = _tipo
	   and sldet_cuenta  = _cuenta
	   and sldet_ccosto  = _ccosto
	   and sldet_ano     = _ano
	   and sldet_periodo = 14;

	if _debito2 is null then 
		let _debito2 = 0;
	end if
	   
	if _credito2 is null then 
		let _credito2 = 0;
	end if

	if _debito1  <> _debito2  or
	   _credito1 <> _credito2 then

		return _tipo,
		       _cuenta,
			   _ccosto,
			   _ano,
			   14,
			   _debito1,
			   _credito1,
			   _debito2,
			   _credito2,
			   _validar
			   with resume;

	end if

end foreach
--}

-- Saldos Vs cglresumen

let _validar  = "cglsaldodet";

{
foreach
 select sldet_tipo,
        sldet_cuenta,
		sldet_ccosto,
        sldet_ano,
	    sldet_periodo,
		sldet_debtop,
		sldet_cretop
   into _tipo,
        _cuenta,
        _ccosto,
        _ano,
        _mes,
		_debito1,
		_credito1
   from cglsaldodet
  where sldet_ano >= _ano_eval

	select cta_recibe
	  into _cta_recibe
	  from cglcuentas
	 where cta_cuenta = _cuenta;

	if _cta_recibe = "N" then
		continue foreach;
	end if

	if _mes = 14 then

		select sum(res_debito),
		       sum(res_credito)
		  into _debito2,
		       _credito2
		  from cglresumen
		 where year(res_fechatrx)  = _ano
		   and month(res_fechatrx) = 12
		   and res_cuenta          = _cuenta
	       and res_tipcomp         in ("021")
		   and res_tipo_resumen    = _tipo
		   and res_ccosto          = _ccosto;

	elif _mes = 13 then

		select sum(res_debito),
		       sum(res_credito)
		  into _debito2,
		       _credito2
		  from cglresumen
		 where year(res_fechatrx)  = _ano
		   and month(res_fechatrx) = 12
		   and res_cuenta          = _cuenta
	       and res_tipcomp         in ("020")
		   and res_tipo_resumen    = _tipo
		   and res_ccosto          = _ccosto;

	else

		select sum(res_debito),
		       sum(res_credito)
		  into _debito2,
		       _credito2
		  from cglresumen
		 where year(res_fechatrx)  = _ano
		   and month(res_fechatrx) = _mes
		   and res_cuenta          = _cuenta
	       and res_tipcomp         not in ("020", "021")
		   and res_tipo_resumen    = _tipo
		   and res_ccosto          = _ccosto;

	end if

--		let _debito2 = 0;
--		let _credito2 = 0;

	if _debito2 is null then 
		let _debito2 = 0;
	end if
	   
	if _credito2 is null then 
		let _credito2 = 0;
	end if

	let _credito2 = _credito2 * -1;
	
	if _debito1  <> _debito2  or
	   _credito1 <> _credito2 then
		
		return _tipo,
		       _cuenta,
			   _ccosto,
			   _ano,
			   _mes,
			   _debito1,
			   _credito1,
			   _debito2,
			   _credito2,
			   _validar
			   with resume;

	end if

end foreach
--}

end

return "",
       "",
	   "",
	   "",
	   0,
	   0,
	   0,
	   0,
	   0,
	   ""
	   with resume;

end procedure