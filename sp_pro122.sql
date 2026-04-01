-- Polizas que Cobra Ancon y no estan en el Call Center
-- 
-- Creado    : 23/06/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 23/06/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_pro122;

create procedure sp_pro122()
returning integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
          integer,
		  char(3),
          integer,
          integer;

define _no_documento	char(20);
define _no_poliza		char(10);
define _estatus_poliza	char(1);
define _fecha_emision	date;
define _vigencia_final	date;
define _dias			integer;
define _cant_doc_end	integer;

define _cant_pol 		integer;
define _cant_doc		integer;

define _cant_pol_vigentes integer;
define _cant_pol_canc_0   integer;
define _cant_pol_canc_1   integer;
define _cant_pol_venc_0   integer;
define _cant_pol_venc_1   integer;
	   
define _cant_doc_vigentes integer;
define _cant_doc_canc_0   integer;
define _cant_doc_canc_1   integer;
define _cant_doc_venc_0   integer;
define _cant_doc_venc_1   integer;

define _cod_ramo		  char(3);
	
set isolation to dirty read;

foreach
 select no_documento
   into	_no_documento
   from emipomae 
  where actualizado  = 1
  group by no_documento		

	let _no_poliza = sp_sis21(_no_documento);

	select estatus_poliza,
           fecha_cancelacion,
		   vigencia_final,
		   cod_ramo
	  into _estatus_poliza,
           _fecha_emision,
		   _vigencia_final,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	let _cant_pol_vigentes = 0;
	let _cant_pol_canc_0   = 0;
	let _cant_pol_canc_1   = 0;
	let _cant_pol_venc_0   = 0;
	let _cant_pol_venc_1   = 0;

	let _cant_doc_vigentes = 0;
	let _cant_doc_canc_0   = 0;
	let _cant_doc_canc_1   = 0;
	let _cant_doc_venc_0   = 0;
	let _cant_doc_venc_1   = 0;

	select count(*)
	  into _cant_doc_end
	  from endedmae
	 where no_documento = _no_documento
	   and actualizado  = 1;


	if _estatus_poliza = 1 then

		let _cant_pol_vigentes = 1;
		let _cant_doc_vigentes = _cant_doc_end;

	elif _estatus_poliza = 2 or
	     _estatus_poliza = 4 then

		let _dias = today - _fecha_emision;

		if _dias < 366 then
			let _cant_pol_canc_0 = 1;
			let _cant_doc_canc_0 = _cant_doc_end;
		else
			let _cant_pol_canc_1 = 1;
			let _cant_doc_canc_1 = _cant_doc_end;
		end if			


	elif _estatus_poliza = 3 then

		let _dias = today - _vigencia_final;

		if _dias < 366 then
			let _cant_pol_venc_0 = 1;
			let _cant_doc_venc_0 = _cant_doc_end;
		else
			let _cant_pol_venc_1 = 1;
			let _cant_doc_venc_1 = _cant_doc_end;
		end if			

	end if

	let _cant_pol = _cant_pol_vigentes + _cant_pol_canc_0 + _cant_pol_canc_1 + _cant_pol_venc_0 + _cant_pol_venc_1;
	let _cant_doc = _cant_doc_vigentes + _cant_doc_canc_0 + _cant_doc_canc_1 + _cant_doc_venc_0 + _cant_doc_venc_1;

	return _cant_pol_vigentes,
		   _cant_doc_vigentes,
		   _cant_pol_canc_0,
		   _cant_doc_canc_0,
		   _cant_pol_canc_1,
		   _cant_doc_canc_1,
		   _cant_pol_venc_0,
		   _cant_doc_venc_0,
		   _cant_pol_venc_1,
		   _cant_doc_venc_1,
		   _cod_ramo,
		   _cant_pol,
		   _cant_doc
		   with resume;

end foreach

end procedure