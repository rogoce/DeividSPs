-- Pasar polizas de Salud para el Call Center
-- 
-- Creado    : 31/03/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/03/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_cobr_sp_cob100_dw1 - DEIVID, S.A.

drop procedure sp_cas030;

create procedure sp_cas030()
returning char(20),
          char(1);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _cobra_poliza	char(1);
define _cantidad		smallint;
define _estatus_poliza	char(1);
define _cod_tipoprod	char(3);

define _dia_cobros1		smallint;
define _dia_cobros2		smallint;
define _dia_temporal	smallint;
define _fecha_1_pago	date;
define _cod_pagador		char(10);

define _cod_cobrador	char(3);
define _fecha_ult_pro	date;


set isolation to dirty read;

begin work;

foreach 
 select no_documento
   into	_no_documento
   from emipomae 
  where actualizado  = 1
    and cod_ramo     = "018"
--	and no_documento = "1800-00009-01"
  group by no_documento		

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_ramo,
		   cobra_poliza,
		   estatus_poliza,
		   dia_cobros1,
		   dia_cobros2,
		   fecha_primer_pago,
		   cod_pagador
	  into _cod_tipoprod,
		   _cod_ramo,
		   _cobra_poliza,
		   _estatus_poliza,
		   _dia_cobros1,
		   _dia_cobros2,
		   _fecha_1_pago,
		   _cod_pagador
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if

--	if _cod_ramo <> "018" then
--		continue foreach;
--	end if

	if _cobra_poliza <> "E" then
		continue foreach;
	end if

	if _estatus_poliza = 2 or
	   _estatus_poliza = 4 then
		continue foreach;
	end if

	select count(*)
	  into _cantidad
	  from caspoliza
	 where no_documento = _no_documento;

	if _cantidad = 0 then

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

		call sp_cob102(_cod_pagador, _dia_cobros1, _dia_cobros2, _no_documento);

		-- Determinar el Cobrador para los registros del call center dependiendo del area

		call sp_cas007();

		select cod_cobrador
		  into _cod_cobrador
		  from cascliente
		 where cod_cliente = _cod_pagador;

		select fecha_ult_pro
		  into _fecha_ult_pro
		  from cobcobra
		 where cod_cobrador = _cod_cobrador;

		let _fecha_ult_pro = _fecha_ult_pro + 2;
		let _dia_cobros1   = day(_fecha_ult_pro);
		
		update cascliente
		   set dia_cobros3 = _dia_cobros1
		 where cod_cliente = _cod_pagador;
--}

		return _no_documento,
		       _estatus_poliza
			   with resume;

	end if
	
end foreach

commit work;
--rollback work;

end procedure
