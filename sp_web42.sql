-- Procedure que crea el reclamo de los hospitales

-- Creado: 06/04/2017 - Autor: Federico Coronado

drop procedure sp_web42;

create procedure "informix".sp_web42(a_no_poliza 		varchar(10), 
                                     a_cedula_1 		varchar(30), 
									 a_cedula_2 		varchar(30), 
									 a_cod_icd1 		varchar(10), 
									 a_cod_cobertura 	varchar(10),
									 a_cod_hospital 	varchar(10),
									 a_user             varchar(8),
									 a_reserva_inicial  decimal(16,2))
returning integer,
          char(100),
		  varchar(10),
		  varchar(30),
		  varchar(20);

define v_cod_cpt1			varchar(5);
define v_cod_asegurado1     varchar(10);
define v_cod_asegurado2     varchar(10);
define v_nombre_cpt         varchar(30);
define v_cod_asegurado      varchar(10);
define v_cod_producto       varchar(5);
define v_no_unidad          varchar(5);
define v_cod_compania       varchar(3);
define v_suma_asegurada     dec(16,2);
define v_cod_sucursal       varchar(3);
define v_no_documento       varchar(20);
define _fecha_actual        date;
define _periodo_hoy         varchar(7);
define v_no_tranrec         varchar(10);
define v_nombre_icd         varchar(30);
define v_desc_limite        varchar(50);
define v_no_aprovacion      varchar(10);
define v_no_reclamo         varchar(10);
define v_numrecla           varchar(20);
define v_no_trans           varchar(10);
define _cod_compania        char(3);
define _hora                datetime hour to fraction(5);

define _error	   			integer;
define _error_isam 			integer;
define _error_desc 			char(50);

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_isam || " " || trim(_error_desc),"","","";
end exception

--SET DEBUG FILE TO "sp_web42.trc";
--TRACE ON ;
/*
	let _fecha_actual = today;
	let _hora         = current;
	
	call sp_sis39(_fecha_actual) RETURNING _periodo_hoy;
*/
	let _hora         = current;
	call sp_web58() RETURNING _periodo_hoy, _fecha_actual;
	
	let v_cod_cpt1 = '99284';
	
	select cod_cliente
	  into v_cod_asegurado1
	  from cliclien 
	 where cod_cliente = a_cedula_1;
	 
	select cod_cliente
	  into v_cod_asegurado2
	  from cliclien 
	 where cod_cliente = a_cedula_2;
	  
	select nombre
	  into v_nombre_cpt 
	  from reccpt 
	 where cod_cpt = v_cod_cpt1;
	 
	SELECT nombre 
	  into v_nombre_icd
	  from recicd 
	 where cod_icd = a_cod_icd1;
	 
	select cod_asegurado,
		   cod_producto,
		   no_unidad,
		   suma_asegurada
	  into v_cod_asegurado,
		   v_cod_producto,
		   v_no_unidad,
		   v_suma_asegurada
	  from emipouni 
	 where no_poliza		= a_no_poliza 
	   and cod_asegurado	= v_cod_asegurado1 
	   and activo 			= 1;
	   
	SELECT desc_limite1
	  into v_desc_limite
	  from prdcobpd 
	 where cod_cobertura 	= 	a_cod_cobertura  
	   and cod_producto		=	v_cod_producto; 

	select cod_sucursal, 
		   no_documento,
		   cod_compania
	  into v_cod_sucursal,
		   v_no_documento,
		   v_cod_compania
	  from emipomae 
	 where no_poliza		=	a_no_poliza;
	 
	let v_no_aprovacion = sp_sis13(v_cod_compania, 'REC', '02', 'par_aprob');
	let v_no_reclamo	= sp_sis13(v_cod_compania, 'REC', '02', 'par_reclamo');
	let v_no_tranrec	= sp_sis13(v_cod_compania, 'REC', '02', 'par_tran_genera');
	let v_numrecla   	= sp_rwf11(v_cod_compania, v_cod_sucursal,v_no_reclamo,a_no_poliza);
	let v_no_trans   	= sp_sis12a(v_cod_compania, v_cod_sucursal,a_no_poliza);
	
	Insert into recprea1 (no_aprobacion, 
	                      no_documento, 
						  cod_reclamante, 
						  cod_cliente, 
						  cod_icd1,
						  cod_cpt1, 
						  fecha_autorizacion, 
						  autorizado_por, 
						  comentario, 
						  estado, 
						  tipo_hab,
						  tipo_procedimiento,
						  via_info) 
				   values (v_no_aprovacion,
 				           v_no_documento,
						   v_cod_asegurado2,
						   a_cod_hospital,
						   a_cod_icd1,
						   v_cod_cpt1,
						   _fecha_actual, 
						   a_user,
						   v_desc_limite,
						   '1',
						   '2',
						   '3',
						   '6');
	Insert into recrcmae (no_reclamo, 
						  cod_compania, 
						  cod_sucursal, 
						  ajust_interno,
						  cod_evento,
						  cod_hospital, 
						  cod_doctor, 
						  cod_lugar, 
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
						  cod_icd, 
						  cord_beneficios, 
						  hora_reclamo,
						  reserva_inicial, 
						  reserva_actual, 
						  subir_bo,
						  cod_producto) 
				   values(v_no_reclamo, 
						  '001', 
						  v_cod_sucursal, 
						  '244', 
						  '038', 
						  a_cod_hospital,
						  a_cod_hospital,
						  '001',
						  v_cod_asegurado2,
						  v_cod_asegurado,
						  a_no_poliza,
						  v_no_unidad,
						  v_no_documento,
						  _fecha_actual,
						  _fecha_actual,
						  0,
						  v_numrecla,
						  _fecha_actual,
						  0,
						  1, 
						  v_no_trans,
						  'A',
						  _periodo_hoy,
						  0,
						  v_suma_asegurada,
						  _hora, 
						  a_user,
						  a_cod_icd1,
						  0,
						  _hora, 
						  a_reserva_inicial, 
						  a_reserva_inicial,
						  1,
						  v_cod_producto);
						  
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
				          a_cod_cobertura,
						  a_reserva_inicial,
						  0, 
						  a_reserva_inicial, 
						  a_reserva_inicial, 
						  0,
						  0,
						  0,
						  0,
						  0,
						  1);
					
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
						  fecha_factura, 
						  subir_bo, 
						  cod_cpt)
				   values(v_no_tranrec, 
				          '001',
						  v_cod_sucursal,
						  v_no_reclamo, 
						  v_cod_asegurado1, 
						  '001', 
						  v_numrecla, 
						  _fecha_actual, 
						  1, 
						  v_no_trans,
						  _periodo_hoy,
						  a_reserva_inicial,
						  a_reserva_inicial,
						  0,
						  1, 
						  a_user,
						  _fecha_actual,
						  1, 
						  v_cod_cpt1);
	
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
				         a_cod_cobertura,
						 a_reserva_inicial,
						 a_reserva_inicial,
						 0,
						 0,
						 0,
						 0,
						 0,
						 1);
end
return 0, "Exito",v_no_aprovacion,v_nombre_cpt,v_numrecla;

end procedure