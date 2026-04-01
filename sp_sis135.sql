--Procedure que retorna si alguna unidad tiene algun contrato fronting
--drop procedure sp_sis135;		
--Armando Moreno 30/09/2010

create procedure "informix".sp_sis135(a_no_poliza char(10))
returning integer;

define _cod_contrato char(5);
define _cnt          smallint;

set isolation to dirty read;
begin

foreach
	select cod_contrato
	  into _cod_contrato
	  from emifacon
	 where no_poliza = a_no_poliza
	   and no_endoso = '00000'
	   and porc_partic_suma <> 0
	   and porc_partic_prima <> 0

	select count(*)
	  into _cnt
	  from reacomae
	 where cod_contrato = _cod_contrato
	   and fronting     = 1;

	if _cnt > 0 then --es fronting el contrato
		return 1;
    end if
end foreach

return 0;
end
end procedure;