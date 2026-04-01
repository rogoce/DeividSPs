-- agregar beneficiarios 
--
-- Creado    : 29/09/2000 - Autor: Lic. Armando Moreno 

DROP PROCEDURE sp_ammm02;
CREATE PROCEDURE sp_ammm02()
RETURNING dec(16,2) as saldo,
          dec(16,2) as prima_bruta,
		  char(1)   as condicion,
		  char(10)  as remesa,
		  integer   as renglon,
		  char(20)  as poliza,
		  char(10)  as no_poliza,
		  dec(16,2) as monto,
		  date      as fecha,
		  date      as fecha_suscripcion,
		  date      as vig_ini,
		  char(5)   as cod_corredor,
		  varchar(50) as nombre_corredor,
		  dec(5,2)    as porc_comis_pagada;
		  
define _no_documento	char(20);
define _no_cuenta       char(17);
define _nueva_renov,_tipo_agente,_tipo_mov,_tipo_remesa     char(1);
define _periodo         char(7);
define _no_remesa,_no_poliza,_no_pol_ult,_no_pol_ant char(10);
define _n_agente      varchar(50);
define  _cod_agente char(5);
define _cnt,_renglon integer;
define _porc_comis_agt		dec(5,2);
define _monto,v_por_vencer,v_exigible,v_corriente,v_monto_30,v_monto_45,v_monto_60,v_saldo,_prima_bruta dec(16,2);
define _fecha, _vig_ini,_fecha_suscripcion,_fecha_menos date;

let _porc_comis_agt = 0.00;
foreach
	select count(distinct c.no_poliza),
	       c.doc_remesa
      into _cnt,
	       _no_documento
	  from cobredet c, emipomae e
	 where c.no_poliza = e.no_poliza
	   and c.tipo_mov = 'P'
	   and c.doc_remesa[1,2]  = '19'
	   and c.periodo >= '2023-06'
	   and c.periodo <= '2024-06'
	   and c.actualizado = 1
	   and c.fecha < e.vigencia_final
	 group by c.doc_remesa

	let _no_pol_ult = sp_sis21(_no_documento);
	
    if _cnt > 1 then
		
		let _no_pol_ant = sp_sis21am(_no_documento);
		
		select nueva_renov
		  into _nueva_renov
		  from emipomae
		where no_poliza = _no_pol_ant;
		
		if _nueva_renov = 'N' then
		else
			continue foreach;
		end if	
		
		select vigencia_inic,
		       fecha_suscripcion
		  into _vig_ini,
		       _fecha_suscripcion
		  from emipomae
		where no_poliza = _no_pol_ult;
		
		foreach
			select no_remesa,
			       renglon,
				   monto,
				   fecha,
				   no_poliza,
				   periodo
			  into _no_remesa,
                   _renglon,
                   _monto,
				   _fecha,
				   _no_poliza,
				   _periodo
			  from cobredet
             where doc_remesa = _no_documento
		 	   and periodo >= '2023-06'
	           and periodo <= '2024-06'
	           and actualizado = 1
			   
			select tipo_remesa into _tipo_remesa from cobremae
			where no_remesa = _no_remesa;
			
			if _tipo_remesa = 'T' then
				continue foreach;
			end if
			   
			foreach
				select cod_agente,
				       porc_comis_agt
				  into _cod_agente,
                       _porc_comis_agt
				  from cobreagt
				 where no_remesa = _no_remesa
				   and renglon   = _renglon
				   
				exit foreach;	   
			end foreach

			select nombre,
			       tipo_agente
			  into _n_agente,
			       _tipo_agente
			  from agtagent
			 where cod_agente = _cod_agente;
			 
			if _tipo_agente = 'A' then
			else
				continue foreach;
			end if
			  
			let _fecha_menos = _fecha - 1 units day;
			call sp_cob33d('001','001',_no_documento,_periodo,_fecha_menos) returning v_por_vencer,v_exigible,v_corriente,v_monto_30,v_monto_45,v_monto_60,v_saldo;
			
			select sum(prima_bruta)
			  into _prima_bruta
			  from endedmae
			 where actualizado   = 1
               and no_poliza     = _no_pol_ult
			   and fecha_emision <= _fecha;
			   
			if _fecha >= _fecha_suscripcion and _fecha <= _vig_ini then
				return v_saldo,_prima_bruta,'1',_no_remesa,_renglon,_no_documento,_no_poliza,_monto,_fecha,_fecha_suscripcion,_vig_ini,_cod_agente,_n_agente,_porc_comis_agt with resume;
			end if
			
			if abs(v_saldo) > abs(_prima_bruta) and _fecha > _vig_ini then
				return v_saldo,_prima_bruta,'2',_no_remesa,_renglon,_no_documento,_no_poliza,_monto,_fecha,_fecha_suscripcion,_vig_ini,_cod_agente,_n_agente,_porc_comis_agt with resume;
			end if	
			 
		end foreach
	end if
end foreach
END PROCEDURE;
