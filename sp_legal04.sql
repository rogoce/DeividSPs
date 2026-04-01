-- Reporte de Polizas Perdida Total polizas nuevas con un año o menos de vigencia por fecha de siniestro
-- Creado : 30/03/2021 - Autor: Henry Giron
-- SIS v.2.0 - d_cob_sp_legal04_dw1 - DEIVID, S.A.  
-- execute procedure sp_legal04('001','001','01/03/2021','01/04/2021')

drop procedure sp_legal04;
create procedure sp_legal04(
a_compania char(3),
a_agencia  char(3),
a_fecha1   date,
a_fecha2   date)

returning   
	char(20) as reclamo,
    char(10) as no_tramite,
    char(20) as poliza,
    char(5) as no_unidad,
	char(10) as cod_cliente,
    varchar(100) as asegurado,
    DATE as fecha_siniestro,
    DATE as fecha_cierre,
	DATE as fecha_reclamo,  
	dec(16,2) as Suma_Asegurada,  
	dec(16,2) as Monto_Pagado, 
	DATE as vigencia_inic,  
	DATE as vigencia_final,
	DATE as Fecha_emision_pol, 
	varchar(50) as marca,
    varchar(50) as modelo,
	varchar(50) as color, 
	char(10) as placa,
	varchar(50) as corredor,
	char(50) as Ejecutivo_comercial,  
    dec(16,2) as prima_suscrita,   
	varchar(100) as Beneficiario_chq,   
	char(50) as Canal, 
	varchar(255) as desc_siniestro,  
    varchar(50) as ajustador_interno,
	char(50) as ajustador_externo,   
	char(50) as Nombre_pagador, 
	smallint as Dias;

				   		
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
define _corredor        	varchar(50);
define _asegurado       	varchar(100);
define _ajustador       	varchar(50);
define _ajust_nombre		char(50);
define _no_motor        	char(30);
define _placa           	char(10);							
define _marca				varchar(50);
define _modelo		    	varchar(50);
define _cod_marca       	char(5);
define _cod_modelo      	char(5);
define _cod_color       	char(5);
define _color		    	varchar(50);
define _no_unidad			char(5);
define _cantidad			integer;
define _cod_cliente		    char(10);
define _fecha_cierre    	date;
define _nom_cliente_ben     varchar(100);
define _ajust_externo 	    char(3);
define _no_tramite      	char(10);
define _cod_pagador      	char(10);
define _nombre_pag			varchar(50);
define _cod_vendedor		char(3);
define _nombre_vendedor	    char(50);
define _prima_suscrita		dec(16,2);
define _suma_asegurada		dec(16,2);
define _monto_pagado		dec(16,2);
define _canal               char(50);
define _fecha_reclamo       date;
define _prima   			dec(16,2);
define _dias                smallint;
define _transaccion		    char(10);
define _no_requis		    char(10);  
define _desc_sin            varchar(255);
define _desc_transaccion    varchar(60);
define _no_endoso_ori       char(5);     

let _canal = '';

 --SET DEBUG FILE TO "sp_pro1025.trc";      
 --TRACE ON;   

foreach
	 select a.no_reclamo,
			a.numrecla,
			a.cod_asegurado,
			a.no_documento,
			a.no_poliza,		
			a.fecha_siniestro,	
			a.ajust_interno,
			a.no_motor,       	
			a.no_unidad,
			a.ajust_externo,	
			a.no_tramite,
			a.fecha_reclamo,
			b.vigencia_inic,
	        b.vigencia_final,
		    b.fecha_suscripcion,
		    b.cod_pagador,
		    b.cod_contratante
	   into	_no_reclamo,
			_numrecla,
			_cod_asegurado,
			_no_documento,
			_no_poliza,		
			_fecha_siniestro,	        
			_ajust_interno,
			_no_motor,        
			_no_unidad,
			_ajust_externo,
			_no_tramite,
			_fecha_reclamo,
			_vigencia_inic,
	        _vigencia_final,
		    _fecha_suscripcion,
		    _cod_pagador,
		    _cod_cliente
	   from recrcmae a, emipomae b
	  where a.no_poliza = b.no_poliza
		and a.fecha_siniestro between  a_fecha1 and a_fecha2
		and a.actualizado    = 1
		and b.actualizado    = 1	 
		and a.perd_total = 1		    
		and b.nueva_renov = 'N' 	
		and a.estatus_reclamo in ( 'A','C')	   
    
	let _marca    = null;
	let _modelo   = null;
	let _color    = null;
	let _cantidad = 0;			
    let _monto_pagado = 0;	
 
    select count(*),sum(pagos)
	  into _cantidad,_monto_pagado
	  from recrccob
	 where no_reclamo = _no_reclamo
	   and cod_cobertura in (
	select cod_cobertura
	  from prdcober
	 where cod_cober_reas in ('031','034'));
	 
    if _cantidad is null then
		 let _cantidad = 0;
	end if
	if _cantidad > 0 then
	else
	  continue foreach;
	end if         	   		   

	
	 
	LET _dias = _fecha_siniestro - _fecha_suscripcion;   
   
    --Sacar el corredor
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

    select nombre 
      into _asegurado
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
   
	select cod_marca,
		   cod_modelo,
		   cod_color,
		   placa
	  into _cod_marca,
		   _cod_modelo,
		   _cod_color,
		   _placa			
	  from emivehic
	 where no_motor = _no_motor; 
	  
	if _cod_marca is null then
		let _cod_marca = "";
	else
		select nombre
		  into _marca
		  from emimarca
		 where cod_marca = _cod_marca;
	end if

	if _cod_modelo is null then
		let _cod_modelo = "";
	else
		select nombre
		  into _modelo
		  from emimodel
		 where cod_marca  = _cod_marca
		   and cod_modelo = _cod_modelo;
	end if
	
	if _cod_color is null then
		let _cod_color = "";
	else
		select nombre
		  into _color
		  from emicolor
		 where cod_color  = _cod_color;
	end if	

	select nombre
	  into _ajust_nombre
	  from recajust
	 where cod_ajustador = _ajust_externo;		
	 
   	let _prima_suscrita = 0.00;
	let _suma_asegurada = 0.00;
	{
	select prima_suscrita,suma_asegurada
	  into _prima_suscrita,_suma_asegurada
	  from emipouni
	 where no_poliza = _no_poliza
	   AND no_unidad = _no_unidad;		   
    }

		  select min(no_endoso)
			into _no_endoso_ori 
			from endeduni
			where no_poliza = _no_poliza
			and no_unidad   = _no_unidad;

	      SELECT suma_asegurada,
		         prima_suscrita
	        INTO _suma_asegurada,
			     _prima_suscrita
	        FROM endeduni
	       WHERE no_poliza = _no_poliza
		     AND no_unidad = _no_unidad
		     AND no_endoso = _no_endoso_ori;
			 
	let _nom_cliente_ben = '';
	let _no_requis = '';	   

	foreach
		select no_requis
		  into _no_requis
		  from rectrmae a,rectrcon b
		 where a.no_reclamo = _no_reclamo
		   and a.no_tranrec = b.no_tranrec
		   and a.cod_tipopago = '003'  -- Pago al Asegurado
		   and a.cod_tipotran = '004'  -- Pago del Reclamo
		   and b.cod_concepto  in ('015', '044') -- Reembolso al asegurado
		   and a.actualizado = 1		   
		 order by a.fecha_pagado desc 
		  exit foreach;
	end foreach	   	 
	
	select a_nombre_de
	  into _nom_cliente_ben
	  from chqchmae
	 where no_requis = _no_requis;	
	
	let _fecha_cierre   = null;	
   foreach 
		select fecha
		  into _fecha_cierre
		  from rectrmae 
		 where no_reclamo = _no_reclamo
		   and cod_tipotran in ('011')				 		
	      exit foreach;
	end foreach	 		
	
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
 
	return _numrecla,
		   _no_tramite,
		   _no_documento,
		   _no_unidad,
		   _cod_asegurado,
	       _asegurado,
		   _fecha_siniestro,
           _fecha_cierre,
	       _fecha_reclamo,  
	       _suma_asegurada, 
	       _monto_pagado ,  
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_suscripcion,
		   _marca,
		   _modelo,
		   _color,
           _placa,
	       _corredor,
	       _nombre_vendedor,
    	   _prima_suscrita,
    	   _nom_cliente_ben,   
	       _canal,         
	       _desc_sin,   
	       _ajustador,
	       _ajust_externo, 
	       _nombre_pag,
           _dias		   
	with resume;		   
END foreach
END PROCEDURE;