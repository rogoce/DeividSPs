-- Procedimiento que Verifica las primas suscritas entre entre endedmae y sac

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_sac44;

create procedure "informix".sp_sac44()
returning integer;

define _prima_susc1	dec(16,2);
define _prima_susc2	dec(16,2);
define _no_poliza  	char(10);
define _no_endoso  	char(5);
define _no_factura 	char(10);
define _cod_endomov	char(3);
define _periodo		char(7);

define _par_mesfiscal char(2);
define _par_anofiscal char(4);

select par_mesfiscal,
	   par_anofiscal
  into _par_mesfiscal,
	   _par_anofiscal
  from cglparam;

let _periodo = _par_anofiscal || "-" || _par_mesfiscal;
 
foreach
 select prima_suscrita,
        no_poliza,
		no_endoso,
		no_factura,
		cod_endomov,
		periodo
   into _prima_susc1,
        _no_poliza,
		_no_endoso,
		_no_factura,
		_cod_endomov,
		_periodo
   from endedmae
  where periodo     >= "2004-10"
    and periodo     <= _periodo
    and actualizado = 1  

	select sum(debito + credito)
	  into _prima_susc2
	  from endasien
	 where no_poliza   = _no_poliza
	   and no_endoso   = _no_endoso
	   and cuenta[1,3] = "411";

	if _prima_susc2 is null then
		let _prima_susc2 = 0;
	end if

	let _prima_susc2 = _prima_susc2 * -1;

	if _prima_susc1 <> _prima_susc2 then
		
		return 1;

	end if

end foreach

return 0;

end procedure