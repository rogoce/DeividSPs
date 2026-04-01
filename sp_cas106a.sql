-- Procedimiento para la Insercion Inicial de Polizas para el sistema de Cobros por Campana
-- Creado    : 01/10/2010- Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cas106;

CREATE PROCEDURE sp_cas106()
RETURNING INTEGER, CHAR(100);




Define v_no_documento	char(20);
Define v_no_poliza		char(10);
Define _error			smallint;
Define v_vigencia_ini	date;
Define v_vigencia_fin	date;


begin work;

begin

on exception set _error
    rollback work;
	return _error, "Error al Ingresar los Registro en emipoliza";
end exception
--set debug file to "sp_cas106.trc";
--trace on;

foreach
	select no_documento
	  into v_no_documento
	  from emipoliza

	let v_no_documento = trim(v_no_documento);
	let v_no_poliza = sp_sis21(v_no_documento);

	select 
		   vigencia_inic,
		   vigencia_final		   
	  into v_vigencia_ini,
		   v_vigencia_fin
	  from emipomae
	 where no_poliza = v_no_poliza;

	update emipoliza
	   set vigencia_inic = v_vigencia_ini,
		   vigencia_fin	 = v_vigencia_fin;
	   
end foreach

commit work;
return 0,"Actualizacion Exitosa";

end	 		   	
end procedure
