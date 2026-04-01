--****************************************************************************************************
-- Procedimiento para determinar CONCURSO TRIMESTRAL PROYECTO CCP  INCENTIVO 2
--****************************************************************************************************

-- Creado    : 08/05/2021 - Autor: Armando Moreno M.

DROP PROCEDURE sp_boccpin201;
CREATE PROCEDURE sp_boccpin201(a_ano smallint, a_trimestre smallint)
RETURNING smallint,char(5),varchar(50),char(3),varchar(50),dec(16,2),integer,dec(16,2),smallint,smallint;

DEFINE _cod_agente      CHAR(5);
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
define _cnt             integer;
define _cnt_pol         integer;
define _ranking        smallint;
define _pagada          smallint;
define _no_documento    char(20);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _n_corredor,_n_zona varchar(50);
define _prima_fac       DEC(16,2);
define _clasificado,_falg     smallint ;
define _fecha_ini		date;
define _fecha_fin		date;
define _no_requis		char(10);
define _porc_coaseguro    decimal(7,4);
define _cod_coasegur      char(3);
define _prima             decimal(16,2);
define _categoria,_tipo_contrato  smallint;

let _error           = 0;
let _pagada          = 0;
let _prima_fac	     = 0;
let _prima_suscrita  = 0;
let _prima_sus_ant   = 0;
let _cnt_pol         = 0;
let _prima           = 0;

SET ISOLATION TO DIRTY READ;

--******************************************************
drop table if exists tmp_bono_inc2;
create temp table tmp_bono_inc2(
categoria           smallint,
cod_agente          char(5),
cod_vendedor		char(3),
pri_cob_nueva_aa	dec(16,2) 	default 0,
pri_sus_ap			dec(16,2) 	default 0,
no_pol_nue_aa		integer		default 0,
no_poliza           char(10)) with no log;

CREATE INDEX i1tmp_bono_inc2 ON tmp_bono_inc2(categoria);
CREATE INDEX i2tmp_bono_inc2 ON tmp_bono_inc2(cod_agente);
--******************************************************
delete from bonoccpinc2;

let _cod_coasegur = '036';	--ASEGURADORA ANCON, S.A.

--SET DEBUG FILE TO "sp_bonoccp01.trc";
--TRACE ON;

if a_trimestre = 1 then
	Let _fecha_ini = '01/01/2021';
	Let _fecha_fin = '31/03/2021';
elif a_trimestre = 2 then
	Let _fecha_ini = '01/04/2021';
	Let _fecha_fin = '30/06/2021';
elif a_trimestre = 3 then
	Let _fecha_ini = '01/07/2021';
	Let _fecha_fin = '30/09/2021';
else
	Let _fecha_ini = '01/10/2021';
	Let _fecha_fin = '31/12/2021';
end if

--********************Recorre corredores con PS anterior  menor a 25,000.
foreach
	select sum(prima_suscrita),
	       cod_agente
	  into _prima_sus_ant,
           _cod_agente	  
      from prisusapccp
     group by cod_agente
	 having sum(prima_suscrita) < 25000
	
	--***Categorizar al corredor.
	if _prima_sus_ant > 10000 and _prima_sus_ant < 25000 then
		let _categoria = 1;
	elif _prima_sus_ant <= 10000 then
		let _categoria = 2;
	end if
	foreach
		select e.no_documento,e.no_poliza
		  into _no_documento,_no_poliza
		  from emipomae e, emipoagt t
		 where e.no_poliza         = t.no_poliza
		   and e.cod_compania      = '001'
		   and e.actualizado       = 1
		   and e.nueva_renov       = "N"
		   and e.cod_ramo not in('008')	--excluye fianzas
		   and e.vigencia_inic between  _fecha_ini and _fecha_fin
		   and t.cod_agente        = _cod_agente
		 group by e.no_documento,e.no_poliza
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
		   {and fecha_emision >= _fecha_ini
		   and fecha_emision <= _fecha_fin;}
		   
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
			select pagada
			  into _pagada
			  from emiletra
			 where no_poliza = _no_poliza
			   and no_letra = 1;
			if _pagada = 0 then
				continue foreach;
			end if	
		end if
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
			let _prima = _prima * (_porc_partic / 100);
		end foreach
		--********  Unificacion de Agente *******
		call sp_che168(_cod_agente) returning _error,_cod_agente;	
		
		INSERT INTO tmp_bono_inc2(
		    categoria,
			cod_agente,
			cod_vendedor,
			pri_cob_nueva_aa,
			pri_sus_ap,
			no_poliza,
			no_pol_nue_aa
			)
			VALUES(
			_categoria,
			_cod_agente,
			_cod_vendedor,
			_prima,
			_prima_sus_ant,
			_no_poliza,
			1
			);
	end foreach
end foreach

let _prima_sus_ant = 0;
let _ranking       = 0;
let _falg          = 0;
let _prima         = 0;
foreach
	select cod_agente,
		   categoria,
	       sum(pri_cob_nueva_aa),
		   sum(no_pol_nue_aa)
	  into _cod_agente,
	       _categoria,
           _prima,
		   _cnt_pol
	  from tmp_bono_inc2
	 group by cod_agente,categoria
	 order by categoria,sum(pri_cob_nueva_aa) desc
	 
	foreach
		select pri_sus_ap,cod_vendedor
		  into _prima_sus_ant,_cod_vendedor
		  from tmp_bono_inc2
		 where cod_agente = _cod_agente
		
		exit foreach;
	end foreach
	--*******Inicializar ranking cuando cambia la categoria.
    if _categoria = 2 And _falg = 0 then
		let _ranking = 0;
		let _falg    = 1;
    end if
	
	let _ranking     = _ranking + 1;
	let _clasificado = 0;
	
	if _prima >= 1500 and _cnt_pol >= 15 then	--***Prima Cobrada Minima 1500 y debe tener al menos 15 polizas.
		let _clasificado = 1;
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
			trimestre
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
			a_trimestre
			);
end foreach
drop table if exists tmp_bono_inc2;

--Salida del Reporte
foreach
	select categoria,
		   cod_agente,
	       cod_vendedor,
	       prima_sus_ap,
		   cnt_pol,
		   prima_cobrada,
		   ranking,
		   clasificado
	  into _categoria,
	       _cod_agente,
		   _cod_vendedor,
		   _prima_sus_ant,
		   _cnt_pol,
		   _prima,
		   _ranking,
		   _clasificado
	  from bonoccpinc2
	 order by categoria,prima_cobrada desc
	 
	select nombre into _n_corredor from agtagent
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
		   _clasificado with resume;
	
end foreach
END PROCEDURE;