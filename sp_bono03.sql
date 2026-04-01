-- Reporte detalle de polizas Bono de Rentabilidad Ramos Generales
-- Creado    : 13/10/2015 - Autor: Armando Moreno
--

DROP PROCEDURE sp_bono03;
CREATE PROCEDURE sp_bono03(a_compania CHAR(3),a_ano integer,a_cod_agente CHAR(5) default "*") 
RETURNING CHAR(5),         
		  CHAR(50),        
		  decimal(16,2),
          decimal(16,2),   
          char(20),
		  char(50),
		  DATE,
		  DATE;
		  
DEFINE _cod_agente       CHAR(5);
DEFINE _n_corredor  	 CHAR(50);
DEFINE _prima_suscrita   DECIMAL(16,2);
DEFINE _prima_cobrada    DECIMAL(16,2);
DEFINE _no_documento     char(20);
define _n_ramo           char(50);
define _no_poliza        char(10);
define _cod_ramo         char(3);
DEFINE _fecha1           date;
DEFINE _fecha2           date;
DEFINE _ano_actual       integer;
define _fecha_actual     date;
define _periodo_actual   char(7); 

let _ano_actual = year(current);
let _periodo_actual = _ano_actual || '-12';

let _ano_actual = a_ano;
if a_ano = 2025 then
	let _fecha1    = mdy(1, 1, _ano_actual);
	let _fecha2    = sp_sis36(_periodo_actual);

	foreach

		select cod_agente_uni,
			   sum(prima_suscrita) as prima_suscrita
		  into _cod_agente,
			   _prima_suscrita	  
		  from bono_prod_d
		 where periodo[1,4] = a_ano
		   and cod_agente_uni matches a_cod_agente
		 group by cod_agente_uni
		 order by prima_suscrita desc

		foreach
			select sum(prima_cobrada),
				   sum(prima_suscrita),
				   no_documento
			  into _prima_cobrada,
				   _prima_suscrita,
				   _no_documento
			  from bono_prod_d
			 where cod_agente_uni = _cod_agente
			 group by no_documento

			select nombre
			  into _n_corredor
			  from agtagent
			 where cod_agente = _cod_agente;
			 
			let _no_poliza = sp_sis21(_no_documento);
			
			select cod_ramo
			  into _cod_ramo
			  from emipomae
			 where no_poliza = _no_poliza;

			select nombre
			  into _n_ramo
			  from prdramo
			 where cod_ramo = _cod_ramo;

			return _cod_agente,_n_corredor,_prima_suscrita,_prima_cobrada,_no_documento,_n_ramo,_fecha1,_fecha2 with resume;
			   
		end foreach
	end foreach
else
	let _periodo_actual = a_ano || '-12';
	let _fecha1    = mdy(1, 1, a_ano);
	let _fecha2    = sp_sis36(_periodo_actual);
	foreach
			select cod_agente_uni,
				   sum(prima_suscrita) as prima_suscrita
			  into _cod_agente,
				   _prima_suscrita	  
			  from bono_prod_d_copy
			 where periodo[1,4] = a_ano
			   and cod_agente_uni matches a_cod_agente
			 group by cod_agente_uni
			 order by prima_suscrita desc

			foreach
				select sum(prima_cobrada),
					   sum(prima_suscrita),
					   no_documento
				  into _prima_cobrada,
					   _prima_suscrita,
					   _no_documento
				  from bono_prod_d_copy
				 where cod_agente_uni = _cod_agente
				   and periodo[1,4] = a_ano
				 group by no_documento

				select nombre
				  into _n_corredor
				  from agtagent
				 where cod_agente = _cod_agente;
				 
				let _no_poliza = sp_sis21(_no_documento);
				
				select cod_ramo
				  into _cod_ramo
				  from emipomae
				 where no_poliza = _no_poliza;

				select nombre
				  into _n_ramo
				  from prdramo
				 where cod_ramo = _cod_ramo;

				return _cod_agente,_n_corredor,_prima_suscrita,_prima_cobrada,_no_documento,_n_ramo,_fecha1,_fecha2 with resume;
				   
			end foreach
	end foreach
end if		
END PROCEDURE;