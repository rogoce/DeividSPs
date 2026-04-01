-- Cuentas que tienen auxiliar y no se peuden afectar por el mayor
-- 
-- Creado    : 04/01/2005 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - - DEIVID, S.A.

DROP PROCEDURE sp_sac26;

CREATE PROCEDURE "informix".sp_sac26(a_periodo char(7))
returning char(100),
          dec(16,2),
          dec(16,2),
          char(25);

define _no_remesa	char(10);
define _renglon	    char(5);
define _cuenta		char(25);
define _debito		dec(16,2);
define _credito		dec(16,2);

foreach
 select d.no_remesa,
		d.renglon,
		d.doc_remesa,
		a.debito,
		a.credito
   into	_no_remesa,
        _renglon,
		_cuenta,
		_debito,
		_credito
   from cobredet d, cobasien a
  where d.periodo         = a_periodo
    and d.actualizado     = 1
	and d.tipo_mov        = "M"
	and d.doc_remesa[1,3] in ("131", "144")
	and d.no_remesa       = a.no_remesa
	and d.renglon         = a.renglon
  order by no_remesa, renglon

	return "Cobros - Remesa # " || _no_remesa || " Renglon # " || _renglon,
		   _debito,
		   _credito,
		   _cuenta
	       with resume;			

end foreach

foreach
 select	c.no_requis,
        c.debito,
        c.credito,
        c.cuenta
   into _no_remesa,
        _debito,
        _credito,
        _cuenta
   from chqchmae m, chqchcta c
  where m.no_requis     = c.no_requis
    and year(fecha_impresion) = a_periodo[1,4]
    and month(fecha_impresion) = a_periodo[6,7]
	and m.origen_cheque <> "6"
	and c.cuenta[1,3]   in ("131", "144")
  order by c.no_requis

	return "Cheques - Requisicion # " || _no_remesa,
		   _debito,
		   _credito,
		   _cuenta
	        with resume;			

end foreach

end procedure
