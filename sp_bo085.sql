-- Procedimiento que calcula la prima devengada vs incurrido bruto (Corredores x periodo)
-- Creado     :	10/01/2014 - Autor: Jorge Contreras

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_bo085;		

create procedure "informix".sp_bo085(_cod_corredor CHAR(5),_periodo_in char(7),_periodo_fin char(7))
returning integer, char(100);

define _no_documento, _no_documento1     char(20);
define _incurrido_bruto, _incurrido_bruto1 DEC(16,2); 
define _pagado_bruto, _salvamento_bruto	   DEC(16,2);
define _pagado_bruto2, _pagado_bruto11	   DEC(16,2);
define _pagado_bruto1, _salvamento_bruto1  DEC(16,2);
define _recupero_bruto, _deducible_bruto   DEC(16,2);
define _recupero_bruto1, _deducible_bruto1 DEC(16,2);
define _pri_dev_aa1, _pri_dev_aa2		   DEC(16,2);
define _reserva_bruto, _reserva_bruto1     DEC(16,2); 
define _tri             CHAR(255);
define _cod_agente1	    char(5);
define _nombre_agente1	char(50);
define _no_poliza		char(10);
define _cod_ramo		char(3);


set isolation to dirty read;

--set debug file to "sp_par319.trc";
--trace on;

CREATE TEMP TABLE tmp_sinpri(
        no_documento         CHAR(20)  NOT NULL,
	   	pri_dev_aa			 dec(16,2) 	default 0,
		incurrido_bruto      DEC(16,2) default 0,
		pagado_bruto		 DEC(16,2) default 0,
		reserva_bruto		 DEC(16,2) default 0,
		pagado_bruto1		 DEC(16,2) default 0,
        salvamento_bruto	 DEC(16,2) default 0,
		recupero_bruto		 DEC(16,2) default 0, 
		deducible_bruto 	 DEC(16,2) default 0
		) WITH NO LOG;

CREATE TEMP TABLE tmp_sinpri1(
        no_documento         CHAR(20)  NOT NULL,
		no_poliza		     char(10),
		cod_ramo			 CHAR(3),
		cod_agente           char(5),          
	   	pri_dev_aa			 dec(16,2) 	default 0,
		incurrido_bruto      DEC(16,2) default 0,
		pagado_bruto		 DEC(16,2) default 0,
		reserva_bruto		 DEC(16,2) default 0,
		pagado_bruto1		 DEC(16,2) default 0,
        salvamento_bruto	 DEC(16,2) default 0,
		recupero_bruto		 DEC(16,2) default 0, 
		deducible_bruto 	 DEC(16,2) default 0
		) WITH NO LOG;



--******************************************Calcular Prima devengada****************************************--

CALL sp_bo084(_periodo_fin);	

foreach
    
    select  no_documento, 
            pri_dev_aa
    into  _no_documento, 
          _pri_dev_aa1
    from tmp_dev
  

	insert into tmp_sinpri(no_documento, pri_dev_aa)
	values (_no_documento, _pri_dev_aa1);

end foreach

DROP TABLE tmp_dev;
  

--********************************************Incurrido bruto*********************************************--


call sp_rec01d("001", "001", _periodo_in, _periodo_fin) returning _tri;

foreach
 select doc_poliza,
        incurrido_bruto,
		pagado_bruto,
		reserva_bruto,
		pagado_bruto1,
		salvamento_bruto,
		recupero_bruto,
		deducible_bruto
   into _no_documento,
        _incurrido_bruto,
        _pagado_bruto,
		_reserva_bruto,
		_pagado_bruto11,
        _salvamento_bruto,
		_recupero_bruto,
		_deducible_bruto 
   from tmp_sinis

   insert into tmp_sinpri(no_documento, incurrido_bruto, pagado_bruto, reserva_bruto, pagado_bruto1, salvamento_bruto, recupero_bruto, deducible_bruto )
   values (_no_documento, _incurrido_bruto, _pagado_bruto, _reserva_bruto, _pagado_bruto11, _salvamento_bruto, _recupero_bruto, _deducible_bruto);

end foreach

 DROP TABLE tmp_sinis;
   
--********************************************************************************************************--
foreach
 select no_documento,
        sum(pri_dev_aa),
	    sum(incurrido_bruto),
		sum(pagado_bruto),
		sum(reserva_bruto),
		sum(pagado_bruto1),
		sum(salvamento_bruto),
		sum(recupero_bruto),
		sum(deducible_bruto)
  into   _no_documento1,
        _pri_dev_aa2,
	    _incurrido_bruto1,
		_pagado_bruto1,
		_reserva_bruto1,
		_pagado_bruto2,
		_salvamento_bruto1,
		_recupero_bruto1,
		_deducible_bruto1
  from tmp_sinpri
--where no_documento <> "0808-00336-01"
  group by no_documento
		 
  let _no_poliza = sp_sis21(_no_documento1);

  foreach
	 select cod_agente
	   into _cod_agente1
	   from emipoagt
	  where no_poliza = _no_poliza
	  order by porc_partic_agt desc
		exit foreach;
	end foreach

	select nombre
	  into _nombre_agente1
	  from agtagent
	 where cod_agente = _cod_agente1;

	select cod_ramo
	  into _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;    

   insert into tmp_sinpri1(no_documento, no_poliza, cod_ramo, cod_agente,pri_dev_aa,incurrido_bruto, pagado_bruto, reserva_bruto, pagado_bruto1, salvamento_bruto, recupero_bruto, deducible_bruto)
   values (_no_documento1,  _no_poliza, _cod_ramo, _cod_agente1, _pri_dev_aa2, _incurrido_bruto1, _pagado_bruto1,_reserva_bruto1, _pagado_bruto2, _salvamento_bruto1,_recupero_bruto1,_deducible_bruto1);

end foreach

DROP TABLE tmp_sinpri;

 return 0, "Actualizacion Exitosa";


end procedure
