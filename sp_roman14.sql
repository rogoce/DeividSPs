-- POLIZAS serafin saldo meor a cero
--Armando Moreno M.

DROP procedure sp_roman14;
CREATE procedure sp_roman14()
RETURNING char(20),date,date,dec(16,2),dec(16,2),CHAR(5),char(50),char(10),char(50);

DEFINE _no_poliza	 		CHAR(10);
DEFINE _no_documento    	CHAR(20);
DEFINE _cod_asegurado 		char(10);
DEFINE _n_grupo,_n_asegurado  		CHAR(50);
define _vigencia_inic, _vigencia_final date;
define _cod_grupo    		char(5);
define _saldo,_prima_bruta 	dec(16,2);

let _saldo = 0.00;
let _prima_bruta = 0.00;

foreach
	select no_poliza,
	       no_documento,
		   vigencia_inic,
		   vigencia_final,
		   saldo,
		   cod_grupo
	  into _no_poliza,
	       _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _saldo,
		   _cod_grupo
	  from emipomae
	 where actualizado = 1
	   and cod_grupo in('00068','77974')
	   --and cod_ramo = '002'
	   and cod_no_renov = '039'
	   and saldo < 0
	   and vigencia_final between '01/07/2024' and '31/07/2024'
	   
	select nombre
	  into _n_grupo
	  from cligrupo
     where cod_grupo = _cod_grupo;
	 
	select prima_bruta
	  into _prima_bruta
	  from endedmae
     where no_poliza = _no_poliza
	   and no_endoso = '00000';
	 
	foreach
		select cod_asegurado
		  into _cod_asegurado
		  from emipouni
		 where no_poliza = _no_poliza

			exit foreach;
			
	end foreach
	
	select nombre
	  into _n_asegurado
	  from cliclien
	 where cod_cliente = _cod_asegurado;
	
	return _no_documento,_vigencia_inic,_vigencia_final,_saldo,_prima_bruta,_cod_grupo,_n_grupo,_cod_asegurado,_n_asegurado with resume;
	
end foreach

END PROCEDURE;
