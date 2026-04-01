--- Codigo: Colocar Firma Autorizada de Endoso de cancelacion Automatica en INSUSER
--- Creado: Henry Giron 
--- Fecha:  25/08/2010

drop procedure ap_corrige_recibo;
create procedure "informix".ap_corrige_recibo()
RETURNING SMALLINT, CHAR(30);

DEFINE _cant          	INTEGER;

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
DEFINE _no_remesa, _recibo_old, _recibo_new   CHAR(10);
  
BEGIN

ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

SET ISOLATION TO DIRTY READ;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--SET DEBUG FILE TO "sp_seg009.trc"; 
--TRACE ON;
foreach with hold
select no_remesa, recibo_old, recibo_new
  into _no_remesa, _recibo_old, _recibo_new
  from tmp_corrige_recibo
 where seleccionado = 0

update cobredet
   set no_recibo = _recibo_new
 where no_remesa = _no_remesa
   and no_recibo = _recibo_old;

update tmp_corrige_recibo
   set seleccionado = 1;
end foreach
RETURN r_error, r_descripcion ;

END

end procedure;
