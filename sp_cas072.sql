-- Arreglar Sucursal Equivocada

-- Creado    : 23/01/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_cas072;

create procedure "informix".sp_cas072()
returning smallint;

define _cod_cliente char(10);
define _cantidad	smallint;

let _cantidad = 0;

begin work;

foreach
 select c1.cod_cliente
   into _cod_cliente
   from cascliente c1, caspoliza c2, emipomae p
  where c1.cod_cliente = c2.cod_cliente
    and c2.no_documento = p.no_documento
    and c1.cod_cobrador in ('006', '044', '046')
    and p.sucursal_origen = '003'

	update cascliente 
	   set cod_cobrador = "018"
	 where cod_cliente  = _cod_cliente;

	let _cantidad = _cantidad + 1;

end foreach

if _cantidad = 126 then
	commit work;
else
	rollback work;
end if

return _cantidad;

end procedure