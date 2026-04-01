
drop procedure ap_corrige_atcdocma1;
create procedure "informix".ap_corrige_atcdocma1()
RETURNING SMALLINT, CHAR(30);

DEFINE _cant          	INTEGER;

DEFINE r_error        	SMALLINT;
DEFINE r_error_isam   	SMALLINT;
DEFINE r_descripcion  	CHAR(30);
DEFINE _cod_entrada     integer;
DEFINE _cod_ent_char    char(10);
DEFINE _cod_entrada_vjo CHAR(10);

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



	select *
	  from d
	 where cod_entrada  between '94318' and '94347'
	 order by 1
	  into temp tmp_ttco;


   let _cod_entrada = 94561;

   foreach

    select cod_entrada
	  into _cod_entrada_vjo
	  from tmp_ttco
	  order by 1

	let _cod_ent_char = _cod_entrada;

	update tmp_ttco
	   set cod_entrada = _cod_ent_char
	 where cod_entrada = _cod_entrada_vjo;

	insert into atcdocma
	select * 
	  from tmp_ttco
	 where cod_entrada = _cod_ent_char;

    let _cod_entrada = _cod_entrada + 1;


  end foreach


RETURN r_error, r_descripcion ;

--drop table tmp_ttco;

END

end procedure;
