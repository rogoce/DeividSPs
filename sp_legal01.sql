   --Reporte Monitoreo - Listado de PEP
   --  Armando Moreno M. 31/03/2021
      
   DROP procedure sp_legal01;
   CREATE procedure sp_legal01(a_cia CHAR(03),a_agencia CHAR(3),a_fecha_desde date, a_fecha_hasta date)
   RETURNING date,char(10),varchar(100),char(20),dec(16,2),varchar(50),varchar(50),char(50),varchar(50),varchar(100);


    DEFINE _cod_ramo,_cod_vendedor,_cod_subramo  CHAR(3);
    DEFINE _n_ramo,_n_vendedor    CHAR(50);
    DEFINE _n_agente     CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE _no_poliza,_cod_agente         CHAR(10);
    DEFINE _prima_suscrita	  DECIMAL(16,2);
	define _n_asegurado,_n_pagador		VARCHAR(50);

	define _cod_contratante char(10);
	define _cod_pagador char(10);
	define _cod_cliente  char(10);
	DEFINE _date_added DATE;
	DEFINE _no_documento char(20);
    define _canal char(50);	
    define _cod_producto       CHAR(5);
    define _nombre_producto    char(50);
	define _no_unidad			char(5);
	define _cantidad_polizas,_estatus_poliza    smallint;
	
LET _prima_suscrita  = 0;

SET ISOLATION TO DIRTY READ;
LET descr_cia = sp_sis01(a_cia);

--set debug file to "sp_legal01.trc";
--trace on;

--CLIENTES PEP
foreach
	select date_added,
           cod_cliente,
		   nombre
	  into _date_added,
           _cod_cliente,
		   _n_asegurado
	  from cliclien
	 where cliente_pep = 1
	   and date_added >= a_fecha_desde
	   and date_added <= a_fecha_hasta   
	   
	foreach
		select no_documento
		  into _no_documento
		  from emipomae
		 where actualizado = 1
		   and cod_contratante = _cod_cliente
		 group by no_documento
         order by no_documento
		 
        let _no_poliza = sp_sis21(_no_documento);
		
		select cod_pagador,
		       cod_ramo,
			   cod_subramo,
			   estatus_poliza
		  into _cod_pagador,
		       _cod_ramo,
			   _cod_subramo,
			   _estatus_poliza
		  from emipomae
		 where no_poliza = _no_poliza;
		 
		if _estatus_poliza = 1 then --solo pol. vigente
		else
			continue foreach;
		end if
		
		select nombre
		  into _n_pagador
		  from cliclien
		 where cod_cliente = _cod_pagador; 
		 
		select nombre
		  into _n_ramo
		  from prdsubra
		 where cod_ramo = _cod_ramo
		   and cod_subramo = _cod_subramo; 		
		
		foreach
			select a.nombre,a.cod_vendedor
			  into _n_agente,_cod_vendedor
			  from emipoagt e, agtagent a
			 where e.cod_agente = a.cod_agente
			   and e.no_poliza = _no_poliza
			 order by porc_partic_agt desc, a.nombre asc
			exit foreach;
		end foreach			

		 
		select nombre
		  into _n_vendedor
		  from agtvende
		 where cod_vendedor = _cod_vendedor;
		 
		select sum(prima_suscrita)
		  into _prima_suscrita
		  from endedmae
		 where actualizado = 1
           and no_poliza = _no_poliza;
		   
		select b.nombre
		  into _canal
		  from ponderacion a, clicanal b
		 where a.cod_cliente = _cod_cliente
		   and a.cod_canal = b.cod_canal;	

		
	    return _date_added,_cod_cliente,_n_asegurado,_no_documento,_prima_suscrita,_n_agente,_n_vendedor,_canal,_n_ramo,_n_pagador with resume;
	end foreach   
end foreach
END PROCEDURE;