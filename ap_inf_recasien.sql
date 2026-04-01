--- Codigo: Colocar Firma Autorizada de Endoso de cancelacion Automatica en INSUSER
--- Creado: Henry Giron 
--- Fecha:  25/08/2010

drop procedure ap_inf_recasien;
create procedure "informix".ap_inf_recasien()
RETURNING CHAR(30), CHAR(10), CHAR(10), DATE;

DEFINE _cant          	INTEGER;

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
DEFINE _numrecla        char(20);
DEFINE _no_tranrec      CHAR(10);
DEFINE _transaccion     CHAR(10);
DEFINE _cnt_rec   		INTEGER;
DEFINE _cnt_tra   		INTEGER;
DEFINE _fecha           DATE;
  
BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_descripcion, r_error, NULL, NULL;
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';
LET _cnt_rec       = 0;
LET _cnt_tra       = 0;


--SET DEBUG FILE TO "sp_seg009.trc"; 
--TRACE ON;

foreach with hold
select numrecla
  into _numrecla
  from tmp_recla2014

	foreach with hold
	select no_tranrec, transaccion
	  into _no_tranrec, _transaccion
	  from rectrmae
	 where numrecla = _numrecla

	foreach with hold
	   select fecha
	     into _fecha
		 from sac999:recasien
	    where no_tranrec = _no_tranrec
	   group by no_tranrec, fecha
		
		RETURN _numrecla, _transaccion, _no_tranrec, _fecha WITH RESUME;
	end foreach
	end foreach
end foreach

foreach with hold
select transaccion
  into _transaccion
  from tmp_trans2014

select no_tranrec, numrecla
  into _no_tranrec, _numrecla
  from rectrmae
 where transaccion = _transaccion;

	foreach with hold
	   select fecha
	     into _fecha
		 from sac999:recasien
	    where no_tranrec = _no_tranrec
	   group by no_tranrec, fecha

		RETURN _numrecla, _transaccion, _no_tranrec, _fecha WITH RESUME;
	end foreach
end foreach



END

end procedure;
