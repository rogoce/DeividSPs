-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure SpCargaRectrmae;

create procedure "informix".SpCargaRectrmae() 
returning	smallint,varchar(200);

define _prima_neta_emi 		dec(16,2);
define _prima_neta 			dec(16,2);
define _dif_prima 			dec(16,2);
define _cant_iter 			smallint;
define _cont 				smallint;
define _error           	smallint;
define _no_tarjeta		   	char(19);
define _no_cuenta		   	char(17);
define _no_poliza		   	char(10);
define _fecha_exp      		char(7);
define _no_unidad      		char(5);
define _cod_formapag      	char(3);
define _cod_perpago      	char(3);
define _cod_banco      		char(3);
define _error_desc			varchar(200);
define _error_isam			smallint;
define _error_title			varchar(30);
define _vigencia_inic		date;
define _dia_cob2			smallint;
define _dia_cob1			smallint;
define _no_pagos			smallint;
define _tipo_tarjeta		smallint;
define _tipo_cuenta			char(1);
define _cnt					smallint;
define v_codcompania		char(3);
define _no_documento		varchar(20);

--Insert into deivid_bo:rectrmae_bo
SELECT no_tranrec, cod_compania, cod_sucursal, no_reclamo,cod_cliente, cod_tipotran, cod_tipopago, no_requis, no_remesa,renglon, numrecla, fecha, impreso, transaccion, perd_total, cerrar_rec, no_impresion, periodo, pagado, monto, 
      variacion, generar_cheque, actualizado, user_added,fecha_pagado, facturado, elegible, a_deducible, co_pago, monto_no_cubierto, coaseguro, ahorro, cod_cpt, incurrido_total, incurrido_bruto, incurrido_neto, pagado_proveedor, 
	  pagado_taller, pagado_asegurado, pagado_tercero, fecha_factura, wf_apr_js, wf_apr_js_fh, wf_apr_j, wf_apr_j_fh, wf_apr_jt, wf_apr_jt_fh, wf_apr_jt_2, wf_apr_jt_2_fh, wf_apr_g, wf_apr_g_fh, cod_asignacion, no_factura, anular_nt
FROM deivid:informix.rectrmae
WHERE actualizado = 1
  AND no_tranrec <> '698459'
  
