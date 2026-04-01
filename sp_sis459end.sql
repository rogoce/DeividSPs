--Procedimiento texto de comision de agente
--Henry Giron  11/12/2018
-- AMORENO:24/04/2019 Debemos deshabilitar las comisiones en las pólizas para los ramos de personas también
-- se vuelve a colocar segun correo JBRITO 24/04/2019
drop procedure sp_sis459end;
create procedure sp_sis459end(no_poliza char(10))
returning char(75) as agt_txt,
          int as visto;
define _agt_txt	char(75);
define _visto   integer;
define _agt_no_poliza	char(10);

let _agt_txt    = '';
let _visto      = 0;
let _agt_no_poliza = trim(no_poliza);
    FOREACH EXECUTE PROCEDURE sp_sis459(_agt_no_poliza) INTO _agt_txt,_visto
        return _agt_txt,_visto with resume;
    END FOREACH;

end procedure