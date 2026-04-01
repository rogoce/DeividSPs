-- Procedimiento que Realiza la insercion a la tabla emiderec Recargo. del dependiente

-- Creado    : 21/01/2011 - Autor: Armando Moreno M.

drop procedure sp_sis144;

create procedure "informix".sp_sis144(
a_no_poliza   char(10),
a_no_unidad   char(5),
a_cod_depen   char(10),
a_cod_recargo char(3),
a_porc_rec    dec(16,2)
)
RETURNING INTEGER;


DEFINE _error          smallint; 


--SET DEBUG FILE TO "sp_sis143.trc"; 
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

ON EXCEPTION SET _error
  RETURN _error;
END EXCEPTION


insert into emiderec(
	   no_poliza,  
	   no_unidad,  
	   cod_cliente,
	   cod_recargo,
	   por_recargo
	   )	
       values (
        a_no_poliza,
        a_no_unidad,
        a_cod_depen,
		a_cod_recargo,
        a_porc_rec
		);

END
RETURN 0;
end procedure;
