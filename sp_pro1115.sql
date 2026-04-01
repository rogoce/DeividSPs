-- Ajustes
-- Amado Perez 18/05/2023                                  
drop procedure sp_pro1115;

create procedure sp_pro1115()
returning integer, char(50);

define _no_documento    char(20);
define _prima           dec(16,2); 
define _descuento       dec(16,2);  
define _prima_neta      dec(16,2); 
define _impuesto        dec(16,2);
define _prima_bruta	    dec(16,2);  
define r_error        	integer;
define r_descripcion  	char(50);
define r_error_isam   	integer;

begin

on exception set r_error, r_error_isam, r_descripcion
 	return r_error, r_descripcion;
end exception

set isolation to dirty read;

let r_error       = 0;
let r_descripcion = 'Actualizacion Exitosa ...';
let _prima = 0.00; 
let _descuento = 0.00; 
let _prima_neta = 0.00; 
let _impuesto = 0.00; 
let _prima_bruta = 0.00;

foreach
	select no_documento, 
	       prima, 
		   descuento, 
		   prima_neta, 
		   impuesto, 
		   prima_bruta
	  into _no_documento, 
	       _prima, 
		   _descuento, 
		   _prima_neta, 
		   _impuesto, 
		   _prima_bruta	   
	  from endedmae
	 where no_documento in (
		'0217-11476-47',
		'0219-94040-47',
		'0219-94039-47',
		'0216-10930-47',
		'0222-16627-47',
		'0218-12406-47',
		'0219-14281-47',
		'0216-10935-47',
		'0215-10381-47',
		'0216-00283-12',
		'0219-14312-47',
		'0213-91851-47',
		'0218-01238-01',
		'0222-16646-47',
		'0219-01656-01',
		'0221-01425-01',
		'0217-00671-11')
	  and no_endoso = '00000'
	  and actualizado = 1
	  and year(vigencia_inic) = 2023
 order by no_documento
 
   update emirenduc
      set prima_sin_desc = _prima,
	      monto_desc     = _descuento,
		  prima          = _prima_neta,
		  monto_imp      = _impuesto,
		  tot_prima      = _prima_bruta
    where no_documento   = _no_documento
      and periodo        = '2023-07';	

return 0, _no_documento with resume;
end foreach


return r_error, r_descripcion;

end
end procedure;