-- Procedimiento para validar los % de la ruta de reaseguro versus los % de la factura
-- Creado    : 25/07/2017 - Autor: Armando Moreno M.

drop procedure sp_sis451;
create procedure sp_sis451(a_no_poliza char(10))
returning smallint,char(100);

define _porc_partic_suma	dec(16,2);
define _porc_partic_prima	dec(16,2);
define _porc_partic_prima_e dec(16,2);
define _porc_partic_suma_e dec(16,2);

define _cod_cober_reas		char(3);
define _cod_endomov			char(3);
define _cod_contrato,_no_unidad,_cod_ruta 	char(5);
define _cod_ramo			char(3);

define _error				smallint;
define _error_isam			smallint;
define _error_desc			char(100);

BEGIN

ON EXCEPTION SET _error, _error_isam, _error_desc 
 	RETURN _error, _error_desc;         
END EXCEPTION           

--set debug file to "sp_sis450.trc";
--trace on;

set isolation to dirty read;

let a_no_poliza = trim(a_no_poliza);

let _porc_partic_prima = 0.00;
let _porc_partic_suma  = 0.00;
let _porc_partic_prima_e = 0.00;
let _porc_partic_suma_e  = 0.00;


foreach
	select no_unidad,
		   porc_partic_prima,
	       porc_partic_suma,
		   cod_contrato,
		   cod_cober_reas
	  into _no_unidad,
	       _porc_partic_prima_e,
           _porc_partic_suma_e,
           _cod_contrato,
           _cod_cober_reas
	from emifacon
   where no_poliza = a_no_poliza
	 and no_endoso = '00000'
	 order by no_unidad,orden

	if (_porc_partic_suma_e <> 0 And _porc_partic_prima_e = 0) Or (_porc_partic_suma_e = 0 And _porc_partic_prima_e <> 0) then
		return 1,"Unidad: " || _no_unidad || ", Ambos % deben tener valor para el contrato, Por Favor Verifique ...";
	end if

end foreach
end
return 0, "Actualizacion Exitosa";
end procedure;