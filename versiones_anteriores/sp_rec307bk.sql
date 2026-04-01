-- Procedimiento PERDIDAS TOTALES ENVIADO A AMADO PEREZ EL DIA DE AYER,  ESTE VEZ SACANDO SOLO LAS PERDIDAS TOTALES PENDIENTES A LA FECHA DE HOY
-- Creado : 07/02/2020 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.

{
ya1.	Marca del vehículo
ya2.	Modelo del vehículo
ya3.	Color del vehículo
ya4.	Año del vehículo
ya5.	Estatus del reclamo
ya6.	Monto de deducible cobrado
ya7.	Estatus de audiencia
ya8.	Si tiene formato único
ya9.	Ajustador externo
ya10.	Acreedor hipotecario
11.	Fecha de inspección realizada al vehículo
12.	Por quien fue realiza la inspección (usuario, sucursal, corredor)
ya13.	Taller asignado para la custodia (si tiene pagos a taller detallar)
ya14.	Usuario que adiciono la reserva inicial 
ya15.	Adicional el siguiente esquema de columnas:
}

DROP PROCEDURE sp_rec307;
CREATE PROCEDURE informix.sp_rec307(
a_compania	char(3),
a_agencia	char(3),
a_periodo	char(7),
a_cod_ramo	varchar(255)	default '*')
RETURNING   CHAR(20) as reclamo,
			VARCHAR(100) as asegurado,
			DATE as fecha_siniestro,
			DATE as fecha_notificacion,
			DECIMAL(16,2) as reserva_actual,
			DECIMAL(16,2) as reserva_inicial,
			CHAR(20) as poliza,
			DATE as vigencia_inic,
			DATE as vigencia_final,
			CHAR(1) as nueva_renovada,
			VARCHAR(50) as cobertura,
			VARCHAR(50) as sucursal,
			VARCHAR(50) as ajustador,
			VARCHAR(50) as corredor,
			DATE as fecha_suscripcion,
			VARCHAR(50) as marca,
            VARCHAR(50) as modelo,
			VARCHAR(50) as color,
            INTEGER as year_auto,
			char(10) as estatus_nom,
			DEC(16,2) as monto_deducible,
			char(20) as est_audiencia, 
            char(5) as formato_unico,
			char(50) as ajust_externo,
            char(50) as n_acreedor_hip,
			DATE as ins_fecha,
			VARCHAR(50) as ins_suc_name,
			char(50) as nombre_taller,
			char(2) as _es_pago_taller,
			CHAR(10) as user_added, 
			date as fecha_001,
			dec(16,2) as monto_001,
			date as fecha_011,
			dec(16,2) as monto_011,			
			date as fecha_012,
			dec(16,2) as monto_012,
			date as fecha_002,
			dec(16,2) as monto_002,
			CHAR(30) as no_chasis,
            CHAR(30) as no_motor,
            CHAR(10) as placa;			
				   		
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
DEFINE _monto_deducible    DEC(16,2); 
DEFINE _ins_suc_name       VARCHAR(50);
DEFINE _ins_suc            CHAR(3);
define _ins_tipo           smallint;		
DEFINE _es_pago_taller     CHAR(2);

DEFINE _fecha_001          DATE;
DEFINE _monto_001          DEC(16,2); 

DEFINE _fecha_011          DATE;
DEFINE _monto_011          DEC(16,2); 

DEFINE _fecha_012          DATE;
DEFINE _monto_012          DEC(16,2); 

DEFINE _fecha_002          DATE;
DEFINE _monto_002          DEC(16,2); 

call sp_rec02(a_compania, a_agencia, a_periodo,'*','*','*',a_cod_ramo,'*') returning v_filtros; 

 --SET DEBUG FILE TO "sp_rec307.trc";      
 --TRACE ON;   

FOREACH
 SELECT no_reclamo,
        numrecla,
        cod_asegurado,
        no_documento,
        no_poliza,		
        fecha_siniestro,	
        fecha_documento,
        ajust_interno,
        no_motor,
        estatus_reclamo,        	
		no_unidad,
		estatus_audiencia,
		ajust_externo,
		user_added,
		ins_fecha,
		ins_suc,
		ins_tipo
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
		_ins_tipo
   FROM recrcmae
  WHERE  perd_total = 1	
    --AND fecha_reclamo >= '01/01/2019'
    --AND fecha_reclamo <= '31/12/2019'
    
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
	
	select count(*)
	  into _existe
	  from tmp_sinis		   
     where seleccionado = 1
	   and no_reclamo = _no_reclamo;
	   
      if _existe = 0 then
	     continue foreach;
	end if;
 	   
	
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
	       sucursal_origen
      INTO _vigencia_inic,
	       _vigencia_final,
		   _nueva_renov,
		   _fecha_suscripcion,
	       _sucursal_origen
      FROM emipomae
     WHERE no_poliza = _no_poliza;
   
   FOREACH
	SELECT cod_agente
	  INTO _cod_agente
	  FROM emipoagt
	 WHERE no_poliza = _no_poliza	 
	EXIT FOREACH;
   END FOREACH
   
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
	 

  --********  está de más la tabla recrcmae ****	 
	SELECT sum(a.monto)
	  INTO _monto_deducible
	   from rectrmae a, recrcmae b
	  where a.cod_compania = a_compania
		and a.actualizado  = 1
        and a.no_reclamo = b.no_reclamo
        and a.numrecla = b.numrecla
		and a.no_reclamo = _no_reclamo
		and a.cod_tipotran = '007'	    	 
	 
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
	   
		if _estatus_audiencia = 7 then  
			let _audiencia = "FUT - Ganado";
		elif _estatus_audiencia = 8 then  
			let _audiencia = "FUT - Responsable";
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
	 
	foreach 
	-- ****** la tabla recrcmae esta de mas
	-- Esto  no es lo que te había explicado
	SELECT a.cod_tipopago
	  INTO _cod_tipopago
	   from rectrmae a, recrcmae b
	  where a.cod_compania = a_compania
		and a.actualizado  = 1
        and a.no_reclamo = b.no_reclamo
        and a.numrecla = b.numrecla
		and a.no_reclamo = _no_reclamo
		and a.cod_tipotran = '004'	
	 --having sum(a.variacion) > 0
	  order by no_tranrec desc
	  exit foreach;
	end foreach	 	 
	let _cod_tipopago = _cod_tipopago;
	 let _nombre_cliente = '';
    foreach
		select cod_cliente
		  into _cod_cliente
		  from rectrmae
		 where no_reclamo = _no_reclamo
		   and cod_tipopago = _cod_tipopago
		   and cod_tipotran = "004"
		   and actualizado = 1
	  order by no_tranrec desc
	  
			if _cod_cliente is null then
				
				let _es_taller = '0';
				let _es_pago_taller = 'NO';
			else	
				select nombre, es_taller 
				  into _nombre_cliente, _es_taller
				  from cliclien 
				 where cod_cliente = _cod_cliente;
				 let _es_pago_taller = 'SI';
				
			end if	  	  
			 exit foreach;
	end foreach	 	
	
	let _nombre_cliente = _nombre_cliente;
	 
	 
   foreach 
	 SELECT b.user_added
	   INTO _user_added
	   from rectrmae a, recrcmae b
	  where a.cod_compania = a_compania
		and a.actualizado  = 1
        and a.no_reclamo = b.no_reclamo
        and a.numrecla = b.numrecla
		and a.no_reclamo = _no_reclamo
        and a.cod_tipotran = '001'			 

	   exit foreach;
	    end foreach	 

   foreach 
	 SELECT min(a.fecha),sum(a.monto)
	   INTO _fecha_001,_monto_001
	   from rectrmae a, recrcmae b
	  where a.cod_compania = a_compania
		and a.actualizado  = 1
        and a.no_reclamo = b.no_reclamo
        and a.numrecla = b.numrecla
		and a.no_reclamo = _no_reclamo
        and a.cod_tipotran = '001'			 

	   --exit foreach;
	    end foreach	 	 
		
   foreach 
	 SELECT min(a.fecha),sum(a.monto)
	   INTO _fecha_011,_monto_011
	   from rectrmae a, recrcmae b
	  where a.cod_compania = a_compania
		and a.actualizado  = 1
        and a.no_reclamo = b.no_reclamo
        and a.numrecla = b.numrecla
		and a.no_reclamo = _no_reclamo
        and a.cod_tipotran = '011'			 

	   exit foreach;
	    end foreach	 		

   foreach 
	 SELECT min(a.fecha),sum(a.monto)
	   INTO _fecha_012,_monto_012
	   from rectrmae a, recrcmae b
	  where a.cod_compania = a_compania
		and a.actualizado  = 1
        and a.no_reclamo = b.no_reclamo
        and a.numrecla = b.numrecla
		and a.no_reclamo = _no_reclamo
        and a.cod_tipotran = '012'			 

	   exit foreach;
	    end foreach	 

   foreach 
	 SELECT min(a.fecha),sum(a.monto)
	   INTO _fecha_002,_monto_002
	   from rectrmae a, recrcmae b
	  where a.cod_compania = a_compania
		and a.actualizado  = 1
        and a.no_reclamo = b.no_reclamo
        and a.numrecla = b.numrecla
		and a.no_reclamo = _no_reclamo
        and a.cod_tipotran = '002'			 

	   exit foreach;
	    end foreach	 	
		
		let _ins_suc_name = '';
		
	  SELECT descripcion
		INTO _ins_suc_name
		FROM insagen
	   WHERE codigo_compania = a_compania
		 AND codigo_agencia = _ins_suc;	 		
 
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
           _fecha_011,
		   _monto_011,		   
		   _fecha_012,
		   _monto_012,
           _fecha_002,
		   _monto_002,
           _no_chasis,
           _no_motor,
           _placa		   
	WITH RESUME;

END FOREACH
DROP TABLE tmp_sinis;
END PROCEDURE;