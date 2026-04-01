-- Procedimiento para insertar registros en COBPRONPA para proceso diario de pronto pago
-- Creado: 03/09/2009	- Autor: Roberto Silvera
-- Modificado: 21/02/2013	- Autor: Roman Gordon	Se cambiaron todas las condiciones al procedure sp_sis402 y se hace el llamado desde aqui
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro863('',,'DEIVID','')

drop procedure sp_pro863;
create procedure sp_pro863(
a_no_poliza		char(10),
a_prima_end		dec(16,2),
a_user_added	char(8),
a_no_remesa		char(10))
returning smallint,char(30);

define _error_desc      varchar(100);
define _razon			char(255);
define _no_documento	char(20);
define _cod_contratante	char(10);
define _cod_pagador		char(10);
define _cod_compania	char(3);
define _cod_formapag    char(3);
define _cod_sucursal	char(3);
define _tipo_remesa     char(1);
define _monto_pago		dec(16,2);
define _prima_bruta		dec(16,2);
define _descuento		dec(16,2);
define _saldo			dec(16,2);
define _pagado			dec(16,2);
define v_flag_existe	smallint;
define _aplica			smallint;
define _error_code	   	integer;
define _error_isam	   	integer;
define _fecha_hoy		date;

begin

--set debug file to "sp_pro863.trc";
--trace on;

on exception set _error_code, _error_isam, _error_desc
 	return _error_code, _error_desc;
end exception

let _descuento = 0.00;
let _aplica		= 0;
let _cod_compania = '001';
let _cod_sucursal = '001';

--verifica si ya existe en la tabla	
select count(*)
  into v_flag_existe
  from cobpronpa
 where no_poliza = a_no_poliza;

if v_flag_existe > 0 then
	return 1, "Ya existe.";
end if

select fecha,tipo_remesa
  into _fecha_hoy,_tipo_remesa
  from cobremae
 where no_remesa = a_no_remesa;
	
--Verifica si cumple con las condiciones del Descuento de Pronto Pago
select no_documento,
	   prima_bruta,
	   cod_contratante,
	   cod_pagador,
	   cod_formapag
  into _no_documento,
	   _prima_bruta,
	   _cod_contratante,
	   _cod_pagador,
	   _cod_formapag
  from emipomae
 where no_poliza = a_no_poliza;

if _no_documento is null then
	return 1,'Póliza Invalida';
end if

if _cod_formapag <> '092' then	--092 = Ducruet electronico
	call sp_sis402(a_no_poliza,_fecha_hoy,1,a_no_remesa) returning _aplica,_razon,_descuento;

	if _tipo_remesa <> 'A' then	--Si es remesa automatica no debe verificar contra el saldo alctual
		call sp_cob115b(_cod_compania,_cod_sucursal,_no_documento, "") returning _saldo;  --saldo incluye el pago de la remesa.
		
		let _pagado = abs(_saldo) - abs(_descuento);

		if abs(_pagado) > 0.03 then   --El saldo no debe ser mayor al descuento
			if _descuento < _saldo then
				let _aplica = 1;
			end if
		end if
	end if
else
	call sp_sis403(_no_documento) returning _aplica,_razon,_descuento;	 --Ducruet electronico
end if

{	if _saldo < _descuento then
		let _aplica = 1;
	end if
	let _pagado = _prima_bruta - _saldo;
	if	abs(_pagado ) < (round(_prima_bruta - _descuento,2))   then
		let _aplica = 1;
	end if}
		
if _aplica = 0 then
	let _descuento = _descuento * -1;
	insert into cobpronpa(
			no_poliza,
			no_documento,
			cod_pagador,
			cod_contratante,
			prima_bruta,
			monto_descuento,
			factura,
			fecha,
			seleccionado,
			user_added)
	values(	a_no_poliza,
			_no_documento,
			_cod_contratante,
			_cod_pagador,
			_prima_bruta,
			_descuento,
			"",
			sp_sis26(),
			0,
			a_user_added);
end if
return _aplica,_razon;
end
end procedure;