
drop procedure sp_armando_callcenter;

create procedure "informix".sp_armando_callcenter(a_cod_agente char(5))
returning char(20);

define _no_poliza 		char(10);
define _cod_agente      char(5);
define _no_documento    char(20);
define _fecha_aviso     date;
define _cod_leasing     char(10);
define _cod_errado      char(10);
define _cod_leasing1    char(10);
define _cod_errado1     char(10);
define _cnt             integer;								
define li_return        integer;
define _vigencia_final  date;
define _cod_pagador		char(10);
define _cod_cliente  	char(10);
define _cantidad		smallint;
define _error,_valor	smallint;
define _cobra_poliza    char(1);
define _estatus         smallint;
define _fec_aviso_canc  date;

set isolation to dirty read;


{foreach

	select a.no_documento
	  into _no_documento
	  from emipomae a, emipoagt e
	 where a.no_poliza = e.no_poliza
	   and a.actualizado = 1
	   and a.cobra_poliza = 'E'
	   and e.cod_agente = a_cod_agente

	select	cod_cliente
	  into	_cod_pagador
	  from	caspoliza
	 where	no_documento = _no_documento;

	select	count(*)
	  into	_cantidad
	  from	caspoliza
	 where	cod_cliente = _cod_pagador;

	let _no_poliza = sp_sis21(_no_documento);

	Update emipomae
	   Set cobra_poliza = "C",
		   cod_formapag = "008"
	 Where no_poliza    = _no_poliza;

	if _cantidad = 1 then

		delete from caspoliza
		 where cod_cliente = _cod_pagador;

		delete from cascliente
		 where cod_cliente = _cod_pagador;

		delete from cobcapen
		 where cod_cliente = _cod_pagador;

	elif _cantidad > 1 then

		delete from caspoliza
		 where no_documento = _no_documento;

	end if

    RETURN _no_documento WITH RESUME;

end foreach	 }

CREATE TEMP TABLE temp_corr
 (no_documento    CHAR(20),
  no_poliza       CHAR(10),
  cod_agente      CHAR(5),
  PRIMARY KEY (no_documento)) WITH NO LOG;


foreach

	select cod_agente
	  into _cod_agente
	  from agtagent
	 where cod_cobrador = '166'

	foreach

		select no_poliza
		  into _no_poliza
		  from emipoagt
		 where cod_agente = _cod_agente
		group by no_poliza
		order by no_poliza

		select cobra_poliza,no_documento,estatus_poliza
		  into _cobra_poliza,_no_documento,_estatus
		  from emipomae
		 where no_poliza = _no_poliza;

		let _no_poliza = sp_sis21(_no_documento);

		select cobra_poliza,no_documento,fecha_aviso_canc
		  into _cobra_poliza,_no_documento,_fec_aviso_canc
		  from emipomae
		 where no_poliza = _no_poliza;

--		if _cobra_poliza = "C" and _estatus = 1 then

		if _fec_aviso_canc = "21/12/2009" then

	    	BEGIN
	          ON EXCEPTION IN(-239)

	          END EXCEPTION
	        INSERT INTO temp_corr
	             VALUES(_no_documento,	 
	                   _no_poliza, 
					   _cod_agente
					   );

	    	END

			{   	Update emipomae
				   Set cobra_poliza = "E",
		   			   cod_formapag = "006"
				 Where no_poliza    = _no_poliza;

				let _valor = sp_cas022(_no_poliza);	 }

			   	Update emipomae
				   Set carta_aviso_canc = 0,
		   			   fecha_aviso_canc = null
				 Where no_poliza    = _no_poliza;

		end if

	end foreach

end foreach

	foreach

		select no_documento
		  into _no_documento
		  from temp_corr

	    RETURN _no_documento WITH RESUME;

	end foreach

DROP TABLE temp_corr;

end procedure