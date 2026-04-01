-- Procedimiento para verifica las polizas de salud con morosidad a 60 dias
--
-- Creado    : 18/03/2011 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob270;

create procedure "informix".sp_cob270()
returning char(20),
          dec(16,2),
          dec(16,2),
          dec(16,2),
		  dec(16,2);

define _no_documento	char(20);
define _cod_compania	char(3);
define _cod_sucursal	char(3);

define _por_vencer		dec(16,2);
define _exigible		dec(16,2);      
define _corriente		dec(16,2);    
define _monto_30		dec(16,2);
define _monto_60		dec(16,2);      
define _monto_90		dec(16,2);
define _saldo			dec(16,2);   
define _monto_60_mas	dec(16,2);      

define _periodo			char(7);
define _fecha			date;

set isolation to dirty read;

let _fecha        = today;
let _periodo      = sp_sis39(_fecha);

let _saldo        = 0;
let _monto_60 	  = 0;
let _monto_90	  = 0;
let _monto_60_mas = 0;
  
foreach
 select no_documento,
        cod_compania,
		cod_sucursal
   into _no_documento,
        _cod_compania,
		_cod_sucursal
   from emipomae
  where actualizado    = 1
    and estatus_poliza = 1
    and cod_ramo       = "018" 

	call sp_cob33(_cod_compania, _cod_sucursal, _no_documento, _periodo, _fecha) 
	returning _por_vencer,
	 		  _exigible,
			  _corriente,
			  _monto_30,
			  _monto_60,
			  _monto_90,
			  _saldo;

	let _monto_60_mas = _monto_60 + _monto_90;

	if _monto_60_mas > 0 then

		return _no_documento,
		       _saldo,
			   _monto_60,
			   _monto_90,
			   _monto_60_mas
			   with resume;

	end if

end foreach

return "",
       0,
       0,
       0,
	   0;

end procedure
