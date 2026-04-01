-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud36;		

create procedure "informix".sp_aud36() 
returning char(20),
		  varchar(50),
		  char(30),
		  varchar(30),
		  varchar(50),	
		  varchar(50),
		  smallint,
		  varchar(50),
		  integer,
		  dec(16,2),
		  varchar(50); 
		  		  

define _fecha			date;
define _transaccion		char(10);
define _cod_cliente		char(10);
define _monto			dec(16,2);
define _numrecla		char(20);
define _estatus_rec		char(1);
define _no_documento	char(20);
define _ajust_interno	char(3);
define _reserva			dec(16,2);
define _no_tranrec      char(10);

define _no_reclamo		char(10);
define _nom_cliente		varchar(50);
define _estatus_nom		char(10);
define _estatus_nom2	char(10);
define _ajust_nombre	varchar(50);
define _cod_tipopago    char(3);
define _fecha_pagado    date;
define _no_unidad		char(5);
define _cod_asegurado	char(10);
define _no_motor		char(30);
define _cant_uni        int;
define _es_flota        char(1);
define _edad            smallint;
define _cod_cobertura   char(5);
define _nom_cobertura   varchar(50);
define _nom_cobertura1   varchar(50);
define _nom_cobertura2   varchar(50);
define _nom_cobertura3   varchar(50);
define _nom_cobertura4   varchar(50);

define _limite_1, _limite_2 dec(16,2);
define _limite_11 dec(16,2);
define _limite_21 dec(16,2);
define _limite_12 dec(16,2);
define _limite_22 dec(16,2);
define _limite_13 dec(16,2);
define _limite_23 dec(16,2);
define _limite_14 dec(16,2);
define _limite_24 dec(16,2);

define _variacion_cob	dec(16,2);
define _variacion_cob1	dec(16,2);
define _variacion_cob2	dec(16,2);
define _variacion_cob3	dec(16,2);
define _variacion_cob4	dec(16,2);

define _cod_concepto 	char(3);
define _monto_con	    dec(16,2);
define _monto_con1	    dec(16,2);
define _monto_con2	    dec(16,2);
define _monto_con3	    dec(16,2);
define _monto_con4	    dec(16,2);

define _nom_concepto	varchar(50);
define _nom_concepto1	varchar(50);
define _nom_concepto2	varchar(50);
define _nom_concepto3	varchar(50);
define _nom_concepto4	varchar(50);

define _nom_asegurado   varchar(100);
define _direccion         varchar(50);
define _desc_transaccion  varchar(60);
define _desc_transaccion1 varchar(60);
define _desc_transaccion2 varchar(60);
define _desc_transaccion3 varchar(60);
define _desc_transaccion4 varchar(60);
define _renglon			  smallint;
define _tipo_pago_nom     varchar(50);
define _suma_asegurada    dec(16,2);
define _cant_dev		  int;
define _devolucion_prima  smallint;
define _fecha_aniversario date;
define _no_poliza         char(10);
define _no_poliza2        char(10);
define _estatus_poliza    smallint;

define _fila              smallint;

define _user_added		  char(8);
define _usuario           char(30);

define _fecha_suscripcion date; 
define _vigencia_inic, _vigencia_inic_rec, _vigencia_final_rec	  date;
define _vigencia_final	  date;
define _no_factura        char(10);
define _cod_evento        char(3);
define _causa             varchar(50);
define _fecha_siniestro	  date;
define _fecha_documento	  date;
define _pagado        	  smallint;
define _situacion         char(10);
define _cod_agente		  char(10);
define _agente            varchar(50);
define _cod_vendedor      char(3);
define _agencia			  varchar(50);
define _no_chasis 		  char(30);
define _placa 			  char(10);
define _cod_marca 		  char(5);
define _cod_modelo 		  char(5);
define _ano_auto		  smallint;
define _cod_tipoveh		  char(3);
define _uso_auto		  char(1);
define _marca			  varchar(50);
define _modelo			  varchar(50);
define _cod_tipoauto	  char(3);
define _tipo			  varchar(50);
define _tipo_veh		  varchar(50);
define _uso_veh			  char(10);
define _no_orden  		  char(10);
define _monto_pza_t		  dec(16,2);
define _monto_pza_c		  dec(16,2);
define _monto_pza_r		  dec(16,2);
define _cant_pza   		  int;
define _cant_pza_r 		  int;
define _cant_pza_c 		  int;
define _nom_proveedor  	  varchar(50);
define _nom_taller	      varchar(50);
define _nom_tercero		  varchar(50);

define _sucursal_origen   char(3);
define _sucursal          char(30);
define _tipo_ord_comp     char(1);
define _prima             dec(16,2);
define _cant_uni2         smallint;
define _monto_aseg        dec(16,2);
define _perd_total        smallint;
define _cod_taller        char(10);
define _no_parte          char(5);
define _desc_parte        varchar(50);
define _cod_provedor	  char(10);

set isolation to dirty read;

foreach 
	select no_reclamo,
	       estatus_reclamo,
	       no_documento,
		   ajust_interno,
		   no_unidad,
	       cod_asegurado,
		   no_motor,
		   suma_asegurada,
		   no_poliza,
		   cod_evento,
		   fecha_siniestro,
		   fecha_documento,
		   perd_total,
		   cod_taller
	  into _no_reclamo,
	       _estatus_rec,
	       _no_documento,
		   _ajust_interno,
		   _no_unidad,
	       _cod_asegurado,
		   _no_motor,
		   _suma_asegurada,
		   _no_poliza,
		   _cod_evento,
		   _fecha_siniestro,
		   _fecha_documento,
		   _perd_total,
		   _cod_taller
	  from recrcmae
	 where numrecla[1,2] in ("02", "20", "23")
	   and fecha_reclamo >= "01-01-2017"
	   and fecha_reclamo <= "30-04-2017"
	   and actualizado = 1

foreach
 select no_tranrec,
        cod_tipopago,
        fecha,
        transaccion,
		cod_cliente,
		monto,
		numrecla,
		no_reclamo,
		fecha_pagado,
		user_added,
		pagado
   into _no_tranrec,
        _cod_tipopago,
        _fecha,
        _transaccion,
		_cod_cliente,
		_monto,
		_numrecla,
		_no_reclamo,
		_fecha_pagado,
		_user_added,
		_pagado
   from	rectrmae
  where no_reclamo    = _no_reclamo
    and actualizado   = 1
    and cod_tipotran  = "004"
	and monto         <> 0
--    and no_requis     is not null
--	and pagado        = 1
    and anular_nt     is null
  order by fecha

    select descripcion
	  into _usuario
	  from insuser
	 where usuario = _user_added;

	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_taller;

    if _pagado = 1 then
		let _situacion = "PAGADO";
	else
		let _situacion = "PENDIENTE";
	end if
    
    select nombre
	  into _causa
	  from recevent
	 where cod_evento = _cod_evento;

    if _perd_total = 1 then
		let _causa = "PERDIDA TOTAL";
	end if

	select nombre, direccion_1, fecha_aniversario 
	  into _nom_asegurado, _direccion, _fecha_aniversario
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	let _edad = sp_sis78(_fecha_aniversario, today);

	call sp_sis21(_no_documento) returning _no_poliza2;

    foreach
		select fecha_suscripcion
		  into _fecha_suscripcion
		  from emipomae
		 where no_documento = _no_documento
		order by no_poliza

        exit foreach;
	end foreach

    select estatus_poliza, sucursal_origen, vigencia_inic, vigencia_final
	  into _estatus_poliza, _sucursal_origen, _vigencia_inic, _vigencia_final
	  from emipomae
	 where no_poliza = _no_poliza2;

    select vigencia_inic, vigencia_final, no_factura 
	  into _vigencia_inic_rec, _vigencia_final_rec, _no_factura
	  from emipomae
	 where no_poliza = _no_poliza;

    select no_chasis, placa, cod_marca, cod_modelo, ano_auto
	  into _no_chasis, _placa, _cod_marca, _cod_modelo, _ano_auto
	  from emivehic
	 where no_motor = _no_motor;

	select count(*)
	  into _cant_uni2
	  from emipouni
	 where no_poliza = _no_poliza
   	   and no_unidad = _no_unidad;

   if _cant_uni2 > 0 then
		select prima_neta
		  into _prima
		  from emipouni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
   else
    foreach
		select prima_neta
		  into _prima
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad
		order by no_endoso asc

        exit foreach;
	end foreach
   end if
	FOREACH
	    SELECT cod_tipoveh,
		       uso_auto
		  INTO _cod_tipoveh,
	           _uso_auto
		  FROM endmoaut
		 WHERE no_poliza = _no_poliza
		   AND no_unidad = _no_unidad
		ORDER BY no_endoso DESC

	  EXIT FOREACH;
       
	END FOREACH

    SELECT nombre
	  INTO _marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

    SELECT nombre,
	       cod_tipoauto
	  INTO _modelo,
	       _cod_tipoauto
	  FROM emimodel
	 WHERE cod_marca  = _cod_marca
	   AND cod_modelo = _cod_modelo;

    SELECT nombre
	  INTO _tipo
	  FROM emitiaut
	 WHERE cod_tipoauto = _cod_tipoauto;

    SELECT nombre
	  INTO _tipo_veh
	  FROM emitiveh
	 WHERE cod_tipoveh = _cod_tipoveh;

    if _uso_auto = "P" then
		LET _uso_veh = "PARTICULAR";
	else 
		LET _uso_veh = "COMERCIAL";
	end if

	select nombre
	  into _ajust_nombre
	  from recajust
	 where cod_ajustador = _ajust_interno;

	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo  = _no_reclamo
	   and actualizado = 1;

    select count(*)
	  into _cant_uni
	  from emipouni
	 where no_poliza = _no_poliza;

    if _cant_uni > 1 then
		let _es_flota = "C";
	else
		let _es_flota = "I";
	end if

    foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza2

        exit foreach;
	end foreach

    select nombre
	  into _agente
	  from agtagent
	 where cod_agente = _cod_agente;

    SELECT cod_vendedor
	  INTO _cod_vendedor
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	SELECT nombre
	  INTO _agencia    
	  FROM agtvende
	 WHERE cod_vendedor = _cod_vendedor; 

    select nombre
	  into _tipo_pago_nom
	  from rectipag
	 where cod_tipopago = _cod_tipopago;

    select descripcion
	  into _sucursal
	  from insagen
	 where codigo_agencia =	_sucursal_origen;

    let _no_orden = null;
	let _monto_pza_t = 0;
	let _monto_pza_c = 0;
	let _monto_pza_r = 0;
	let _cant_pza     = 0;
	let _cant_pza_r   = 0;
	let _cant_pza_c   = 0;
    let _nom_proveedor = null;
	let _nom_taller	= null;
	let _nom_tercero = null;
   	let _nom_taller = _nom_cliente;

    if 	_nom_taller is null then
	    foreach
		    select cod_proveedor
			  into _cod_taller
			  from recordma
			 where no_reclamo= _no_reclamo 
			   and tipo_ord_comp = "R"
			exit foreach;
		end foreach

		select nombre
		  into _nom_taller
		  from cliclien
		 where cod_cliente = _cod_taller;

	end if

    select no_orden, monto, tipo_ord_comp, cod_proveedor
	  into _no_orden, _monto_pza_t, _tipo_ord_comp, _cod_provedor
	  from recordma
	 where transaccion = _transaccion
	   and tipo_ord_comp = "C";

	if _no_orden is not null then
		select nombre
		  into _nom_proveedor
		  from cliclien
		 where cod_cliente = _cod_provedor;

	    foreach
		    select no_parte, cantidad, valor
			  into _no_parte, _cant_pza_c, _monto_pza_c 
			  from recordde
			 where no_orden = _no_orden

	        select desc_parte
			  into _desc_parte
			  from recparte
			 where no_parte = _no_parte;

			let _monto_pza_c = _monto_pza_c + (_monto_pza_c * 7 / 100);

			return _numrecla,		  --	  char(20),
				   _nom_proveedor,	  -- 	  varchar(50),
			       _sucursal,		  --      char(30),
				   _usuario,	      --	  varchar(100),
				   _marca,			  --	  varchar(50),	
				   _modelo,			  --      varchar(50),
				   _ano_auto,		  --      smallint,
				   _desc_parte,		  --	  varchar(50),
				   _cant_pza_c,       --      integer,
			       _monto_pza_c,	  --      dec(16,2),
				   _nom_taller        -- 	  varchar(50);   
			   with resume;
		 end foreach
	end if
	 


end foreach
end foreach
end procedure

