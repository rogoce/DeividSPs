-- Procedure para auditoria interna - Archivo de Reclamo - Leyri Moreno
-- 
-- Creado    : 18/04/2013 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud37;		

create procedure "informix".sp_aud37() 
returning dec(16,2),
		  char(20),
		  varchar(50),
		  varchar(50),
		  smallint,
		  dec(16,2),	
		  dec(16,2),	
		  dec(16,2),	
		  dec(16,2),	
		  dec(16,2),	
		  date,
		  varchar(50),
		  varchar(50),
		  varchar(50),
		  varchar(50),
		  char(30),
		  dec(16,2);
		  

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
define _no_orden  		  char(5);
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
define _monto_recuperado  dec(16,2);
define _monto_salvamento  dec(16,2);
define _monto_deducible   dec(16,2);

define _cod_tipotran      char(3);
define _monto_recuperado_t  dec(16,2);
define _monto_salvamento_t  dec(16,2);
define _monto_deducible_t   dec(16,2);
define _monto_t			    dec(16,2);
define _variacion_reserva   dec(16,2);
define _monto_perdida       dec(16,2);
define _cnt_pag, _cnt_ter   smallint;
define _piezas, _chapisteria, _mecanica, _aa, _otros dec(16,2);

set isolation to dirty read;

begin

on exception
	return null,_numrecla,null, null,null, null,null, null,null, null,null, null,null, null,null, null, null;		
end exception

SET DEBUG FILE TO "sp_aud37.trc"; 

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
		   numrecla
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
		   _numrecla
	  from recrcmae
	 where numrecla[1,2] in ("02", "20")
	   and fecha_documento >= "01-01-2011"
	   and fecha_documento <= "01-05-2013"
	   and actualizado = 1
 	   and perd_total = 1

   	if _numrecla = "02-0211-00433-10" then
		trACE ON;
	else
		trACE Off;
  	end if 

   { foreach
	    select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo
		   and cod_cobertura in ('00119','00121','00606','00118','00900','00120','00902','01146','00103','00901')

	    select nombre
		  into _nom_cobertura
		  from prdcober
		 where cod_cobertura = _cod_cobertura;

        exit foreach;
	end foreach}

    let _piezas = 0.00;
    let _chapisteria = 0.00;
    let _mecanica = 0.00;
    let _aa = 0.00;
    let _otros = 0.00;

	select piezas, chapisteria, mecanica, aa, otros
	  into _piezas, _chapisteria, _mecanica, _aa, _otros 
	  from recperdida
	 where no_reclamo = _no_reclamo;

    let  _monto_perdida =  _piezas + _chapisteria + _mecanica + _aa + _otros;
    
	if _suma_asegurada = 0.00 then
		select suma_asegurada
		  into _suma_asegurada
		  from emipouni
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
	end if

    select sum(variacion)
	  into _variacion_reserva
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and actualizado = 1;
	 

	let _monto_t = 0.00;
	let _monto_recuperado_t = 0.00;
  	let _monto_salvamento_t = 0.00;
  	let _monto_deducible_t = 0.00;

    
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

	select nombre, usuario
	  into _ajust_nombre, _user_added
	  from recajust
	 where cod_ajustador = _ajust_interno;

    select descripcion
	  into _usuario
	  from insuser
	 where usuario = _user_added;


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

    select descripcion
	  into _sucursal
	  from insagen
	 where codigo_agencia =	_sucursal_origen;

   let _cod_cobertura = null;

   foreach
	 select no_tranrec
	   into _no_tranrec
	   from	rectrmae
	  where no_reclamo    = _no_reclamo
	    and actualizado   = 1
		and cod_tipotran  = "004"
		and cod_tipopago  = "003"
	    and no_requis     is not null
		and pagado        = 1

	  select cod_cobertura
	    into _cod_cobertura
		from rectrcob
	   where no_tranrec = _no_tranrec
	     and cod_cobertura in ('00119','00121','00606','00118','00900','00120','00902','01146','00103','00901')
	     and monto <> 0;
	  if _cod_cobertura is not null then
      	exit foreach;
	  end if
   end foreach   


    select nombre
	  into _nom_cobertura
	  from prdcober
	 where cod_cobertura = _cod_cobertura;


	select sum(b.variacion)
	  into _variacion_reserva
	  from rectrmae a, rectrcob	b
	 where a.no_reclamo  = _no_reclamo
	   and a.no_tranrec  = b.no_tranrec
	   and b.cod_cobertura = _cod_cobertura
	   and a.actualizado = 1;

    if _variacion_reserva is null then
		let _variacion_reserva = 0.00;
	end if

foreach
 select no_tranrec,
        cod_tipopago,
        fecha,
        transaccion,
		cod_cliente,
  --		monto,
		fecha_pagado,
		user_added,
		pagado,
		cod_tipotran,
		perd_total
   into _no_tranrec,
        _cod_tipopago,
        _fecha,
        _transaccion,
		_cod_cliente,
  --		_monto,
		_fecha_pagado,
		_user_added,
		_pagado,
		_cod_tipotran,
		_perd_total
   from	rectrmae
  where no_reclamo    = _no_reclamo
    and actualizado   = 1
	and ((cod_tipotran  = "004"
    and no_requis     is not null
	and pagado        = 1)
    or  cod_tipotran  in ("005", "006", "007"))
	and monto         <> 0
    and anular_nt     is null
  order by fecha

  let _monto = 0.00;

  select monto
    into _monto
	from rectrcob
   where no_tranrec = _no_tranrec
     and cod_cobertura = _cod_cobertura;

  if _monto is null then
	let _monto = 0.00;
  end if

 --	and pagado        = 1)

  let _monto_recuperado = 0.00;
  let _monto_salvamento = 0.00;
  let _monto_deducible  = 0.00;

  if _cod_tipotran = "005" then
  	let _monto_salvamento = _monto;
  	let _monto            = 0.00;
  elif _cod_tipotran = "006" then
  	let _monto_recuperado = _monto;
  	let _monto            = 0.00;
  elif _cod_tipotran = "007" then
  	let _monto_deducible = _monto;
  	let _monto            = 0.00;
  else
    select descripcion
	  into _usuario
	  from insuser
	 where usuario = _user_added;
  end if

	let _monto_t = _monto_t + _monto;
	let _monto_recuperado_t = _monto_recuperado_t + _monto_recuperado;
	let _monto_salvamento_t = _monto_salvamento_t + _monto_salvamento;
	let _monto_deducible_t  = _monto_deducible_t  + _monto_deducible;

 { if _cod_tipotran = "004"  then 
	    select count(*)
		  into _cnt_pag
		  from rectrcon
		 where no_tranrec = _no_tranrec
		   and cod_concepto in ('015');
	    
   	if _cnt_pag > 0 then
	    foreach
		    select cod_cobertura, monto
			  into _cod_cobertura, _variacion_cob
			  from rectrcob
			 where no_tranrec = _no_tranrec
			   and cod_cobertura in ('00119','00121','00606','00118','00900','00120','00902','01146','00103','00901')
			   and monto <> 0

		    select nombre
			  into _nom_cobertura
			  from prdcober
			 where cod_cobertura = _cod_cobertura;

	       -- exit foreach;
		end foreach
	 end if
  end if}	 
end foreach


return _suma_asegurada,	  --	  dec(16,2),
	   _numrecla,		  --	  char(20),
	   _marca,			  --	  varchar(50),	
	   _modelo,			  --      varchar(50),
	   _ano_auto,		  --      smallint,
	   _monto_t,		  --      dec(16,2),	   -- Monto Pagado
	   _monto_recuperado_t, --      dec(16,2),	   -- Monto recuperado
	   _monto_salvamento_t,
	   _monto_deducible_t,
	   _variacion_reserva, 
	   _fecha_siniestro,  --      date,
	   upper(_usuario),	  --      varchar(50),     -- Ajustador
	   _agente,			  --      varchar(50),	   -- productor
	   _agencia,		  -- 	  varchar(50),     -- suscursal productor
	   _nom_cobertura,	  -- 	  varchar(50),     -- tipo de cobertura
	   _no_chasis,		  --	  char(30),
	   _monto_perdida
	   with resume;
end foreach

end
end procedure

