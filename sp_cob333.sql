-- Verificando si estas polizas de la remesa estan canceladas por falta de pago para realizar el movimiento de Devolucion por Cancelacion Poliza "K"
-- Creado por: Amado Perez M - 18/03/2013

drop procedure sp_cob333;

create procedure sp_cob333(a_no_remesa char(10))
returning integer,
          char(100);

define _e_mail			varchar(50);
define _desc_error		char(100); 
define _doc_remesa		char(20);
define _cod_contratante	char(10);
define _cob_no_devleg	char(10);
define _no_requis		char(10);
define _no_poliza		char(10);
define _no_recibo		char(10);
define _cod_tipocan		char(3);
define _saldo			dec(16,2);
define _monto			dec(16,2);
define _prima_neta		dec(16,2);
define _estatus_poliza	smallint;
define _renglon_rem		integer;
define _cant			integer;
define _error			integer;
define _fecha			date;

begin
on exception set _error
	return _error, "Error Actualizando Pago Cobranza Externa";
end exception

foreach
	select doc_remesa,
	       no_poliza,
		   no_recibo,
		   renglon,
		   monto,
		   fecha
	  into _doc_remesa,
	       _no_poliza,
		   _no_recibo,
	       _renglon_rem,
		   _monto,
		   _fecha
	  from cobredet
	 where no_remesa = a_no_remesa
	   and tipo_mov  = "P"

    let _cant = 0;

    select count(*)
	  into _cant
	  from coboutleg
	 where no_documento = _doc_remesa;
	 
	if _cant = 0 then
		continue foreach;
	end if

	update cobredet
	   set tipo_mov  = "L",
		   prima_neta = monto,
		   impuesto   = 0.00
	 where no_remesa = a_no_remesa
	   and renglon = _renglon_rem;

	delete from cobreagt 
	 where no_remesa = a_no_remesa
	   and renglon = _renglon_rem;
end foreach
end

return 0, "Actualizacion Exitosa";

end procedure