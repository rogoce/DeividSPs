-- Generacion del Archivo para BAC --- American Express
-- Creado: 29/02/2016 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob294;
create procedure "informix".sp_cob294(
a_compania		char(3),
a_sucursal		char(3),
a_user			char(8))
returning	smallint,
			char(100);

define _nombre			char(100);
define _campo			char(64);
define _no_documento	char(20);
define _no_tarjeta		char(19);
define _id_terminal		char(10);
define _afiliacion		char(13);
define _monto_char		char(13);
define _cod_cliente		char(10);
define _fecha_char		char(10);
define _fecha_exp		char(7);
define _no_lote_char	char(5);
define _cant_tran_char	char(3);
define _id_operador		char(3);
define _id_sucursal		char(3);
define _codigo			char(2);
define _monto			dec(16,2);
define _error_code		smallint;
define _cant_tran		integer;
define _valor			integer;
define _fecha           date;

--let _afiliacion = '001908342013 ';

--set debug file to "sp_cob294a.trc";
--trace on;                                                                

begin

on exception set _error_code 
 	return _error_code, 'error al actualizar los lotes';         
end exception           

--delete from cobtaban3;
delete from cobtaban;

let _valor = 0;

-- Selecciona los Lotes

foreach
	select no_lote,
		   total_transac,
		   id_operador,
		   id_terminal,
		   fecha,
		   id_oficina,
		   total_monto
	  into _no_lote_char,
		   _cant_tran,
		   _id_operador,
		   _id_terminal,
		   _fecha,
		   _id_sucursal,
		   _monto
	  from cobtalot
	 order by no_lote

	foreach
		select renglon,
			   no_tarjeta,
			   codigo,
			   fecha_exp,
			   monto,
			   no_documento
		  into _cant_tran,
			   _no_tarjeta,
			   _codigo,
			   _fecha_exp,
			   _monto,
			   _no_documento
		  from cobtatra
		 where no_lote = _no_lote_char
		 order by renglon

		let _no_tarjeta = _no_tarjeta[1,4] || _no_tarjeta[6,11] || _no_tarjeta[13,17];
		let _campo = 'Venta,' || trim(_id_terminal) || ',' || trim(_no_tarjeta) || ',' || _fecha_exp[1,2] || _fecha_exp[6,7] || ',' || cast(_monto as varchar(8)) || ','  || cast(_cant_tran as varchar(4)) || ',' || _no_lote_char ;

		insert into cobtaban
		values (_campo);
	end foreach  		   	
end foreach

let _valor = sp_cob243a(a_user);

return 0, 'Actualizacion Exitosa ...'; 
end 
end procedure;