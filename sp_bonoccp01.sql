--****************************************************************************************************
-- Procedimiento para determinar bono sobre prima nueva cobrada 2025 PROYECTO CCP  INCENTIVO 1
--****************************************************************************************************

-- Creado    : 08/05/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_bonoccp01;
CREATE PROCEDURE sp_bonoccp01()
RETURNING INTEGER;

DEFINE _cod_agente,_cod_agente_anterior CHAR(5);
DEFINE _cod_agente_tmp  CHAR(5);
DEFINE _no_poliza       CHAR(10);
define _cod_vendedor    char(3); 
DEFINE _monto           DEC(16,2);
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
define _forma_pag		smallint;
define _prima_sus_ant	DEC(16,2);
define _cod_grupo       char(5);
define _prima_neta		DEC(16,2);
define _renglon         smallint;
define _no_recibo       char(10);
define _cnt             smallint;
define _prima_r         DEC(16,2);
define _monto_b         DEC(16,2);
define _prima_n         DEC(16,2);
define _cod_subramo     char(3);
define _concurso        smallint;
define _declarativa     smallint;
define _agente_agrupado char(5);
define _no_documento    char(20);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _prima_fac       DEC(16,2);
define v_exigible       DEC(16,2);
define v_corriente		DEC(16,2);
define v_monto_30		DEC(16,2);
define v_monto_60		DEC(16,2);
define _es_mensual      smallint ;
define _desde			char(7);
define _hasta           char(7);
define _fecha_ini		date;
define _fecha_fin		date;
define _fecha_anulado   date;
define _pagado          smallint;
define _pri_sus_fal     dec(16,2);
define _no_requis		char(10);
define _monto_fac_ac    dec(16,2);
define _monto_fac       dec(16,2);
define _porc_partic_prima dec(16,2);
define _porc_proporcion   dec(16,2);
define _periodo           char(4);
define _porc_coaseguro    decimal(7,4);
define _cod_coasegur      char(3);
define _prima             decimal(16,2);
define _prima_retenida,_meta_minima    decimal(16,2);
define _cnt_rg,_tipo_contrato,_valor,_estatus_poliza		  smallint;
define _ano_actual,_unificar        integer;
define _periodo_actual    char(7);
define _prima_cob_ap      decimal(16,2);

on exception set _error, _error_isam, _error_desc
   return _error;
end exception

let _error           = 0;
let _prima_neta      = 0;
let _cnt             = 0;
let _prima_r         = 0;
let _monto_b         = 0;
let _prima_n         = 0;
let _declarativa     = 0;
let _prima_fac	     = 0;
let	v_exigible  	 = 0;
let	v_corriente		 = 0;
let	v_monto_30		 = 0;
let	v_monto_60		 = 0;
let _pri_sus_fal	 = 0;
let _monto_fac_ac    = 0;
let _monto_fac		 = 0;
let _porc_proporcion = 0;
let _porc_partic_prima = 0;
let _prima_suscrita    = 0;
let _cnt_rg            = 0;
let _prima_retenida    = 0;
let _prima_sus_ant     = 0;
let _prima_cob_ap      = 0;

let _desde = null;
let _hasta = null;

--Meta Minima
let _meta_minima = 2000;

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "sp_bonoccp01.trc";
--TRACE ON;
--******************************************************
select periodo_verifica
  into _periodo_actual
  from emirepar;
  
let _periodo = _periodo_actual[1,4];

--if _periodo_actual[1,4] = '2026' then
	return 0; --YA NO SE VA A PAGAR POR INSTRUCCION DE ROMAN 12/05/2025
--end if
--******************************************************
let _cod_coasegur = '036';	--ASEGURADORA ANCON, S.A.

delete from bono_ccpl
where periodo = _periodo;

--***************************AGREGAR CORREDORES NUEVOS
foreach
	select cod_agente
	  into _cod_agente
	  from agtagent
	 where year(date_added) = _periodo
	   and tipo_agente      = 'A'
	   
	let _cod_agente_anterior = _cod_agente;
	call sp_che168(_cod_agente_anterior) returning _error,_cod_agente;  --Buscar si el corredor nuevo esta agrupado y ya existia en la tabla.

	select count(*)
	  into _cnt
	  from prisusapccp
	 where cod_agente = _cod_agente;
	
    if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt = 0 then	--Si no esta el corredor Nuevo, se inserta con prima anterior suscrita = 0   Subido:22/11/2021
		insert into prisusapccp(no_documento, prima_suscrita, cod_agente,cod_ramo)
		values ('', 0, _cod_agente,'');
	end if
end foreach
--****************************************************
--Solo para corredores con PS anterior menor a 25,000.
foreach
	select sum(prima_suscrita),
	       cod_agente
	  into _prima_sus_ant,
           _cod_agente	  
      from prisusapccp
     where cod_ramo not in('019')
     group by cod_agente
    having sum(prima_suscrita) < 25000
	
	foreach
		select e.no_documento,e.no_poliza
		  into _no_documento,_no_poliza
		  from emipomae e, emipoagt t
		 where e.no_poliza         = t.no_poliza
		   and e.cod_compania      = '001'
		   and e.actualizado       = 1
		   and e.nueva_renov       = "N"
		   and e.cod_ramo not in('008','019')	--excluye fianzas y vida individual
		   and e.vigencia_inic between  "01/01/2025" and "31/12/2025"
		   and t.cod_agente        = _cod_agente
		 group by e.no_documento,e.no_poliza
		 order by e.no_documento

		select porc_partic_agt
		  into _porc_partic
		  from emipoagt
		 where cod_agente = _cod_agente
		   and no_poliza  = _no_poliza;
				 
		select cod_ramo,
			   cod_subramo,
			   cod_tipoprod,
			   prima_suscrita,
			   estatus_poliza,
			   prima_retenida,
			   cod_grupo
		  into _cod_ramo,
			   _cod_subramo,
			   _cod_tipoprod,
			   _prima_suscrita,
			   _estatus_poliza,
			   _prima_retenida,
			   _cod_grupo
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		--se excluye 02442 caso 11579 19/09/24 9:45 am
		if _cod_agente in ('02442') then
			continue foreach;
		end if
			   
		if _cod_tipoprod in('002') then	--Se excluye tipo producción reaseguro asumido
			continue foreach;
		end if

		--Si la poliza es solo facultativo se excluye.
		let _cnt = 0;
		foreach
			select r.tipo_contrato
			  into _tipo_contrato
		   	  from emifacon e, reacomae r
		     where e.cod_contrato = r.cod_contrato
		       and e.no_poliza = _no_poliza
		     group by r.tipo_contrato
			 
			let _cnt = _cnt + 1;
		end foreach
		if _cnt = 1 and _tipo_contrato = 3 then --Es 100% facultativo, se excluye.
			continue Foreach;
		end if
		
		let _prima_fac = 0;

		select sum(c.prima)
		  into _prima_fac
		  from emifacon c, reacomae r
		 where c.no_poliza = _no_poliza
		   and r.cod_contrato = c.cod_contrato
		   and r.tipo_contrato = 3;

		if _prima_fac is null then
			let _prima_fac = 0.00;
		end if

		let _prima_suscrita = _prima_suscrita - _prima_fac;
			
		--Se Excluye poliza cancelada o rehabilitada,
		select count(*)
		  into _cnt
		  from endedmae
		 where no_poliza     = _no_poliza
		   and actualizado   = 1
		   and cod_endomov in ('003','002')  	
		   and fecha_emision >= '01/01/2025'
		   and fecha_emision <= '31/12/2025';
		   
		if _cnt > 0 then
			continue foreach;
		end if
		
		if _prima_suscrita is null then
			let _prima_suscrita = 0.00;
		end if	
		let _prima_suscrita = _prima_suscrita * (_porc_partic / 100);
			
		if _cod_grupo in('00000','1000') then --Grupo del estado no aplica
			continue foreach;
		end if
		
		--Zona de ventas
		select cod_vendedor
		  into _cod_vendedor
		  from agtagent
		 where cod_agente = _cod_agente;
		 
		let _pri_sus_fal = 0;
		let _pri_sus_fal = _meta_minima - _prima_suscrita;
		
		{if _cod_agente in('02825','02531','02830','02831') then
			continue foreach;
		end if}
		
		INSERT INTO bono_ccpl(
			cod_agente,
			cod_vendedor,
			prima_suscrita,
			periodo,
			prima_sus_fal,
			no_documento,
			prima_cobrada,
			no_poliza,
			cod_agente_uni,
			prima_cob_ap
			)
			VALUES(
			_cod_agente,
			_cod_vendedor,
			_prima_suscrita,
			_periodo,
			_pri_sus_fal,
			_no_documento,
			0,
			_no_poliza,
			_cod_agente,
			0
			);
	end foreach
end foreach
--***********Recorrer los corredores en busca de la prima cobrada de las polizas nuevas.
foreach
	select no_poliza,
	       cod_agente
	  into _no_poliza,
           _cod_agente	  
	  from bono_ccpl
	 where periodo = _periodo 
	 order by cod_agente

	foreach
			select d.no_poliza,
				   d.renglon,
				   d.no_recibo,
				   d.monto,
				   d.prima_neta,
				   c.porc_partic_agt
			  into _no_poliza,
				   _renglon,
				   _no_recibo,
				   _monto,
				   _prima,
				   _porc_partic
			  from cobredet d, cobremae m, cobreagt c
			 where	d.no_remesa    = m.no_remesa
			   and d.no_remesa    = c.no_remesa
			   and d.renglon      = c.renglon
			   and d.cod_compania = '001'
			   and d.actualizado  = 1
			   and d.tipo_mov     in ('P','N')
			   and d.fecha        >= '01/01/2025'
			   and d.fecha        <= '31/12/2025'
			   and d.no_poliza     = _no_poliza
			   and m.tipo_remesa  in ('A', 'M', 'C')
			   and c.cod_agente   = _cod_agente
			 order by d.fecha,d.no_recibo,d.no_poliza
			 
			select cod_tipoprod
		      into _cod_tipoprod
			  from emipomae
             where no_poliza = _no_poliza;

			if _cod_tipoprod = "001" then	-- Coaseguro Mayoritario, nuestra participacion.

				select porc_partic_coas
				  into _porc_coaseguro
				  from emicoama
				 where no_poliza    = _no_poliza
				   and cod_coasegur = _cod_coasegur;

				if _porc_coaseguro is null then
					let _porc_coaseguro = 0.00;		          
				end if
				
				let _prima = _prima * (_porc_coaseguro / 100);
			end if
			
			let _prima = _prima * (_porc_partic / 100);
			 
			update bono_ccpl
               set prima_cobrada = prima_cobrada + _prima
             where cod_agente = _cod_agente
			   and periodo    = _periodo
               and no_poliza  = _no_poliza;			 

	end foreach
end foreach
--*********** prima cobrada año pasado de polizas nuevas .
foreach
	select cod_agente
	  into _cod_agente	  
      from prisusapccp
     where cod_ramo not in('019')
     group by cod_agente
    having sum(prima_suscrita) < 25000
	
	foreach
		select e.no_documento,e.no_poliza
		  into _no_documento, _no_poliza
		  from emipomae e, emipoagt t
		 where e.no_poliza         = t.no_poliza
		   and e.cod_compania      = '001'
		   and e.actualizado       = 1
		   and e.nueva_renov       = "N"
		   and e.cod_ramo not in('008','019')	--excluye fianzas y vida individual
		   and e.vigencia_inic between  "01/03/2024" and "31/12/2024"
		   and t.cod_agente        = _cod_agente
		 group by e.no_documento,e.no_poliza
		 order by e.no_documento

		foreach
				select d.renglon,
					   d.no_recibo,
					   d.monto,
					   d.prima_neta,
					   c.porc_partic_agt
				  into _renglon,
					   _no_recibo,
					   _monto,
					   _prima,
					   _porc_partic
				  from cobredet d, cobremae m, cobreagt c
				 where	d.no_remesa    = m.no_remesa
				   and d.no_remesa    = c.no_remesa
				   and d.renglon      = c.renglon
				   and d.cod_compania = '001'
				   and d.actualizado  = 1
				   and d.tipo_mov     in ('P','N')
				   and d.fecha        >= '01/01/2024'
				   and d.fecha        <= '31/12/2024'
				   and d.no_poliza     = _no_poliza
				   and m.tipo_remesa  in ('A', 'M', 'C')
				   and c.cod_agente   = _cod_agente
				 order by d.fecha,d.no_recibo,d.no_poliza
				 
				select cod_tipoprod
				  into _cod_tipoprod
				  from emipomae
				 where no_poliza = _no_poliza;

				if _cod_tipoprod = "001" then	-- Coaseguro Mayoritario, nuestra participacion.

					select porc_partic_coas
					  into _porc_coaseguro
					  from emicoama
					 where no_poliza    = _no_poliza
					   and cod_coasegur = _cod_coasegur;

					if _porc_coaseguro is null then
						let _porc_coaseguro = 0.00;		          
					end if
					
					let _prima = _prima * (_porc_coaseguro / 100);
				end if
				
				let _prima = _prima * (_porc_partic / 100);
				
				begin
				ON EXCEPTION IN(-239,-268)                     
				update bono_ccpl
				   set prima_cob_ap = prima_cob_ap + _prima
				 where cod_agente   = _cod_agente
				   and periodo      = _periodo
				   and no_documento = _no_documento;  --no_poliza  = _no_poliza;									  
				END EXCEPTION        		 
				
					INSERT INTO bono_ccpl(
						cod_agente,
						cod_vendedor,
						prima_suscrita,
						periodo,
						prima_sus_fal,
						no_documento,
						prima_cobrada,
						no_poliza,
						cod_agente_uni,
						prima_cob_ap
						)
						VALUES(
						_cod_agente,
						_cod_vendedor,
						0,
						_periodo,
						0,
						_no_documento,
						0,
						_no_poliza,
						_cod_agente,
						_prima
						);	
				end
		end foreach
	end foreach
end foreach
--unificaciones
foreach
	select cod_agente
	  into _cod_agente	  
	  from bono_ccpl
	 where periodo = _periodo 
	 group by cod_agente 
	 order by cod_agente
	 
	let _cod_agente_tmp = '';
	let _cod_agente_tmp = _cod_agente;

	--********  Unificacion de Agente *******
	call sp_che168(_cod_agente_tmp) returning _error,_cod_agente;	

	update bono_ccpl
	   set cod_agente     = _cod_agente,
		   cod_agente_uni = _cod_agente
     where cod_agente     = _cod_agente_tmp
	   and periodo        = _periodo;

end foreach
return 0;
END PROCEDURE;