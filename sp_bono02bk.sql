-- Reporte Totales Bono de Rentabilidad Ramos Generales
-- Creado    : 13/10/2015 - Autor: Armando Moreno
--

DROP PROCEDURE sp_bono02;
CREATE PROCEDURE "informix".sp_bono02(a_compania CHAR(3), a_ano integer,a_cod_agente CHAR(5) default "*") 
RETURNING CHAR(5),         
		  CHAR(50),        
		  decimal(16,2),
          decimal(16,2),   
          DECIMAL(16,2),   
		  decimal(16,2),
		  DATE,
		  DATE;
		  
DEFINE _cod_agente       CHAR(5);
DEFINE _n_corredor  	 CHAR(50);
DEFINE _prima_suscrita   DECIMAL(16,2);
DEFINE _prima_cobrada    DECIMAL(16,2);
DEFINE _porc_bono        DECIMAL(16,2);
DEFINE _prima_bono       DECIMAL(16,2);
DEFINE _return           smallint;
DEFINE _fecha1           date;
DEFINE _fecha2           date;
DEFINE _ano_actual       integer;
define _fecha_actual     date;
define _periodo_actual   char(7);

create temp table temp_bono(
cod_agente			char(7),
periodo				char(7),
prima_suscrita		dec(16,2),
prima_cobrada		dec(16,2),
comision            dec(16,2),
porc_bono           dec(16,2)) with no log;

let _ano_actual     = a_ano;
let _periodo_actual = _ano_actual || '-12';

if a_ano = 2021 then
	let _fecha1    = mdy(1, 1, _ano_actual);
	let _fecha2    = sp_sis36(_periodo_actual);

	foreach
		select cod_agente_uni,                        
			   sum(prima_cobrada),
			   sum(prima_suscrita)
		  into _cod_agente,
			   _prima_cobrada,
			   _prima_suscrita
		  from bono_prod_d
		 where periodo[1,4] = a_ano
		   and cod_agente_uni matches a_cod_agente
		 group by cod_agente_uni

		 let _prima_bono = 0.00;
		 let _porc_bono  = 0.00;
		 if _prima_suscrita >= 25000 And _prima_suscrita <= 50000 then
			let _porc_bono = 1;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 elif _prima_suscrita > 50000 And _prima_suscrita <= 100000 then
			let _porc_bono = 2.5;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 elif _prima_suscrita > 100000 then
			let _porc_bono = 5;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 end if
		 
		foreach
			select prima_cobrada,
				   prima_suscrita
			  into _prima_cobrada,
				   _prima_suscrita
			  from bono_prod_d
			 where cod_agente_uni = _cod_agente
			 
			insert into temp_bono(cod_agente,periodo,prima_suscrita,prima_cobrada,comision,porc_bono)
			values(_cod_agente,_periodo_actual,_prima_suscrita,_prima_cobrada,_prima_cobrada * _porc_bono /100,_porc_bono);
			 
		end foreach
    end foreach		
	foreach

		select cod_agente,                        
			   sum(prima_cobrada),
			   sum(prima_suscrita),
			   sum(comision)
		  into _cod_agente,
			   _prima_cobrada,
			   _prima_suscrita,
			   _prima_bono
		  from temp_bono
		 where periodo[1,4] = a_ano
		 group by cod_agente
		
		foreach
			select porc_bono
 			  into _porc_bono
			  from temp_bono
			where cod_agente = _cod_agente

			exit foreach;
		end foreach
		 
		select nombre
		  into _n_corredor
		  from agtagent
		 where cod_agente = _cod_agente; 

		return _cod_agente,_n_corredor,_prima_suscrita,_prima_cobrada,_prima_bono,_porc_bono,_fecha1,_fecha2 with resume;
		   
	end foreach
	drop table temp_bono;

elif a_ano = 2020 then
	let _fecha1    = mdy(1, 1, _ano_actual);
	let _fecha2    = sp_sis36(_periodo_actual);

	foreach
		select cod_agente_uni,                        
			   sum(prima_cobrada),
			   sum(prima_suscrita)
		  into _cod_agente,
			   _prima_cobrada,
			   _prima_suscrita
		  from bono_prod_d_copy
		 where periodo[1,4] = a_ano
		   and cod_agente_uni matches a_cod_agente
		 group by cod_agente_uni

		 let _prima_bono = 0.00;
		 let _porc_bono  = 0.00;
		 if _prima_suscrita >= 25000 And _prima_suscrita <= 50000 then
			let _porc_bono = 1;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 elif _prima_suscrita > 50000 And _prima_suscrita <= 100000 then
			let _porc_bono = 2.5;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 elif _prima_suscrita > 100000 then
			let _porc_bono = 5;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 end if
		 
		foreach
			select prima_cobrada,
				   prima_suscrita
			  into _prima_cobrada,
				   _prima_suscrita
			  from bono_prod_d_copy
			 where cod_agente_uni = _cod_agente
			   and periodo[1,4] = a_ano
			 
			insert into temp_bono(cod_agente,periodo,prima_suscrita,prima_cobrada,comision,porc_bono)
			values(_cod_agente,_periodo_actual,_prima_suscrita,_prima_cobrada,_prima_cobrada * _porc_bono /100,_porc_bono);
			 
		end foreach
    end foreach		
	foreach

		select cod_agente,                        
			   sum(prima_cobrada),
			   sum(prima_suscrita),
			   sum(comision)
		  into _cod_agente,
			   _prima_cobrada,
			   _prima_suscrita,
			   _prima_bono
		  from temp_bono
		 where periodo[1,4] = a_ano
		 group by cod_agente
		
		foreach
			select porc_bono
 			  into _porc_bono
			  from temp_bono
			where cod_agente = _cod_agente

			exit foreach;
		end foreach
		 
		select nombre
		  into _n_corredor
		  from agtagent
		 where cod_agente = _cod_agente; 

		return _cod_agente,_n_corredor,_prima_suscrita,_prima_cobrada,_prima_bono,_porc_bono,_fecha1,_fecha2 with resume;
		   
	end foreach
	
elif a_ano = 2019 then
	let _fecha1    = mdy(1, 1, _ano_actual);
	let _fecha2    = sp_sis36(_periodo_actual);
	foreach
		select cod_agente_uni,                        
			   sum(prima_cobrada),
			   sum(prima_suscrita)
		  into _cod_agente,
			   _prima_cobrada,
			   _prima_suscrita
		  from bono_prod_d_copy
		 where periodo[1,4] = a_ano
		   and cod_agente_uni matches a_cod_agente
		 group by cod_agente_uni

		 let _prima_bono = 0.00;
		 let _porc_bono  = 0.00;
		 if _prima_suscrita >= 25000 And _prima_suscrita <= 50000 then
			let _porc_bono = 1;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 elif _prima_suscrita > 50000 And _prima_suscrita <= 100000 then
			let _porc_bono = 2.5;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 elif _prima_suscrita > 100000 then
			let _porc_bono = 5;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 end if
		 
		foreach
			select prima_cobrada,
				   prima_suscrita
			  into _prima_cobrada,
				   _prima_suscrita
			  from bono_prod_d_copy
			 where cod_agente_uni = _cod_agente
			   and periodo[1,4] = a_ano
			 
			insert into temp_bono(cod_agente,periodo,prima_suscrita,prima_cobrada,comision,porc_bono)
			values(_cod_agente,_periodo_actual,_prima_suscrita,_prima_cobrada,_prima_cobrada * _porc_bono /100,_porc_bono);
			 
		end foreach
    end foreach		
	foreach

		select cod_agente,                        
			   sum(prima_cobrada),
			   sum(prima_suscrita),
			   sum(comision)
		  into _cod_agente,
			   _prima_cobrada,
			   _prima_suscrita,
			   _prima_bono
		  from temp_bono
		 where periodo[1,4] = a_ano
		 group by cod_agente
		
		foreach
			select porc_bono
 			  into _porc_bono
			  from temp_bono
			where cod_agente = _cod_agente

			exit foreach;
		end foreach
		 
		select nombre
		  into _n_corredor
		  from agtagent
		 where cod_agente = _cod_agente; 

		return _cod_agente,_n_corredor,_prima_suscrita,_prima_cobrada,_prima_bono,_porc_bono,_fecha1,_fecha2 with resume;
		   
	end foreach
	drop table temp_bono;
elif a_ano = 2018 then
	let _periodo_actual = a_ano || '-12';
	let _fecha1         = mdy(1, 1, a_ano);
	let _fecha2         = sp_sis36(_periodo_actual);
	foreach
		select cod_agente_uni,                        
			   sum(prima_cobrada),
			   sum(prima_suscrita)
		  into _cod_agente,
			   _prima_cobrada,
			   _prima_suscrita
		  from bono_prod_d_copy
		 where periodo[1,4] = a_ano
		   and cod_agente_uni matches a_cod_agente
		 group by cod_agente_uni
		 let _prima_bono = 0.00;
		 let _porc_bono  = 0.00;
		 if _prima_suscrita >= 25000 And _prima_suscrita <= 50000 then
			let _porc_bono = 1;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 elif _prima_suscrita > 50000 And _prima_suscrita <= 100000 then
			let _porc_bono = 2.5;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 elif _prima_suscrita > 100000 then
			let _porc_bono = 5;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 end if
		 
		select nombre
		  into _n_corredor
		  from agtagent
		 where cod_agente = _cod_agente; 

		return _cod_agente,_n_corredor,_prima_suscrita,_prima_cobrada,_prima_bono,_porc_bono,_fecha1,_fecha2 with resume;
		   
	end foreach
elif a_ano <= 2017 then
	let _periodo_actual = a_ano || '-12';
	let _fecha1    = mdy(1, 1, a_ano);
	let _fecha2    = sp_sis36(_periodo_actual);
	foreach
		select cod_agente_uni,                        
			   sum(prima_cobrada),
			   sum(prima_suscrita)
		  into _cod_agente,
			   _prima_cobrada,
			   _prima_suscrita
		  from bono_prod_d_copy
		 where periodo[1,4] = a_ano
		   and cod_agente_uni matches a_cod_agente
		 group by cod_agente_uni

		 let _prima_bono = 0.00;
		 let _porc_bono  = 0.00;
		 if _prima_suscrita >= 20000 And _prima_suscrita <= 50000 then
			let _porc_bono = 1;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 elif _prima_suscrita >= 50000 And _prima_suscrita <= 100000 then
			let _porc_bono = 2.5;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 elif _prima_suscrita > 100000 then
			let _porc_bono = 5;
			let _prima_bono = _prima_cobrada * _porc_bono /100;
		 end if
		 
		select nombre
		  into _n_corredor
		  from agtagent
		 where cod_agente = _cod_agente; 

		return _cod_agente,_n_corredor,_prima_suscrita,_prima_cobrada,_prima_bono,_porc_bono,_fecha1,_fecha2 with resume;
		   
	end foreach
end if	
END PROCEDURE;