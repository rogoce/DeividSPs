-- POLIZAS de salud con vigencia inic septiembre distinto de colectivo, cuya facturacion de julio es diferente a a la de agosto
--Armando Moreno M.

DROP procedure sp_roman15;
CREATE procedure sp_roman15()
RETURNING char(10),char(20),char(10),char(10),dec(16,2),char(10),char(10),dec(16,2),char(10),char(10),dec(16,2);

DEFINE _no_poliza	 		CHAR(10);
DEFINE _no_documento    	CHAR(20);
DEFINE _cod_asegurado,_no_factura_j,_no_factura_a,_no_endoso_j,_no_endoso_a,_no_factura_s,_no_endoso_s 		char(10);
DEFINE _n_grupo,_n_asegurado  		CHAR(50);
define _vigencia_inic, _vigencia_final date;
define _cod_grupo    		char(5);
define _prima_bruta_j,_prima_bruta_a,_prima_bruta_s 	dec(16,2);
define _cnt integer;

let _prima_bruta_j = 0.00;
let _prima_bruta_a = 0.00;

foreach
	select no_poliza,
	       no_documento,
		   vigencia_inic,
		   vigencia_final
	  into _no_poliza,
	       _no_documento,
		   _vigencia_inic,
		   _vigencia_final
	  from emipomae
	 where actualizado = 1
	   and cod_ramo = '018'
	   and cod_subramo <> '012'
	   and month(vigencia_inic) = 9
	   
	select count(*)
	  into _cnt
	  from endedmae
	 where no_poliza = _no_poliza
	   and actualizado = 1
	   and cod_endomov = '014'
	   and periodo = '2024-07';
	   
	if _cnt is null then
		let _cnt = 0;
	end if	
	if _cnt > 0 then
	else
		continue foreach;
	end if
	
	select count(*)
	  into _cnt
	  from endedmae
	 where no_poliza = _no_poliza
	   and actualizado = 1
	   and cod_endomov = '014'
	   and periodo = '2024-08';
	   
	if _cnt is null then
		let _cnt = 0;
	end if	
	if _cnt > 0 then
	else
		continue foreach;
	end if
		   
	foreach
		select prima_bruta,
		       no_factura,
			   no_endoso
		  into _prima_bruta_j,
		       _no_factura_j,
			   _no_endoso_j
		  from endedmae
		 where no_poliza = _no_poliza
		   and actualizado = 1
		   and cod_endomov = '014'
		   and periodo = '2024-07'
		   
		exit foreach;
	end foreach
	
	foreach
		select prima_bruta,
		       no_factura,
			   no_endoso
		  into _prima_bruta_a,
		       _no_factura_a,
			   _no_endoso_a
		  from endedmae
		 where no_poliza = _no_poliza
		   and actualizado = 1
		   and cod_endomov = '014'
		   and periodo = '2024-08'
		   
		exit foreach;
	end foreach
	
	if _prima_bruta_j <> _prima_bruta_a then
		foreach
			select prima_bruta,
				   no_factura,
				   no_endoso
			  into _prima_bruta_s,
				   _no_factura_s,
				   _no_endoso_s
			  from endedmae
			 where no_poliza = _no_poliza
			   and actualizado = 1
			   and cod_endomov = '014'
			   and periodo = '2024-09'
			   
			exit foreach;
		end foreach
		return _no_poliza,_no_documento,_no_factura_j,_no_endoso_j,_prima_bruta_j,_no_factura_a,_no_endoso_a,_prima_bruta_a,_no_factura_s,_no_endoso_s,_prima_bruta_s with resume;
	else
		continue foreach;
	end if
end foreach

END PROCEDURE;
