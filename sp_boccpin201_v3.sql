--****************************************************************************************************
-- Procedimiento para determinar CONCURSO TRIMESTRAL PROYECTO CCP  INCENTIVO 2
--****************************************************************************************************

-- Creado    : 01/04/2025 - Autor: Armando Moreno M.

--DROP PROCEDURE sp_boccpin201_v3;
CREATE PROCEDURE sp_boccpin201_v3(a_ano smallint, a_trimestre smallint)
RETURNING smallint,char(5),varchar(50),char(3),varchar(50),dec(16,2),integer,dec(16,2),smallint,smallint,dec(16,2);

DEFINE _cod_agente,_cod_agente_uni      CHAR(5);
DEFINE _cod_agente_u    CHAR(5);
DEFINE _no_poliza       CHAR(10);
define _cod_vendedor    char(3); 
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _cod_ramo        CHAR(3);  
define _prima_sus_ant	DEC(16,2);
define _cod_grupo       char(5);
define _renglon         smallint;
define _no_recibo       char(10);
define _cnt,_cnt2       integer;
define _cnt_pol         integer;
define _ranking        smallint;
define _pagada          smallint;
define _no_documento    char(20);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _n_corredor,_n_zona varchar(50);
define _prima_fac       DEC(16,2);
define _clasificado,_flag     smallint ;
define _fecha_ini		date;
define _fecha_fin		date;
define _no_requis		char(10);
define _porc_coaseguro    decimal(7,4);
define _cod_coasegur      char(3);
define _prima             decimal(16,2);
define _monto_letra         decimal(16,2);
define _monto_pen         decimal(16,2);
define _prima_cob,_prima_sus_nva         decimal(16,2);
define _categoria,_tipo_contrato  smallint;

let _error           = 0;
let _pagada          = 0;
let _prima_fac	     = 0;
let _prima_suscrita  = 0;
let _prima_sus_ant   = 0;
let _cnt_pol         = 0;
let _prima           = 0;
let _prima_sus_nva   = 0;

SET ISOLATION TO DIRTY READ;

--PONER EN COMENTARIO CUANDO SE IMPLEMENTE, HAY QUE CARGAR LA TABLA DE PRIMAS AÑO PASADO.
--if a_ano <> 2021 then
	--return 0,'','REPORTE NO HABILITADO.','','',0,0,0,0,0,0;
--end if
--******************************************************
drop table if exists tmp_bono_inc2;
create temp table tmp_bono_inc2(
categoria           smallint,
cod_agente          char(5),
cod_vendedor		char(3),
pri_cob_nueva_aa	dec(16,2) 	default 0,
pri_sus_ap			dec(16,2) 	default 0,
no_pol_nue_aa		integer		default 0,
prima_sus_nva       dec(16,2) 	default 0,
no_poliza           char(10)) with no log;

CREATE INDEX i1tmp_bono_inc2 ON tmp_bono_inc2(categoria);
CREATE INDEX i2tmp_bono_inc2 ON tmp_bono_inc2(cod_agente);
--******************************************************
delete from bonoccpinc2;

let _cod_coasegur = '036';	--ASEGURADORA ANCON, S.A.

--SET DEBUG FILE TO "sp_bonoccp01.trc";
--TRACE ON;

if a_trimestre = 1 then
	Let _fecha_ini = '01/01/2025';
	Let _fecha_fin = '31/03/2025';
elif a_trimestre = 2 then
	Let _fecha_ini = '01/04/2025';
	Let _fecha_fin = '30/06/2025';
elif a_trimestre = 3 then
	Let _fecha_ini = '01/07/2025';
	Let _fecha_fin = '30/09/2025';
else
	Let _fecha_ini = '01/10/2025';
	Let _fecha_fin = '31/12/2025';
end if

--********************Recorre corredores con PS anterior  <= a 100,000.
foreach
	select sum(prima_suscrita),
	       cod_agente
	  into _prima_sus_ant,
           _cod_agente	  
      from prisusapccp
     group by cod_agente
	 having sum(prima_suscrita) <= 100000
	
	--***Categorizar al corredor.
	if _prima_sus_ant > 50000 and _prima_sus_ant <= 100000 then
		let _categoria = 1;
	elif _prima_sus_ant > 20000 and _prima_sus_ant <= 50000 then
		let _categoria = 2;
	else
		let _categoria = 3;
	end if
	--se excluye caso 11579
	if _cod_agente in ('02442') then
		continue foreach;
	end if
	if _cod_agente in ('02642','02731','02732','02762') then
		let _categoria = 1;
	end if
	
	if _cod_agente = '02757' then
			foreach
				select e.no_documento,
					   e.no_poliza,
					   t.cod_agente,
					   t.porc_partic_agt * e.prima_suscrita /100
				  into _no_documento,
					   _no_poliza,
					   _cod_agente,
					   _prima_sus_nva
				  from emipomae e, emipoagt t
				 where e.no_poliza         = t.no_poliza
				   and e.cod_compania      = '001'
				   and e.actualizado       = 1
				   and e.nueva_renov       = "N"
				   and e.cod_ramo not in('008')	--excluye fianzas
				   and e.vigencia_inic between _fecha_ini and _fecha_fin
				   and t.cod_agente         in('02757','02863','02864','02867')
				 order by e.no_documento

				select cod_ramo,
					   cod_tipoprod,
					   cod_grupo
				  into _cod_ramo,
					   _cod_tipoprod,
					   _cod_grupo
				  from emipomae
				 where no_poliza = _no_poliza;
					   
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
				--Se Excluye poliza cancelada o rehabilitada
				select count(*)
				  into _cnt
				  from endedmae
				 where no_poliza     = _no_poliza
				   and actualizado   = 1
				   and cod_endomov in ('003','002')
				   and vigencia_inic between  _fecha_ini and _fecha_fin;
				   
				if _cnt > 0 then
					continue foreach;
				end if
				--Se Excluye Grupo de Estado.
				if _cod_grupo in('00000','1000') then --Grupo del estado no aplica
					continue foreach;
				end if
				
				--Se busca que la primera letra este pagada.
				let _pagada = 0;
				select pagada
				  into _pagada
				  from emiletra
				 where no_poliza = _no_poliza
				   and no_letra = 1;
				   
				if _pagada = 0 then        -- reconfimar que la primera letra este pagada.
					call sp_pro525f(_no_poliza) returning _error,_error_desc;
					select pagada,
						   monto_pen,
						   monto_letra
					  into _pagada,
						   _monto_pen,
						   _monto_letra
					  from emiletra
					 where no_poliza = _no_poliza
					   and no_letra = 1;

					if _pagada = 0 and _monto_pen > 1 and _monto_letra > 1 then
						continue foreach;
					end if	
				end if

				let _prima_cob = 0.00;
				--***SACAR LA PRIMA COBRADA DEL TRIMESTRE
				foreach
					select d.no_poliza,
						   d.renglon,
						   d.no_recibo,
						   d.prima_neta,
						   c.porc_partic_agt
					  into _no_poliza,
						   _renglon,
						   _no_recibo,
						   _prima,
						   _porc_partic
					  from cobredet d, cobremae m, cobreagt c
					 where	d.no_remesa    = m.no_remesa
					   and d.no_remesa    = c.no_remesa
					   and d.renglon      = c.renglon
					   and d.cod_compania = '001'
					   and d.actualizado  = 1
					   and d.tipo_mov     in ('P','N')
					   and d.fecha        >= _fecha_ini
					   and d.fecha        <= _fecha_fin
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
					let _prima_cob = _prima_cob + (_prima * (_porc_partic / 100));
				end foreach
			--********  Unificacion de Agente *******
			call sp_che168(_cod_agente) returning _error,_cod_agente_u;
			
			--Zona de ventas
			select cod_vendedor
			  into _cod_vendedor
			  from agtagent
			 where cod_agente = _cod_agente_u;
			
			INSERT INTO tmp_bono_inc2(
				categoria,
				cod_agente,
				cod_vendedor,
				pri_cob_nueva_aa,
				pri_sus_ap,
				no_poliza,
				no_pol_nue_aa,
				prima_sus_nva
				)
				VALUES(
				_categoria,
				_cod_agente_u,
				_cod_vendedor,
				_prima_cob,
				_prima_sus_ant,
				_no_poliza,
				1,
				_prima_sus_nva
				);
			end foreach
	else
	
		foreach
			select e.no_documento,e.no_poliza
			  into _no_documento,_no_poliza
			  from emipomae e, emipoagt t
			 where e.no_poliza         = t.no_poliza
			   and e.cod_compania      = '001'
			   and e.actualizado       = 1
			   and e.nueva_renov       = "N"
			   and e.cod_ramo not in('008')	--excluye fianzas
			   and e.vigencia_inic between _fecha_ini and _fecha_fin
			   and t.cod_agente        = _cod_agente
			 group by e.no_documento,e.no_poliza
			 order by e.no_documento

			select cod_ramo,
				   cod_tipoprod,
				   cod_grupo,
				   prima_suscrita
			  into _cod_ramo,
				   _cod_tipoprod,
				   _cod_grupo,
				   _prima_sus_nva
			  from emipomae
			 where no_poliza = _no_poliza;
				   
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
			--Se Excluye poliza cancelada o rehabilitada
			select count(*)
			  into _cnt
			  from endedmae
			 where no_poliza     = _no_poliza
			   and actualizado   = 1
			   and cod_endomov in ('003','002')
			   and vigencia_inic between  _fecha_ini and _fecha_fin;
			   
			if _cnt > 0 then
				continue foreach;
			end if
			--Se Excluye Grupo de Estado.
			if _cod_grupo in('00000','1000') then --Grupo del estado no aplica
				continue foreach;
			end if
			
			--Zona de ventas
			select cod_vendedor
			  into _cod_vendedor
			  from agtagent
			 where cod_agente = _cod_agente;
			 
			--Se busca que la primera letra este pagada.
			let _pagada = 0;
			select pagada
			  into _pagada
			  from emiletra
			 where no_poliza = _no_poliza
			   and no_letra = 1;
			   
			if _pagada = 0 then        -- reconfimar que la primera letra este pagada.
				call sp_pro525f(_no_poliza) returning _error,_error_desc;
				select pagada,
					   monto_pen,
					   monto_letra
				  into _pagada,
					   _monto_pen,
					   _monto_letra
				  from emiletra
				 where no_poliza = _no_poliza
				   and no_letra = 1;

				if _pagada = 0 and _monto_pen > 1 and _monto_letra > 1 then
					continue foreach;
				end if	
			end if

			let _prima_cob = 0.00;
			--***SACAR LA PRIMA COBRADA DEL TRIMESTRE
			foreach
				select d.no_poliza,
					   d.renglon,
					   d.no_recibo,
					   d.prima_neta,
					   c.porc_partic_agt
				  into _no_poliza,
					   _renglon,
					   _no_recibo,
					   _prima,
					   _porc_partic
				  from cobredet d, cobremae m, cobreagt c
				 where	d.no_remesa    = m.no_remesa
				   and d.no_remesa    = c.no_remesa
				   and d.renglon      = c.renglon
				   and d.cod_compania = '001'
				   and d.actualizado  = 1
				   and d.tipo_mov     in ('P','N')
				   and d.fecha        >= _fecha_ini
				   and d.fecha        <= _fecha_fin
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
				let _prima_cob = _prima_cob + (_prima * (_porc_partic / 100));
			end foreach
			--********  Unificacion de Agente *******
			call sp_che168(_cod_agente) returning _error,_cod_agente_u;
			
			INSERT INTO tmp_bono_inc2(
				categoria,
				cod_agente,
				cod_vendedor,
				pri_cob_nueva_aa,
				pri_sus_ap,
				no_poliza,
				no_pol_nue_aa,
				prima_sus_nva
				)
				VALUES(
				_categoria,
				_cod_agente_u,
				_cod_vendedor,
				_prima_cob,
				_prima_sus_ant,
				_no_poliza,
				1,
				_prima_sus_nva
				);
		end foreach
	end if
end foreach

let _prima_sus_ant = 0;
let _ranking       = 0;
let _flag          = 0;
let _prima         = 0;
foreach
	select cod_agente,
		   categoria,
	       sum(pri_cob_nueva_aa),
		   sum(prima_sus_nva),
		   sum(no_pol_nue_aa)
	  into _cod_agente,
	       _categoria,
           _prima,
		   _prima_sus_nva,
		   _cnt_pol
	  from tmp_bono_inc2
	 group by categoria,cod_agente
	 order by categoria,sum(pri_cob_nueva_aa) desc
	 
	foreach
		select pri_sus_ap,cod_vendedor
		  into _prima_sus_ant,_cod_vendedor
		  from tmp_bono_inc2
		 where cod_agente = _cod_agente
		   and categoria  = _categoria
		
		exit foreach;
	end foreach
	--*******Inicializar ranking cuando cambia la categoria.
    if _categoria = 2 And _flag = 0 then
		let _ranking = 0;
		let _flag    = 1;
    end if
	
    if _categoria = 3 and _flag = 1 then
		let _ranking = 0;
		let _flag = 0;
    end if	
	
	let _ranking     = _ranking + 1;
	let _clasificado = 0;
	
	if _categoria = 1 then
		if _prima >= 10000 and _prima_sus_nva >= 10000 then
			let _clasificado = 1;
		end if
	elif _categoria = 2 then
		if _prima >= 7500 and _prima_sus_nva >= 7500 then
			let _clasificado = 1;
		end if
	else
		if _prima >= 5000 and _prima_sus_nva >= 5000 then
			let _clasificado = 1;
		end if
	end if
	--se excluye 02442 caso 11579 19/09/24 9:45 am
	if _cod_agente in ('02442') then
		continue foreach;
	end if
	INSERT INTO bonoccpinc2(
		    categoria,
			cod_agente,
			cod_vendedor,
			prima_sus_ap,
			cnt_pol,
			prima_cobrada,
			ranking,
			clasificado,
			ano,
			trimestre,
			prima_sus_nva
			)
			VALUES(
			_categoria,
			_cod_agente,
			_cod_vendedor,
			_prima_sus_ant,
			_cnt_pol,
			_prima,
			_ranking,
			_clasificado,
			a_ano,
			a_trimestre,
			_prima_sus_nva
			);
end foreach
--drop table if exists tmp_bono_inc2;

--Salida del Reporte
foreach
	select categoria,
		   cod_agente,
	       cod_vendedor,
	       prima_sus_ap,
		   cnt_pol,
		   prima_cobrada,
		   ranking,
		   clasificado,
		   prima_sus_nva
	  into _categoria,
	       _cod_agente,
		   _cod_vendedor,
		   _prima_sus_ant,
		   _cnt_pol,
		   _prima,
		   _ranking,
		   _clasificado,
		   _prima_sus_nva
	  from bonoccpinc2
	 order by categoria,prima_cobrada desc
	 
	{if _cod_agente = '02825' then  --se excluye 02825 caso 3631
		continue foreach;
	end if}
	
	select nombre, 
	       cod_vendedor 
	  into _n_corredor,
           _cod_vendedor	  
	  from agtagent
    where cod_agente = _cod_agente;
	
	select nombre into _n_zona from agtvende
    where cod_vendedor = _cod_vendedor;
		
	
	return _categoria,
	       _cod_agente,
		   _n_corredor,
		   _cod_vendedor,
		   _n_zona,
		   _prima_sus_ant,
		   _cnt_pol,
		   _prima,
		   _ranking,
		   _clasificado,
           _prima_sus_nva with resume;
	
end foreach
END PROCEDURE;