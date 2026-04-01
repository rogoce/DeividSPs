-- Procedure que Retorna el Nombre del Tipo de Comprobante

-- Creado    : 23/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac11;

create procedure "informix".sp_sac11(
a_origen	smallint,
a_tipo_comp	smallint
) returning char(50);

define _tipo_compd		char(50);

define _cod_banco		char(3);
define _cod_chequera	char(3);

let _tipo_compd = "ORIGEN " || a_origen || " TIPO " || a_tipo_comp || " NO DEFINIDO EN SP_SAC11()";
 
if a_origen = 1 then -- Produccion

	if a_tipo_comp = 1 then
		let _tipo_compd = "PRIMA SUSCRITA";
	elif a_tipo_comp = 2 then
		let _tipo_compd = "COMISIONES";
	elif a_tipo_comp = 3 then
		let _tipo_compd = "REASEGURO CEDIDO";
	elif a_tipo_comp = 4 then
		let _tipo_compd = "REASEGURO ASUMIDO";
	elif a_tipo_comp = 5 then
		let _tipo_compd = "REASEGURO RETROCEDIDO";
	elif a_tipo_comp = 6 then
		let _tipo_compd = "RESERVA ESTADISTICA";
	elif a_tipo_comp = 7 then
		let _tipo_compd = "RESERVA CATASTROFICA";
	elif a_tipo_comp = 9 then
		let _tipo_compd = "CONSOLIDACION COMPANIAS";
	elif a_tipo_comp = 10 then
		let _tipo_compd = "COMPROBANTE PRODUCCION INCENDIO";
	elif a_tipo_comp = 11 then
		let _tipo_compd = "COMPROBANTE PRODUCCION AUTOMOVIL";
	elif a_tipo_comp = 12 then
		let _tipo_compd = "COMPROBANTE PRODUCCION FIANZAS";
	elif a_tipo_comp = 13 then
		let _tipo_compd = "COMPROBANTE PRODUCCION PERSONAS";
	elif a_tipo_comp = 14 then
		let _tipo_compd = "COMPROBANTE PRODUCCION PATRIMONIALES";
	end if

elif a_origen = 2 then -- Reclamos

	if a_tipo_comp = 1 then
		let _tipo_compd = "RESERVA DE SINIESTROS";
	elif a_tipo_comp = 2 then
		let _tipo_compd = "SINIESTROS PAGADOS";
	elif a_tipo_comp = 3 then
		let _tipo_compd = "SINIESTROS COASEGUROS";
	elif a_tipo_comp = 4 then
		let _tipo_compd = "REASEGURO CEDIDO - SINIESTROS PAGADOS";
	elif a_tipo_comp = 5 then
		let _tipo_compd = "REASEGURO CEDIDO - SALVAMENTO, RECUPERO, DEDUCIBLE";
	elif a_tipo_comp = 9 then
		let _tipo_compd = "CONSOLIDACION COMPANIAS";
	elif a_tipo_comp = 10 then
		let _tipo_compd = "COMPROBANTE RECLAMOS INCENDIO";
	elif a_tipo_comp = 11 then
		let _tipo_compd = "COMPROBANTE RECLAMOS AUTOMOVIL";
	elif a_tipo_comp = 12 then
		let _tipo_compd = "COMPROBANTE RECLAMOS FIANZAS";
	elif a_tipo_comp = 13 then
		let _tipo_compd = "COMPROBANTE RECLAMOS PERSONAS";
	elif a_tipo_comp = 14 then
		let _tipo_compd = "COMPROBANTE RECLAMOS PATRIMONIALES";
	end if

elif a_origen = 3 then -- Cobros

	if a_tipo_comp = 1 then

		let _tipo_compd = "RECIBOS";

	elif a_tipo_comp = 2 then

		let _tipo_compd = "COMPROBANTES";

	else
		
		let _cod_banco = "146";
		
		if a_tipo_comp < 10 then
			let _cod_chequera = "00" || a_tipo_comp;
		elif a_tipo_comp < 100 then
			let _cod_chequera = "0" || a_tipo_comp;
		else
			let _cod_chequera = a_tipo_comp;
		end if
		
		select nombre
		  into _tipo_compd
		  from chqchequ
		 where cod_banco    = _cod_banco
		   and cod_chequera = _cod_chequera;

	end if

elif a_origen = 4 then -- Cheques

	if a_tipo_comp = 1 then
		let _tipo_compd = "CHEQUES PAGADOS";
	elif a_tipo_comp = 2 then
		let _tipo_compd = "CHEQUES ANULADOS";
	elif a_tipo_comp = 3 then
		let _tipo_compd = "ACH PAGADOS";
	elif a_tipo_comp = 4 then
		let _tipo_compd = "ACH ANULADOS";
	end if

elif a_origen = 5 then -- Produccion - Incobrables

	if a_tipo_comp = 1 then
		let _tipo_compd = "INCOBRABLES - PRIMA SUSCRITA";
	elif a_tipo_comp = 2 then
		let _tipo_compd = "INCOBRABLES - COMISIONES";
	elif a_tipo_comp = 3 then
		let _tipo_compd = "INCOBRABLES - REASEGURO CEDIDO";
	elif a_tipo_comp = 4 then
		let _tipo_compd = "INCOBRABLES - REASEGURO ASUMIDO";
	elif a_tipo_comp = 5 then
		let _tipo_compd = "INCOBRABLES - REASEGURO RETROCEDIDO";
	elif a_tipo_comp = 6 then
		let _tipo_compd = "INCOBRABLES - RESERVA ESTADISTICA";
	elif a_tipo_comp = 7 then
		let _tipo_compd = "INCOBRABLES - RESERVA CATASTROFICA";
	end if

elif a_origen = 6 then -- Planilla

	if a_tipo_comp = 1 then
		let _tipo_compd = "PLANILLA - CHEQUES PAGADOS";
	elif a_tipo_comp = 2 then
		let _tipo_compd = "PLANILLA - CHEQUES ANULADOS";	
	elif a_tipo_comp = 3 then
		let _tipo_compd = "PLANILLA - ACH PAGADOS";
	elif a_tipo_comp = 4 then
		let _tipo_compd = "PLANILLA - ACH ANULADOS";
	end if


elif a_origen = 7 then -- Cancelaciones Masivas

	if a_tipo_comp = 1 then
		let _tipo_compd = "PRIMA SUSCRITA - CAN";
	elif a_tipo_comp = 2 then
		let _tipo_compd = "COMISIONES - CAN";
	elif a_tipo_comp = 3 then
		let _tipo_compd = "REASEGURO CEDIDO - CAN";
	elif a_tipo_comp = 4 then
		let _tipo_compd = "REASEGURO ASUMIDO - CAN";
	elif a_tipo_comp = 5 then
		let _tipo_compd = "REASEGURO RETROCEDIDO - CAN";
	elif a_tipo_comp = 6 then
		let _tipo_compd = "RESERVA ESTADISTICA - CAN";
	elif a_tipo_comp = 7 then
		let _tipo_compd = "RESERVA CATASTROFICA - CAN";
	elif a_tipo_comp = 9 then
		let _tipo_compd = "CONSOLIDACION COMPANIAS - CAN";
	end if

elif a_origen = 8 then -- Cobros

	if a_tipo_comp = 1 then
		let _tipo_compd = "RECIBOS - SALDOS CREDITOS";
	elif a_tipo_comp = 2 then
		let _tipo_compd = "COMPROBANTES - SALDOS CREDITOS";
	end if

elif a_origen = 9 then -- Reaseguro

	if a_tipo_comp = 1 then
		let _tipo_compd = "PAGOS DE REASEGURO";
	end if

elif a_origen = 10 then -- Suministros

	if a_tipo_comp = 1 then
		let _tipo_compd = "SALIDA DE SUMINISTROS";
	elif a_tipo_comp = 2 then
		let _tipo_compd = "ENTRADA DE SUMINISTROS";
	end if

elif a_origen = 11 then -- Agentes

	if a_tipo_comp = 1 then
		let _tipo_compd = "BONIFICACION DE COBRANZAS";
	elif a_tipo_comp = 2 then
		let _tipo_compd = "";
	end if

elif a_origen = 12 then -- Comprobante de Reaseguro

	if a_tipo_comp = 1 then
		let _tipo_compd = "REASEGURO CAJAS-COMPROBANTES";
	elif a_tipo_comp = 2 then
		let _tipo_compd = "REASEGURO RECLAMOS PAGOS";
	elif a_tipo_comp = 3 then
		let _tipo_compd = "REASEGURO RECLAMOS SALVAMENTOS";
	elif a_tipo_comp = 4 then
		let _tipo_compd = "REASEGURO RECLAMOS RECUPEROS";
	elif a_tipo_comp = 5 then
		let _tipo_compd = "REASEGURO RECLAMOS DEDUCIBLES";
	elif a_tipo_comp = 6 then
		let _tipo_compd = "";
	elif a_tipo_comp = 7 then
		let _tipo_compd = "";
	elif a_tipo_comp = 9 then
		let _tipo_compd = "";
	elif a_tipo_comp = 10 then
		let _tipo_compd = "REASEGURO PRODUCCION INCENDIO";
	elif a_tipo_comp = 11 then
		let _tipo_compd = "REASEGURO PRODUCCION AUTOMOVIL";
	elif a_tipo_comp = 12 then
		let _tipo_compd = "REASEGURO PRODUCCION FIANZAS";
	elif a_tipo_comp = 13 then
		let _tipo_compd = "REASEGURO PRODUCCION PERSONAS";
	elif a_tipo_comp = 14 then
		let _tipo_compd = "REASEGURO PRODUCCION PATRIMONIALES";
	elif a_tipo_comp = 15 then
		let _tipo_compd = "REASEGURO CHEQ. PAG. DEV. PRIMAS";
	elif a_tipo_comp = 16  then
		let _tipo_compd = "REASEGURO CHEQ. ANU. DEV. PRIMAS";
	end if

elif a_origen = 13 then -- Comprobante de Inventario

	if a_tipo_comp = 1 then
	
		let _tipo_compd = "COMPROBANTE DE INVENTARIO";

	end if

end if

return _tipo_compd;

end procedure