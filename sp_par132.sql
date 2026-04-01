-- Procedimiento que muestra la provision de comision por pagar
-- 
-- Creado     : 28/12/2004 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par132;

create procedure "informix".sp_par132(a_periodo char(7))
returning char(20),
	      dec(16,2),
		  char(3),
		  char(50);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_impuesto	char(3);

define _saldo			dec(16,2);

define _cod_tipoprod	char(3);
define _cod_ramo		char(3);
define _nombre_ramo		char(50);

--set debug file to "sp_par131.trc";
--trace on;

set isolation to dirty read;

foreach
 select no_documento
   into _no_documento
   from emipomae
  where actualizado = 1
    and cod_tipoprod in ("001", "002", "005")
--  and cod_tipoprod in ("002")
--	and no_documento = "0203-00428-23"
  group by no_documento

	let _no_poliza   = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_ramo
	  into _cod_tipoprod,
	       _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "004" then -- Reaseguro Asumido
		continue foreach;
	end if

	let _saldo = sp_cob175(_no_documento, a_periodo);

	if _saldo = 0.00 then
		continue foreach;
	end if

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	return _no_documento,
	       _saldo,
		   _cod_ramo,
		   _nombre_ramo
		   with resume;

end foreach

end procedure