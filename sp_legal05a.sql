-- Reporte de Pólizas nuevas con menos de un año de vigencia, que han presentados tres o más reclamos tipo pérdida parcial de una misma póliza
-- Creado : 30/03/2021 - Autor: Henry Giron
-- SIS v.2.0 - d_cob_sp_legal05_dw1 - DEIVID, S.A.  
-- execute procedure sp_legal05('001','001','01/03/2021','01/04/2021')

drop procedure sp_legal05;
create procedure sp_legal05(
a_compania char(3),
a_agencia char(3),
a_fecha1 date,
a_fecha2 date)

returning  
    varchar(100) as asegurado,
    char(20) as poliza,
    char(50) as Nombre_Producto,
    varchar(50) as tipo_persona,
	char(20) as reclamo,
	dec(16,2) as Suma_Asegurada,
	DATE as Fecha_emision_pol,  -- Fecha de emisión de la póliza
    DATE as fecha_siniestro,
	dec(16,2) as Monto_Pagado , --Monto Pagado 
	varchar(50) as corredor,
	char(50) as Ejecutivo_comercial,  --Ejecutivo Comercial
	varchar(100) as Beneficiario_chq,  --Nombre del beneficiario del cheque o de la transferencia bancaria
	char(50) As Canal,  --Canal
	varchar(255) as desc_siniestro,   --Descripción del siniestro
    varchar(50) as ajustador_interno,
    dec(16,2) as prima_suscrita,  --Prima 
	char(50) as Nombre_pagador, --Nombre del pagador de la póliza 
	smallint as Dias,
	smallint as cantidad_unidad,
	char(5) as unidad;

				   		
define _no_reclamo      	char(10);
define _numrecla       	    char(20);
define _cod_asegurado  	    char(10);
define _no_documento   	    char(20);
define _no_poliza	   		char(10); 	
define _fecha_siniestro   	date;
define _fecha_suscripcion 	date;
define _ajust_interno		char(3);	
define _vigencia_inic   	date;
define _vigencia_final  	date;
define _sucursal_origen,_cod_subramo 	char(3);
define _cod_agente      	char(5);
define _corredor        	varchar(50);
define _asegurado       	varchar(100);
define _ajustador       	varchar(50);
define _ajust_nombre		char(50);
define _no_unidad			char(5);
define _cod_cliente		    char(10);
define _nom_cliente_ben     varchar(100);
define _cod_pagador      	char(10);
define _nombre_pag			varchar(50);
define _cod_vendedor		char(3);
define _nombre_vendedor	    char(50);
define _cod_ramo            char(3); 
define _prima_suscrita		dec(16,2);
define _suma_asegurada		dec(16,2);
define _monto_pagado		dec(16,2);
define _canal               char(50);
define _fecha_reclamo       date;
define _dias                smallint;
define _tipo_persona        varchar(50); 
define _cant_perdida        smallint;
define _nombre_ramo         char(50);
define _transaccion		    char(10);
define _no_requis		    char(10);  
define _desc_sin            varchar(255);
define _desc_transaccion    varchar(60);
define _cantidad_unidad     smallint;
define  _cod_producto       CHAR(5);
define  _nombre_producto    char(50);
let _canal = '';

 --SET DEBUG FILE TO "sp_pro1026.trc";      
 --TRACE ON;   

foreach
 select a.no_reclamo,
        a.numrecla,
        a.cod_asegurado,
        a.no_documento,
        a.no_poliza,		
        a.fecha_siniestro,	
        a.ajust_interno,          	
		a.no_unidad,
		a.fecha_reclamo,
		b.vigencia_inic,
	    b.vigencia_final,
		b.fecha_suscripcion,
		b.cod_pagador,	
		b.cod_ramo,
        b.cod_subramo,
        b.cod_contratante
   into	_no_reclamo,
        _numrecla,
        _cod_asegurado,
        _no_documento,
        _no_poliza,		
        _fecha_siniestro,	        
        _ajust_interno,       
		_no_unidad,
		_fecha_reclamo,
		_vigencia_inic,
	    _vigencia_final,
		_fecha_suscripcion,
		_cod_pagador,
		_cod_ramo,
		_cod_subramo,
		_cod_cliente
   from recrcmae a, emipomae b
  where a.no_poliza = b.no_poliza
	and b.fecha_suscripcion >= a_fecha1
	and b.fecha_suscripcion <= a_fecha2
	and a.actualizado = 1
	and b.actualizado = 1
	and a.perd_total <> 1	
	and a.fecha_siniestro between b.vigencia_inic and b.vigencia_final
	and b.cod_ramo not in ('004','016','019','018','025','008','020')  -- AccPers, Colectivo,salud,vidaInd,Microseguro y fianzas
	and b.nueva_renov = 'N' 	
	
	-- Perdidos
	select count(*)
	  into _cant_perdida
	  from recrcmae
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and perd_total <> 1	
	   and fecha_reclamo between _vigencia_inic and _vigencia_final
	   and actualizado 		= 1;	
	   
	if _cant_perdida is null then
	   let _cant_perdida = 0;
	end if
	 
	if _cant_perdida < 3 then
	   continue foreach;
	end if	 

	let _monto_pagado   = 0;
	select sum(pagos)
	  into _monto_pagado
	  from recrccob
	 where no_reclamo = _no_reclamo
	   and cod_cobertura not in ( select cod_cobertura
									   from prdcober
									   where cod_ramo = _cod_ramo
									     and (nombre like '%DA%OS%PROP%' or nombre like 'LESI%CORP%')
									);	  

	if _monto_pagado is null then
		let _monto_pagado = 0;
	end if
	
	if _monto_pagado = 0 then
		continue foreach;
	end if	
	
 	LET _dias = _fecha_siniestro - _fecha_suscripcion;
   
	foreach
		select a.nombre,a.cod_vendedor
		  into _corredor,_cod_vendedor
		  from emipoagt e, agtagent a
		 where e.cod_agente = a.cod_agente
		   and e.no_poliza = _no_poliza
		 order by porc_partic_agt desc, a.nombre asc
		exit foreach;
	end foreach
   
	select nombre
	  into _nombre_pag
	  from cliclien
	 where cod_cliente = _cod_pagador;	      
	
	select nombre, (CASE WHEN tipo_persona = "J" THEN "JURIDICO" ELSE (CASE WHEN tipo_persona = "N" THEN "NATURAL" ELSE (CASE WHEN tipo_persona = "G" THEN "GUBERNAMENTAL" ELSE "" END) END) END) tipo_persona
	  into _asegurado, _tipo_persona
	  from cliclien
	 where cod_cliente = _cod_asegurado;         	 
	
	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;			 
   
    select nombre
      into _ajustador
	  from recajust
     where cod_ajustador = _ajust_interno;        
	 
   	let _prima_suscrita = 0.00;
	let _suma_asegurada = 0.00;
	
	let _nombre_ramo = '';
	let _cod_producto = '';
	
	select nombre
	  into _nombre_ramo
	  from prdsubra
	 where cod_ramo = _cod_ramo
       and cod_subramo = _cod_subramo;	 
	
	select prima_suscrita,
	       suma_asegurada,
	       cod_producto
	  into _prima_suscrita,
	       _suma_asegurada,
		   _cod_producto
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
 		   
    
	let _cantidad_unidad = 0;
	let _nom_cliente_ben = '';
	let _no_requis = '';   
	
	select count(*)	
	  into _cantidad_unidad 
	  from emipouni 
	 where no_poliza = _no_poliza
	   and activo = 1;
	   
    
	foreach
		select no_requis
		  into _no_requis
		  from rectrmae a,rectrcon b
		 where a.no_reclamo = _no_reclamo
		   and a.no_tranrec = b.no_tranrec
		   and a.cod_tipotran = '004'  -- Pago del Reclamo
		   and a.cod_tipopago = '003'  -- Pago al Asegurado
		   and b.cod_concepto  in ('015', '044')  -- Reembolso al asegurado 
		   and a.actualizado = 1		   
		 order by a.fecha_pagado desc 
		  exit foreach;
	end foreach	   	
	
	select a_nombre_de
	  into _nom_cliente_ben
	  from chqchmae
	 where no_requis = _no_requis;		

	let _desc_sin = '';
	foreach
		select desc_transaccion
		  into _desc_transaccion
		  from recrcde2
		 where no_reclamo = _no_reclamo

		let _desc_sin = _desc_sin || _desc_transaccion;

	end foreach	

	select b.nombre
      into _canal
	  from ponderacion a, clicanal b
	 where a.cod_cliente = _cod_cliente
	   and a.cod_canal = b.cod_canal;	
 
		
	return _asegurado,
		   _no_documento,
		   _nombre_ramo,
		   _tipo_persona,
		   _numrecla,
	       _suma_asegurada,
		   _fecha_suscripcion,
		   _fecha_siniestro,
	       _monto_pagado,   
	       _corredor,
	       _nombre_vendedor,
	       _nom_cliente_ben,   -- Nombre del beneficiario del cheque o de la transferencia bancaria
	       _canal,             -- Canal
	       _desc_sin,       -- Descripción del siniestro
	       _ajustador,
    	   _prima_suscrita,
	       _nombre_pag,
           _dias,
           _cantidad_unidad,
           _no_unidad		   
	with resume;  

end foreach

END PROCEDURE;