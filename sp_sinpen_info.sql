--execute procedure sp_rec706('001','001','2014-06','2014-06',"*","*","002;","*","*")
drop procedure sp_sinpen_info;

create procedure "informix".sp_sinpen_info(
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
			char(20),
			char(100),
			date,
			date,
			dec(16,2),
			char(50),
			char(50),
			varchar(50),
			date,date,char(50);

-- Reporte de Siniestros Incurridos
-- Creado    : 05/08/2009 - Autor: Henry Giron 
-- Modificado: 05/08/2009 - Autor: Henry Giron
-- SIS v.2.0 - d_recl_sp_rec706_dw1 - DEIVID, S.A.

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
define _no_unidad           char(5);
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
define _cant                integer;
define v_fecha_siniestro	date;
define _vigencia_inic		date;
define _dt_siniestro		date;
define _vig_ini				date;
define _vig_fin				date;
define _porc_reas			dec;
define _porc_coas			dec;
define _cod_agente          char(5);
define _n_agente 			varchar(50);
define _fecha_reclamo,_fecha_documento,_fecha_suscripcion       date;
define estatus              char(50);
define _estatus_reclamo     char(1);

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
	 where seleccionado = 1 
	 group by no_reclamo,no_poliza,cod_ramo,periodo,numrecla,cod_sucursal

	let _cnt3 = 0;

	if _cod_ramo in('001','003') then
		select count(*)
		  into _cnt3 
		  from recrccob r, prdcober p
		 where r.cod_cobertura = p.cod_cobertura
	   	   and r.no_reclamo    = _no_reclamo
		   and p.relac_inundacion = 1;
	end if

	select no_documento,
		   vigencia_inic
	  into _no_documento,
		   _vigencia_inic
	  from emipomae 
	 where no_poliza = _no_poliza;

	{if _vigencia_inic < '01/07/2014' then
		continue foreach;
	end if}
	
	select count(*) 
	  into _cnt 
	  from reaexpol 
	 where no_documento = _no_documento
       and activo       = 1;  			--Tabla para excluir polizas

    if _cnt > 0 then
		continue foreach;
	end if

	let v_transaccion = 'TODOS';
	let v_fecha_siniestro = current;


   	if _reserva_bruto is null  then
		let _reserva_bruto = 0;
	end if
	if _reserva_neto is null  then
		let _reserva_neto = 0;
	end if

	foreach
		select cod_cobertura
		  into _cod_cobertura
		  from recrccob
		 where no_reclamo = _no_reclamo
		exit foreach;
	end foreach


-- Procesos para Filtros

let v_filtros = "";

if a_sucursal <> "*" THEN

	let v_filtros = trim(v_filtros) || " Sucursal: " ||  trim(a_sucursal);

	let _tipo = sp_sis04(a_sucursal);  -- Separa los Valores del String en una tabla de codigos

	if _tipo <> "E" then -- Incluir los Registros

		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal not in (select codigo from tmp_codigos);

	else		        -- Excluir estos Registros
		update tmp_sinis
		   set seleccionado = 0
		 where seleccionado = 1
		   and cod_sucursal in (select codigo from tmp_codigos);
	end if

	drop table tmp_codigos;
end if

	select fecha_siniestro,fecha_reclamo,fecha_documento,estatus_reclamo
	  into v_fecha_siniestro,_fecha_reclamo,_fecha_documento,_estatus_reclamo
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	If _estatus_reclamo = 'A' Then
	 LET estatus = 'ABIERTO';
	ELIF _estatus_reclamo = 'C' Then
	 LET estatus = 'CERRADO';
	ELIF _estatus_reclamo = 'R' Then
	 LET estatus = 'RE-ABIERTO';
	ELIF _estatus_reclamo = 'T' Then
	 LET estatus = 'EN TRAMITE';
	ELIF _estatus_reclamo = 'D' Then
	 LET estatus = 'DECLINADO';
	ELIF _estatus_reclamo = 'N' Then
	 LET estatus = 'NO APLICA';
	END IF

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

	select no_documento,
		   cod_contratante,
		   suma_asegurada,
		   vigencia_inic,
		   vigencia_final,
		   fecha_suscripcion
	  into v_doc_poliza,
	       _cod_cliente,
		   _suma_asegurada,
		   _vig_ini,
		   _vig_fin,
		   _fecha_suscripcion
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	 foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
			
			exit foreach;
    end foreach	
	
	select nombre
	  into _n_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	select nombre
	  into v_cliente_nombre		
	  from cliclien 
	 where cod_cliente = _cod_cliente;

   --let _inc_bruto = v_reserva_cedido + _fac_car_1;
	let _incurrido_neto = 0;

	RETURN v_doc_reclamo,         --1
	       v_doc_poliza,		  --2
	 	   v_cliente_nombre, 	  --3
	 	   v_fecha_siniestro,
		   _fecha_reclamo,
		   _reserva_bruto,		  --6
		   v_ramo_nombre,
		   _n_agente,
		   _suma_asegurada,
		   _fecha_documento,
		   _fecha_suscripcion,
		   estatus
		   with resume;
end foreach

drop table tmp_sinis;

end procedure;	   