-- procedimiento para realizar la facturacion automatica de polizas que tenian morosidad de 61 dias o mas (SALUD)

-- creado    : 15/11/2010 - autor: roman gordon

drop procedure sp_pro351;

create procedure "informix".sp_pro351(a_secuencia integer)
returning	char(20),char(7),char(50),char(50),char(50);


define _error				integer;
define _error_isam			integer;
define _error_desc			char(100);
define _nombre_cli			char(50);
define _cobrador			char(50);
define _agente				char(50);
define _no_documento		char(20);
define _no_poliza			char(10);
define _cod_cliente			char(10);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_cobrador		char(3);
define _cod_formapag		char(3);



set isolation to dirty read;
foreach
	select no_documento,
	       no_remesa
	  into _no_documento,
	  	   _periodo
	  from parmailcomp
	 where mail_secuencia = a_secuencia
	 
	let _no_poliza = sp_sis21(_no_documento);
	
	select cod_pagador,
		   cod_formapag
	  into _cod_cliente,
	  	   _cod_formapag
	  from emipomae
	 where no_poliza = _no_poliza;
	
	select nombre
	  into _nombre_cli
	  from cliclien
	 where cod_cliente = _cod_cliente;
	
	select cod_cobrador
	  into _cod_cobrador
	  from cobforpa
	 where cod_formapag = _cod_formapag;

    foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	if _cod_cobrador is null or _cod_cobrador = '' then
		select cod_cobrador
		  into _cod_cobrador
		  from agtagent
		 where cod_agente = _cod_agente;
	end if
			
	select nombre
	  into _cobrador
	  from cobcobra
	 where cod_cobrador = _cod_cobrador;
	
	select nombre
	  into _agente
	  from agtagent
	 where cod_agente = _cod_agente;

	return _no_documento,_periodo,_nombre_cli,_cobrador,_agente with resume;

end foreach;

end procedure; 
