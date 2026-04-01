-- Procedimiento para verificar si la suma asegurada es igual al valor actual del auto
--
-- Creado    : 10/01/2013 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_imp11;

CREATE PROCEDURE sp_imp11(a_poliza CHAR(10), a_unidad CHAR(5))
	
DEFINE v_suma_asegurada  decimal(10,2);
DEFINE v_valor_auto      decimal(10,2);
DEFINE v_no_motor        CHAR(30);
DEFINE v_mensaje        CHAR(30);

SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_imp11.trc";
--TRACE ON;                                                                 

select suma_asegurada
  into v_suma_asegurada
  from emipouni 
 where no_poliza = a_poliza
   and no_unidad = a_unidad;

select no_motor
  into v_no_motor
  from emiauto
 where no_poliza = a_poliza
  and no_unidad = a_unidad;

select valor_auto
  into v_valor_auto
  from emivehic 
 where no_motor = v_no_motor;

if v_suma_asegurada <> v_valor_auto then
	update emivehic
	   set valor_auto = v_suma_asegurada
	 where no_motor = v_no_motor;
end if
END PROCEDURE