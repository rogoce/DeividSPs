-- Requisiciones Pendientes de Pagar para los Reclamos de Salud
-- Para poder agregar mas transacciones de reclamos a una misma 
-- requisicion

-- Creado    : 15/01/2002 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 15/01/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado: 09/10/2003 - Autor: Demetrio Hurtado Almanza
--			   Se elimino la parte de buscar que sea el mismo reclamo, para que sean
--			   todas las transacciones de pago del mismo cliente

-- SIS v.2.0 - d_recl_sp_rec55_dw1 - DEIVID, S.A.

drop procedure sp_rec63;

create procedure sp_rec63(
a_cod_cliente char(10), 
a_numrecla char(20)
) returning date,
			char(10),
			char(100),
			dec(16,2);


define _no_requis		char(10);
define _fecha_captura	date;
define _nombre			char(100);
define _monto			dec(16,2);
define _cantidad		integer;

SET ISOLATION TO DIRTY READ;

select nombre
  into _nombre
  from cliclien
 where cod_cliente = a_cod_cliente;

foreach
 select	no_requis,
		fecha_captura,
		monto
   into	_no_requis,
		_fecha_captura,
		_monto
   from	chqchmae
  where cod_cliente   = a_cod_cliente
    and autorizado    = 0
	and origen_cheque = "3"

	 select	count(*)
	   into	_cantidad
	   from chqchrec
	  where no_requis = _no_requis
	    and numrecla  = a_numrecla;

	if _cantidad is null then
		let _cantidad = 0;
	end if
		
	if _cantidad <> 0 then

		return _fecha_captura,
		       _no_requis,
			   _nombre,
			   _monto
			   with resume;

	end if

end foreach

end procedure
