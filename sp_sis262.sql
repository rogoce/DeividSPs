--Procedimiento para evitar que se haga una devolucion de prima de una poliza y requisición para un cliente en particular.
--esta vinculado a transacciones de reclamos desde deivid, que quieran generar requisicion de cheques.

DROP PROCEDURE sp_sis262;
CREATE PROCEDURE sp_sis262(a_no_documento CHAR(20), a_cod_cte char(10) default "") RETURNING smallint,varchar(100);


SET ISOLATION TO DIRTY READ;

if a_cod_cte = "" then
	if a_no_documento in('2322-00013-01') then
		return 1,"A esta poliza NO se le puede hacer Devolucion de Prima, consultar con Cobros.";
	end if
else
	if a_cod_cte in("26040","660714") then
		return 1,"A este Cliente NO se le puede hacer Requisicion, consultar con Cobros.";
	end if
end if	

RETURN 0,"";

END PROCEDURE;