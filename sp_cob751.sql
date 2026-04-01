-- Borrar Carga de COBPAEX0, COBPAEX1 
-- Realizado : Henry Giron 28/08/2010
 													   
drop procedure sp_cob751;

create procedure sp_cob751(a_cod_agente char(10), a_no_remesa char(10), a_numero char(10))
returning integer,
          char(100);

define _numero	char(10);
define _cant	integer;
define _error	integer;

--return 1,'SOLICITAR AUTORIZACION A COMPUTO';	  --Quitar cuando se desee eliminar la carga
--set debug file to "sp_cob751.trc";
--trace on;


begin
on exception set _error
	return _error, "Error Borrar Carga de Pagos Externos.";
end exception

let _cant = 0;

select count(*)
  into _cant
  from cobpaex0
 where cod_agente = a_cod_agente
   and no_remesa  = a_no_remesa
   and insertado_remesa = 0 ;

if _cant = 0 Then
	return 1, "Carga no Valida para ser Eliminada " || a_no_remesa;
end if

{select trim(numero)
  into _numero
  from cobpaex0
 where cod_agente = a_cod_agente
   and no_remesa  = a_no_remesa
   and insertado_remesa = 0;}

delete from cobpaex4 where numero = a_numero;
delete from cobpaex1 where numero = a_numero;
delete from cobpaex0 where cod_agente = a_cod_agente and no_remesa = a_no_remesa and numero = a_numero;

end

return 0, "Carga Eliminada con Exito.";

end procedure