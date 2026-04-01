-- Creacion de las letras de pago de las polizas por nueva ley de seguros

-- Creado    : 21/06/2012 - Autor: Demetrio Hurtado Almanza 
-- modificado: 03/12/2013 - Autor: Angel Tello
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_pro528;

create procedure sp_pro528(a_no_poliza	char(10), a_no_endoso char(10)) 
				returning	int, 
							char(50);

define _letra			smallint;
define _fecha_pago		date;
define _periodo_gracia	date;
define _fecha_cancel	date;
define _fecha_aviso		date;
define _monto_letra		dec(16,2);
define _no_recibo		char(10);
define _fecha_pagado	date;
define _letra_pagada	smallint;

define _mes_int			smallint;
define _mes_dec			dec(16,2);
define _mes_letra		smallint;
define _ano_letra		smallint;
define _mes_gracia		smallint;
define _ano_gracia		smallint;
define _mes_cancela		smallint;
define _ano_cancela		smallint;
define _dias_vigencia	smallint;
define _dias_letra		smallint;
define _dias_letra_dec	dec(16,2);

define _prima_bruta		dec(16,2);
define _fecha_1_pago	date;
define _no_pagos		smallint;
define _vigencia_final	date;
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _no_pagos_can    smallint;
define _no_pagos_new	int;
define _mont_pag		int;
define _mont_pag_new	int;
define _no_letra 	    smallint;
define _resto           dec(16,2);
define _letra_ini		smallint;


set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_pro528.trc";
--trace on;

let _resto = 0;

delete from endletra where no_poliza = a_no_poliza and no_endoso = a_no_endoso;

--lectura de emipomae
select prima_bruta
  into _prima_bruta
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;

select * from emiletra
 where no_poliza = a_no_poliza
   and pagada = 0
  into temp tmp_letra;

 -- lectura de emiletras / saca la cantidad de letras pagadas

select count(*)
  into _no_pagos_can
  from tmp_letra
 where no_poliza = a_no_poliza;
 
select max(no_letra)
	into _letra_ini
	from emiletra
 where no_poliza = a_no_poliza;
 

let _resto = _prima_bruta;

let _monto_letra = _prima_bruta / _no_pagos_can;

for	_letra = 1 to _no_pagos_can

	update tmp_letra
	   set monto_letra = _monto_letra;

	let _resto = _resto - _monto_letra;

end for

update tmp_letra	
   set monto_letra = monto_letra + _resto
 where no_poliza   = a_no_poliza
   and no_letra    = _letra_ini;


	insert into endletra(
		    no_poliza,
			no_letra,
			fecha_vencimiento,
			periodo_gracia,
			pagada,
			fecha_aviso,
			aviso_enviado,
			cancelar_poliza,
			poliza_cancelada,
			monto_letra,
			dias_letra,
			no_endoso)
	select a_no_poliza,
		   no_letra,
		   fecha_vencimiento,
		   periodo_gracia,
		   pagada,
		   fecha_aviso,
		   aviso_enviado,
		   cancelar_poliza,
		   poliza_cancelada,
		   monto_letra,
		   dias_letra,
		   a_no_endoso
	  from tmp_letra;

drop table tmp_letra;

foreach

  select no_letra,
         monto_letra
    into _no_letra,
         _monto_letra
    from endletra
   where no_poliza = a_no_poliza
     and no_endoso = a_no_endoso

  update emiletra
     set monto_letra = monto_letra + _monto_letra
   where no_poliza   = a_no_poliza
     and no_letra    = _no_letra;

end foreach

end

return 0, "Actualizacion Exitosa";

end procedure
