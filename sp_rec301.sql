-- Procedimiento que busca la Transaccion con mismo monto pagado para un reclamo

-- Creado    : 14/10/2019 - Autor: Amado Perez M.
-- Modificado: 14/10/2019 - Autor: Amado Perez M.



drop PROCEDURE sp_rec301;

CREATE PROCEDURE sp_rec301(a_no_tranrec	char(10))
RETURNING INTEGER,VARCHAR(100);

define _no_factura   char(10);
define _cod_tipotran char(3);
define _cod_cpt      char(10);
define _monto        dec(16,2);
define _cant         smallint;
define _transaccion  char(10);
define _no_reclamo   char(10);
define _anular_nt    char(10);

SET ISOLATION TO DIRTY READ;

let _no_factura = null;
let _cant = 0;

select no_reclamo,
       cod_tipotran,
	   monto,
	   anular_nt
  into _no_reclamo,
       _cod_tipotran,
	   _monto,
	   _anular_nt
  from rectrmae
 where no_tranrec = a_no_tranrec;
 
if _cod_tipotran not in ('004','007','005','006') then
	return 0, "";
end if

if _anular_nt is not null and trim(_anular_nt) <> "" then
	return 0, "";
end if
 
SELECT count(*)
  INTO _cant
  FROM rectrmae
 WHERE no_tranrec <> a_no_tranrec
   and no_reclamo = _no_reclamo
   and actualizado = 1
   and cod_tipotran = _cod_tipotran
   and anular_nt is null
   and monto = _monto;

if _cant > 0 then
    foreach
		select transaccion
		  into _transaccion
		  from rectrmae
		 where no_tranrec <> a_no_tranrec
	       and no_reclamo = _no_reclamo
		   and actualizado = 1
		   and cod_tipotran = _cod_tipotran
		   and anular_nt is null
		   and monto = _monto
		  
		  exit foreach;
	end foreach
	
	if _transaccion is null then
		let _transaccion = '';
	end if
    
	return 1,"Ya existe pago con este mismo monto en la transaccion " || trim(_transaccion) || ", verifique"; 

end if

return 0,"";

END PROCEDURE
