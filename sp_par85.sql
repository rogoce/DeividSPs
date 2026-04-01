-- Actualizadion masiva de los datos de promotorias

-- Creado    : 04/09/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 04/09/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par85;

create procedure "informix".sp_par85()

define _ret_desc		char(100);
define _ret_valor		smallint;
define _cod_agente 		char(5);
define _cod_vendedor	char(3);
define _cod_ramo 		char(3);

delete from parpromo;

foreach
 select	cod_agente,
        cod_vendedor
   into _cod_agente,
        _cod_vendedor
   from agtagent

	call sp_par82(_cod_agente, "informix") returning _ret_valor, _ret_desc;

	if _cod_vendedor = "003" or
	   _cod_vendedor = "015" or
	   _cod_vendedor = "016" or
	   _cod_vendedor = "018" then

		foreach 
		 select cod_ramo
		   into _cod_ramo
		   from prdramo
		  where cod_tiporamo = "002"

			update parpromo
			   set cod_vendedor = _cod_vendedor
			 where cod_agencia  = "001"
			   and cod_ramo     = _cod_ramo
			   and cod_agente   = _cod_agente;
		   
		end foreach
	
	end if

	-- Corredores de Melissa

	if _cod_agente in ("00081", "00731", "00960", "00169", "00623", "00620", "00521", "00650", "00291", "00270",
	                   "00176", "00499", "00130", "00636", "00517", "00917", "00795", "00197", "00802", "00726",
					   "00088", "00457", "00883", "00732", "00400", "00865", "00742", "00214", "00235", "00044",
					   "00874", "00180", "00141") then
 
		foreach 
		 select cod_ramo
		   into _cod_ramo
		   from prdramo
		  where cod_tiporamo = "001"

			update parpromo
			   set cod_vendedor = "005"
			 where cod_agencia  = "001"
			   and cod_ramo     = _cod_ramo
			   and cod_agente   = _cod_agente;
		   
		end foreach

	end if

	-- Corredores de Itza

	if _cod_agente in ("00882", "00031", "00494", "00621", "00011", "00035", "00743", "00629", "00218", "00107",
	                   "00120", "00626") then
 
		foreach 
		 select cod_ramo
		   into _cod_ramo
		   from prdramo
		  where cod_tiporamo = "001"

			update parpromo
			   set cod_vendedor = "025"
			 where cod_agencia  = "001"
			   and cod_ramo     = _cod_ramo
			   and cod_agente   = _cod_agente;
		   
		end foreach

	end if
	   						  
	-- Corredores de Raul

	if _cod_agente in ("00119", "00398", "00037", "00041", "00166", "00117", "00779", "00083", "00189", "00726",
	                   "00161", "00892", "00021", "00705", "00473", "00959", "00933") then
 
		foreach 
		 select cod_ramo
		   into _cod_ramo
		   from prdramo
		  where cod_tiporamo = "001"

			update parpromo
			   set cod_vendedor = "027"
			 where cod_agencia  = "001"
			   and cod_ramo     = _cod_ramo
			   and cod_agente   = _cod_agente;
		   
		end foreach

	end if

end foreach

update parpromo
   set cod_vendedor = "028"
 where cod_agencia  = "001"
   and cod_vendedor is null;
  
end procedure;

























