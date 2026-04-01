-- Procedimiento que genera la reversión de una factura, a través deun endoso de Modificación.

-- Creado     : 23/02/2022 - Autor: Armando Moreno Montenegro

drop procedure sp_par184b;
create procedure sp_par184b(a_no_factura char(10),a_usuario char(8))
returning integer,
          char(100),
		  char(5);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _saldo			dec(16,2);
define _no_poliza,_no_factura		char(10);
define _no_endoso		char(5);
define _no_unidad		char(5);
define _no_endoso_ant	char(5);
define _estatus_poliza	smallint;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);

define _descripcion		char(50);
define _cantidad		integer;
define _cod_pagador		char(10);
define _user_added		char(8);
define _facultativo     smallint;

--set debug file to "sp_par184.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc,'';
end exception

let _cantidad    = 0;
let _facultativo = 0;
let _user_added = a_usuario;

select no_poliza,
       no_endoso,
	   no_documento
  into _no_poliza,
       _no_endoso_ant,
	   _no_documento
  from endedmae
 where no_factura = a_no_factura;

					 
call sp_par130b(_no_poliza, _no_endoso_ant, _user_added) returning _error, _descripcion, _no_endoso;

if _error <> 0 then
	return _error, trim(_no_documento) || " " || _descripcion,'' with resume; 
end if

--*****Insersion a tabla nota_cesion para polizas facultativas para el envio de la nota de cesion por correo Armando 14/11/2017.
select facultativo,no_factura
  into _facultativo,_no_factura
  from endedmae
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;
   
if _facultativo = 1 then
	insert into nota_cesion(no_poliza,no_endoso,enviado)
	values(_no_poliza,_no_endoso,0);
end if
--*****************************************************************
end 
return 0, "Reversion Exitosa. Factura: " || _no_factura,_no_endoso; 
end procedure