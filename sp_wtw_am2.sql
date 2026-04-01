--procedimiento para buscar info para corredor WTW
--29/07/2025

DROP procedure sp_wtw_am2;
CREATE procedure sp_wtw_am2()
RETURNING char(50)      as corredor,
          char(20)      as poliza,
          char(50)      as asegurado,
		  char(10)      as recibo,
		  date          as fecha_pago,
		  decimal(16,2) as monto,
		  decimal(16,2) as prima_neta,
		  decimal(5,2)  as porc_partic,
		  decimal(5,2)  as porc_comision,
		  decimal(16,2) as comis_pagado_ancon,
		  decimal(16,2) as porc_comis_desc,
		  decimal(16,2) as monto_desc;
		  
DEFINE _no_recibo,_no_poliza,_no_remesa,_cod_contratante 	CHAR(10);
DEFINE _no_documento        			    CHAR(20);
define _prima_neta,_monto					dec(16,2);
define _monto_descontado,_monto_calc          dec(16,2);
define _cliente,_error_desc                 char(100);
define _vig_inic_p,_vig_fin_p,_fecha_pago,_vig_ini   date;
define _renglon                             smallint;
define _por_comis,_porc_partic              dec(5,2);
define _error,_error_isam integer;
define _n_asegurado,_n_corredor       char(50);
define _cod_agente     char(5);
define _porc_partic_agt,_porc_comis_agt,_porc_comis_desc_agt  dec(5,2);

begin

let _monto_calc = 0.00;

foreach
			select d.no_recibo,
			       d.fecha,
				   d.renglon,
				   d.prima_neta,
				   d.monto_descontado,
				   d.no_remesa,
				   d.doc_remesa,
				   d.no_poliza,
				   d.monto,
				   c.porc_comis_agt,
				   c.porc_partic_agt,
				   c.monto_calc,			--comision pagado ancon
				   c.cod_agente
			  into _no_recibo,
                   _fecha_pago,
                   _renglon,
                   _prima_neta,
				   _monto_descontado,
				   _no_remesa,
				   _no_documento,
				   _no_poliza,
				   _monto,
				   _porc_comis_agt,
				   _porc_partic_agt,
				   _monto_calc,
				   _cod_agente
			  from cobredet d, cobreagt c
             where d.no_remesa = c.no_remesa
			   and d.renglon = c.renglon
               and d.actualizado = 1
               and d.tipo_mov in('P','N')
			   and c.cod_agente = '00035'  --'02656'
			   and year(d.fecha) >=  2021
   			   and year(d.fecha) <=  2025
			
		    let _porc_comis_desc_agt = 0;
			if _monto_descontado <> 0 and _prima_neta <> 0 then
				let _porc_comis_desc_agt = _monto_descontado / _prima_neta * 100;
			end if
			
			select cod_contratante
			  into _cod_contratante
			  from emipomae
			 where no_poliza = _no_poliza;
			
			select nombre
			  into _n_asegurado
			  from cliclien
			 where cod_cliente = _cod_contratante; 
			 
			select nombre
			  into _n_corredor
			  from agtagent
			 where cod_agente = _cod_agente;
			
		return _n_corredor,_no_documento,_n_asegurado,_no_recibo,_fecha_pago,_monto,_prima_neta,_porc_partic_agt,_porc_comis_agt,_monto_calc,_porc_comis_desc_agt,_monto_descontado with resume;
		
end foreach
end
END PROCEDURE;
