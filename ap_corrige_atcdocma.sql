
drop procedure ap_corrige_atcdocma;
create procedure "informix".ap_corrige_atcdocma()
RETURNING SMALLINT, CHAR(30);

DEFINE _cant          	INTEGER;

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
define _cod_entrada     char(10);
define _cod_entrada2    char(10);


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



foreach

	select cod_entrada,cod_entrada2
	  into _cod_entrada,_cod_entrada2
	  from d
	 where cod_entrada between '94319' and '94347'
	 order by 1

	select * from atcdocma
	 where cod_entrada = _cod_entrada2
	  into temp prueba;

    update prueba
	   set cod_entrada  = _cod_entrada;

	delete from atcdocma
	 where cod_entrada = _cod_entrada2;


    update atcdocma
	   set cod_entrada  = _cod_entrada2
	  where cod_entrada = _cod_entrada;

	insert into atcdocma
	select * from prueba;

	drop table prueba;

end foreach

RETURN r_error, r_descripcion ;

END

end procedure;
