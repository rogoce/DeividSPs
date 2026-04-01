-- Procedure : arregla registros de ponderación
-- 
-- Creado    : 22/10/2021 - Autor: Amado Perez M.
--

drop procedure ap_arregla_pond;
create procedure ap_arregla_pond()
returning	smallint as registros, 
            smallint as procesados; 

define _cod_cliente char(10);
define _cod_correcto char(10);
define _cod_corr_ant char(10);
define _date_add     date;
define _cant         smallint;
define _reg          smallint;
define _proc         smallint;

let _cod_corr_ant = null;
let _cant = 0;
let _reg = 0;
let _proc = 0;

set isolation to dirty read;

FOREACH with hold
 select distinct pon.cod_cliente, 
        pon.date_add,
        dep.cod_correcto
   into _cod_cliente,
        _date_add,
        _cod_correcto
   from ponderacion pon
   inner join clidepur dep on dep.cod_errado = pon.cod_cliente
   order by dep.cod_correcto, pon.date_add Desc

   let _reg = _reg + 1;
   
   select count(*)
     into _cant
	 from ponderacion
	where cod_cliente = _cod_correcto;
	
   if _cant is null THEN
		let _cant = 0;
   end if
   
   if _cant > 0 THEN
	continue foreach;
   end IF
   
   if _cod_correcto <> _cod_corr_ant then
	   update ponderacion
		  set cod_cliente = _cod_correcto
		where cod_cliente = _cod_cliente
		  and date_add = _date_add;
		  
		let _proc = _proc + 1;
   end if
   
   let _cod_corr_ant = _cod_correcto;
   
 END FOREACH

return _reg, _proc; 
end procedure;