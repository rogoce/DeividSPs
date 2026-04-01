DROP PROCEDURE sp_insp01;

CREATE PROCEDURE "informix".sp_insp01(a_usuario1 CHAR(8), a_usuario2 char(8)) RETURNING	smallint;

define _code_correg char(5);

create temp table tmp_corredor(
cod_correg	     CHAR(5),
primary key	(cod_correg)) with no log;

foreach
	select code_correg
	  into _code_correg
 	  from gencorr
     where usuario = a_usuario1

    INSERT INTO tmp_corredor (cod_correg) values(_code_correg);
end foreach

update gencorr
   set usuario = a_usuario1
 where usuario = a_usuario2;

 foreach
    select cod_correg
	  into _code_correg
 	  from tmp_corredor
	
	update gencorr
	   set usuario = a_usuario2
	 where code_correg = _code_correg;
 
 end foreach
 
DROP TABLE tmp_corredor;
 
RETURN 0; 
end procedure    