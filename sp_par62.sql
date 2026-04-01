-- Procedimiento que carga las facturas para que se generen los registros contables
-- 
-- Creado    : 31/10/2002 - Autor: Marquelda Valdelamar
--
-- SIS v.2.0 - DEIVID, S.A.

Drop Procedure sp_par62;		

Create Procedure "informix".sp_par62(a_periodo1 CHAR(7), a_periodo2 CHAR(7))
RETURNING INTEGER, CHAR(100);
		  	
 Define _no_poliza        CHAR(10); 
 Define _no_endoso        CHAR(5);
 Define _error_cod		  INTEGER;
 Define _error_desc		  CHAR(100);

  Set Isolation To Dirty Read;

  Foreach
   Select no_poliza,
 		  no_endoso
  	 Into _no_poliza,
		  _no_endoso
	 From endedmae
	Where actualizado = 1
	  And periodo    >= a_periodo1
	  And periodo    <= a_periodo2
--	  and user_added = "GERENCIA"
	  	
		delete from endasiau
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

		delete from endasien
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

--{
		Call sp_par59(
		_no_poliza,
		_no_endoso
		) RETURNING _error_cod, _error_desc;

		If _error_cod <> 0 then
			return _error_cod, _error_desc;
		end if
--}

  End Foreach;

  let _error_cod  = 0;
  let _error_desc = "Proceso Completado ...";	
  return _error_cod, _error_desc;

End Procedure;
