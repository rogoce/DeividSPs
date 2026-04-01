-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud33;		

create procedure "informix".sp_aud33(a_periodo1 char(7), a_periodo2 char(7)) 
returning char(20),char(20),varchar(100),varchar(50),char(10),dec(16,2),char(10),char(10),varchar(50),dec(16,2),smallint,integer,varchar(50),smallint,char(30),
          char(5),dec(16,2),varchar(50),dec(16,2),dec(16,2),varchar(50),dec(16,2),dec(16,2),varchar(50),dec(16,2),dec(16,2),varchar(50),dec(16,2),dec(16,2),
          varchar(50),dec(16,2),varchar(50),dec(16,2),varchar(50),dec(16,2),varchar(50),dec(16,2),varchar(60),varchar(60),varchar(60),varchar(60),date,smallint,
          varchar(50),char(30),varchar(50),char(2),char(5),varchar(50),date,date,date,date,varchar(30),varchar(75),char(10),varchar(50);
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
define _es_flota        smallint;
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

define _nom_asegurado     varchar(100);
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
define _cod_taller        char(10);
define _perd_total		  smallint;
define _estatus_poliza    smallint;
define _cod_agente        char(5);
define _n_taller          varchar(50);
define _n_agente          varchar(50);
define _perdida           char(2);
define _fecha_susc        date;
define _vigencia_inic     date;
define _vigencia_final    date;
define _fecha_siniestro   date;
define _cedula            varchar(30);
define _cod_formapag      char(3);
define _n_formapag        varchar(50);
define _n_pagador         varchar(75);
define _cod_pagador       char(10);
define _fila              smallint;
define _user_added		  char(8);
define _usuario           char(30);

set isolation to dirty read;

let _perd_total = 0;
let _cod_taller = "";
let _n_taller   = "";
let	_n_agente	= "";

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
		user_added
   into _no_tranrec,
        _cod_tipopago,
        _fecha,
        _transaccion,
		_cod_cliente,
		_monto,
		_numrecla,
		_no_reclamo,
		_fecha_pagado,
		_user_added
   from	rectrmae
  where actualizado   = 1
    and cod_tipotran  = "004"
	and monto         <> 0
    and numrecla[1,2] in ("02", "20")
    and no_requis     is not null
	and pagado        = 1
    and anular_nt     is null
	and periodo       >= a_periodo1
	and periodo       <= a_periodo2
  order by fecha

    select descripcion
	  into _usuario
	  from insuser
	 where usuario = _user_added;

	select nombre,cedula
	  into _nom_cliente,_cedula
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select estatus_reclamo,
	       no_documento,
		   ajust_interno,
		   no_unidad,
	       cod_asegurado,
		   no_motor,
		   suma_asegurada,
		   no_poliza,
		   cod_taller,
		   perd_total,
		   fecha_siniestro
	  into _estatus_rec,
	       _no_documento,
		   _ajust_interno,
		   _no_unidad,
	       _cod_asegurado,
		   _no_motor,
		   _suma_asegurada,
		   _no_poliza,
		   _cod_taller,
		   _perd_total,
		   _fecha_siniestro
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select nombre, direccion_1, fecha_aniversario 
	  into _nom_asegurado, _direccion, _fecha_aniversario
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	let _edad = sp_sis78(_fecha_aniversario, today);

	call sp_sis21(_no_documento) returning _no_poliza2;

    select estatus_poliza,
		   fecha_suscripcion,
		   vigencia_inic, 
		   vigencia_final,
		   cod_formapag,
		   cod_pagador
	  into _estatus_poliza,
		   _fecha_susc,    
		   _vigencia_inic, 
		   _vigencia_final,
		   _cod_formapag,
		   _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza2;

    select nombre into _n_formapag from cobforpa where cod_formapag = _cod_formapag;

	let _n_pagador = '';

	select nombre
	  into _n_pagador
	  from cliclien
	 where cod_cliente = _cod_pagador;

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

    if _estatus_poliza = 1 then
	  let _estatus_nom2 = "VIGENTE";
	elif _estatus_poliza = 2 then
	  let _estatus_nom2 = "CANCELADA";
	elif _estatus_poliza = 3 then
	  let _estatus_nom2 = "VENCIDA";
	elif _estatus_poliza = 4 then
	  let _estatus_nom2 = "ANULADA";
	else
	  let _estatus_nom2 = "NO APLICA";
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
		let _es_flota = 1;
	else
		let _es_flota = 0;
	end if

	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

       exit foreach;

	end foreach

	select nombre
	  into _n_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into _n_taller
	  from cliclien
	 where cod_cliente = _cod_taller;


	let _fila = 1;
	let _nom_cobertura1 = null;
	let _variacion_cob1 = null;
	let _nom_cobertura2	= null;
	let _variacion_cob2	= null;
	let _nom_cobertura3	= null;
	let _variacion_cob3	= null;
	let _nom_cobertura4 = null;
	let _variacion_cob4 = null;
	let _limite_11      = null;
	let _limite_21      = null;
	let _limite_12      = null;
	let _limite_22      = null;
	let _limite_13      = null;
	let _limite_23      = null;
	let _limite_14      = null;
	let _limite_24      = null;

    foreach
	    select cod_cobertura, monto
		  into _cod_cobertura, _variacion_cob
		  from rectrcob
		 where no_tranrec = _no_tranrec
		   and monto <> 0

	    select nombre
		  into _nom_cobertura
		  from prdcober
		 where cod_cobertura = _cod_cobertura;

        foreach
		    select limite_1, limite_2
			  into _limite_1, _limite_2
			  from endedcob
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			   and cod_cobertura = _cod_cobertura

	        exit foreach;
		end foreach

        if _fila = 1 then
			let _nom_cobertura1 = _nom_cobertura;
			let _variacion_cob1 = _variacion_cob;
			let _limite_11      = _limite_1;
			let _limite_21      = _limite_2;
        elif _fila = 2 then                                                                      
			let _nom_cobertura2 = _nom_cobertura;
			let _variacion_cob2 = _variacion_cob;
			let _limite_12      = _limite_1;
			let _limite_22      = _limite_2;
        elif _fila = 3 then                                                                      
			let _nom_cobertura3 = _nom_cobertura;
			let _variacion_cob3 = _variacion_cob;
			let _limite_13      = _limite_1;
			let _limite_23      = _limite_2;
        elif _fila = 4 then                                                                      
			let _nom_cobertura4 = _nom_cobertura;
			let _variacion_cob4 = _variacion_cob;
			let _limite_14      = _limite_1;
			let _limite_24      = _limite_2;
		end if

		let _fila = _fila + 1;
       
	end foreach

	let _fila = 1;
	let _nom_concepto1 = null;
	let _monto_con1 = 	 null;
	let _nom_concepto2 = null;
	let _monto_con2 = 	 null;
	let _nom_concepto3 = null;
	let _monto_con3 = 	 null;
	let _nom_concepto4 = null;
	let _monto_con4 = 	 null;

    foreach
	    select cod_concepto, monto
		  into _cod_concepto, _monto_con
		  from rectrcon
		 where no_tranrec = _no_tranrec
		 --  and monto > 0

	   	select nombre
		  into _nom_concepto
	      from recconce
		 where cod_concepto = _cod_concepto;

        if _fila = 1 then
			let _nom_concepto1 = _nom_concepto;
			let _monto_con1 = _monto_con;
        elif _fila = 2 then                                                                      
			let _nom_concepto2 = _nom_concepto;
			let _monto_con2 = _monto_con;
        elif _fila = 3 then                                                                      
			let _nom_concepto3 = _nom_concepto;
			let _monto_con3 = _monto_con;
        elif _fila = 4 then                                                                      
			let _nom_concepto4 = _nom_concepto;
			let _monto_con4 = _monto_con;
		end if

		let _fila = _fila + 1;
	end foreach

	let _desc_transaccion1 = null;
	let _desc_transaccion2 = null;
	let _desc_transaccion3 = null;
	let _desc_transaccion4 = null;
   
    foreach
		select renglon, desc_transaccion
		  into _renglon, _desc_transaccion
		  from rectrde2
		 where no_tranrec = _no_tranrec

        if _renglon = 1 then
			let _desc_transaccion1 = _desc_transaccion;
        elif _renglon = 2 then                                                                      
			let _desc_transaccion2 = _desc_transaccion;
        elif _renglon = 3 then                                                                      
			let _desc_transaccion3 = _desc_transaccion;
        elif _renglon = 4 then                                                                      
			let _desc_transaccion4 = _desc_transaccion;
		end if
	end foreach

    select count(*)
	  into _cant_dev
	  from cobredet
	 where doc_remesa = _no_documento
	   and tipo_mov = "M";

    if _cant_dev > 0 then
		let _devolucion_prima = 1;
	else
		let _devolucion_prima = 0;
	end if

    select nombre
	  into _tipo_pago_nom
	  from rectipag
	 where cod_tipopago = _cod_tipopago;

    if _perd_total is null then
		let _perd_total = 0;
	end if

    if _perd_total = 1 then
		let _perdida = 'Si';
	else
		let _perdida = '';
	end if

	return _no_documento,
		   _numrecla,
		   _nom_asegurado,
		   _nom_cliente,
		   _transaccion,
		   _monto,
		   _estatus_nom,
		   _estatus_nom2,
		   _ajust_nombre,
		   _reserva,
	       _es_flota,
		   _cant_uni,
		   _direccion,
		   _edad,
		   _no_motor,
		   _no_unidad,
		   _suma_asegurada,
		   _nom_cobertura1,
		   _limite_11,
		   _limite_21,
		   _nom_cobertura2,
		   _limite_12,
		   _limite_22,
		   _nom_cobertura3,
		   _limite_13,
		   _limite_23,
		   _nom_cobertura4,
		   _limite_14,
		   _limite_24,
		   _nom_concepto1,
		   _monto_con1,
		   _nom_concepto2,
		   _monto_con2,
		   _nom_concepto3,
		   _monto_con3,
		   _nom_concepto4,
		   _monto_con4,
		   _desc_transaccion1,
		   _desc_transaccion2,
		   _desc_transaccion3,
		   _desc_transaccion4,
		   _fecha_pagado,
		   _devolucion_prima,
		   _tipo_pago_nom,
		   _usuario,
		   _n_taller,
		   _perdida,
		   _cod_agente,
		   _n_agente,
		   _fecha_susc,     
		   _vigencia_inic,  
		   _vigencia_final, 
		   _fecha_siniestro,
		   _cedula,
		   _n_pagador,
		   _cod_pagador,
		   _n_formapag
		   with resume;

end foreach

end procedure