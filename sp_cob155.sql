-- Procedimiento que actualiza el saldo inicial para cobcuasa
-- 
-- Creado    : 08/07/2004 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob155;

create procedure "informix".sp_cob155()

define _no_documento	char(20);
define _periodo			char(7);
define _periodo_ant		char(7);
define _saldo			dec(16,2);
define _mes				smallint;

foreach
 select no_documento,
        periodo
   into _no_documento,
        _periodo
   from cobcuasa
  where periodo[1,4] = 1999

	let _mes = _periodo[6,7];
	
	if _mes = 1 then
		let _periodo_ant = "1998-12";
	else
		
		let _mes = _mes - 1;
				
		if _mes < 10 then
			let _periodo_ant = _periodo[1,4] || "-0" || _mes;
		else
			let _periodo_ant = _periodo[1,4] || "-" || _mes;
		end if 

	end if

	select saldo_final
	  into _saldo
	  from cobcuasa
	 where no_documento = _no_documento
	   and periodo      = _periodo_ant;

	if _saldo is null then
		let _saldo = 0;
	end if

	update cobcuasa
	   set saldo_inicial = _saldo
	 where no_documento  = _no_documento
	   and periodo       = _periodo;
			
end foreach

end procedure
