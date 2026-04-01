-- Creado    : 21/08/2014 - Autor: Armando Moreno M.
-- Reporte para verificar letras de Ach diferentes

drop procedure sp_par349;			
create procedure "informix".sp_par349()
returning char(20),
          char(17),
		  varchar(100),
          dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  smallint,
		  smallint,
		  date;

define _no_documento	char(20);
define _monto			dec(16,2);
define _prima_bruta		dec(16,2);
define _prima_b			dec(16,2);
define _nombre          varchar(100);
define _no_cuenta       char(17);
define _no_poliza       char(10);
define _estatus,_no_pagos    smallint;
define _cod_ramo        char(3);
define v_fecha          date;
define v_periodo        char(7);
define v_por_vencer		dec(16,2);
define v_corriente		dec(16,2);
define v_exigible		dec(16,2);
define v_monto_30		dec(16,2);
define v_monto_60		dec(16,2);
define v_monto_90		dec(16,2);
define _saldo           dec(16,2);
define _dia             smallint;
define _vig_ini         date;


let _monto       = 0;
let _prima_bruta = 0;
let _prima_b     = 0;
let	v_por_vencer = 0;
let	v_corriente	 = 0;
let	v_exigible	 = 0;
let	v_monto_30	 = 0;
let	v_monto_60	 = 0;
let	v_monto_90	 = 0;
let	_saldo       = 0;
let _dia         = 0;

let v_fecha       = today;

if month(v_fecha) < 10 then
	let v_periodo = year(v_fecha) || '-0' || month(v_fecha);
else
	let v_periodo = year(v_fecha) || '-' || month(v_fecha);
end if 


foreach
 select no_documento,
        monto,
		nombre,
		no_cuenta,
		dia
   into _no_documento,
        _monto,
		_nombre,
		_no_cuenta,
		_dia
   from cobcutas
  order by no_documento

	foreach
	 select	no_poliza,
	        vigencia_inic
	   into	_no_poliza,
			_vig_ini
	   from	emipomae
	  where no_documento       = _no_documento
		and actualizado        = 1
	  order by vigencia_final desc

		if _vig_ini <= v_fecha then
			exit foreach;
		end if
	end foreach


  select prima_bruta / no_pagos,
         estatus_poliza,
		 prima_bruta,
		 no_pagos,
		 cod_ramo
    into _prima_bruta,
	     _estatus,
		 _prima_b,
		 _no_pagos,
		 _cod_ramo
	from emipomae
   where no_poliza = _no_poliza
     and actualizado = 1;

   if _cod_ramo = '018' then

      if _estatus not in(1,3) then
	     continue foreach;
	  else
	     if _estatus = 3 then
			call sp_cob33('001', '001', _no_documento, v_periodo, v_fecha)
			returning   v_por_vencer,
						v_exigible,
						v_corriente,
						v_monto_30,
						v_monto_60,
						v_monto_90,
						_saldo;
			if _saldo = 0 then
				continue foreach;
			end if
		 end if
	  end if

	  foreach
			select prima_bruta / no_pagos,
			       prima_bruta
			  into _prima_bruta,
			       _prima_b
			  from endedmae
			 where actualizado  = 1
			   and cod_endomov  = '014'
			   and no_documento	= _no_documento
			 order by periodo desc

            exit foreach;
	  end foreach
   else
	   if _estatus <> 1 then
			continue foreach;
	   else
			call sp_cob33('001', '001', _no_documento, v_periodo, v_fecha)
			returning   v_por_vencer,
						v_exigible,
						v_corriente,
						v_monto_30,
						v_monto_60,
						v_monto_90,
						_saldo;

			if _saldo <= 0 then
				continue foreach;
			end if

	   end if

   end if

   if ABS(_monto) <> ABS(_prima_bruta) then

		if ABS(ABS(_monto) - ABS(_prima_bruta)) > 0.01 OR ABS(ABS(_monto) - ABS(_prima_bruta)) < 0.01 then

			return _no_documento,_no_cuenta,_nombre,_monto,_prima_bruta,_prima_b,_no_pagos,_dia,_vig_ini with resume;

		end if

   end if

end foreach


end procedure