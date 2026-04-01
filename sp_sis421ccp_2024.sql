--Procedimiento para cargar la prima suscrita periodo anterior del concurso.

drop procedure sp_sis421ccp_2024;
create procedure sp_sis421ccp_2024()
returning integer;

define _error			integer;
define _no_poliza       char(10);
define _no_endoso,_cod_agente,_cod_agente_anterior       char(10);
define _no_documento    char(20);	   
define _prima_suscrita  dec(16,2);
define _prima_suscrita2 dec(16,2);
define _prima_fac       dec(16,2);
define _cnt             integer;
define _porc_coaseguro	dec(16,4);
define _cod_tipoprod,_cod_ramo,_cod_subramo    char(3);
define _porcentaje   dec(16,4);
define _concurso,_unificar     smallint;
define _tipo_agente    char(1);
define _cod_grupo      char(5);

begin
on exception set _error
	return _error;
end exception

let _prima_suscrita	= 0;
let _prima_fac      = 0;
let _concurso       = 0;

delete from deivid_tmp:prisusapccp_24;

foreach
	select no_poliza,
		   no_endoso,
		   no_documento,
		   prima_suscrita
	  into _no_poliza,
		   _no_endoso,
		   _no_documento,		   
		   _prima_suscrita
	  from endedmae
	 where actualizado  = 1
	   and periodo between '2023-01' and '2023-12'
	
	select cod_ramo, cod_subramo, cod_tipoprod,cod_grupo
	  into _cod_ramo, _cod_subramo, _cod_tipoprod,_cod_grupo
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	if _cod_grupo in('00000','1000') then --Grupo del estado no aplica
		continue foreach;
	end if	 

--	 Se quita caso: 1688   Roman G.
{	select concurso
	  into _concurso
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;

	if _concurso = 0 then -- Excluir del Concurso
		continue foreach;
	end if  	
}
	if _cod_tipoprod = "004" then	--Excluir Reaseguro Asumido
		continue foreach;
	end if

    if (_cod_ramo = '001' and _cod_subramo = '006') OR _cod_ramo = '008' then  -- Se excluye Zona L.,France F. y Cocosolito. y ramo de Fianzas
		continue foreach;
	end if
	
	let _prima_fac = 0;
	
	select sum(c.prima)
	  into _prima_fac
	  from emifacon c, reacomae r
	 where c.no_poliza = _no_poliza
	   and c.no_endoso = _no_endoso
	   and r.cod_contrato = c.cod_contrato
	   and r.tipo_contrato = 3;

	if _prima_fac is null then
		let _prima_fac = 0.00;
	end if

	let _prima_suscrita = _prima_suscrita - _prima_fac;

   --rehabilitada o cancelada en el periodo del concurso no va
   --Se quita caso: 1688   Roman G.

{   select count(*)
     into _cnt
     from endedmae
    where no_poliza     = _no_poliza
	  and actualizado   = 1
      and cod_endomov in ('003','002') --rehabilitacion y cancelacion 	
      and fecha_emision >= '01/01/2020'
      and fecha_emision <= '31/12/2020';
	  
	if _cnt is null then
		let _cnt = 0;
	end if
}	
	--if _cnt = 0 then
		foreach
			select cod_agente,
				   porc_partic_agt
			  into _cod_agente,
				   _porcentaje
			  from endmoage
			 where no_poliza = _no_poliza
               and no_endoso = _no_endoso
			   
		    let _prima_suscrita2 = 0.00;
			let _prima_suscrita2 = _prima_suscrita * _porcentaje /100;
			
			--********  Unificacion de Agente *******
			let _cod_agente_anterior = _cod_agente;
			call sp_che168(_cod_agente_anterior) returning _error,_cod_agente;
			
			select tipo_agente
			  into _tipo_agente
			  from agtagent
			 where cod_agente = _cod_agente;

			IF _tipo_agente <> "A" then	-- Solo Corredores
				continue foreach;
			END IF

			if _cod_agente = "00180" and   -- Tecnica de Seguros
			   _cod_ramo   = "016"	 and   -- Colectivo de vida
			   _cod_grupo  = "01016" then  -- Grupo Suntracs
				continue foreach;
			end if
			insert into deivid_tmp:prisusapccp_24(no_documento, prima_suscrita, cod_agente,cod_ramo)
			values (_no_documento, _prima_suscrita2, _cod_agente,_cod_ramo);
			
		end foreach
	--end if	
end foreach
end
return 0;
end procedure