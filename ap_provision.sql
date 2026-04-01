

DROP PROCEDURE ap_provision;
CREATE PROCEDURE ap_provision() RETURNING integer;

define _no_poliza			CHAR(10);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _periodo 			char(7);
define _no_documento		char(20);
define _cod_agente			char(5);
define _comision			dec(16,2);
define _monto_comision		dec(16,2);
define _saldo_pxc			dec(16,2);
define _prima_agente		dec(16,2);

SET ISOLATION TO DIRTY READ;


FOREACH
	select periodo,
	       no_poliza,
	       no_documento,
	       cod_agente,
		   comision,
		   porc_partic_agt,
		   porc_comis_agt
	  into _periodo,
	       _no_poliza,
	       _no_documento,
	       _cod_agente,
		   _comision,
		   _porc_partic_agt,
		   _porc_comis_agt
	  from deivid_tmp:prov_agt_ori_202508

 {  let _saldo_pxc = 0.00; 
   let _prima_agente = 0.00; 
   let _monto_comision = 0.00; 
	
   select saldo_pxc
	  into _saldo_pxc
	  from deivid_cob:cobmoros2
	 where no_documento = _no_documento
	   and periodo = _periodo;
	 	 
	let _prima_agente = _saldo_pxc * (_porc_partic_agt/100);
	
	if _comision <> 0.00 then 
		let _monto_comision = _prima_agente * (_porc_comis_agt/100);
	end if
}	
	update prov_agt
	   set comision = _comision
	 where periodo = _periodo
	   and no_poliza = _no_poliza
	   and cod_agente = _cod_agente;
	 
END FOREACH

RETURN 0;
                                                                                                                                                                                    


END PROCEDURE;