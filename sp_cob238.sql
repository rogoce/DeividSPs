-- Creacion de las formas de pago para las remesa de Cierre de Caja

-- Creado    : 01/02/2010 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
--drop procedure sp_cob238;

create procedure sp_cob238()
returning integer,
          char(100);

define _no_remesa	char(10);
define _cantidad	smallint;
define _importe		dec(16,2);

foreach
 select no_remesa,
        monto_chequeo
   into _no_remesa,
        _importe
   from cobremae
  where tipo_remesa = "M"
    and actualizado = 1
	and periodo     >= "2010-01"

	select count(*)
	  into _cantidad
	  from cobrepag
	 where no_remesa = _no_remesa;

	if _cantidad = 0 then

		insert into cobrepag(no_remesa, renglon, tipo_pago, tipo_tarjeta, cod_banco, fecha, no_cheque, girado_por, a_favor_de, importe)
		values (_no_remesa, 1, 1, null, null, null, null, null, null, _importe);

	end if

end foreach

return 0, "Actualizacion Exitosa";

end procedure