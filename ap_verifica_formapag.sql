drop procedure ap_verifica_formapag;
create procedure ap_verifica_formapag() returning smallint, char(18), char(10), char(3), char(10), char(3);

define a_no_poliza 		char(10);
define _cnt        		smallint;
define _cod_formapag 	char(3);
define _cod_agente 		char(10);
define _cod_cobrador	char(3);
define _error			smallint;
define _no_documento	char(18);

set isolation to dirty read;

foreach
	select no_poliza_r,
	       no_documento
	  into a_no_poliza,
		   _no_documento
	  from prdpreren
	 where periodo = '2025-10'
	   and tipo_ren = 3
	   and procesado = 1
	   and renovada = 0
	   
	select cod_formapag
	  into _cod_formapag
	  from emipomae
	 where no_poliza = a_no_poliza;

	select count(*)
	  into _cnt
	  from emipoagt
	 where no_poliza = a_no_poliza;
	if _cnt is null then
		let _cnt = 0;
	end if
	
	let _error = 0;
	
	if _cod_formapag = "008" And _cnt = 1 then --and _cod_ramo = "020" then -- solo ramo soda solicitado por analisa.
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = a_no_poliza
			 
			 select cod_cobrador
			   into _cod_cobrador
			   from agtagent
			  where cod_agente = _cod_agente;
			  
			if _cod_cobrador = "217" then
				let _error = 1;
				exit foreach;
			end if
		end foreach
	elif _cod_formapag = "006" And _cnt = 1 then
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = a_no_poliza
			 
			 select cod_cobrador
			   into _cod_cobrador
			   from agtagent
			  where cod_agente = _cod_agente;
			  
			if _cod_cobrador <> "217" then
				let _error = 1;
				exit foreach;
			end if
		end foreach
	end if
	if _error = 1 then
		return 322, --El Corredor No puede usar esta forma de pago, verifique.
		       _no_documento,
			   a_no_poliza,
			   _cod_formapag,
			   _cod_agente,
			   _cod_cobrador WITH RESUME; 
	end if
end foreach
end procedure;