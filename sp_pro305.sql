-- Procedure que retorna el porcentaje de comision del corredor dependiendo del ramo

drop procedure sp_pro305;

create procedure sp_pro305(a_cod_agente char(5), a_cod_ramo char(3), a_cod_subramo char(3) default "*", a_no_poliza char(10) default null) 
returning dec(5,2);

define _porc_comision	dec(5,2);
define _porc_comis_sub  dec(5,2);
define _tipo_agente		char(1);
define _anos_pagador    smallint;
define _cod_prod        char(5);
define _porc_com        dec(5,2);
define _nueva_renov     char(1);

set isolation to dirty read;

select tipo_agente
  into _tipo_agente
  from agtagent
 where cod_agente = a_cod_agente;

if _tipo_agente = "O" then
	return 0.00;
end if

let _porc_comis_sub = 0;
let _porc_com = 0;

select porc_comision
  into _porc_comision
  from agtcomsu
 where cod_agente  = a_cod_agente
   and cod_ramo	   = a_cod_ramo
   and cod_subramo = a_cod_subramo;

if _porc_comision is null then

	select porc_comis_agt
	  into _porc_comision
	  from agtcomra
	 where cod_agente = a_cod_agente
	   and cod_ramo	  = a_cod_ramo;

	if _porc_comision is null then

		select porc_comision
		  into _porc_comision
		  from prdramo
		 where cod_ramo	= a_cod_ramo;
		 
		-- Se agrega lo de las renovaciones de vida individual -- Amado 15-12-2022
		
		if a_cod_ramo = '019' and a_no_poliza is not null then
			select anos_pagador,
			       nueva_renov
			  into _anos_pagador,
			       _nueva_renov
			  from emipomae
			 where no_poliza = a_no_poliza;
			 
			if _nueva_renov = 'R' then 
				foreach
					select cod_producto
					  into _cod_prod
					  from emipouni
					 where no_poliza = a_no_poliza
					exit foreach;
				end foreach			 
				 
				foreach
					select porc_comis_agt
					  into _porc_com
					  from prdcoprd
					 where cod_producto = _cod_prod
					   and _anos_pagador between ano_desde and ano_hasta
					exit foreach;
				end foreach
				
				if _porc_com is null then
					let _porc_com = 0;
				end if
				
				if _porc_com > 0 then
					return _porc_com;
				end if
			end if
        end if		

		select porc_comision
		  into _porc_comis_sub
		  from prdsubra
		 where cod_ramo    = a_cod_ramo
		   and cod_subramo = a_cod_subramo;

		if _porc_comis_sub is not null then
			if _porc_comis_sub > 0 and _porc_comis_sub <= 100 then
				let _porc_comision = _porc_comis_sub;
			end if
		end if
	end if
end if

return _porc_comision;

end procedure