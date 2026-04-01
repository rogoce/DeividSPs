-- Procedimiento que Realiza el proceso de Rehabilitación de pólizas en cobros legal .
-- Creado    : 03/02/2014 - Autor: Román Gordón
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis253;
create procedure "informix".sp_sis253(a_no_poliza char(10))
returning		integer,	--1._error
				char(250);	--2._error_desc

define _error_desc			char(250);
define _comentario			char(250);
define _no_motor_n			char(30);
define _no_documento		char(20);
define _no_factura_rehab	char(10);
define _no_factura_canc		char(10);
define _no_poliza			char(10);
define _no_endoso_rehab		char(5);
define _cod_producto		char(5);
define _no_unidad			char(5);
define _no_endoso			char(5);
define _cod_formapag		char(3);
define _cod_compania		char(3);
define _cod_sucursal		char(3);
define _cod_abogado			char(3);
define _cod_tipocan			char(3);
define _prima_b_rehab		dec(16,2);
define _monto_endoso		dec(16,2);
define _prima_b_canc		dec(16,2);
define _estatus_poliza		smallint;
define _no_endoso_int		smallint;
define _dias_valida			smallint;
define _recupero			smallint;
define _error_isam			integer;
define _error				integer;
define _fecha_cancelacion	date;
define _vigencia_final		date;
define _fecha_hoy			date;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	return _error, _error_desc;
end exception

--set debug file to "sp_cob337.trc";
--trace on;

let _no_endoso = '00000';
let _fecha_hoy = today;

select cod_ramo,
	   cod_sucursal
  into _cod_ramo,
	   _cod_sucursal
  from emipomae
 where no_poliza = a_no_poliza;

return 0, 'Validación no Necesaria.';


if _cod_ramo = '002' and _cod_sucursal = '009' then
	select cod_producto
	  into _cod_producto
	  from emipouni
	 where no_poliza = a_no_poliza;
	 
	if _cod_producto = '10602' then

		select no_motor
		  into _no_motor_n
		  from emiauto
		 where no_poliza = a_no_poliza;

		foreach
			select max(emi.vigencia_final),
				   max(emi.fecha_cancelacion),
				   estatus_poliza
			  into _vigencia_final,
				   _fecha_cancelacion,
				   _estatus_poliza
			  from emipomae emi
			 inner join emiauto aut on aut.no_poliza = emi.no_poliza
			 where aut.no_motor = _no_motor_n
			   and emi.actualizado = 1

			if _estatus_poliza in (1,3) then
				let _dias_valida = _fecha_hoy - _vigencia_final;
				
				if _dias_valida <= 30 then
					return 1,'Existe una póliza con Vigencia Final con menos de 30 días de su vencimiento.';
				end if
			elif _estatus_poliza in (2,4) then
				let _dias_valida = _fecha_hoy - _vigencia_final;
				
				if _dias_valida <= 30 then
					return 1,'Existe una póliza con Fecha de Cancelación/Anulación con menos de 30 días transcurridos.';
				end if
			end if
		end foreach
	else
		return 0, 'Validación no Necesaria.';
	end if
else
	return 0, 'Validación no Necesaria.';
end if



end
end procedure 