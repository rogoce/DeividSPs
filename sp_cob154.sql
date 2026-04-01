-- Procedimiento para cuadrar saldos
-- 
-- Creado    : 01/07/2004 - Autor: Demetrio Hurtado Almanza
-- 
-- SIS v.2.0 - DEIVID, S.A.


DROP PROCEDURE sp_cob154;

CREATE PROCEDURE "informix".sp_cob154(_periodo char(7)) 
returning char(50);

define _fecha	date;

let _fecha = sp_sis36(_periodo);

execute procedure sp_cob152(_periodo, _fecha);
return "Proceso Terminado para " || _periodo with resume;

--let _periodo = "1998-12";
--let _fecha   = "31/12/1998";

--execute procedure sp_cob153(_periodo);
--return "Proceso Terminado para " || _periodo with resume;

{
let _periodo = "1999-02";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;

let _periodo = "1999-03";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;

let _periodo = "1999-04";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;

let _periodo = "1999-05";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;

let _periodo = "1999-06";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;

let _periodo = "1999-07";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;

let _periodo = "1999-08";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;

let _periodo = "1999-09";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;

let _periodo = "1999-10";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;

let _periodo = "1999-11";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;

let _periodo = "1999-12";
execute procedure sp_cob153(_periodo);
return "Proceso Terminado para " || _periodo with resume;
}

end procedure