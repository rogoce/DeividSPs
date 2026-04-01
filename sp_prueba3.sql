--DROP PROCEDURE sp_prueba3;

CREATE PROCEDURE sp_prueba3()
RETURNING char(7);




update a
   set hora_captura = current;


return "";

end procedure