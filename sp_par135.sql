-- Procedimiento que genera las cancelaciones por lote de las incobrables
-- 
-- Creado     : 24/10/2002 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_par135;

create procedure "informix".sp_par135()
returning char(20),
          dec(16,2),
          dec(16,2),
          char(10),
          char(5),
          dec(16,2);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _saldo			dec(16,2);
define _prima_endoso	dec(16,2);

define _tiene_impuesto	smallint;

define _prima_neta		dec(16,2);
define _impuesto		dec(16,2);
define _suma_impuesto	dec(16,2);
define _factor_impuesto	dec(16,2);
define _cod_impuesto	char(3);


define _error			integer;
define _descripcion		char(50);
define _cantidad		integer;

--set debug file to "sp_par129.trc";
--trace on;

set isolation to dirty read;

--begin work;


let _cantidad = 0;
 
foreach
 select no_documento,
        saldo
   into _no_documento,
        _saldo
   from cobinc04

	let _prima_bruta = sp_cob174(_no_documento);

--	if _prima_bruta <> 0.00 then

		select no_poliza,
		       no_endoso,
			   prima_bruta,
			   tiene_impuesto
		  into _no_poliza,
		       _no_endoso,
			   _prima_endoso,
			   _tiene_impuesto
		  from endedmae
		 where no_documento = _no_documento
		   and cod_endomov  = "002"
		   and cod_tipocan  = "013";
		
{
		let _prima_bruta = _prima_bruta * -1;

		if _tiene_impuesto = 1 then

			Let _suma_impuesto = 0.00;

			Foreach	
			 Select cod_impuesto
			   Into _cod_impuesto
			   From emipolim
			  Where no_poliza = _no_poliza

				Select factor_impuesto
				  Into _factor_impuesto
				  From prdimpue
				 Where cod_impuesto = _cod_impuesto;
					    
				Let _suma_impuesto = _suma_impuesto  + (_factor_impuesto / 100);

			End Foreach

			let _prima_neta = _prima_bruta / (1 + _suma_impuesto);

		else

			let _prima_neta = _prima_bruta;

		end if

		let _impuesto = _prima_bruta - _prima_neta;

		update endedmae
		   set prima_neta     = _prima_neta,
			   impuesto       = _impuesto,
			   prima_bruta    = _prima_bruta
		 where no_poliza      = _no_poliza
		   and no_endoso      = _no_endoso;
}
		return _no_documento,
		       _saldo,
			   _prima_bruta,
			   _no_poliza,
			   _no_endoso,
			   _prima_endoso
			   with resume;

--	end if

end foreach

end procedure
