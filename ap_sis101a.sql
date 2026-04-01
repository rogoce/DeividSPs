-- Procedimiento que determina el codigo de corredor deacuerdo al periodo del concurso

drop procedure ap_sis101a;
create procedure ap_sis101a(a_no_documento char(20),a_fecha_desde date, a_fecha_hasta date, a_sesid integer)
returning smallint;
          
define _porc_partic_agt     decimal(16,4);
define _cnt					integer;
define _no_poliza           char(10);
define _no_endoso           char(10);
define _cod_agente          char(10);
define _fecha_emision       date;
define _porc_comis_agt      decimal(16,4);

BEGIN

--set debug file to "sp_sis101a.trc";
--trace on;

set isolation to dirty read;

let _porc_comis_agt = 0.00;

let _no_poliza = null;

delete from con_corr
 where sessionid = a_sesid;

	let _no_poliza = null;
	foreach
		select no_poliza,no_endoso,fecha_emision
		  into _no_poliza,_no_endoso,_fecha_emision
		  from endedmae
		 where actualizado = 1
		   and fecha_emision <= a_fecha_hasta
		   and no_documento = a_no_documento
		order by 3 desc
		exit foreach;
	end foreach

	if _no_poliza is null then
		foreach
			select no_poliza,no_endoso,fecha_emision
			  into _no_poliza,_no_endoso,_fecha_emision
			  from endedmae
			 where actualizado = 1
			   and no_documento = a_no_documento
			order by 3 desc
			exit foreach;
		end foreach
	end if
	foreach
		select cod_agente,
			   porc_partic_agt,
			   porc_comis_agt
		  into _cod_agente,
			   _porc_partic_agt,
			   _porc_comis_agt
		  from endmoage
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
	   
		insert into con_corr(cod_agente, porcentaje, porc_comis_agt,sessionid)
		values(_cod_agente,_porc_partic_agt, _porc_comis_agt,a_sesid);
	end foreach	
end
return 0;
end procedure;