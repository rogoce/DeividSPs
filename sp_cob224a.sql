-- Procedure que Retorna la caja para comprobantes

-- Creado    : 25/01/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob224a;

create procedure sp_cob224a(a_cod_formato char(10),a_tipo_formato smallint)
returning char(3), 
          char(3);

define _caja_caja	char(3);
define _caja_comp	char(3);

set isolation to dirty read;

let a_cod_formato = trim(a_cod_formato); 

select cod_banco,
	   cod_chequera
  into _caja_caja,
  	   _caja_comp
  from cobforpaexm
 where cod_agente	= a_cod_formato
   and tipo_formato	= a_tipo_formato;

if _caja_comp is null then	  --Prod. 16/09/2013
	let _caja_comp = '023';
end if

return _caja_caja, _caja_comp;

end procedure