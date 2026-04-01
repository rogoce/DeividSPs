-- Procedimiento para la Insercion Inicial de Polizas para el sistema de Cobros por Campana
-- Creado    : 01/10/2010- Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cas106;

CREATE PROCEDURE sp_cas106()
RETURNING INTEGER, CHAR(100);




Define v_no_documento	char(20);
Define v_no_poliza		char(10);
Define v_cod_ramo		char(3);
Define v_cod_formapag	char(3);
Define v_cod_suc		char(3);
Define v_cod_status		char(1);
Define v_cod_zona		char(3);
Define v_cod_agente		char(5);
Define v_cod_area		char(5);
Define v_cod_grupo		char(5);
Define v_cod_acreencia	char(3);
Define v_cod_pagos		char(3);
Define v_cod_pagador	char(10);
Define v_dia_cob1		smallint;
Define v_dia_cob2		smallint;
Define _error			smallint;
Define _cont_acre		smallint;
Define _cont_agente		smallint;
Define v_vigencia_ini	date;
Define v_vigencia_fin	date;
Define v_prima_bruta	decimal(16,2);


begin work;

begin

on exception set _error
    rollback work;
	return _error, "Error al Ingresar los Registro en emipoliza";
end exception

let v_cod_agente = '';
let v_cod_zona	 = '';
let v_cod_acreencia = '';
--set debug file to "sp_cas106.trc";
--trace on;

foreach
	select no_documento
	  into v_no_documento
	  from emipoliza

	let v_no_documento = trim(v_no_documento);
	let v_no_poliza = sp_sis21(v_no_documento);

	select cod_ramo,
		   cod_formapag,
		   cod_grupo,
		   cod_pagador,
		   cod_sucursal,
		   dia_cobros1,
		   dia_cobros2,
		   estatus_poliza,
		   vigencia_inic,
		   vigencia_final,
		   prima_bruta		   
	  into v_cod_ramo,
		   v_cod_formapag,
		   v_cod_grupo,
		   v_cod_pagador,
		   v_cod_suc,
		   v_dia_cob1,
		   v_dia_cob2,
		   v_cod_status,
		   v_vigencia_ini,
		   v_vigencia_fin,
		   v_prima_bruta
	  from emipomae
	 where no_poliza = v_no_poliza;

	select code_correg
	  into v_cod_area
	  from cliclien
	 where cod_cliente = v_cod_pagador;
	  
   	select count(*)
      into _cont_acre
	  from emipoacr
	 where no_poliza = v_no_poliza;
	
	if _cont_acre = 0 then
		let v_cod_acreencia = '002';
	else 
		let v_cod_acreencia = '001';
	end if

	select count(*)
	  into _cont_agente
	  from emipoagt
	 where no_poliza = v_no_poliza;
	
	if _cont_agente = 0 then
		let v_cod_agente = '';
		let v_cod_zona	 = '';
	elif _cont_agente = 1 then
	 	select cod_agente
		  into v_cod_agente
		  from emipoagt
		 where no_poliza = v_no_poliza;

		select cod_cobrador
		  into v_cod_zona
		  from agtagent
		 where cod_agente = v_cod_agente;
	else
		let v_cod_agente = '00000';
		let v_cod_zona   = '000';	
	end if
	

			   
	update emipoliza
	   set cod_ramo 	 = v_cod_ramo,
		   cod_formapag  = v_cod_formapag,
		   cod_zona 	 = v_cod_zona,
		   cod_grupo	 = v_cod_grupo,
		   cod_pagador	 = v_cod_pagador,
		   cod_sucursal	 = v_cod_suc,
		   dia_cobros1	 = v_dia_cob1,
		   dia_cobros2 	 = v_dia_cob2,
		   cod_status	 = v_cod_status,
		   vigencia_inic = v_vigencia_ini,
		   vigencia_fin	 = v_vigencia_fin,
		   cod_area		 = v_cod_area,
		   cod_agente	 = v_cod_agente,
		   cod_acreencia = v_cod_acreencia,
		   prima_bruta	 = v_prima_bruta
	 where no_documento	 = v_no_documento;

end foreach

commit work;
return 0,"Actualizacion Exitosa";

end	 		   	
end procedure
