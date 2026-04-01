-- Numero Interno de Reclamo para Workflow

-- Creado    : 10/03/2004 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_sis151;

create procedure "informix".sp_sis151()
returning char(10),
          char(20),
          dec(16,2);

define _transaccion	char(10);
define _numrecla    char(20);
define _cantidad	smallint;
define _cod_endomov char(3);
define _no_factura2 char(10);
define _no_poliza	char(10);
define _no_endoso	char(5);
define _monto       dec(16,2);

set isolation to dirty read;

foreach 
 select a.transaccion, a.numrecla, a.monto 
   into _transaccion, _numrecla, _monto
   from chqchrec a, chqchmae b
  where a.no_requis = b.no_requis
    and b.fecha_captura >= '01/01/2011'

  let _cantidad = 0;

  select count(*)
    into _cantidad
	from rectrmae
   where transaccion = _transaccion;

  if _cantidad = 0 then
     return _transaccion, _numrecla, _monto with resume;
  end if
  

end foreach

end procedure