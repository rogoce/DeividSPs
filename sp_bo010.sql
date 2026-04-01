-- Procedimiento que crea las tablas para la carga de los estados financieros

-- Creado    : 14/10/2005 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_bo010;

create procedure "informix".sp_bo010()
returning integer,
          char(50);

define _error	integer;
define _descrip char(50);

set isolation to dirty read;

begin 
on exception set _error
	return _error, "Error al Actualizar Registros";
end exception

{
-- Conversion de la tabla de centro de costos

call sp_bo051() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo051";
end if

-- Conversion de la tabla de Cuentas

call sp_bo013() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo013";
end if

-- Conversion de los Saldos de todas las companias

call sp_bo014() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo014";
end if

-- Actualizacion de Enlaces

call sp_bo061() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo014";
end if

-- Conversion de Detalle de Cuentas Resumen

call sp_bo031() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo031";
end if

-- Conversion de Auxiliares de Cuentas

call sp_bo039() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo039";
end if

--}

{
-- Calculo de la prima cobrada

--call sp_bo062() returning _error, _descrip;  -- Usando Cobasien

call sp_bo059() returning _error, _descrip;	   -- Usando Cobredet

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo062";
end if
}

--{
-- Creacion del esquema inicial de ef_estfin

call sp_bo055() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo055";
end if

-- Calculo de los estados financieros

call sp_bo015() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo015";
end if

-- Calculo del Peso de la Cartera

call sp_bo016() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo016";
end if

-- Calculo para la Ponderacion de los gastos

call sp_bo017() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo017";
end if

-- Variacion de Reservas

call sp_bo018() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo018";
end if

-- Gastos Administrativos, Ingresos y Utilidad

call sp_bo019() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo019";
end if

-- Pasivos de Gastos Administrativos, Ingresos y Utilidad

call sp_bo063() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo063";
end if

-- Presupuesto de Gastos Administrativos, Ingresos y Utilidad

call sp_bo057() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo019";
end if

-- Acumulacion de Totales

call sp_bo056() returning _error, _descrip;

if _error <> 0 then
	return _error, trim(_descrip) || " sp_bo056";
end if
--}

end

return 0, "Actualizacion Exitosa";

end procedure