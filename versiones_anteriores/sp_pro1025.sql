-- Reporte de Polizas Perdida Total polizas nuevas con un año o menos de vigencia por fecha de siniestro
-- Creado : 30/03/2021 - Autor: Henry Giron
-- SIS v.2.0 - d_cob_sp_pro1025_dw1 - DEIVID, S.A.  
-- execute procedure sp_pro1025('001','001','01/03/2021','01/04/2021')

drop procedure sp_pro1025;
create procedure sp_pro1025(
a_compania 		char(3),
a_agencia  		char(3),
a_fecha1 date,
a_fecha2 date)

RETURNING   
	char(20) as reclamo,
    char(10) as no_tramite,
    char(20) as poliza,
    char(5) as no_unidad, 
    VARCHAR(100) as asegurado,
    DATE as fecha_siniestro,
    DATE as fecha_cierre_reserva,
	DATE as fecha_reclamo,  -- Fecha de presentación del reclamo
	dec(16,2)	As Suma_Asegurada,    --Suma_Asegurada de la unidad afectada.
	dec(16,2)	As Monto_Pagado , --Monto Pagado 
	DATE as vigencia_inic,  -- vigencia de la poliza
	DATE as vigencia_final,
	DATE as fecha_suscripcion,  -- Fecha de emisión de la póliza
	VARCHAR(50) as marca,
    VARCHAR(50) as modelo,
	VARCHAR(50) as color, --Descripción del bien de la unidad afectada (marca, modelo, color, placa) 
	CHAR(10) as placa,
	VARCHAR(50) as corredor,
	char(50) 	As Ejecutivo,  --Ejecutivo Comercial
    dec(16,2)	As Prima,  --Prima 
	VARCHAR(100) as a_nombre_de,  --Nombre del beneficiario del cheque o de la transferencia bancaria
	char(50) As Canal,  --Canal
	VARCHAR(50) as desc_evento,   --Descripción del siniestro
    VARCHAR(50) as ajustador,
	char(50) as ajust_externo,   --Ajustador externo
	char(50) as _nombre_pag, --Nombre del pagador de la póliza 
	smallint as Dias;

				   		
DEFINE _no_reclamo     CHAR(10);
DEFINE _numrecla       CHAR(20);
DEFINE _cod_asegurado  CHAR(10);
DEFINE _no_documento   CHAR(20);
DEFINE _no_poliza	   CHAR(10); 	
DEFINE _fecha_siniestro DATE;
DEFINE _fecha_notificacion DATE;
DEFINE _ajust_interno	CHAR(3);	
DEFINE _cod_cobertura CHAR(5);
DEFINE _reserva_inicial DEC(16,2); 
DEFINE _reserva_actual  DEC(16,2); 
DEFINE _pagos           DEC(16,2);
DEFINE _cobertura       VARCHAR(50);
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final  DATE;
DEFINE _nueva_renov     char(1);
DEFINE _fecha_suscripcion DATE;
DEFINE _sucursal_origen CHAR(3);
DEFINE _cod_agente      CHAR(5);
DEFINE _corredor        VARCHAR(50);
DEFINE _asegurado       VARCHAR(100);
DEFINE _sucursal        VARCHAR(50);
DEFINE _ajustador       VARCHAR(50);
define v_filtros		VARCHAR(255);

DEFINE _no_motor        CHAR(30);
DEFINE _no_chasis       CHAR(30);
DEFINE _placa           CHAR(10);							
DEFINE _marca			VARCHAR(50);
DEFINE _modelo		    VARCHAR(50);
DEFINE _cod_marca       CHAR(5);
DEFINE _cod_modelo      CHAR(5);
DEFINE _cod_color       CHAR(5);
DEFINE _color		    VARCHAR(50);
define _ano_auto		INTEGER;
define _estatus_rec		char(1);
define _estatus_nom		char(10);
define _no_unidad		char(5);
define _cantidad		INTEGER;
define _existe		    INTEGER;

define _estatus_audiencia  smallint;
define _audiencia          char(20);
define _est_aud		       char(5);
define _ajust_externo 	   char(3);
define _ajust_nombre	   char(50);
DEFINE _cod_acreedor       char(5);
define _nombre_acreedor    char(50);
define _cod_tipopago	   char(3);
define _cod_cliente		   char(10);
define _nombre_cliente     char(50);
DEFINE _es_taller          CHAR(5);
DEFINE _user_added         CHAR(10);
DEFINE _ins_fecha          DATE;
DEFINE _monto_deducible, _monto_deducible_2 DEC(16,2); 
DEFINE _ins_suc_name       VARCHAR(50);
DEFINE _ins_suc            CHAR(3);
define _ins_tipo           smallint;		
DEFINE _es_pago_taller     CHAR(2);
DEFINE _cod_tipotran_b     CHAR(3);

DEFINE _fecha_b            DATE;
DEFINE _monto_b            DEC(16,2); 

DEFINE _fecha_001          DATE;
DEFINE _monto_001          DEC(16,2); 

DEFINE _fecha_cierre          DATE;
DEFINE _monto_011          DEC(16,2); 

DEFINE _fecha_012          DATE;
DEFINE _monto_012          DEC(16,2); 

DEFINE _fecha_002          DATE;
DEFINE _monto_002          DEC(16,2); 
DEFINE _pagado             SMALLINT;

DEFINE _cod_cliente2        CHAR(10);
DEFINE _a_nombre_de        VARCHAR(100);
DEFINE _tipo_persona       CHAR(1);
DEFINE _monto              DEC(16,2);

define _no_tramite      	char(10);
define _cod_pagador      	CHAR(10);
define _nombre_pag			varchar(50);
define _suc_prom        	char(5);
define _cod_vendedor		char(3);
define _nombre_vendedor	    char(50);
define _cod_ramo            char(3); 
define _prima_bruta			dec(16,2);
define _suma_asegurada		dec(16,2);
define _monto_pagado		dec(16,2);
define _cnt 				integer;
define _canal               char(50);
define _fecha_reclamo       date;
define _cod_evento          char(3);
define _desc_evento         varchar(50); 
define _periodo         	char(7);
define _fecha_actual		date;
define _prima   			dec(16,2);
define _dias                smallint;

let _canal = '';

let _fecha_actual = date(current);
call sp_sis39(_fecha_actual) returning _periodo;
--call sp_rec02(a_compania, a_agencia, _periodo,'*','*','*','020,002,023,024,017;','*') returning v_filtros; 

 --SET DEBUG FILE TO "sp_rec307.trc";      
 --TRACE ON;   

FOREACH
 SELECT a.no_reclamo,
        a.numrecla,
        a.cod_asegurado,
        a.no_documento,
        a.no_poliza,		
        a.fecha_siniestro,	
        a.fecha_documento,
        a.ajust_interno,
        a.no_motor,
        a.estatus_reclamo,        	
		a.no_unidad,
		a.estatus_audiencia,
		a.ajust_externo,		
		a.user_added,
		a.ins_fecha,
		a.ins_suc,
		a.ins_tipo,
		a.no_tramite,
		a.fecha_reclamo,
		a.cod_evento
   INTO	_no_reclamo,
        _numrecla,
        _cod_asegurado,
        _no_documento,
        _no_poliza,		
        _fecha_siniestro,	
        _fecha_notificacion,
        _ajust_interno,
        _no_motor,
        _estatus_rec,        
		_no_unidad,
		_estatus_audiencia,
		_ajust_externo,
		_user_added,
		_ins_fecha,
		_ins_suc,
		_ins_tipo,
        _no_tramite		,
		_fecha_reclamo,
		_cod_evento
   from recrcmae a, emipomae b
  where a.no_poliza = b.no_poliza
	and a.fecha_siniestro >= a_fecha1
	and a.fecha_siniestro <= a_fecha2
	and a.actualizado    = 1
	and b.vigencia_final - a.fecha_siniestro <= 365
	--and b.cod_ramo in ('020','002','023','024','017')  
    AND a.numrecla[1,2] in ('02','20','23','24','17')   --Auto – Casco Marítimo – Casco Aéreo (placer) 	
	--and a.estatus_reclamo = "A"
	and a.perd_total = 1		    
	and b.nueva_renov = 'N' 	
	   
    
	let _existe = 0;
	let _marca    = null;
	let _modelo   = null;
	let _color    = null;
	let _audiencia = null;
	let _cod_tipopago = null;
	let _cod_cliente = null;
	
	LET _cod_acreedor = '';
	let _est_aud = 'NO';
	let _ano_auto = 0;
	let _cantidad = 0;	
	
	let _fecha_b     = null;
	let _fecha_001   = null;
	let _fecha_cierre   = null;
	let _fecha_012   = null;	
	let _fecha_002   = null;	
	
	let _monto_b   = 0;		
	let _monto_001 = 0;
	let _monto_011 = 0;	
	let _monto_012 = 0;
	let _monto_002 = 0;		
	
	let _pagado = 0;
	
	let _reserva_inicial = 0.00;
	let _reserva_actual = 0.00;
	let _pagos = 0.00;
	let _cod_cobertura = null;
	
	let _monto_deducible = 0.00;
	let _monto_deducible_2 = 0.00;
	
	let _monto = 0.00;
	let _cod_cliente2 = null;
	let _a_nombre_de = null;
	let _tipo_persona = null;	

	{
	select count(*)
	  into _existe
	  from tmp_sinis		   
     where seleccionado = 1
	   and no_reclamo = _no_reclamo;
	   
      if _existe = 0 then
	     continue foreach;
	end if;
	}
	
	
  select nombre 
    into _desc_evento
	from recevent
   where cod_evento = _cod_evento;	
 	   
	
	FOREACH
		SELECT cod_cobertura, 
		       reserva_inicial, 
			   reserva_actual, 
			   pagos
		  INTO _cod_cobertura,
		       _reserva_inicial, 
			   _reserva_actual, 
			   _pagos
		  FROM recrccob
		 WHERE no_reclamo = _no_reclamo
		   and cod_cobertura in (select cod_cobertura from prdcober where nombre like 'ROBO%' OR nombre like 'COLI%')
	    EXIT FOREACH;
	END FOREACH
	
	SELECT nombre
	  INTO _cobertura
	  FROM prdcober
	 WHERE cod_cobertura = _cod_cobertura;
	
	SELECT vigencia_inic,
	       vigencia_final,
		   nueva_renov,
		   fecha_suscripcion,
	       sucursal_origen,
		   cod_pagador,
		   prima_bruta,	
		   cod_ramo
      INTO _vigencia_inic,
	       _vigencia_final,
		   _nueva_renov,
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
   
	select trim(nombre)
	  into _nombre_pag
	  from cliclien
	 where cod_cliente = _cod_pagador;	   
   
   SELECT nombre
     INTO _corredor 
	 FROM agtagent
	WHERE cod_agente = _cod_agente;
	
  SELECT nombre 
    INTO _asegurado
	FROM cliclien
   WHERE cod_cliente = _cod_asegurado;
   
  SELECT descripcion
    INTO _sucursal
	FROM insagen
   WHERE codigo_compania = '001'
     AND codigo_agencia = _sucursal_origen;
	 
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
   
     select cod_marca,
	        cod_modelo,
			cod_color,
			ano_auto,
			no_chasis,
			placa
	   into _cod_marca,
	        _cod_modelo,
			_cod_color,
			_ano_auto,
			_no_chasis,
			_placa			
	   from emivehic
	  where no_motor = _no_motor; 
	  
	if _ano_auto is null then
		let _ano_auto = 0;
	end if	

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
	
    if _estatus_rec = 'A' then
	  let _estatus_nom = "ABIERTO";
	elif _estatus_rec = 'C' then
	  let _estatus_nom = "CERRADO";
	elif _estatus_rec = 'R' then
	  let _estatus_nom = "RE-ABIERTO";
	elif _estatus_rec = 'T' then
	  let _estatus_nom = "EN TRAMITE";
	elif _estatus_rec = 'D' then
	  let _estatus_nom = "DECLINADO";
	else
	  let _estatus_nom = "NO APLICA";
	end if		
	 

	SELECT sum(monto)
	  INTO _monto_deducible
	   from rectrmae 
	  where cod_compania = a_compania
		and actualizado  = 1
		and no_reclamo = _no_reclamo
		and cod_tipotran = '007';	  

    if _monto_deducible is null then
		let _monto_deducible = 0;
	end if

    SELECT sum(b.monto)
      INTO _monto_deducible_2
	   from rectrmae a, rectrcon b
	  where a.no_tranrec = b.no_tranrec
	    and a.actualizado  = 1
		and a.no_reclamo = _no_reclamo
		and a.cod_tipotran <> '007'
		and b.cod_concepto = '006';	  
		
    if _monto_deducible_2 is null then
		let _monto_deducible_2 = 0;
	end if
		
	let _monto_deducible = _monto_deducible + _monto_deducible_2;
	 
	 select count(*)
	   into _cantidad
	  from recrcmae
	 where estatus_audiencia in (7,8)	   
	   and no_reclamo = _no_reclamo;
	   
	   if _cantidad is null then
			let _cantidad = 0;
	   end if
	   
	   if _cantidad = 0 then
	      let  _est_aud = 'NO';
	   elif _cantidad <> 0 then
	      let  _est_aud = 'SI';
	   end if
	   
	   let  _est_aud = _est_aud;
	   
	   if  _estatus_audiencia = 0 then 
	       LET _audiencia = 'Perdido';
	   ELIF _estatus_audiencia = 1 then 
	       LET _audiencia = 'Ganado' ;
	   ELIF _estatus_audiencia = 2 then 
	       LET _audiencia = 'Por Definir'; 
	   ELIF _estatus_audiencia = 3 then 
	       LET _audiencia = 'Proceso Penal'; 
	   ELIF  _estatus_audiencia = 4 then 
	       LET _audiencia = 'Proceso Civil'; 
	   ELIF _estatus_audiencia = 5 then 
	       LET _audiencia = 'Apelacion' ;
	   ELIF _estatus_audiencia = 6 then 
	       LET _audiencia = 'Resuelto'; 
	   ELIF _estatus_audiencia = 7 then 
	       LET _audiencia = 'FUT - Ganado';
		ELIF _estatus_audiencia = 8 then  
			let _audiencia = "FUT - Responsable";		   
	   ELse  
	       LET _audiencia = '';
	   end if	   	   
   
		let _ajust_externo = _ajust_externo;
		
	select nombre
	  into _ajust_nombre
	  from recajust
	 where cod_ajustador = _ajust_externo;		
	 
	 
	 let _cod_acreedor = _cod_acreedor;
	 let _no_poliza = _no_poliza;
	 let _no_unidad = _no_unidad;
	 
	 foreach
	  SELECT cod_acreedor
	   INTO _cod_acreedor 
	   FROM emipoacr
	  WHERE no_poliza = _no_poliza
	    AND no_unidad = _no_unidad
       exit foreach;
	    end foreach			
		
	select nombre
	  into _nombre_acreedor
	  from emiacre
	 where cod_acreedor = _cod_acreedor;
	 
    let _no_reclamo = _no_reclamo;
	let _prima = 0.00;
	let _suma_asegurada = 0.00;
	
	SELECT prima_suscrita,suma_asegurada
	  INTO _prima,_suma_asegurada
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = _no_unidad;
	 
	
	 let _nombre_cliente = '';
     let _es_taller = '0';
	 let _es_pago_taller = 'NO';
    foreach
		select cod_cliente
		  into _cod_cliente
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and cod_tipopago = '001'
		   and cod_tipotran = "004"
		   and actualizado = 1
	  order by no_tranrec desc
	  
			if _cod_cliente is null then				
			else	
				select nombre, es_taller 
				  into _nombre_cliente, _es_taller
				  from cliclien 
				 where cod_cliente = _cod_cliente;				 				 				
			end if	  	  
			 exit foreach;
	end foreach	 	
	
	if _es_taller = 1 then 
		let _es_pago_taller = 'SI';
	else
		let _es_pago_taller = 'NO';
		 let _nombre_cliente = '';
	end if
	
	let _nombre_cliente = _nombre_cliente;	 	 

	 SELECT distinct user_added
	   INTO _user_added
	   from rectrmae a
	  where no_reclamo = _no_reclamo
        and cod_tipotran = '001';
		
   foreach 
	 SELECT fecha
	   INTO _fecha_cierre
	   from rectrmae 
	  where no_reclamo = _no_reclamo
        and cod_tipotran in ('011')				 
		
		 exit foreach;
	end foreach	 	 
				
		let _ins_suc_name = '';
		
	  SELECT descripcion
		INTO _ins_suc_name
		FROM insagen
	   WHERE codigo_compania = a_compania
		 AND codigo_agencia = _ins_suc;	 	

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
		 
    if _pagado > 0 then
		foreach
			select cod_cliente 
			  into _cod_cliente2
			  from rectrmae
			 where no_reclamo = _no_reclamo
			   and cod_tipopago = '003'
			   and cod_tipotran = "004"
			   and actualizado = 1
		   exit foreach;  
		end foreach
		
		select nombre,
		       tipo_persona
		  into _a_nombre_de,
		       _tipo_persona
		  from cliclien
		 where cod_cliente = _cod_cliente2;
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
 
 {
 
   SELECT recrcde2.no_reclamo,   
         recrcde2.renglon,   
         recrcde2.desc_transaccion  
    FROM recrcde2  
   WHERE recrcde2.no_reclamo = :no_reclamo   
ORDER BY recrcde2.renglon ASC   

	RETURN _numrecla,
	       _asegurado,
		   _fecha_siniestro,
		   _fecha_notificacion,
		   _reserva_actual,
		   _reserva_inicial,
		   _no_documento,
		   _vigencia_inic,
		   _vigencia_final,
		   _nueva_renov,
		   _cobertura,
		   _sucursal,
		   _ajustador,
	       _corredor,
		   _fecha_suscripcion,
		   _marca,
		   _modelo,
		   _color,
		   _ano_auto,
		   _estatus_nom,
		   _monto_deducible,
		   _audiencia,
		   _est_aud,
		   _ajust_nombre,
		   _nombre_acreedor,
		   _ins_fecha,
		   _ins_suc_name,
		   _nombre_cliente,
		   _es_pago_taller,
		   _user_added,
		   _fecha_001,
		   _monto_001,
           _fecha_cierre,
		   _monto_011,		   
		   _fecha_012,
		   _monto_012,
           _fecha_002,
		   _monto_002,
           _no_chasis,
           _no_motor,
           _placa,
           _no_reclamo,
           CASE WHEN _pagado > 0 THEN "SI" ELSE "NO" END,
		   _monto,
           _a_nombre_de,
           CASE WHEN _tipo_persona = "J" THEN "JURIDICO" ELSE (CASE WHEN _tipo_persona = "N" THEN "NATURAL" ELSE (CASE WHEN _tipo_persona = "G" THEN "GUBERNAMENTAL" ELSE "" END) END) END
	WITH RESUME;
	}
	RETURN _numrecla,
		   _no_tramite,
		   _no_documento,
		   _no_unidad, 
	       _asegurado,
		   _fecha_siniestro,
           _fecha_cierre,
	       _fecha_reclamo,  -- Fecha de presentación del reclamo
	       _suma_asegurada, -- Suma_Asegurada de la unidad afectada.
	       _monto_pagado ,  -- Monto Pagado 
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_suscripcion,
		   _marca,
		   _modelo,
		   _color,
           _placa,
	       _corredor,
	       _nombre_vendedor,
    	   _prima,
    	   _a_nombre_de,   -- Nombre del beneficiario del cheque o de la transferencia bancaria
	       _canal,         -- Canal
	       _desc_evento,   -- Descripción del siniestro
	       _ajustador,
	       _ajust_externo, -- Ajustador externo
	       _nombre_pag     
	WITH RESUME;		   



END FOREACH
DROP TABLE tmp_sinis;
END PROCEDURE;