--execute procedure sp_rec706('001','001','2014-06','2014-06',"*","*","002;","*","*")
--drop procedure sp_sin_pend_aud;

create procedure "informix".sp_sin_pend_aud(
a_compania	char(3),
a_agencia	char(3),
a_periodo1	char(7),
a_periodo2	char(7),
a_sucursal	char(255) default "*",
a_contrato	char(255) default "*",
a_ramo		char(255) default "*",
a_serie		char(255) default "*",
a_cober		char(255) default "*")
returning	char(18),
			char(100),
			char(20),
			date,
			date,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(50),
			char(50),
			char(3),
			char(50);


define v_filtros			char(255);
define v_cliente_nombre		char(100);  
define v_contrato_nombre	char(50);
define v_compania_nombre	char(50);
define v_ramo_nombre		char(50);
define _n_cober				char(30);
define _no_documento		char(20);
define v_doc_poliza			char(20);
define v_doc_reclamo		char(18);
define _serie_char			char(15);
define v_transaccion		char(10);
define _cod_cliente			char(10);
define _no_reclamo			char(10);
define _no_tranrec			char(10);
define _no_poliza			char(10);
define _periodo				char(7);
define _cod_cobertura		char(5);
define _cod_contrato		char(5);
define _serie_c				char(4);
define _cod_cober_reas		char(3);
define _cod_sucursal		char(3);
define _cod_ramo			char(3);
define _tipo				char(1);
define v_incurrido_cedido	dec(16,2);
define v_reserva_cedido		dec(16,2);
define _incurrido_bruto		dec(16,2);
define _incurrido_neto		dec(16,2);
define _suma_asegurada		dec(16,2);
define v_pagado_cedido		dec(16,2);
define _reserva_bruto		dec(16,2);
define _reserva_neto		dec(16,2);
define _pagado_bruto		dec(16,2);
define _pagado_neto			dec(16,2);
define _monto_bruto			dec(16,2);
define _monto_total			dec(16,2);
define _ret_casco			dec(16,2);
define v_suma_pag			dec(16,2);
define v_suma_res			dec(16,2);
define _fac_car_1			dec(16,2);
define _fac_car_2			dec(16,2);
define _fac_car_3			dec(16,2);	
define _inc_bruto			dec(16,2);
define _pag_cont			dec(16,2);
define _res_cont			dec(16,2);
define _pag_ret				dec(16,2);
define _pag_fac				dec(16,2);
define _res_ret				dec(16,2);
define _res_fac				dec(16,2);
define _exc_pag				dec(16,2);
define _exc_res				dec(16,2);
define _exc_fac				dec(16,2);
define _exc_ret				dec(16,2);
define _cp_pag				dec(16,2);
define _cp_res				dec(16,2);
define _pag_5				dec(16,2);
define _pag_7				dec(16,2);
define _res_5				dec(16,2);
define _res_7				dec(16,2);
define v_xl					dec(16,2);
define _facilidad_car		smallint;
define _tipo_contrato		smallint;
define _si_hay				smallint;
define _serie1				smallint;
define _serie				smallint;
define _cnt3				smallint;
define _cnt					smallint;
define v_fecha_siniestro	date;
define _dt_siniestro		date;
define _vig_ini				date;
define _vig_fin				date;
define _porc_reas			dec;
define _porc_coas			dec;
define _cod_ajustador       char(3);
define _n_ajustador         char(50);
define _ult_fecha           date;

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania
let  v_compania_nombre = sp_sis01(a_compania);

call sp_rec02(a_compania, a_agencia, a_periodo2,a_sucursal,'*','*',a_ramo,'*') returning v_filtros; 

--set debug file to "sp_rec706.trc"; 
--trace on; 


foreach 
	select no_reclamo,		
		   no_poliza,
		   cod_ramo,
		   periodo,
		   numrecla,
		   cod_sucursal,
		   sum(pagado_bruto),
		   sum(reserva_bruto),
		   sum(incurrido_bruto),
		   sum(pagado_neto),
		   sum(reserva_neto),
		   sum(incurrido_neto)
	  into _no_reclamo,
		   _no_poliza,
		   _cod_ramo,
		   _periodo,
		   v_doc_reclamo,
		   _cod_sucursal,
		   _pagado_bruto,
		   _reserva_bruto,
		   _incurrido_bruto,
		   _pagado_neto,
		   _reserva_neto,
		   _incurrido_neto	
	  from tmp_sinis
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal
	 order by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal

	select no_documento 
	  into _no_documento
	  from emipomae 
	 where no_poliza = _no_poliza;


   	if _reserva_bruto is null  then
		let _reserva_bruto = 0;
	end if
	if _reserva_neto is null  then
		let _reserva_neto = 0;
	end if


	select fecha_siniestro,
	       ajust_interno
	  into v_fecha_siniestro,
	       _cod_ajustador
	  from recrcmae
	 where no_reclamo = _no_reclamo;

	select nombre
	  into _n_ajustador
	  from recajust
	 where cod_ajustador = _cod_ajustador;


	select nombre
	  into v_ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo

		exit foreach;
	end foreach

	select nombre
	  into _n_cober
	  from prdcober
	 where cod_cobertura = _cod_cobertura;

	select no_documento,
		   cod_contratante,
		   suma_asegurada,
		   vigencia_inic,
		   vigencia_final
	  into v_doc_poliza,
	       _cod_cliente,
		   _suma_asegurada,
		   _vig_ini,
		   _vig_fin
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into v_cliente_nombre		
	  from cliclien 
	 where cod_cliente = _cod_cliente;

	select max(fecha)
	  into _ult_fecha
	  from rectrmae
	 where no_reclamo  = _no_reclamo
	   and actualizado = 1;


	RETURN v_doc_reclamo,
	       v_cliente_nombre, 
	       v_doc_poliza,	 
	 	   v_fecha_siniestro,
		   _ult_fecha,
		   _pagado_bruto,
		   _pagado_neto,
		   _reserva_bruto,
		   _reserva_neto,
		   _incurrido_bruto,
		   _incurrido_neto,
		   v_ramo_nombre,	 
		   v_compania_nombre,
		   _cod_ajustador,	 
		   _n_ajustador		 
		   with resume;
end foreach

drop table tmp_sinis;

end procedure;	   