drop procedure sp_sac70;

create procedure sp_sac70()
returning integer;

define _cod_auxiliar	char(5);
define _debito			dec(16,2);
define _credito			dec(16,2);
define _linea			integer;

begin work;

let _linea = 6;

foreach
select a.cod_auxiliar, 
       sum(a.debito), 
       sum(a.credito)
  into _cod_auxiliar,
       _debito,
	   _credito
  from chqchmae q, chqchcta c, chqctaux a
 where q.no_requis = c.no_requis
   and c.no_requis       = a.no_requis
   and c.renglon         = a.renglon
   and q.pagado = 1
   and month(q.fecha_impresion) = 7
   and year(q.fecha_impresion) = 2007
   and c.cuenta = "26410"
 group by a.cod_auxiliar

	let _linea = _linea + 1;

	insert into cglresumen1
	values (73297, _linea, "01", "CHE07071", "26410", _cod_auxiliar, _debito, _credito, "CGL");

end foreach

--rollback work;
commit work;

return 0;

end procedure