-- Proceso que verifica si hay diferencia del impuesto entre endedmae y endeduni
-- Creado    : 08/08/2012 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_diferencia_impuesto;

create procedure "informix".sp_diferencia_impuesto()
returning char(20),
		  char(10),
          char(5),
          dec(16,2);

define _no_documento	char(20);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _imp_endeduni	dec(16,2);
define _imp_endedmae	dec(16,2);
define _unidad_imp		dec(16,2);
define _dif_imp			dec(16,2);
define _cant_iter		smallint;
define _cont			smallint;

let _no_unidad		= '00000';
let _imp_endeduni	= 0.00;
let	_imp_endedmae	= 0.00;
let	_unidad_imp		= 0.00;
let	_dif_imp		= 0.00;
let _cant_iter		= 0;
let _cont			= 0;

--set debug file to "sp_diferencia_impuesto.trc";
--trace on;


foreach
	select no_poliza,
		   no_documento	
	  into _no_poliza,
		   _no_documento	
	  from emipomae
	 where cod_compania   = '001'
	   and cod_ramo       = '018'
	   and vigencia_final >= '01/07/2011'
	   and vigencia_final <= '31/07/2011'
	   and estatus_poliza in (1,3)
	   and actualizado    = 1
	   and (cod_tipoprod  = '001' or cod_tipoprod  = '005')
	   and no_documento   not in ("1802-00086-01", "1800-00036-01")	

	foreach
		select no_endoso,
			   impuesto	
		  into _no_endoso,
			   _imp_endedmae	
		  from endedmae
		 where no_poliza = _no_poliza
	
		select sum(impuesto)
		  into _imp_endeduni
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		let _dif_imp	= (_imp_endedmae - _imp_endeduni);
		
		if _dif_imp <> 0.00 then
			return _no_documento,
				   _no_poliza,
				   _no_endoso,
				   _dif_imp with resume;
		end if
	end foreach
end foreach
end procedure

				   	   
