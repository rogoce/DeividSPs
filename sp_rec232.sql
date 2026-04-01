-- Procedure que carga la tabla recordadd en caso de estar vacia 													   
-- Creado por: Amado Perez 08/10/2014

drop procedure sp_rec232;

create procedure sp_rec232(a_ajus_orden char(10) , a_renglon smallint, a_orden CHAR(10))
returning integer;

define _cnt             smallint;
define _tramite         char(10);
define _numrecla		char(18);
define _no_orden        char(10);
define _error           integer;
define _cod_proveedor   char(10);
define _dif             dec(16,2);
define _tipo_opc        smallint;

--SET DEBUG FILE TO "sp_rec232.trc"; 
--TRACE ON;                                                                

set isolation to dirty read;

begin


let _error     = 0;
let _dif       = 0;
let _tipo_opc  = 0;

let _cnt = 0;

select monto_orden - monto, 
       tipo_opc 
  into _dif, 
       _tipo_opc
  from recordad
 where no_ajus_orden = a_ajus_orden
   and renglon = a_renglon;

select count(*)
  into _cnt
  from recordadd
 where no_ajus_orden = a_ajus_orden
   and renglon       = a_renglon;

if _cnt = 0 and _tipo_opc = 0 then
	insert into recordadd (
		no_ajus_orden,
		renglon,
		no_orden,
		renglon2,
		no_parte,
		desc_orden,
		cantidad,
		valor,
		despachado,
		cnt_despachado,
		valor_ajust)
    select	a_ajus_orden,
	        a_renglon,
			no_orden,
			renglon,
			no_parte,
			desc_orden,
			cantidad - cnt_despachado,
			(valor / cantidad) * (cantidad - cnt_despachado),
			0,
			0,
			0
	   from	recordde
	  where no_orden = a_orden
	    and cantidad <> cnt_despachado;  


   if _dif = 0 then
	update recordadd
	   set despachado = 1,
	       cnt_despachado = cantidad,
		   valor_ajust = valor
	 where no_ajus_orden = a_ajus_orden
	   and renglon = a_renglon;
   end if

end if


end

return 0;
end procedure