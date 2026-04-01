-- Validacion de rezagada, si cumple pago entonces entra a verificar el bono
-- Creado     : 05/04/2018 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
-- execute procedure sp_che175('001','001','2017-10','DEIVID')

drop procedure sp_che175;
create procedure sp_che175(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo char(7), a_usuario CHAR(8))
returning smallint,
          char(100);

define _error_desc			char(100);
define _no_poliza           char(10);
define _no_documento		char(20);
define _error_isam			integer;
define _error				integer;
define _null				char(1);
define _cnt_pago            smallint;
define _cant				smallint;
define _cnt_aplica          smallint;
define _prima_sus_nva       dec(16,2);
define _prima_mensual       dec(16,2);
define _prima_cobrada       dec(16,2);
define _pri_sus_act         dec(16,2);
define _pri_sus_rezagada    dec(16,2);
define _motivo              char(100);
define _periodo_retro       char(7);
define _cod_agente			char(5);
define _monto_descontado	dec(16,2);
define _bono_rezagada		dec(16,2);
define _bono	            dec(16,2);
define _monto_rezagada		dec(16,2); 
define _cod_tipoprod        char(3);
define _porc_coaseguro      dec(9,4);
define _estatus_licencia    char(1);

begin
 on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception
set isolation to dirty read;

let _no_documento		= '';
let _cod_agente			= '';
let	_bono_rezagada		= 0.00;
let	_bono	            = 0.00;
let	_monto_rezagada	    = 0.00;
let _null				= null;
let _motivo             = '';
let _cnt_aplica         = 0;

--set debug file to "sp_cob175.trc";
--trace on;

--Busqueda de Poliza que aplican para el pago del bono y no ha sido rezagadas
foreach
 select r.cod_agente,r.no_poliza,cod_tipoprod,sum(a.prima_neta),round(sum(r.prima_sus_nva/p.no_pagos),2) 
  into _cod_agente, _no_poliza,_cod_tipoprod,_prima_cobrada,_prima_mensual
   from chqbono019 r, cobredet a, emipomae p
  where p.no_poliza = r.no_poliza
    and p.no_poliza = a.no_poliza
    and trim(lower(r.motivo)) = 'poliza no se pago su primera letra.'
    and a.periodo <= a_periodo	
    and r.periodo <> a_periodo
    and a.tipo_mov in ('P','N')
    and a.actualizado  = 1    
    and r.rezagada     = 0
    and r.aplica       = 0	
    and r.no_requis is null	
    group by 1,2,3	
	
	if _cod_tipoprod = "001" then	   -- Coaseguro Mayoritario, se debe sacar solo la parte de ancon.
		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = '036';

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;
		end if
		let _prima_cobrada = _prima_cobrada * (_porc_coaseguro / 100);
	end if	
		
		-- se coloca polizas que cumplen mas quedan en rezagada hasta que se pague.
		--if _prima_cobrada >= _prima_mensual then							   
		if abs(_prima_cobrada - _prima_mensual) <= 0.05 then	-- KLITUMA 24/09/2018 Rango de Holgura US $0.05		
			-- se adiciona no_requis en detalle para controlar las rezagadas
			UPDATE chqbono019
			   SET rezagada     = 1, motivo = _null
			 WHERE cod_agente   = _cod_agente
			   and no_poliza    = _no_poliza
			   AND no_requis    is null
			   AND aplica       = 0
			   AND rezagada     = 0;	   						
		end if				
		
end foreach	
	
select count(*) 
   into _cant 
   from chqbono019 
  where no_requis is null
    and motivo is null
	and rezagada = 1 	
	and aplica = 0;
	
if _cant = 0 or _cant = _null then
	return 0, 'No hay Polizas Rezagadas de Bono Vida Individual(Nuevas), Periodo: '||a_periodo;
end if		

--- Analiza polizas rezagadas por periodo retroactivos 
foreach 
 select periodo, cod_agente, count(no_documento), sum(prima_sus_nva)
   into _periodo_retro, _cod_agente, _cnt_pago, _pri_sus_rezagada
   from chqbono019 
  where no_requis is null
    and motivo is null
	and rezagada = 1 	
	and aplica = 0
	group by 1,2
  
  	if _pri_sus_rezagada is null then  	
	    Let _pri_sus_rezagada = 0.00;
	end if
	
	Let _bono_rezagada = 0;	   
	select bono,pri_sus_act
	  into _bono,_pri_sus_act
	  from chqbono019e   
	 where cod_agente = _cod_agente 
	   and periodo    = _periodo_retro;
	   
  	if _bono is null then  	
	     Let _bono = 0.00;
	end if	 	   
	   
  	if _pri_sus_act is null then  	
	     Let _pri_sus_act = 0.00;
	end if	   
	   
	let _prima_sus_nva = _pri_sus_act + _pri_sus_rezagada;
	
	-- Unificar Tabla de Rangos Bono sumando Rezadagas
	select monto
	  into _bono_rezagada  
	  from bonomae2 
	 where periodo[1,4]  = _periodo_retro[1,4] 
	   and cod_bono = '001' 
	   and round(_prima_sus_nva,0) between desde and hasta; 
	
	if _bono_rezagada is null then  	
	     Let _bono_rezagada = 0.00;
	end if			   
	   
	let _monto_rezagada = _bono_rezagada - _bono ;

	if _monto_rezagada = 0 then
	
	    if _cnt_pago > 0 then
			UPDATE chqbono019e
			   SET pri_sus_act = pri_sus_act + _pri_sus_rezagada,
				   cantidad    = cantidad + _cnt_pago
			 WHERE cod_agente  = _cod_agente 
			   and periodo     = _periodo_retro ; 
			   
			UPDATE chqbono019
			   SET aplica      = 1, motivo = 'rezagada se mantuvo en el rango '||cast(_bono_rezagada as varchar(10))
			 WHERE cod_agente   = _cod_agente	   
			   AND periodo     = _periodo_retro 
			   AND no_requis    is null
			   AND motivo       is null
			   AND aplica       = 0
			   AND rezagada     = 1;				   		
		end if
	
		continue foreach;
    else		
		select count(*) 
		   into _cant 
		   from chqbono019 
		  where cod_agente  = _cod_agente 
			and periodo     = _periodo_retro 
			and aplica = 1;
			
			if _cant = 0 or _cant is null then
			 let _cant = 0; 
		    end if			
			
			let _cnt_aplica = _cant + _cnt_pago; 
			
	         if _cnt_aplica >= 2 and _prima_sus_nva >= 1000 then	-- Para incluir la exclusion Pto-2 y Pto-3 
				UPDATE chqbono019 
				   SET rezagada     = 1   --  en caso que cumpla incluyendo la rezagada 
				 WHERE cod_agente   = _cod_agente 
				   AND periodo      = _periodo_retro  
				   AND no_requis    is null 
				   AND motivo       is null 
				   AND aplica       = 0 ; 
		   else
		       continue foreach;
		    end if											
	end if									
	
	
	-- Afecta el Encabezado de bono, prima_sus,cantidad y bono queda
	UPDATE chqbono019e
	   SET pri_sus_act = pri_sus_act + _pri_sus_rezagada,
		   cantidad    = cantidad + _cnt_pago,
		   bono_queda  = bono_queda + _monto_rezagada,
		   bono        = bono + _monto_rezagada,
		   aplica      = 1,
		   usuario     = a_usuario,
		   fecha       = current
	 WHERE cod_agente  = _cod_agente
	   and periodo     = _periodo_retro ;	   
	   
	--Afecta el detalle de No requis   
	UPDATE chqbono019
       SET monto_bono   = round((_monto_rezagada * round((1/_cnt_pago),4)),2),  
		    porc_bono   = round(round((1/_cnt_pago),4)*100,2), 									
		    aplica      = 1   
	 WHERE cod_agente   = _cod_agente	   
	   AND periodo     = _periodo_retro 
	   AND no_requis    is null
	   AND motivo       is null
	   AND aplica       = 0
	   AND rezagada     = 1;	 	   	   	 
	
end foreach
--- se genera la requisicion acumulativa sin importar el periodo retroactivo, los pagos iran al periodo de ejecucion del mes
let _error = 0;
foreach
select distinct cod_agente
   into _cod_agente
   from chqbono019 
  where no_requis is null
    and motivo    is null
	and rezagada  = 1 	
	and aplica    = 1
	
		select estatus_licencia
	  into _estatus_licencia
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	if _estatus_licencia = 'A' then
	
    -- se genera la requisiscion rezagadas del detalle
		call sp_che176(a_compania,a_sucursal,_cod_agente,a_usuario,'001','001',a_periodo) returning _error;
		if _error <> 0 then
			return _error,'Actualiza Poliza Rezagada Exitosa...Error. '||a_periodo;
		end if
	
	end if
		


end foreach	

return 0, 'Actualizacion Exitosa... '||a_periodo;
end
end procedure