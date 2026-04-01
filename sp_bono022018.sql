-- Reporte Totales Bono de Rentabilidad Ramos Generales
-- Creado    : 13/10/2015 - Autor: Armando Moreno
--

--DROP PROCEDURE sp_bono022018;
CREATE PROCEDURE "informix".sp_bono022018(a_compania CHAR(3), a_ano integer,a_cod_agente CHAR(5) default "*") 
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

let _ano_actual = year(current);
let _periodo_actual = _ano_actual || '-12';

if a_ano = _ano_actual then
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