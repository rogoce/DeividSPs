-- Call Center - Datos Iniciales
-- 
-- Creado    : 13/05/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 13/05/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas016;

create procedure sp_cas016()

define _doc_poliza		char(20);		  
define _no_poliza		char(10);
define _cobra_poliza	char(1);
define _cod_cliente		char(10);
define _estatus_poliza	smallint;
define _dia_cobros1		smallint;
define _dia_cobros2		smallint;
define _cod_tipoprod	char(3);
define _fecha_1_pago	date;
define _dia_temporal	smallint;

delete from caspoliza;
delete from cascliente;
delete from cobcahis;
delete from cobcapen;
delete from cobcadate;
delete from cobruter2;
delete from cobruter1;

set isolation to dirty read;

-- Cargar los Registros para el Call Center

foreach 
 select no_documento
   into	_doc_poliza
   from emipomae 
  where cod_compania = "001"
    and actualizado  = 1
  group by no_documento		

	let _no_poliza = sp_sis21(_doc_poliza);

	select cobra_poliza,
		   cod_pagador,
		   estatus_poliza,
		   dia_cobros1,
		   dia_cobros2,
		   cod_tipoprod,
		   fecha_primer_pago
	  into _cobra_poliza,
		   _cod_cliente,
		   _estatus_poliza,
		   _dia_cobros1,
		   _dia_cobros2,
		   _cod_tipoprod,
		   _fecha_1_pago
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

	if _cobra_poliza = "E" then

		if _estatus_poliza = 1 then

			if _dia_cobros1 > _dia_cobros2 then
				let _dia_temporal = _dia_cobros2;
				let _dia_cobros2  = _dia_cobros1;
				let _dia_cobros1  = _dia_temporal;
			end if

			if _dia_cobros1 <> _dia_cobros2 then
				if (_dia_cobros2 - _dia_cobros1) <= 10 then
					let _dia_cobros1 = _dia_cobros2;
				end if
			end if

			if _dia_cobros1 = 0 then
				let _dia_cobros1 = day(_fecha_1_pago);
				let _dia_cobros2 = day(_fecha_1_pago);
			end if

			call sp_cob102(_cod_cliente, _dia_cobros1, _dia_cobros2, _doc_poliza);

		end if

	end if

end foreach

-- Actualizar las Direcciones de Cobros Utilizando los Datos del Programa anterior de 
-- Dia de Cobros

call sp_cas001();

-- Determinar el Cobrador para los registros del call center dependiendo del area

call sp_cas007();

update cobcobra
   set fecha_ult_pro = "30/05/2003"
 where tipo_cobrador = 1;

end procedure
