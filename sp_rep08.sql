-- Procedimiento que genera preliminar con pólizas  que tienen 16 dias sin pagos filtrado por agentes
-- Creado    : 02/06/2015 -- Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rep08;

create procedure "informix".sp_rep08(a_cod_agente varchar(10))
returning varchar(20),
          varchar(100),
		  varchar(30),
		  varchar(30),
		  varchar(100),
		  varchar(100),
		  varchar(100),
		  date,
          date,
		  dec(10,2),
		  dec(10,2),  
		  dec(10,2), 
		  dec(10,2), 
		  dec(10,2), 
		  dec(10,2), 
		  dec(10,2),
		  varchar(20),
		  char(3),
		  varchar(100),
		 -- date,
		  date,
		  smallint; 

-- Actualizar Polizas Nuevas

define _fecha_resta			date;
define _vigencia_inic   	date;
define _vigencia_final  	date;
define _error_desc	    	varchar(100);
define _nombre_forma_pag    varchar(30);
define _error		    	integer;
define _no_poliza       	varchar(10);
define _no_documento    	varchar(20);
define _cod_pagador     	varchar(10);
define _cod_ramo        	char(3);
define _cod_formapag    	char(3);
define _prima_bruta     	dec(10,2);
define _nombre_cliente      varchar(100);
define _nombre_ramo         varchar(30);
define _cod_agente          varchar(10);
define _nombre_corredor     varchar(100);
define _periodo             char(7);
define _por_vencer          dec(10,2);   
define _exigible            dec(10,2); 
define _corriente           dec(10,2); 
define _monto_30            dec(10,2); 
define _monto_60            dec(10,2); 
define _monto_90            dec(10,2); 
define _monto_120           dec(10,2); 
define  _monto_150          dec(10,2); 
define _monto_180           dec(10,2); 
define _saldo_total         dec(10,2); 
define _nombre_acreedor     varchar(100);
define _cod_acreedor        varchar(10);
define _nueva_renov         char(1);
define _estado              varchar(20);
define _cod_vendedor        char(3);
define _nombre_zona         varchar(100);
define _tipo                char(1);
define _tipo_vendedor       char(1);
define _cnt                 integer;
define _cantidad            integer;
define _dias_anulacion		smallint;
define _dias_sin_pago		smallint; 
define _fecha_actual        date;
define _fecha_anulacion     date;

set isolation to dirty read;

let _fecha_actual = today;

--set debug file to "sp_repo06.trc";
--trace on;

let _cod_acreedor = "";
let _dias_anulacion = 60;

select count(*)
  into _cantidad
  from tmp_caspoliza;
  
	if _cantidad > 0 then
				foreach
					select no_documento,
					       dia_cobros1
					  into _no_documento,
						   _dias_sin_pago
					  from tmp_caspoliza
				  order by no_documento asc
					 
					let _no_poliza = sp_sis21(_no_documento);
					foreach
						select cod_agente
						  into _cod_agente
						  from emipoagt
						 where no_poliza = _no_poliza
						 --  and cod_agente = a_cod_agente

						if trim(_cod_agente) = trim(a_cod_agente) then
							exit foreach;
						end if
					end foreach
					
					if trim(_cod_agente) <> trim(a_cod_agente) then
						continue foreach;
					end if					

					select cod_pagador,
						   cod_ramo,
						   cod_formapag,
						   vigencia_inic,
						   vigencia_final,
						   prima_bruta,
						   nueva_renov
					  into _cod_pagador,
						   _cod_ramo,
						   _cod_formapag,
						   _vigencia_inic,
						   _vigencia_final,
						   _prima_bruta,
						   _nueva_renov
					  from emipomae
					 where no_poliza = _no_poliza;
					 
					let _fecha_anulacion = _vigencia_inic + _dias_anulacion units day;
					
					if _nueva_renov = 'N' then
						let _estado = "Nuevas";
					else
						let _estado = "Renovadas";
					end if
					
					select nombre
					  into _nombre_forma_pag
					  from cobforpa
					 where cod_formapag = _cod_formapag;
					
					select nombre
					  into _nombre_cliente
					  from cliclien
					 where cod_cliente = _cod_pagador;
					 
					select nombre
					  into _nombre_ramo
					  from prdramo
					 where cod_ramo = _cod_ramo;		 
					
					select nombre,
						   cod_vendedor
					  into _nombre_corredor,
						   _cod_vendedor
					  from agtagent
					 where cod_agente = _cod_agente;
					
					select nombre
					  into _nombre_zona
					  from agtvende 
					 where cod_vendedor = _cod_vendedor;
					 
					let _cod_acreedor = "";
					
					foreach
						select x.cod_acreedor
						  into _cod_acreedor
						  from emipoacr x, emipouni e
						 where x.no_poliza = e.no_poliza
						   and x.no_unidad = e.no_unidad
						   and e.no_poliza = _no_poliza
						 exit foreach;
					end foreach
					
					select nombre
					  into _nombre_acreedor
					  from emiacre
					 where cod_acreedor = _cod_acreedor;
					 
					call sp_sis39(_fecha_actual) returning _periodo;
					call sp_cob245(
						 "001",
						 "001",	
						 _no_documento,
						 _periodo,
						 _fecha_actual)
					returning	_por_vencer,      
								_exigible,         
								_corriente,        
								_monto_30,         
								_monto_60,         
								_monto_90,
								_monto_120,
								_monto_150,
								_monto_180,
								_saldo_total;

					return _no_documento,
						   _nombre_cliente,
						   _nombre_ramo,
						   _nombre_forma_pag,
						   _cod_agente,
						   _nombre_corredor,
						   _nombre_acreedor,
						   _vigencia_inic,
						   _vigencia_final,
						   _prima_bruta,
						   _por_vencer,  
						   _exigible,    
						   _corriente,   
						   _monto_30,    
						   _monto_60,    
						   _monto_90,
						   _estado,
						   _cod_vendedor,
						   _nombre_zona,
						   --_fecha_anulacion,
						   _fecha_actual,
						   _dias_sin_pago
						   with resume; 
				end foreach
	end if

--drop table if exists tmp_codigos;
--drop table if exists tmp_caspoliza;
end procedure;