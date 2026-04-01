
drop procedure sp_consumo;

create procedure "informix".sp_consumo() 
returning	char(50), --_nombre_cliente	
			char(20), --_no_documento	
			char(10), --_estatus_poliza	
			char(50), --_ramo			
			char(50), --_nom_formapag	
			char(20), --_zona_formapag		
			char(50), --_nom_agente		
			date,	  --_vigencia_ini			
			date,	  --_vigencia_final	
			dec(16,2),--_por_vencer	
			dec(16,2),--_exigible		
			dec(16,2),--_corriente		
			dec(16,2),--_monto_30		
			dec(16,2),--_monto_60		
			dec(16,2),--_monto_90	
			dec(16,2);--_saldo 		
		  	
define _cod_formapag	char(3);
define _cod_ramo		char(3);
define _cod_zona		char(3);
define _cod_pagador		char(10);
define _no_poliza		char(10);
define _cod_agente		char(5);
define _estatus			smallint;
define _nombre_cliente	char(50);
define _no_documento	char(20);
define _estatus_poliza	char(10);
define _ramo			char(50);
define _nom_formapag	char(50);
define _zona_formapag	char(20);
define _nom_agente		char(50); 
define _por_vencer		dec(16,2);
define _exigible		dec(16,2);
define _corriente		dec(16,2);
define _monto_30		dec(16,2);
define _monto_60		dec(16,2);
define _monto_90		dec(16,2);
define _saldo 			dec(16,2);
define _vigencia_ini	date;
define _vigencia_final	date;

set isolation to dirty read;

foreach
	select cod_agente,
		   nombre
	  into _cod_agente,
		   _nom_agente
	  from agtagent
	 where cod_cobrador = '217'

		foreach
			select no_poliza
			  into _no_poliza
			  from emipoagt
			 where cod_agente = _cod_agente

				select no_documento,
					   cod_pagador,
					   cod_formapag,
					   cod_ramo,
					   estatus_poliza,
					   vigencia_inic,
					   vigencia_final
				  into _no_documento,
					   _cod_pagador,
					   _cod_formapag,
					   _cod_ramo,
					   _estatus,
					   _vigencia_ini,
					   _vigencia_final
				  from emipomae
				 where no_poliza = _no_poliza;
				
				if _estatus = 1 then
					let _estatus_poliza = 'Vigente';
			    else
					continue foreach;
				end if

				select nombre
				  into _nombre_cliente
				  from cliclien
				 where cod_cliente = _cod_pagador;

				select nombre,
					   cod_cobrador
				  into _nom_formapag,
					   _cod_zona
				  from cobforpa
				 where cod_formapag = _cod_formapag;
				

				select nombre
				  into _ramo
				  from prdramo
				 where cod_ramo = _cod_ramo;
				
				select nombre
				  into _zona_formapag
				  from cobcobra
				 where cod_cobrador = _cod_zona;

				call sp_cob33('001', '001', _no_documento, 2011-05, '18/05/2011') 
				returning _por_vencer,
				 		  _exigible,
						  _corriente,
						  _monto_30,
						  _monto_60,
						  _monto_90,
						  _saldo;

				return _nombre_cliente,			
					   _no_documento,			
					   _estatus_poliza,			
					   _ramo,					
					   _nom_formapag,			
					   _zona_formapag,			
					   _nom_agente,			 	
					   _vigencia_ini,			
					   _vigencia_final, 		
					   _por_vencer,				
					   _exigible,				
					   _corriente,				
					   _monto_30,				
					   _monto_60,				
					   _monto_90,				
					   _saldo with resume;		
		end foreach
end foreach
end procedure;


