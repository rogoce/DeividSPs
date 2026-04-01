
-- Creado    : 11/05/2004 - Autor: Armando Moreno M.
-- Modificado: 11/05/2004 - Autor: Armando Moreno M.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

drop PROCEDURE sp_rec736;

CREATE PROCEDURE sp_rec736(a_no_tranrec	char(10))
RETURNING INTEGER,VARCHAR(100);

define _no_factura   char(10);
define _cod_tipotran char(3);
define _cod_cpt      char(10);
define _monto        dec(16,2);
define _cant         smallint;
define _transaccion  char(10);
define _no_reclamo   char(10);

SET ISOLATION TO DIRTY READ;

let _no_factura = null;
let _cant = 0;

select no_reclamo,
       no_factura,
       cod_tipotran,
       cod_cpt,
	   monto
  into _no_reclamo,
       _no_factura,
       _cod_tipotran,
	   _cod_cpt,
	   _monto
  from rectrmae
 where no_tranrec = a_no_tranrec;
 
if _no_factura is not null and trim(_no_factura) <> "" and _cod_tipotran = "004" then
	SELECT count(*)
	  INTO _cant
	  FROM rectrmae
	 WHERE no_tranrec <> a_no_tranrec
	   and no_reclamo = _no_reclamo
	   and no_factura = _no_factura
	   and actualizado = 1
	   and cod_tipotran = _cod_tipotran
	   and anular_nt is null
	   and cod_cpt = _cod_cpt
	   and monto = _monto;

end if	

if _cant > 0 then
    foreach
		select transaccion
		  into _transaccion
		  from rectrmae
		 where no_tranrec <> a_no_tranrec
	       and no_reclamo = _no_reclamo
		   and no_factura = _no_factura
		   and actualizado = 1
		   and cod_tipotran = _cod_tipotran
		   and anular_nt is null
		   and cod_cpt = _cod_cpt
		   and monto = _monto
		  
		  exit foreach;
	end foreach
	
	if _transaccion is null then
		let _transaccion = '';
	end if
 	return 1,"Ya existe pago para esta factura en la transaccion " || trim(_transaccion) || ", verifique"; 

end if

return 0,"";

END PROCEDURE
