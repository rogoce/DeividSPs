-- Procedure que crea el reclamo coaseguros

-- Creado: 14/05/2019 - Autor: Amado Perez

drop procedure sp_rec289;

create procedure "informix".sp_rec289(a_cod_compania    char(3),
                                     a_cod_sucursal     char(3),
                                     a_no_documento 	char(18), 
                                     a_no_unidad 		char(5), 
									 a_fecha_siniestro  date,
									 a_monto            dec(16,2),
									 a_usuario 		    char(8),
									 a_descripcion      varchar(60))
returning integer,
          char(100),
		  varchar(20),
		  varchar(100),
		  char(10);

define v_cod_asegurado1     char(10);
define v_cod_producto       char(5);
define v_suma_asegurada     dec(16,2);
define _fecha_actual        date;
define _periodo_hoy         char(7);
define v_no_tranrec         char(10);
define v_no_reclamo         char(10);
define v_numrecla           char(20);
define v_no_trans           char(10);
define _hora, _hora2        datetime hour to fraction(5);
define _no_poliza           char(10);
define _cod_cobertura       char(5);
define _cod_ajustador       char(3);
define v_no_motor           char(30);
define v_asegurado          varchar(100);
define _contador            smallint;

define _error	   			integer;
define _error_isam 			integer;
define _error_desc 			char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || trim(_error_desc) || " " || a_no_documento,"","","";
end exception

--SET DEBUG FILE TO "sp_rec289.trc";
--TRACE ON ;

    let a_no_documento = a_no_documento;
	let _fecha_actual = today;
	let _hora         = current;
	let _hora2         = '10:00:00';

	call sp_sis39(_fecha_actual) RETURNING _periodo_hoy;
	
	let _contador = 0;
	
	select count(*)
	  into _contador
	  from emipomae
	 where no_documento = a_no_documento
       and actualizado = 1
       and vigencia_inic <= a_fecha_siniestro
       and vigencia_final >= a_fecha_siniestro;

	if _contador = 0 then
		select count(*)
		  into _contador
		  from emipomae
		 where no_poliza_coaseg = a_no_documento
		   and actualizado = 1
		   and vigencia_inic <= a_fecha_siniestro
		   and vigencia_final >= a_fecha_siniestro;
		if _contador = 0 then
			return 1, " Fecha de siniestro fuera del rango de vigencia para la poliza " || a_no_documento,"","","";
		else
			foreach
				select no_documento
				  into a_no_documento
				  from emipomae
				 where no_poliza_coaseg = a_no_documento
				   and actualizado = 1
				   and vigencia_inic <= a_fecha_siniestro
				   and vigencia_final >= a_fecha_siniestro
			end foreach				   
		end if
	end if
	
	FOREACH
		select no_poliza,
		       cod_contratante
		  into _no_poliza,
		       v_cod_asegurado1
		  from emipomae
		 where no_documento = a_no_documento
		   and actualizado = 1
		   and vigencia_inic <= a_fecha_siniestro
		   and vigencia_final >= a_fecha_siniestro
		 order by vigencia_final desc

		exit foreach;
	END FOREACH

    SELECT count(*)
	  INTO _contador
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = a_no_unidad;

	if _contador = 0 then
		return 1, " La unidad " || a_no_unidad || " no existe para esta poliza " || a_no_documento,"","","";
	end if


    SELECT suma_asegurada,
	       cod_producto
	  INTO v_suma_asegurada,
		   v_cod_producto
	  FROM emipouni
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = a_no_unidad;

    SELECT no_motor
	  INTO v_no_motor
	  FROM emiauto
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = a_no_unidad;
	 
    SELECT cod_cobertura
      INTO _cod_cobertura
      FROM emipocob
	 WHERE no_poliza = _no_poliza
	   AND no_unidad = a_no_unidad
	   AND cod_cobertura in (SELECT cod_cobertura from prdcober WHERE nombre LIKE "DA%PRO%AJEN%");	 

    LET _cod_ajustador = NULL; 	   
	   
	SELECT cod_ajustador
      INTO _cod_ajustador
      FROM recajust
     WHERE usuario = a_usuario;	 

    IF _cod_ajustador IS NULL OR TRIM(_cod_ajustador) = "" THEN
		return 1, "Debe ser procesado por un ajustador","","","";
    END IF	
	   	 
	let v_no_reclamo	= sp_sis13(a_cod_compania, 'REC', '02', 'par_reclamo');
	let v_no_tranrec	= sp_sis13(a_cod_compania, 'REC', '02', 'par_tran_genera');
	let v_numrecla   	= sp_rwf11(a_cod_compania, a_cod_sucursal,v_no_reclamo,_no_poliza);
	let v_no_trans   	= sp_sis12a(a_cod_compania, a_cod_sucursal,_no_poliza);
	
	Insert into recrcmae (no_reclamo, 
						  cod_compania, 
						  cod_sucursal, 
						  ajust_interno,
						  cod_evento,
						  cod_reclamante, 
						  cod_asegurado, 
						  no_poliza, 
						  no_unidad, 
						  no_documento, 
						  fecha_siniestro, 
						  fecha_reclamo, 
						  posible_recobro, 
						  numrecla, 
						  fecha_documento, 
						  tiene_audiencia,  
						  actualizado, 
						  transaccion, 
						  estatus_reclamo, 
						  periodo,
						  perd_total, 
						  suma_asegurada, 
						  hora_siniestro, 
						  user_added, 
						  hora_reclamo,
						  reserva_inicial, 
						  reserva_actual, 
						  subir_bo,
						  cod_producto,
						  no_motor) 
				   values(v_no_reclamo, 
						  a_cod_compania, 
						  a_cod_sucursal, 
						  _cod_ajustador, 
						  '016', 
						  v_cod_asegurado1,
						  v_cod_asegurado1,
						  _no_poliza,
						  a_no_unidad,
						  a_no_documento,
						  a_fecha_siniestro,
						  _fecha_actual,
						  0,
						  v_numrecla,
						  _fecha_actual,
						  0,
						  1, 
						  v_no_trans,
						  'C',
						  _periodo_hoy,
						  0,
						  v_suma_asegurada,
						  _hora2, 
						  a_usuario,
						  _hora, 
						  0, 
						  0,
						  1,
						  v_cod_producto,
						  v_no_motor);
						  
	Insert into recrccob (no_reclamo, 
	                      cod_cobertura, 
						  estimado, 
						  deducible,
						  reserva_inicial,
						  reserva_actual, 
						  pagos, 
						  salvamento, 
						  recupero, 
						  deducible_pagado, 
						  deducible_devuel, 
						  subir_bo) 
				   values(v_no_reclamo, 
				          _cod_cobertura,
						  0,
						  0, 
						  0, 
						  0, 
						  a_monto,
						  0,
						  0,
						  0,
						  0,
						  1);
	
 -- Transaccion de reserva inicial
 
	Insert into rectrmae (no_tranrec, 
						  cod_compania, 
						  cod_sucursal, 
						  no_reclamo, 
						  cod_cliente, 
						  cod_tipotran, 
						  numrecla, 
						  fecha, 
						  impreso, 
						  transaccion, 
						  periodo, 
						  monto, 
						  variacion, 
						  generar_cheque,
						  actualizado, 
						  user_added,
						  subir_bo)
				   values(v_no_tranrec, 
				          a_cod_compania,
						  a_cod_sucursal,
						  v_no_reclamo, 
						  v_cod_asegurado1, 
						  '001', 
						  v_numrecla, 
						  _fecha_actual, 
						  1, 
						  v_no_trans,
						  _periodo_hoy,
						  0,
						  0,
						  0,
						  1, 
						  a_usuario,
						  1);
	
	call sp_sis18(v_no_reclamo) returning _error, _error_desc;
		if _error <> 0 then
			return 1, trim(_error_desc),"","","";
		end if
						  
	Insert into rectrcob(no_tranrec, 
	                     cod_cobertura, 
						 monto, 
						 variacion, 
						 facturado, 
						 elegible, 
						 a_deducible, 
						 co_pago, 
						 monto_no_cubierto, 
						 subir_bo)
				  values(v_no_tranrec, 
				         _cod_cobertura,
						 0,
						 0,
						 0,
						 0,
						 0,
						 0,
						 0,
						 1);
						 
 -- Transaccion de Pago de Reclamo
 
	let v_no_tranrec	= sp_sis13(a_cod_compania, 'REC', '02', 'par_tran_genera');
	let v_no_trans   	= sp_sis12a(a_cod_compania, a_cod_sucursal,_no_poliza);
	 
	Insert into rectrmae (no_tranrec, 
						  cod_compania, 
						  cod_sucursal, 
						  no_reclamo, 
						  cod_cliente, 
						  cod_tipotran, 
						  cod_tipopago,
						  numrecla, 
						  fecha, 
						  impreso, 
						  transaccion, 
						  periodo, 
						  monto, 
						  variacion, 
						  generar_cheque,
						  actualizado, 
						  user_added,
						  cerrar_rec,
						  pagado,
						  subir_bo)
				   values(v_no_tranrec, 
				          a_cod_compania,
						  a_cod_sucursal,
						  v_no_reclamo, 
						  v_cod_asegurado1, 
						  '004', 
						  '003',
						  v_numrecla, 
						  _fecha_actual, 
						  0, 
						  v_no_trans,
						  _periodo_hoy,
						  a_monto,
						  0,
						  0,
						  1, 
						  a_usuario,
						  1,
						  1,
						  1);
	
						  
	Insert into rectrcob(no_tranrec, 
	                     cod_cobertura, 
						 monto, 
						 variacion, 
						 facturado, 
						 elegible, 
						 a_deducible, 
						 co_pago, 
						 monto_no_cubierto, 
						 subir_bo)
				  values(v_no_tranrec, 
				         _cod_cobertura,
						 a_monto,
						 0,
						 0,
						 0,
						 0,
						 0,
						 0,
						 1);
 
	Insert into rectrcon(no_tranrec, 
	                     cod_concepto, 
						 monto, 
						 subir_bo)
				  values(v_no_tranrec, 
				         '018',
						 a_monto,
						 1);
						 
	insert into rectrde2(no_tranrec,
	                     renglon,
						 desc_transaccion)
				  values (v_no_tranrec,
				          1,
						  trim(UPPER(a_descripcion)));
						 
	 -- Reaseguro a Nivel de Transaccion
	 CALL sp_sis58(v_no_tranrec) returning _error, _error_desc;
	 IF _error <> 0 THEN
		RETURN  _error, "No se creo el Reaseguro a Nivel de Transaccion", "", "", "";
	 END IF
						 
	select nombre
      into v_asegurado
      from cliclien 
     where cod_cliente = v_cod_asegurado1;
	 
	 
	 
end
return 0, "Exito",v_numrecla,v_asegurado,v_no_trans;

end procedure