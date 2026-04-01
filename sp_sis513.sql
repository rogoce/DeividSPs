-- Procedimiento para buscar el valor del descuento
-- f_emision_busca_descuento
--
-- Creado    : 15/03/2006 - Autor: Amado Perez M.
-- Modificado: 15/03/2006 - Autor: Amado Perez M.
-- Como el sp_proe21 pero para tablas de endoso.
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis513;
create procedure "informix".sp_sis513(a_poliza char(10), a_endoso char(5), a_unidad char(5), a_cobertura char(5), a_prima dec(16,2))
returning   decimal(16,2), decimal(16,2);			 -- ld_descuento

define ld_porc_desc		decimal(10,4);
define ld_prima_neta    decimal(16,2);
define ld_desc_cob      decimal(16,2);
define _cant            smallint;

let ld_porc_desc = 0.00;
let _cant = 0;
let ld_prima_neta = a_prima;
let ld_desc_cob = 0;

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
    foreach
		select porc_descuento
		  into ld_porc_desc
		  from emicobde  
		 where no_poliza = a_poliza
		   and no_unidad = a_unidad 
		   and cod_cobertura = a_cobertura
		
		let ld_desc_cob = ld_desc_cob + ld_prima_neta * ld_porc_desc / 100;
		let ld_prima_neta = ld_prima_neta - ld_prima_neta * ld_porc_desc / 100;
		   
	end foreach
	
else
	select count(*)
	  into _cant
	  from endcobde  
	 where no_poliza = a_poliza
	   and no_endoso = '00000'
	   and no_unidad = a_unidad 
	   and cod_cobertura = a_cobertura;
	   
	if _cant > 0 then
		foreach
			select porc_descuento
			  into ld_porc_desc
			  from endcobde  
			 where no_poliza = a_poliza
			   and no_endoso = '00000'
			   and no_unidad = a_unidad 
			   and cod_cobertura = a_cobertura

			let ld_desc_cob = ld_desc_cob + ld_prima_neta * ld_porc_desc / 100;
			let ld_prima_neta = ld_prima_neta - ld_prima_neta * ld_porc_desc / 100;
		end foreach	
	end if
end if

if ld_prima_neta is null then
	let ld_prima_neta = 0.00;
end if

--let ld_desc_cob = a_prima - ld_prima_neta;
return ld_prima_neta, ld_desc_cob;
end
end procedure;