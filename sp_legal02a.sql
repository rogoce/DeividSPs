   --Reporte Monitoreo - Pagos directos de reclamos con estatus cerrados diferentes al asegurado
   --  Armando Moreno M. 05/04/2021
   
   DROP procedure sp_legal02;
   CREATE procedure sp_legal02(a_cia CHAR(03),a_agencia CHAR(3),a_fecha_desde date, a_fecha_hasta date)
   RETURNING varchar(100),char(20),varchar(100),varchar(50),char(1),char(20),dec(16,2),date,date,dec(16,2),varchar(50),varchar(50),char(50),
             varchar(255),varchar(50),dec(16,2),varchar(50),varchar(100);

    DEFINE _cod_ramo,_cod_vendedor,_cod_subramo  CHAR(3);
    DEFINE _n_ramo,_n_vendedor,_n_ajust_ext,_n_ajustador    CHAR(50);
    DEFINE _n_agente     CHAR(50);
    DEFINE _no_poliza,_cod_agente,_cod_cliente_r         CHAR(10);
    DEFINE _prima_suscrita,_suma_asegurada,_monto_pagado	  DECIMAL(16,2);
	define _n_asegurado,_n_pagador		VARCHAR(50);

	define _cod_contratante,_no_reclamo char(10);
	define _cod_pagador,_no_tranrec,_cod_asegurado char(10);
	define _cod_cliente,_no_requis,_transaccion  char(10);
	DEFINE _fecha_suscripcion,_fecha_siniestro DATE;
	DEFINE _no_documento,_numrecla char(20);
	define _cod_ajustador,_cod_ajus_ext char(3);
	define _cnt smallint;
	define _beneficiario varchar(100);
	define _desc_transaccion varchar(60);
	define _desc_fin  varchar(255);
	define _tipo_persona char(1);
    define _canal char(50);			   
    define _cod_producto       CHAR(5);
    define _nombre_producto    char(50);
	define _no_unidad			char(5);

LET _prima_suscrita = 0;
let _monto_pagado   = 0;

SET ISOLATION TO DIRTY READ;

let _cnt = 0;
let _suma_asegurada = 0;

--set debug file to "sp_legal02.trc";
--trace on;
foreach
	select r.no_tranrec,
	       r.no_requis,
		   r.transaccion,
	       e.cod_asegurado,
		   e.no_documento,
		   e.no_poliza,
		   e.numrecla,
		   e.suma_asegurada,
		   e.fecha_siniestro,
		   e.no_reclamo,
		   e.ajust_interno,
		   e.ajust_externo,
		   t.cod_ramo,
	       t.prima_suscrita,
		   t.cod_pagador,
		   t.fecha_suscripcion,
		   t.cod_subramo,
		   t.cod_contratante,
		   e.no_unidad
	  into _no_tranrec,
  		   _no_requis,
		   _transaccion,
           _cod_asegurado,
		   _no_documento,
		   _no_poliza,
		   _numrecla,
		   _suma_asegurada,
		   _fecha_siniestro,
		   _no_reclamo,
		   _cod_ajustador,
		   _cod_ajus_ext,
		   _cod_ramo,
		   _prima_suscrita,
		   _cod_pagador,
		   _fecha_suscripcion,
		   _cod_subramo,
		   _cod_cliente,
		   _no_unidad
	  from rectrmae r, recrcmae e, emipomae t
	 where r.no_reclamo = e.no_reclamo
	   and e.no_poliza = t.no_poliza
	   and t.cod_ramo not in('004','016','019','018','008','020')	--No incluye ramos de personas ni fianzas.
	   and t.actualizado = 1
       and r.cod_compania = a_cia
	   and r.actualizado  = 1
       and e.actualizado = 1
	   and e.estatus_reclamo = 'C'
	   and r.cod_tipotran = "004"
	   and r.cod_tipopago in ('004','003')
	   and r.fecha_pagado between a_fecha_desde and a_fecha_hasta
	   order by r.fecha_pagado
	   
	select count(*)
	  into _cnt
	  from rectrcob
	 where no_tranrec = _no_tranrec
	   and monto <> 0
	   and cod_cobertura not in( select cod_cobertura
									   from prdcober
									   where cod_ramo = _cod_ramo
									     and (nombre like '%DA%OS%PROP%' or nombre like 'LESI%CORP%'
										       or nombre like 'GAST%MED%' or nombre like 'INV%TOT%')
									);  
	 
	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt > 0 then
	else
		continue foreach;
	end if
	
	select sum(monto)
	  into _monto_pagado
	  from chqchrec
	 where no_requis   = _no_requis
       and transaccion = _transaccion;	 

	select cod_cliente,
	       a_nombre_de
	  into _cod_cliente_r,
	       _beneficiario
	  from chqchmae
	 where no_requis = _no_requis;
	 
	let _cod_asegurado = trim(_cod_asegurado);
    let _cod_cliente_r = trim(_cod_cliente_r);
	
    if _cod_asegurado <> _cod_cliente_r then	--El asegurado es distinto al beneficiario del pago
	else
		continue foreach;
	end if
	let _desc_fin = '';
	foreach
		select desc_transaccion
		  into _desc_transaccion
		  from recrcde2
		 where no_reclamo = _no_reclamo

		let _desc_fin = _desc_fin || _desc_transaccion;

	end foreach
	
	select nombre
	  into _n_ajust_ext
	  from recajust
	 where cod_ajustador = _cod_ajus_ext;

	select nombre
	  into _n_ajustador
	  from recajust
	 where cod_ajustador = _cod_ajustador;	
	
	select nombre,
	       tipo_persona
	  into _n_asegurado,
	       _tipo_persona
	  from cliclien
	 where cod_cliente = _cod_asegurado;
		 
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
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	select nombre,
		   cod_vendedor
	  into _n_agente,
		   _cod_vendedor
	  from agtagent 
	 where cod_agente = _cod_agente;
	 
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
	   
	let _n_ramo = trim(_n_ramo);
	
	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = _no_poliza
	   AND no_unidad = _no_unidad;	  	
	
	select nombre
	  into _nombre_producto	  
	  from prdprod
	 where cod_producto = _cod_producto;	 

	if _nombre_producto is null then
	    let _nombre_producto = '';
	 end if	 
	 
	return _n_asegurado,_no_documento,_beneficiario,_nombre_producto,_tipo_persona,_numrecla,_suma_asegurada,_fecha_suscripcion,_fecha_siniestro,_monto_pagado,
		   _n_agente,_n_vendedor,_canal,_desc_fin,_n_ajustador,_prima_suscrita,_n_ajust_ext,_n_pagador with resume;

end foreach
END PROCEDURE;