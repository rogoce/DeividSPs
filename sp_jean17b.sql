
DROP procedure sp_jean17b;
CREATE procedure sp_jean17b()
RETURNING char(5),char(5);



{char(5) as cod_agente,
char(3) as z_vta_gral_ant,
char(3) as z_vta_gral_act,
char(3) as z_vta_persona_act;}
		  


define _prima_suscrita dec(16,2);
define _cod_agente,_cod_agente_anterior       char(5);
define _error integer;
define _error_desc char(50);

foreach
	select cod_agente,
	       prima_suscrita
	  into _cod_agente,
		   _prima_suscrita
	  from deivid_tmp:galeria_corredor
	 where cod_agente not in('02570','02427','00270')  
	 order by cod_agente
	 
	let _cod_agente_anterior = _cod_agente;
	--********  Unificacion de Agente *******
	call sp_che168(_cod_agente_anterior) returning _error,_cod_agente;
	
	if _cod_agente_anterior <> _cod_agente then
		update deivid_tmp:galeria_corredor
		   set prima_suscrita = prima_suscrita + _prima_suscrita
		  where cod_agente = _cod_agente;
		
		delete from deivid_tmp:galeria_corredor
		 where cod_agente = _cod_agente_anterior;
		
		return _cod_agente_anterior,_cod_agente with resume;
	end if
end foreach
END PROCEDURE;
