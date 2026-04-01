-- Procedimiento para procesar los valores en las tablas de DEIVID y emitir las polizas de ducruet
-- Creado    : 17/05/2019 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emite09;

create procedure "informix".sp_emite09() 
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

	begin
	on exception set _error,_error_isam,_error_desc
		return _error,_error_desc;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;

--begin work;

	let _prima_neta_emi = 0.00;
	let _prima_neta = 0.00;
	let _dif_prima = 0.00;
	let _cant_iter = 0;
	let _cont = 0;
	let v_codcompania = '001';
	let _error_desc = ""; 
let _error = 0;	

	foreach
		select act.no_poliza,
			   act.no_documento,
			   ant.cod_formapag,
			   ant.cod_perpago,
			   ant.no_tarjeta,
			   ant.no_cuenta,
			   ant.cod_banco,
			   ant.no_pagos,
			   ant.dia_cobros1,
			   ant.dia_cobros2,
			   ant.tipo_tarjeta,
			   ant.tipo_cuenta,
			   ant.fecha_exp
			  /*,act.cod_formapag,
			   act.cod_perpago,
			   act.no_tarjeta,
			   act.no_cuenta,
			   act.cod_banco,
			   act.no_pagos,
			   act.dia_cobros1,
			   act.dia_cobros2,
			   act.tipo_tarjeta,
			   act.tipo_cuenta,
			   act.fecha_exp*/
		  into _no_poliza,
			   _no_documento,
			   _cod_formapag,
			   _cod_perpago,
			   _no_tarjeta,
			   _no_cuenta,
			   _cod_banco,
			   _no_pagos,
			   _dia_cob1,
			   _dia_cob2,
			   _tipo_tarjeta,
			   _tipo_cuenta,
			   _fecha_exp
		  from emipomae act
		 inner join emipomae ant on ant.no_documento = act.no_documento and ant.vigencia_final = act.vigencia_inic 
		   and (ant.cod_formapag <> act.cod_formapag or ant.cod_perpago <> act.cod_perpago or ant.no_pagos <> act.no_pagos or ant.no_tarjeta <> act.no_tarjeta or ant.no_cuenta <> act.no_cuenta)
		 where act.no_factura not like '%-%'
		   and act.no_documento not in ('0109-00567-01','0115-00418-01','0309-00207-01','0320-00079-01','0123-00035-01','0123-00035-01','0124-04947-07','0193-0526-01')
		   --and act.no_documento in ()
		   --and ant.cod_formapag = '005'
		   and act.actualizado = 0
		   and act.vigencia_inic >= '01/05/2024'
		   --and act.fecha_suscripcion = today

		   --and act.cod_formapag  in ('003')
		 order by act.no_documento
		
		update emipomae
		   set fecha_exp = _fecha_exp,
			   tipo_tarjeta = _tipo_tarjeta,
			   tipo_cuenta = _tipo_cuenta,
		       cod_formapag = _cod_formapag,
			   cod_perpago = _cod_perpago,
			   no_tarjeta = _no_tarjeta,
			   no_cuenta = _no_cuenta,
			   cod_banco = _cod_banco,
			   no_pagos = _no_pagos,
			   dia_cobros1 = _dia_cob1,
			   dia_cobros2 = _dia_cob2			   
		 where no_poliza = _no_poliza;

		update endedmae
		   set cod_formapag = _cod_formapag,
			   cod_perpago = _cod_perpago,
			   no_pagos = _no_pagos
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';

		if _error <> 0 then
			return _error,_error_desc with resume;
		else
			return 0,"Actualización Exitosa: "|| _no_documento with resume;
		end if
	end foreach	
	
	end
end procedure;

/*
select act.no_documento,aacr.*,tacr.*
  from emipomae act
 inner join emipomae ant on ant.no_documento = act.no_documento and ant.vigencia_final = act.vigencia_inic
 inner join emipoacr aacr on aacr.no_poliza = ant.no_poliza
  left join emipoacr tacr on tacr.no_poliza = act.no_poliza
 where (act.no_factura like '8%' or act.no_factura like '9%')
   and (aacr.cod_acreedor <> tacr.cod_acreedor)
   and act.no_factura not like '%-%'
   and act.actualizado = 0
*/