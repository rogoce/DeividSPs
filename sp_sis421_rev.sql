--Procedimiento para cargar la prima suscrita periodo anterior del concurso.

drop procedure sp_sis421_rev;
create procedure sp_sis421_rev()
returning integer;

define _error					integer;
define _no_documento			char(20);	   
define _cod_agente_anterior	char(10);
define _no_poliza				char(10);
define _cod_agente			char(10);
define _no_endoso				char(10);
define _cod_grupo				char(5);
define _cod_tipoprod			char(3);
define _cod_subramo			char(3);
define _cod_ramo				char(3);
define _tipo_agente			char(1);
define _flag_fronting			smallint;
define _flag_concurso			smallint;
define _flag_canc				smallint;
define _flag_gob				smallint;
define _concurso				smallint;
define _fronting				smallint;
define _unificar				smallint;
define _flag_zl				smallint;
define _cnt					integer;
define _prima_suscrita2		dec(16,2);
define _prima_suscrita		dec(16,2);
define _prima_cedida			dec(16,2);
define _prima_neta			dec(16,2);
define _prima_fac				dec(16,2);
define _porc_coaseguro		dec(16,4);
define _porcentaje			dec(16,4);

begin
on exception set _error
	return _error;
end exception

let _prima_suscrita	= 0;
let _prima_fac      = 0;
let _concurso       = 0;
let _fronting       = 0;

--delete from prisusap;

foreach
	select mae.no_poliza,
			mae.no_endoso,
			mae.no_documento,
			mae.prima_neta,
			mae.prima_suscrita,
			emi.cod_ramo,
			emi.cod_subramo,
			emi.cod_tipoprod,
			emi.cod_grupo,
			emi.fronting
	  into _no_poliza,
		   _no_endoso,
		   _no_documento,		   
		   _prima_neta,
		   _prima_suscrita,
		   _cod_ramo,
		   _cod_subramo,
		   _cod_tipoprod,
		   _cod_grupo,
		   _fronting
	  from endedmae mae
	 inner join emipomae emi on emi.no_poliza = mae.no_poliza
	 where mae.actualizado  = 1
	   and mae.periodo between '2024-01' and '2024-12'
	   
	let _flag_concurso = 0;
	let _flag_fronting = 0;
	let _flag_canc = 0;
	let _flag_gob = 0;
	let _flag_zl = 0;

	if _cod_grupo in('00000','1000') then --Grupo del estado no aplica
		--continue foreach;
		let _flag_gob = 1;
	end if
	if _fronting is null then
		let _fronting = 0;
	end if
	if _fronting = 1 then  --Se excluye polizas fronting
		--continue foreach;
		let _flag_fronting = 1;
	end if

	select concurso
	  into _concurso
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo; 			

	if _concurso = 0 then -- Excluir del Concurso
		--continue foreach;
		let _flag_concurso = 1;
	end if  	

	if _cod_tipoprod = "004" then	--Excluir Reaseguro Asumido
		continue foreach;
	end if

    {if _cod_ramo = '001' then  -- Se excluye Ramo Incendio
		continue foreach;
	end if}
    if _cod_ramo = '001' and _cod_subramo = '006' then  -- Se excluye Zona L.,France F. y Cocosolito. Ramo Incendio
		--continue foreach;
		let _flag_zl = 1;
	end if
    if _cod_ramo = '003' and _cod_subramo = '005' then  -- Se excluye Zona L.,France F. y Cocosolito. Ramo Multiriesgo
		--continue foreach;
		let _flag_zl = 1;
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

   select count(*)
     into _cnt
     from endedmae
    where no_poliza     = _no_poliza
	  and actualizado   = 1
      and cod_endomov in ('003','002') --rehabilitacion y cancelacion 	
      and fecha_emision >= '01/01/2024'
      and fecha_emision <= '31/12/2024';
	  
	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt = 0 then
		let _flag_canc = 0;
	else
		let _flag_canc = 1;
	end if
	
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

			/*IF _tipo_agente <> "A" then	-- Solo Corredores
				continue foreach;
			END IF*/

			if _cod_agente = "00180" and   -- Tecnica de Seguros
			   _cod_ramo   = "016"	 and   -- Colectivo de vida
			   _cod_grupo  = "01016" then  -- Grupo Suntracs
				continue foreach;
			end if
			
			insert into deivid_tmp:tmp_prisusap(no_documento, prima_suscrita, cod_agente,flag_gob,flag_zl,flag_canc,flag_concurso,prima_fac,anio,flag_fronting)
			values (_no_documento, _prima_suscrita2, _cod_agente,_flag_gob,_flag_zl,_flag_canc,_flag_concurso,_prima_fac,2024,_flag_fronting);
			
		end foreach
	--end if	
end foreach
end
return 0;
end procedure;