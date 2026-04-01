-- Procedimiento que elimina linea en blanco de la Descripcion de la Transaccion

-- Creado    : 11/05/2004 - Autor: Armando Moreno M.
-- Modificado: 11/05/2004 - Autor: Armando Moreno M.

-- SIS v.2.0 - uo_recl_validar_m (ue_icon) - DEIVID, S.A.

--drop PROCEDURE sp_rec88;

CREATE PROCEDURE "informix".sp_rec88(a_no_reclamo	char(10),a_no_tranrec	char(10))
RETURNING INTEGER,CHAR(100);



define _renglon			integer;
define _descripcion		char(60);
define _monto_cober     dec(16,2);
define _monto           dec(16,2);

SET ISOLATION TO DIRTY READ;

foreach
	select desc_transaccion,
		   renglon
	  into _descripcion,
	  	   _renglon
	  from rectrde2
	 where no_tranrec = a_no_tranrec

	if _descripcion is null or _descripcion = "" then
		delete from rectrde2
		 where no_tranrec = a_no_tranrec
		   and renglon    = _renglon;
	end if
end foreach

let _monto_cober = 0;

select sum(monto)
  into _monto_cober
  from rectrcob
 where no_tranrec = a_no_tranrec;

let _monto = 0;

select monto
  into _monto
  from rectrmae
 where no_tranrec = a_no_tranrec;

if _monto_cober <> _monto then

	return 1,""; 

end if

return 0,"";

END PROCEDURE
