-- reporte de diferencias con tecnica de seguros

-- Creado: 11/08/2017 - Autor: Federico Coronado

drop procedure sp_end14;

create procedure "informix".sp_end14()
returning date,
          decimal(16,2),
		  decimal(16,2),
          --varchar(10),
          varchar(20),
          varchar(15),
          --smallint,
		  decimal(16,2),
		  decimal(16,2),
		  varchar(10),
		  varchar(15),	
		  varchar(20),
		  decimal(16,2);

define _fecha_registro_json 	date;
define _prima_json_b 				decimal(16,2);
define _prima_json_n 				decimal(16,2);
define _no_poliza_json			varchar(10);
define _no_documento_json		varchar(20);
define _no_unidad_json			varchar(5);
define _no_factura_json			varchar(15);
define _actualizado_json		smallint;
define _prima_deivid_b			decimal(16,2);
define _prima_deivid_n			decimal(16,2);
define _no_poliza_deivid        varchar(10);
define _no_factura_deivid	    varchar(15);	
define _no_documento_deivid     varchar(20);
define v_diferencia			    decimal(16,2); 

set isolation to dirty read;
--SET DEBUG FILE TO "sp_web23.trc"; 
--TRACE ON;
	foreach

		select fecha_registro,
			   sum(prima_neta),
			   sum(prima_bruta),			   
			   --no_poliza, 
			   --no_unidad, 
			   no_factura, 
			   --actualizado, 
			   no_documento
		  into _fecha_registro_json,
			   _prima_json_n,
			   _prima_json_b,
			  -- _no_poliza_json,
			  -- _no_unidad_json,
			   _no_factura_json,
			  -- _actualizado_json,
			   _no_documento_json
		  from prdemielctdet
		 where cod_agente = '00180'
		   and year(fecha_registro) = 2017
		   and actualizado = 1
		   and proceso = 'C'
		   --and no_documento = '1610-00329-01'
		   /*and actualizado = 1*/
		   --and no_factura = '00-00000'
	  group by 1,4,5
	  order by no_factura

	  let _prima_deivid_n 		= 0;
	  let _prima_deivid_b 		= 0;
      let _no_poliza_deivid 	= "";
      let _no_factura_deivid 	= ''; 
      let _no_documento_deivid  = "";
	  
	  
		select sum(prima_bruta),sum(prima_neta),no_poliza, no_factura, no_documento
		  into _prima_deivid_b,_prima_deivid_n, _no_poliza_deivid, _no_factura_deivid, _no_documento_deivid 
		  from endedmae
		 where no_factura    = _no_factura_json
		   and user_added in('informix','DEIVID')
		   group by 3,4,5;
	  
		if _prima_deivid_b is null then
			let _prima_deivid_b = 0;
		end if
	  
	  	if _prima_json_b is null then
			let _prima_json_b = 0;
		end if
		
		let v_diferencia = _prima_json_b - _prima_deivid_b;
	 
	return  _fecha_registro_json,
			_prima_json_n,
			_prima_json_b,
			--_no_poliza_json,
			_no_documento_json,
			_no_factura_json,
			--_actualizado_json,
			_prima_deivid_n,
			_prima_deivid_b,
			_no_poliza_deivid,
			_no_factura_deivid,
			_no_documento_deivid,
			abs(v_diferencia)
			with resume;

	end foreach
end procedure