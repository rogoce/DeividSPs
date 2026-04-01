-- Procedimiento que Carga las tablas para el Analisis de Cuentas 
-- Creado: 20/10/2022 - Autor: Román Gordón
-- execute procedure sp_bi01('001','001','2022-01','2022-10')

drop procedure sp_bi02;
create procedure "informix".sp_bi02()
returning	integer 		as error,
			varchar(100)	as mensaje;

define v_filtros				varchar(255);
define _mensaje					varchar(255);
define _nom_contratante			varchar(100);
define _nom_asegurado			varchar(100);
define _nom_grupo				varchar(100);
define _telefono			varchar(50);
define _email				varchar(50);
define _nom_agente				varchar(50);
define _producto				varchar(50);
define _subramo					varchar(50);
define _ramo					varchar(50);
define _no_documento			char(20); 
define _cod_contratante			char(10); 
define _cod_asegurado			char(10); 
define _cod_cliente				char(10); 
define _no_poliza				char(10); 
define _cod_producto			char(5);
define _cod_agente				char(5);
define _no_unidad				char(5);
define _cod_grupo				char(5);  
define _cod_sucursal			char(3);  
define _cod_tipoprod			char(3);
define _cod_subramo				char(3);  
define _cod_zona				char(3);  
define _cod_ramo				char(3);  
define _cod_origen				char(3);
define _nueva_renov				char(1);
define _prima_susc_dev_uni_ret	dec(16,2); 
define _prima_cob_dev_uni_ret	dec(16,2); 
define _prima_susc_dev_uni		dec(16,2); 
define _prima_cob_dev_uni		dec(16,2); 
define _mto_cob_neto_uni		dec(16,2); 
define _mto_cob_neto_pol		dec(16,2); 
define _rec_pagado_total		dec(16,2); 
define _incurrido_total			dec(16,2);
define _rec_pagado_neto			dec(16,2); 
define _incurrido_neto			dec(16,2); 
define _suma_asegurada			dec(16,2); 
define _prima_neta_uni			dec(16,2); 
define _prima_susc_uni			dec(16,2); 
define _prima_neta_pol			dec(16,2); 
define _prima_susc_pol			dec(16,2); 
define _prima_susc_dev			dec(16,2); 
define _prima_cob_dev			dec(16,2); 
define _prima_ret_pol			dec(16,2); 
define _prima_ced_pol			dec(16,2); 
define _prima_ced_uni			dec(16,2); 
define _prima_ret_uni			dec(16,2); 
define _reserva_total			dec(16,2); 
define _reserva_neta			dec(16,2); 
define _porc_partic_agt			dec(5,2); 
define _porc_ret_uni			dec(9,6); 
define _proporcion_uni			dec(9,6); 
define _porc_comis_agt			dec(5,2); 
define _estatus_poliza			smallint;
define _error_isam				integer;
define _error					integer;
define _fecha_suspension		date;
define _fecha_desde				date;
define _fecha_hasta				date;
define _vigencia_final			date;
define _vigencia_inic			date;
define _fecha_hoy				date;

begin
	on exception set _error,_error_isam,_mensaje
		return _error,_no_documento ||" " ||_mensaje ;         
	end exception

	set isolation to dirty read;
	--set debug file to "sp_emite01.trc"; 
	--trace on;

foreach
	select cod_cliente,
		   email,
		   telefono
	  into _cod_cliente,
		   _email,
		   _telefono
	  from deivid_tmp:tmp_cliente_emb
	 where email is not null

	update cliclien
	   set e_mail = _email
	 where cod_cliente = _cod_cliente;
end foreach

return 0,'Carga Exitosa';

end
end procedure;