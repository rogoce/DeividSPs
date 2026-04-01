-- Procedimiento que determina si la póliza aplica para el cobro reiterado electronico de morosidad.
-- Creado    : 24/02/2015 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob372;
create procedure sp_cob372(a_fecha_desde date, a_fecha_hasta date)
returning	integer			as Cod_Error,
			varchar(100)	as Mensaje_Error;

define _error_desc			varchar(100);
define _no_documento		char(20);
define _cod_tipoprod		char(3);
define _cod_ramo			char(3);
define _no_poliza			char(10);
define _monto_cobrado		dec(16,2);
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _exigible		dec(16,2);
define _monto_30		dec(16,2);
define _monto_60		dec(16,2);
define _monto_90		dec(16,2);
define _saldo			dec(16,2);
define _no_letra_verif		smallint;
define _cnt_emiletra		smallint;
define _renglon			smallint;
define _dia				smallint;
define _error_isam		integer;
define _error			integer;
define _fecha_primer_pago	date;
define _vigencia_inic		date;

set isolation to dirty read;

--set debug file to "sp_cob371.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

let _no_letra_verif = 1;

select cod_campana
  from cascampana
 where estatus = 2
   and tipo_campana = 3
  into temp tmp_cascampana;

foreach
	select no_documento,
		   cod_ramo,
		   cod_tipoprod,
		   no_poliza,
		   vigencia_inic,
		   fecha_primer_pago
	  into _no_documento,
		   _cod_ramo,
		   _cod_tipoprod,
		   _no_poliza,
		   _vigencia_inic,
		   _fecha_primer_pago
	  from emipomae
	 where vigencia_inic >= a_fecha_desde
	   and fecha_impresion <= a_fecha_hasta
	   and nueva_renov = 'N'
	   and actualizado = 1

	let _monto_cobrado = 0.00;
	let _monto_pag = 0.00;
	let _monto_pen = 0.00;
	let _cnt_emiletra = 0;

	if _cod_ramo in ('004','008','016','018','019') then --Ramos Personales y Fianzas
		continue foreach;
	end if

	if _cod_grupo in ('00000','1000') then
		continue foreach;
	end if

	select tipo_produccion
	  into _tipo_produccion
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

	if _tipo_produccion = 3 then
		continue foreach;
	end if

	select count(*)
	  into _cnt_emiletra
	  from emiletra
	 where no_documento
	   and no_letra = _no_letra_verif
	   and pagada = 1;

	if _cnt_emiletra is null then
		let _cnt_emiletra = 0;
	end if

	if _cnt_emiletra > 0 then
		select sum(monto)
		  into _monto_cobrado
		  from cobredet
		 where no_poliza = _no_poliza
		   and tipo_mov in ('P','N','X')
		   and actualizado = 1;

		if _monto_cobrado is null then
			let _monto_cobrado = 0;
		end if
	else
		select monto_pag,
			   monto_pen
		  into _monto_pag,
			   _monto_pen
		  from emiletra
		 where no_poliza = _no_poliza
		   and no_letra = _no_letra_verif;
	end if
end foreach

end
end procedure;