-- Insercion de registros en caspoliza y cascliente

-- Creado    : 08/05/2003 - Autor: Armando Moreno

-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.


drop procedure sp_cas027;

create procedure sp_cas027(
a_cod_cliente	char(10),
a_no_documento	char(20) DEFAULT "*"
)
returning integer;

define _dia_cobros1		integer;
define _dia_cobros2		integer;
define v_documento		char(20);
define _no_poliza		char(10);
define _cod_tipoprod	char(3);
define _cod_formapag	char(3);
define _fecha_1_pago	date;
define _dia_temporal	smallint;
define _estatus_poliza	smallint;
define _cantidad		smallint;
define _tipo_forma      smallint;

--set debug file to "sp_cas027.trc";
--trace on;

set isolation to dirty read;

if a_no_documento = "*" then

	select count(*)
	  into _cantidad
	  from cascliente
	 where cod_cliente = a_cod_cliente;

	{if _cantidad = 0 then
		return 0;
	end if}

	foreach
	 select distinct no_documento
	   into v_documento
	   from emipomae
	  where cod_pagador = a_cod_cliente
	    and actualizado = 1
	  group by 1

		let _no_poliza = sp_sis21(v_documento);

		select dia_cobros1,
			   dia_cobros2,
			   cod_tipoprod,
			   fecha_primer_pago,
			   estatus_poliza,
			   cod_formapag
		  into _dia_cobros1,
			   _dia_cobros2,
			   _cod_tipoprod,
			   _fecha_1_pago,
			   _estatus_poliza,
			   _cod_formapag
		  from emipomae
		 where no_poliza = _no_poliza;

		select tipo_forma
	      into _tipo_forma
	      from cobforpa
	     where cod_formapag = _cod_formapag;

{	    if _tipo_forma = 6 or _tipo_forma = 5 or _tipo_forma = 3 then		--corredor,ancon
		else
			continue foreach;
		end if

	if _cod_tipoprod = "002" or _cod_tipoprod = "004" then
		continue foreach;
	end if

	if _estatus_poliza <> 1 then	 --debe ser vigente
		continue foreach;
	end if}

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

		call sp_cob102(a_cod_cliente, _dia_cobros1, _dia_cobros2, v_documento);

		{update emipomae
		   set cobra_poliza = "E",		  se puso en comentario ya que todas las polizas pueden entrar a la estructura de campaña  Roman 21/09/2011
		       cod_formapag = "006"
	     where no_poliza    = _no_poliza; }

	end foreach

else --el pagador no paga ninguna poliza

	let _no_poliza = sp_sis21(a_no_documento);

	select dia_cobros1,
		   dia_cobros2,
		   cod_tipoprod,
		   fecha_primer_pago,
		   estatus_poliza
	  into _dia_cobros1,
		   _dia_cobros2,
		   _cod_tipoprod,
		   _fecha_1_pago,
		   _estatus_poliza
	  from emipomae
	 where no_poliza = _no_poliza;

   --	if _cod_tipoprod = "002" or _cod_tipoprod = "004" then
   --		return 1;
   --	end if

  {	if _estatus_poliza <> 1 then
		return 1;
	end if }

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

	if _dia_cobros1 is null then
		let _dia_cobros1 = 15;
	end if

	if _dia_cobros2 is null then
		let _dia_cobros2 = 15;
	end if

	call sp_cob102(a_cod_cliente, _dia_cobros1, _dia_cobros2, a_no_documento);

	-- Direccion de Cobros
	call sp_cas001(a_cod_cliente);

	-- Determinar el Cobrador para los registros del call center dependiendo del area
	--call sp_cas007();
		
	--update emipomae                  se puso en comentario ya que todas las polizas pueden entrar a la estructura de campaña  Roman 21/09/2011
	--   set cobra_poliza = "E",
	--       cod_formapag = "006"
    --where no_poliza    = _no_poliza;

	return 0;
end if

select count(*)
  into _cantidad
  from caspoliza
 where cod_cliente = a_cod_cliente;

if _cantidad = 0 then

	delete from cascliente
	 where cod_cliente = a_cod_cliente;

	return 1;

else

	-- Direccion de Cobros
	--call sp_cas001(a_cod_cliente);

	-- Determinar el Cobrador para los registros del call center dependiendo del area
	--call sp_cas007();

end if

return 0;

end procedure;

