-- Creado    : 04/02/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 04/02/2004 - Autor: Demetrio Hurtado Almanza

drop procedure sp_cob127;

create procedure "informix".sp_cob127(
a_no_remesa	char(10)
) returning integer,
            char(100);
