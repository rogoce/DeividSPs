-- Procedimiento para verificar la suma asegurada de las polizas soda
--
-- Creado    : 10/01/2013 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_imp12;

CREATE PROCEDURE "informix".sp_imp12(a_poliza CHAR(10))
			RETURNING  INTEGER,	 -- _error
					   CHAR(50)	 --    Mensaje
	
DEFINE v_suma_asegurada_uni     decimal(10,2);
DEFINE v_suma_asegurada_emi     decimal(10,2);
DEFINE v_suma_asegurada    decimal(10,2);
DEFINE v_cod_ramo    char(3);


SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_imp12.trc";
--TRACE ON;                                                                 

select cod_ramo
into v_cod_ramo
from emipomae
where no_poliza = a_poliza;

if v_cod_ramo = '020' then
	select suma_asegurada
	into v_suma_asegurada_emi
	from emipomae
	where no_poliza = a_poliza;

	select sum(suma_asegurada)
	into v_suma_asegurada_uni
	from emipouni 
	where no_poliza = a_poliza;

	let v_suma_asegurada  = v_suma_asegurada_uni + v_suma_asegurada_emi;
		if v_suma_asegurada <> 0 then
			return 1, 'Las polizas soda no deben llevar suma asegurada';
		else
			return 0, 'Exito';
		end if
end if
return 0, '';
END PROCEDURE