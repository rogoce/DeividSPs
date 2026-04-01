-- Reporte de Polizas Perdida Total polizas nuevas con un año o menos de vigencia por fecha de siniestro
-- Creado : 30/03/2021 - Autor: Henry Giron
-- SIS v.2.0 - d_cob_sp_pro1026_dw1 - DEIVID, S.A.  
-- execute procedure sp_pro1026('001','001','01/03/2021','01/04/2021')

drop procedure sp_pro1026;
create procedure sp_pro1026(
a_compania 		char(3),
a_agencia  		char(3),
a_fecha1 date,
a_fecha2 date)

RETURNING  
    VARCHAR(100) as asegurado,
    char(20) as poliza,
    char(50) as Nombre_Producto,
    VARCHAR(50) as tipo_persona,
	char(20) as reclamo,
	dec(16,2)	As Suma_Asegurada,
	DATE as fecha_suscripcion,  -- Fecha de emisión de la póliza
    DATE as fecha_siniestro,
	dec(16,2)	As Monto_Pagado , --Monto Pagado 
	VARCHAR(50) as corredor,
	char(50) 	As Ejecutivo,  --Ejecutivo Comercial
	VARCHAR(100) as nom_cliente_ben,  --Nombre del beneficiario del cheque o de la transferencia bancaria
	char(50) As Canal,  --Canal
	VARCHAR(50) as desc_evento,   --Descripción del siniestro
    VARCHAR(50) as ajustador,
    dec(16,2)	As Prima,  --Prima 
	char(50) as _nombre_pag, --Nombre del pagador de la póliza 
	smallint as Dias;

				   		
define  _no_reclamo      	char(10);
define  _numrecla       	char(20);
define  _cod_asegurado  	char(10);
define  _no_documento   	char(20);
define  _no_poliza	   		char(10); 	
define  _fecha_siniestro   	date;
define  _fecha_suscripcion 	date;
define  _ajust_interno		char(3);	
define  _cobertura       	varchar(50);
define  _vigencia_inic   	date;
define  _vigencia_final  	date;
define  _sucursal_origen 	char(3);
define  _cod_agente      	char(5);
define  _corredor        	varchar(50);
define  _asegurado       	varchar(100);
define  _sucursal        	varchar(50);
define  _ajustador       	varchar(50);
define  v_filtros			varchar(255);
define  _ajust_nombre		char(50);
define  _no_motor        	char(30);
define  _no_chasis       	char(30);
define  _placa           	char(10);							
define  _marca				varchar(50);
define  _modelo		    	varchar(50);
define  _cod_marca       	char(5);
define  _cod_modelo      	char(5);
define  _cod_color       	char(5);
define  _color		    	varchar(50);
define  _ano_auto			integer;
define  _estatus_rec		char(1);
define  _estatus_nom		char(10);
define  _no_unidad			char(5);
define  _cantidad			integer;
define  _cod_cliente		char(10);
define  _fecha_cierre    	date;
define  _nom_cliente_ben    varchar(100);
define  _ajust_externo 	    char(3);
define  _pagado             smallint;
define  _no_tramite      	char(10);
define  _cod_pagador      	char(10);
define  _nombre_pag			varchar(50);
define  _suc_prom        	char(5);
define  _cod_vendedor		char(3);
define  _nombre_vendedor	char(50);
define  _cod_ramo           char(3); 
define  _prima_bruta		dec(16,2);
define  _suma_asegurada		dec(16,2);
define  _monto_pagado		dec(16,2);
define  _cnt 				integer;
define  _canal              char(50);
define  _fecha_reclamo      date;
define  _cod_evento         char(3);
define  _desc_evento        varchar(50); 
define  _periodo         	char(7);
define  _fecha_actual		date;
define  _prima   			dec(16,2);
define  _dias               smallint;
define  _tipo_persona       varchar(50); 
define  _cod_producto       CHAR(5);
define  _nombre_producto    char(50);

let _canal = '';

 --SET DEBUG FILE TO "sp_pro1026.trc";      
 --TRACE ON;   

FOREACH
 SELECT a.no_reclamo,
        a.numrecla,
        a.cod_asegurado,
        a.no_documento,
        a.no_poliza,		
        a.fecha_siniestro,	
        a.ajust_interno,
        a.no_motor,
        a.estatus_reclamo,        	
		a.no_unidad,
		a.fecha_reclamo,
		a.cod_evento
   INTO	_no_reclamo,
        _numrecla,
        _cod_asegurado,
        _no_documento,
        _no_poliza,		
        _fecha_siniestro,	        
        _ajust_interno,
        _no_motor,
        _estatus_rec,        
		_no_unidad,
		_fecha_reclamo,
		_cod_evento
   from recrcmae a, emipomae b
  where a.no_poliza = b.no_poliza
	and a.fecha_siniestro >= a_fecha1
	and a.fecha_siniestro <= a_fecha2
	and a.actualizado    = 1
	and b.vigencia_inic - a.fecha_siniestro <= 365	
    AND a.numrecla[1,2] not in ('04','16','19','18','25')   -- AccPers, Colectivo,salud,vidaInd,Microseguro				
	and b.nueva_renov = 'N' 	
	 
    
	let _marca    = null;
	let _modelo   = null;
	let _color    = null;
	let _cantidad = 0;	
	let _fecha_cierre   = null;
	let _pagado = 0;
	let _cod_cliente = null;
	let _nom_cliente_ben = null;		
  
  select count(*)
    into _cantidad
	from recrccob
   where no_reclamo = _no_reclamo
     and cod_cobertura in (select cod_cobertura from prdcober where nombre like 'DAÑOS%');
	 
      if _cantidad = 0 or _cantidad is null then
	     continue foreach;
	end if;	 
	   	
	
  select nombre 
    into _desc_evento
	from recevent
   where cod_evento = _cod_evento;	
 	   

	SELECT vigencia_inic,
	       vigencia_final,
		   fecha_suscripcion,
	       sucursal_origen,
		   cod_pagador,
		   prima_bruta,	
		   cod_ramo
      INTO _vigencia_inic,
	       _vigencia_final,
		   _fecha_suscripcion,
	       _sucursal_origen,
		   _cod_pagador,
		   _prima_bruta,
		   _cod_ramo
      FROM emipomae
     WHERE no_poliza = _no_poliza;
	 
	 	LET _dias = _fecha_siniestro - _fecha_suscripcion;
   
   FOREACH
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza	 
	EXIT FOREACH;
   END FOREACH
   
	select nombre
	  into _nombre_pag
	  from cliclien
	 where cod_cliente = _cod_pagador;	   
   
   SELECT nombre
     INTO _corredor 
	 FROM agtagent
	WHERE cod_agente = _cod_agente;
	
  SELECT nombre, (CASE WHEN tipo_persona = "J" THEN "JURIDICO" ELSE (CASE WHEN tipo_persona = "N" THEN "NATURAL" ELSE (CASE WHEN tipo_persona = "G" THEN "GUBERNAMENTAL" ELSE "" END) END) END) tipo_persona
    INTO _asegurado, _tipo_persona
	FROM cliclien
   WHERE cod_cliente = _cod_asegurado;         
	 
	select sucursal_promotoria
	  into _suc_prom
	  from insagen
	 where codigo_agencia  = _sucursal_origen
	   and codigo_compania = '001';  

   select cod_vendedor
	 into _cod_vendedor
	 from parpromo
	where cod_agente  = _cod_agente
	  and cod_agencia = _suc_prom
	  and cod_ramo	   = _cod_ramo;
	
	select nombre
	  into _nombre_vendedor
	  from agtvende
	 where cod_vendedor = _cod_vendedor;			 
   
  SELECT nombre
    INTO _ajustador
	FROM recajust
   WHERE cod_ajustador = _ajust_interno;        
	 
   	let _prima = 0.00;
	let _suma_asegurada = 0.00;
	let _cod_producto = '';
	
	SELECT prima_suscrita,
	       suma_asegurada,
	       cod_producto
	  INTO _prima,
	       _suma_asegurada,
		   _cod_producto
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad;	 
	   
	select nombre
	  into _nombre_producto	  
	  from prdprod
	 where cod_producto = _cod_producto;	 

	if _nombre_producto is null then
	    let _nombre_producto = '';
	 end if	 	   		   

   -- pagado	
	select count(*), 
	       sum(monto)
	  into _pagado,
	       _monto_pagado
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and cod_tipopago = '003'
	   and cod_tipotran = "004"
	   and actualizado = 1;   
	   
		if _monto_pagado is null then
			let _monto_pagado = 0.00;
		end if	   
		if _pagado is null then
			let _pagado = 0;
		end if			
		 
    if _pagado > 0 then
		foreach
			select cod_cliente 
			  into _cod_cliente
			  from rectrmae
			 where no_reclamo = _no_reclamo
			   and cod_tipopago = '003'
			   and cod_tipotran = "004"
			   and actualizado = 1
		   exit foreach;  
		end foreach
		
		select nombre
		  into _nom_cliente_ben
		  from cliclien
		 where cod_cliente = _cod_cliente;
	end if	
	
	let _cnt = 0;	
	select count(*)
	  into _cnt
	  from agtagent
	 where cod_agente = _cod_agente
	   and no_licencia[1,3] = 'OAL'; 	  
	 
		if _cnt is null then
			let _cnt = 0;
		end if
		
		if _cnt > 0 then 
			let _canal = 'BAC INTERNATIONAL BANK INC.';
	   else
	   	    let _canal = _corredor;
		end if			
		
	RETURN _asegurado,
		   _no_documento,
		   _nombre_producto,
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
	       _desc_evento,       -- Descripción del siniestro
	       _ajustador,
    	   _prima,
	       _nombre_pag,
           _dias		 		
	WITH RESUME;  

END FOREACH

END PROCEDURE;