DROP PROCEDURE sp_sis170;

CREATE PROCEDURE sp_sis170(a_requis char(10))
RETURNING smallint;



update chqchmae
   set hora_anulado = current
 where no_requis    = a_requis;


return 0;

end procedure