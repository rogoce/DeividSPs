--- Codigo: Colocar Firma Autorizada de Endoso de cancelacion Automatica en INSUSER
--- Creado: Henry Giron 
--- Fecha:  25/08/2010

drop procedure ap_corrige_recasien;
create procedure "informix".ap_corrige_recasien()
RETURNING SMALLINT, CHAR(30), INTEGER, INTEGER;

DEFINE _cant          	INTEGER;

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
DEFINE _numrecla        char(20);
DEFINE _no_tranrec      CHAR(10);
DEFINE _transaccion     CHAR(10);
DEFINE _cnt_rec   		INTEGER;
DEFINE _cnt_tra   		INTEGER;
  
BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion, _cnt_rec, _cnt_tra;
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
	select no_tranrec
	  into _no_tranrec
	  from rectrmae
	 where numrecla = _numrecla

	update sac999:recasien
	   set periodo = '2014-01'
	 where no_tranrec = _no_tranrec;
	
	LET _cnt_rec = _cnt_rec + 1;
	end foreach
end foreach

foreach with hold
select transaccion
  into _transaccion
  from tmp_trans2014

select no_tranrec
  into _no_tranrec
  from rectrmae
 where transaccion = _transaccion;

update sac999:recasien
   set periodo = '2014-01'
 where no_tranrec = _no_tranrec;

LET _cnt_tra = _cnt_tra + 1;

end foreach


RETURN r_error, r_descripcion, _cnt_rec, _cnt_tra ;

END

end procedure;
