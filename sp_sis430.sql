-- Procedimiento para buscar el valor del descuento
-- f_emision_busca_descuento
--
-- Creado    : 15/03/2006 - Autor: Amado Perez M.
-- Modificado: 15/03/2006 - Autor: Amado Perez M.
-- Como el sp_proe21 pero para tablas de endoso.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis430;
create procedure sp_sis430(a_poliza char(10), a_endoso char(5), a_unidad char(5), a_cobertura char(5))
returning   decimal(10,4);			 -- ld_descuento

define ld_porc_desc		decimal(10,4);
define _cant            smallint;

let ld_porc_desc = 0.00;
let _cant = 0;

begin

set isolation to dirty read;

-- set debug file to "\\nemesis\ancon\store procedures\debug\sp_pro44.trc";      
-- trace on;                                                                     

select count(*)
  into _cant
  from emicobde
 where no_poliza = a_poliza
   and no_unidad = a_unidad 
   and cod_cobertura = a_cobertura;
  
If _cant > 0 then  
	select sum(porc_descuento)
	  into ld_porc_desc
	  from emicobde  
	 where no_poliza = a_poliza
	   and no_unidad = a_unidad 
	   and cod_cobertura = a_cobertura;
else
	select sum(porc_descuento)
	  into ld_porc_desc
	  from endcobde  
	 where no_poliza = a_poliza
	   and no_endoso = '00000'
	   and no_unidad = a_unidad 
	   and cod_cobertura = a_cobertura;
end if

if ld_porc_desc is null then
	let ld_porc_desc = 0.00;
end if

return ld_porc_desc;
end
end procedure;