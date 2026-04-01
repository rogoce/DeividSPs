-- Procedure depuera los codigos de los auxiliares
-- 
-- Creado    : 12/12/2012 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud32;		

create procedure "informix".sp_aud32() 
returning date,
          char(10),
		  char(50),
		  dec(16,2),
		  char(20),
		  char(10),
		  char(20),
		  char(50),
		  dec(16,2);

define _fecha			date;
define _transaccion		char(10);
define _cod_cliente		char(10);
define _monto			dec(16,2);
define _numrecla		char(20);
define _estatus_rec		char(1);
define _no_documento	char(20);
define _ajust_interno	char(3);
define _reserva			dec(16,2);


define _no_reclamo		char(10);
define _nom_cliente		char(50);
define _estatus_nom		char(10);
define _ajust_nombre	char(50);


foreach
 select fecha,
        transaccion,
		cod_cliente,
		monto,
		numrecla,
		no_reclamo
   into _fecha,
        _transaccion,
		_cod_cliente,
		_monto,
		_numrecla,
		_no_reclamo
   from	rectrmae
  where actualizado   = 1
    and cod_tipotran  = "004"
	and monto         <> 0
    and numrecla[1,2] in ("02", "20")
    and no_requis     is null
    and anular_nt     is null
	and periodo       >= "1999-06"
  order by fecha

	select nombre
	  into _nom_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select estatus_reclamo,
	       no_documento,
		   ajust_interno
	  into _estatus_rec,
	       _no_documento,
		   _ajust_interno
	  from recrcmae
	 where no_reclamo = _no_reclamo;

    if _estatus_rec = 'A' then
	  let _estatus_nom = "ABIERTO";
	elif _estatus_rec = 'C' then
	  let _estatus_nom = "CERRADO";
	elif _estatus_rec = 'R' then
	  let _estatus_nom = "RE-ABIERTO";
	elif _estatus_rec = 'T' then
	  let _estatus_nom = "EN TRAMITE";
	elif _estatus_rec = 'D' then
	  let _estatus_nom = "DECLINADO";
	else
	  let _estatus_nom = "NO APLICA";
	end if

	select nombre
	  into _ajust_nombre
	  from recajust
	 where cod_ajustador = _ajust_interno;

	select sum(variacion)
	  into _reserva
	  from rectrmae
	 where no_reclamo  = _no_reclamo
	   and actualizado = 1;

	return _fecha,
	       _transaccion,
		   _nom_cliente,
		   _monto,
		   _numrecla,
		   _estatus_nom,
		   _no_documento,
		   _ajust_nombre,
		   _reserva
		   with resume;

end foreach

end procedure