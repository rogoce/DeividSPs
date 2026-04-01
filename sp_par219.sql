drop procedure sp_par219;

create procedure "informix".sp_par219()
returning integer,
          char(50);

define _cod_contrato	char(5);

foreach
 select cod_contrato
   into _cod_contrato
   from reacomae
  where fronting      = 1
	and tipo_contrato = 3

	delete from rearucon
	 where cod_contrato = _cod_contrato;

end foreach

end procedure