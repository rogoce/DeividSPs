-- Verificar Corredores Directos Contra Forma de Pago Cobra Corredor
-- 
-- Creado    : 03/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 03/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas026;

create procedure sp_cas026()
returning char(20),
          char(1),
          char(3),
          smallint,
          smallint,
          char(1),
          date,
          date,
          char(1);

define _doc_poliza		char(20);		  
define _no_poliza		char(10);
define _incobrable		smallint;
define _cod_formapag	char(3);
define _tipo_forma		smallint;
define _cod_agente		char(5);
define _cobra_poliza	char(1);
define _cobra_poliza2	char(1);
define _cod_tipoprod	char(3);
define _formapag        char(2);

define _asignado		smallint;
define _cantidad        integer;
define _gestion			char(1);

define _doc_caspoliza	char(20);
define _dia_cobros1		smallint;
define _dia_cobros2		smallint;
define _dia_temporal	smallint;
define _estatus_poliza	char(1);

define _vigencia_inic	date;
define _vigencia_final	date;
define _error_vencida	char(1);
define _fecha_1_pago	date;
define _cod_cliente		char(10);
define _cod_cobrador	char(3);
define _fecha_ult_pro	date;

define _error			integer;

let _cantidad = 0;

--set debug file to "sp_cas026.trc";
--trace on;

set isolation to dirty read;

begin work;

begin
on exception set _error

	rollback work;

	return _doc_poliza,
	       "",
		   "",
		   _error,
		   0,
		   "",
		   null,
		   null,
		   "";

end exception

foreach 
 select no_documento
   into	_doc_poliza
   from emipomae 
  where actualizado  = 1
--    and no_documento = "0103-00029-03"
  group by no_documento		

	let _no_poliza = sp_sis21(_doc_poliza);

	select incobrable,
	       cobra_poliza,
		   cod_formapag,
		   cod_tipoprod,
		   gestion,
		   dia_cobros1,
		   dia_cobros2,
		   estatus_poliza,
		   vigencia_inic,
		   vigencia_final,
		   fecha_primer_pago,
		   cod_pagador
	  into _incobrable,
	       _cobra_poliza,
		   _cod_formapag,
		   _cod_tipoprod,
		   _gestion,
		   _dia_cobros1,
		   _dia_cobros2,
		   _estatus_poliza,
		   _vigencia_inic,
		   _vigencia_final,
		   _fecha_1_pago,
		   _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

	select tipo_forma
	  into _tipo_forma
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	if _tipo_forma <> 6 then
		continue foreach;
	end if

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza
		exit foreach;
	end foreach

	if _cod_agente <> "00099" then
		continue foreach;
	end if

	if _cobra_poliza <> "C" then
		continue foreach;
	end if

	if _estatus_poliza = "2" or
	   _estatus_poliza = "3" then
		continue foreach;
	end if

	if _doc_poliza = "1503-00002-01"	or
	   _doc_poliza = "1302-00006-01"	or
	   _doc_poliza = "0602-00212-01"	or
	   _doc_poliza = "0902-00167-01"	or
	   _doc_poliza = "0103-00074-01"	or
	   _doc_poliza = "0202-02726-01"	or
	   _doc_poliza = "0203-00021-01"	or
	   _doc_poliza = "0303-00065-01"	or
	   _doc_poliza = "1502-00017-01"	or
	   _doc_poliza = "1402-00021-01"	or
	   _doc_poliza = "0202-02727-01"	or
	   _doc_poliza = "1503-00014-01"	or
	   _doc_poliza = "1503-00016-01"	or
	   _doc_poliza = "0103-00133-01"	or
	   _doc_poliza = "0203-00960-01"	or
	   _doc_poliza = "0303-00080-01"	or
	   _doc_poliza = "0503-00014-01"	or
	   _doc_poliza = "0603-00066-01"	or
	   _doc_poliza = "0603-00067-01"	or
	   _doc_poliza = "0603-00068-01"	or
	   _doc_poliza = "0903-00097-01"	or
	   _doc_poliza = "1503-00026-01"	or
	   _doc_poliza = "1503-00027-01"	or
	   _doc_poliza = "0603-00011-01"	or
	   _doc_poliza = "1703-00002-01"	then
		continue foreach;
	end if

	select no_documento
	  into _doc_caspoliza
	  from caspoliza
	 where no_documento = _doc_poliza;
		
	let _error_vencida = "";
	if _estatus_poliza = "3"    and
	   _vigencia_final >= today then
		let _error_vencida = "*";
	end if


	if _doc_caspoliza is null then

--{
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
		call sp_cas007();

		select cod_cobrador
		  into _cod_cobrador
		  from cascliente
		 where cod_cliente = _cod_cliente;

		select fecha_ult_pro
		  into _fecha_ult_pro
		  from cobcobra
		 where cod_cobrador = _cod_cobrador;

		if _fecha_ult_pro is null then
			let _fecha_ult_pro = today;
		end if

		let _fecha_ult_pro = _fecha_ult_pro + 2;

		update cascliente
		   set dia_cobros3 = day(_fecha_ult_pro)
		 where cod_cliente = _cod_cliente;
		
		update emipomae
		   set cobra_poliza = "E",
		       cod_formapag = "006"
		 where no_poliza    = _no_poliza;

--}

		return _doc_poliza,
		       _cobra_poliza,
			   _cod_formapag,
			   _dia_cobros1,
			   _dia_cobros2,
			   _estatus_poliza,
			   _vigencia_inic,
			   _vigencia_final,
			   _error_vencida
			   with resume;

	end if

end foreach

commit work;

end

end procedure