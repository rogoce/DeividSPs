-- Reporte Totales Bono de Incentivo 1, Bonificacion sobre prima nueva cobrada
-- Creado    : 08/05/2021 - Autor: Armando Moreno M.
--

DROP PROCEDURE sp_bonoccp02;
CREATE PROCEDURE sp_bonoccp02(a_compania CHAR(3), a_ano integer,a_cod_agente CHAR(255) default "*") 
RETURNING CHAR(5),
		  CHAR(50),
		  CHAR(50),
		  decimal(16,2),
          decimal(16,2),   
          DECIMAL(16,2),
		  decimal(16,2),		  
		  decimal(16,2),dec(16,2);


	  
DEFINE _cod_agente       				CHAR(5);
define _cod_vendedor     				char(3);
define _tipo,_tipo_agente               char(1);
DEFINE _n_corredor,_n_vendedor  	 	CHAR(50);
DEFINE _prima_suscrita   				DECIMAL(16,2);
DEFINE _prima_cobrada    				DECIMAL(16,2);
DEFINE _meta_minima_ps       			DECIMAL(16,2);
DEFINE _porc_bono						DECIMAL(5,2);
DEFINE _prima_bono,_prima_sus_fal       DECIMAL(16,2);
define _periodo          				char(4);
DEFINE _prima_cob_ap         			DECIMAL(16,2);
define _no_documento                    char(20);

create temp table temp_bono(
cod_agente			char(7),
periodo				char(4),
prima_suscrita		dec(16,2),
prima_cobrada		dec(16,2),
cod_vendedor        char(3),
prima_cob_ap        dec(16,2),
prima_bono          dec(16,2)) with no log;

--let _ano_actual = year(current);
let _periodo = a_ano;
let _n_vendedor = "";
let _n_corredor = "";
let _prima_sus_fal = 0;
let _prima_cob_ap = 0;

--let _fecha1    = mdy(1, 1, _ano_actual);
--let _fecha2    = sp_sis36(_periodo_actual);

--Filtro por Corredor
if a_cod_agente <> "*" then
	let _tipo = sp_sis04(a_cod_agente); -- separa los valores del string
	if _tipo <> "E" then -- incluir los registros
		foreach
			select cod_agente_uni,
				   sum(prima_cobrada),
				   sum(prima_suscrita),
				   sum(prima_cob_ap)
			  into _cod_agente,
				   _prima_cobrada,
				   _prima_suscrita,
				   _prima_cob_ap
			  from bono_ccpl
			 where cod_agente_uni in(select codigo from tmp_codigos)
			   and periodo = _periodo
			 group by cod_agente_uni
			 
			select porc_bono
			  into _porc_bono
			  from ccprango
			 where periodo = _periodo
			   and _prima_suscrita between rangops1 and rangops2;
			
			if _porc_bono is null then
				let _porc_bono = 0;
			end if
			let _prima_bono = 0.00;

			foreach
				select prima_cobrada,
					   prima_suscrita,
					   cod_vendedor,
					   prima_cob_ap
				  into _prima_cobrada,
					   _prima_suscrita,
					   _cod_vendedor,
					   _prima_cob_ap
				  from bono_ccpl
				 where cod_agente_uni = _cod_agente
				   and periodo        = _periodo
				 
 				let _prima_bono = _prima_cobrada * _porc_bono /100;
				 
				insert into temp_bono(cod_agente,periodo,prima_suscrita,prima_cobrada,cod_vendedor,prima_cob_ap,prima_bono)
				values(_cod_agente,_periodo,_prima_suscrita,_prima_cobrada,_cod_vendedor,_prima_cob_ap,_prima_bono);
				 
			end foreach
		end foreach
	else
		foreach
			select cod_agente_uni,
				   sum(prima_cobrada),
				   sum(prima_suscrita),
				   sum(prima_cob_ap)
			  into _cod_agente,
				   _prima_cobrada,
				   _prima_suscrita,
				   _prima_cob_ap
			  from bono_ccpl
			 where cod_agente_uni not in(select codigo from tmp_codigos)
			   and periodo = _periodo
			 group by cod_agente_uni

			select porc_bono
			  into _porc_bono
			  from ccprango
			 where periodo = _periodo
			   and _prima_suscrita between rangops1 and rangops2;
			
			if _porc_bono is null then
				let _porc_bono = 0;
			end if
			let _prima_bono = 0.00;
				
			foreach
				select prima_cobrada,
					   prima_suscrita,
					   cod_vendedor,
					   prima_cob_ap
				  into _prima_cobrada,
					   _prima_suscrita,
					   _cod_vendedor,
					   _prima_cob_ap
				  from bono_ccpl
				 where cod_agente_uni = _cod_agente
				   and periodo        = _periodo
				 
				let _prima_bono = _prima_cobrada * _porc_bono /100;
				 
				insert into temp_bono(cod_agente,periodo,prima_suscrita,prima_cobrada,cod_vendedor,prima_cob_ap,prima_bono)
				values(_cod_agente,_periodo,_prima_suscrita,_prima_cobrada,_cod_vendedor,_prima_cob_ap,_prima_bono);
				 
			end foreach
		end foreach
	end if
	drop table tmp_codigos;
else
	foreach
		select cod_agente_uni,                        
			   sum(prima_cobrada),
			   sum(prima_suscrita),
			   sum(prima_cob_ap)
		  into _cod_agente,
			   _prima_cobrada,
			   _prima_suscrita,
			   _prima_cob_ap
		  from bono_ccpl
		 where cod_agente_uni matches a_cod_agente
		   and periodo = _periodo
		 group by cod_agente_uni

		select porc_bono
		  into _porc_bono
		  from ccprango
		 where periodo = _periodo
		   and _prima_suscrita between rangops1 and rangops2;
		
		if _porc_bono is null then
			let _porc_bono = 0;
		end if
		let _prima_bono = 0.00;
		foreach
			select prima_cobrada,
				   prima_suscrita,
				   cod_vendedor,
				   prima_cob_ap
			  into _prima_cobrada,
				   _prima_suscrita,
				   _cod_vendedor,
				   _prima_cob_ap
			  from bono_ccpl
			 where cod_agente_uni = _cod_agente
			   and periodo        = _periodo
			 
			let _prima_bono = _prima_cobrada * _porc_bono /100;
			 
			insert into temp_bono(cod_agente,periodo,prima_suscrita,prima_cobrada,cod_vendedor,prima_cob_ap,prima_bono)
			values(_cod_agente,_periodo,_prima_suscrita,_prima_cobrada,_cod_vendedor,_prima_cob_ap,_prima_bono);
			 
		end foreach
	end foreach
end if
let _meta_minima_ps = 2000;

foreach
	select cod_agente,
	       cod_vendedor,
		   sum(prima_cobrada),
		   sum(prima_suscrita),
		   sum(prima_cob_ap),
		   sum(prima_bono)
	  into _cod_agente,
	       _cod_vendedor,
		   _prima_cobrada,
		   _prima_suscrita,
		   _prima_cob_ap,
		   _prima_bono
	  from temp_bono
	 where periodo[1,4] = a_ano
	 group by cod_agente,cod_vendedor
	 order by cod_agente
	 
	if _prima_suscrita = 0 then
		continue foreach;
	end if		 
	
	select nombre,tipo_agente
	  into _n_corredor,_tipo_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	if _tipo_agente = 'A' then	--Solo para corredores
	else
		continue foreach;
	end if

	select nombre
	  into _n_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;

	let _prima_sus_fal  = 0;
	if  _prima_suscrita >= _meta_minima_ps then
		let _prima_sus_fal = 0;
	else
		let _prima_sus_fal = _meta_minima_ps - _prima_suscrita;
	end if
	let _porc_bono  = 0.00;
	 
	select porc_bono
	  into _porc_bono
	  from ccprango
	 where periodo = _periodo
	   and _prima_suscrita between rangops1 and rangops2;
	
	if _porc_bono is null then
		let _porc_bono = 0;
	end if
	
	if _cod_agente in ('00035','02154','02656','02904','02667',	'02883') then
		let _porc_bono = 0;
		let _prima_bono = 0.00;
	end if

	return _cod_agente,_n_corredor,_n_vendedor,_prima_suscrita,_prima_sus_fal,_prima_cobrada,_prima_bono,_porc_bono,_prima_cob_ap with resume;
	   
end foreach
drop table temp_bono;

END PROCEDURE;