-- Pool de logistica para cancelacion - estados impresion 1 2 3
-- Creado		: 16/2/2016 - Autor: Henry Giron.

drop procedure sp_pr1009;
create procedure "informix".sp_pr1009(a_sucursal char(3), a_estatus char(1))
              returning char(15),
						char(55),
						char(15),
						date,
						smallint,
						smallint,
						char(15),
						date,
						char(3),
						char(1);	

define _no_aviso        char(15);
define _nombre_ramo     char(55);
define _user_proceso    char(15);
define _fecha_proceso   date;
define _sum_saldo       smallint;
define _count_no_poliza smallint;
define _user_imp_aviso_log char(15);
define _date_imp_aviso_log date;

define _fecha_hoy date;
let _fecha_hoy = current;

set isolation to dirty read;

foreach
    select no_aviso,
		   nombre_ramo,
		   user_proceso,
		   fecha_proceso,
		   sum(saldo),
		   count(distinct no_poliza),
		   user_imp_aviso_log,
		   date_imp_aviso_log
      into _no_aviso,
           _nombre_ramo,
           _user_proceso,
           _fecha_proceso,
           _sum_saldo,
           _count_no_poliza,
           _user_imp_aviso_log,
           _date_imp_aviso_log		   		   		   
	  from avisocanc
     where estatus in ('I')
       and (imprimir_log = 0
        or imprimir_log is null)
     group by no_aviso,nombre_ramo,user_proceso,fecha_proceso,user_imp_aviso_log,date_imp_aviso_log

	return _no_aviso,
           _nombre_ramo,
           _user_proceso,
           _fecha_proceso,
           _sum_saldo,
           _count_no_poliza,
           _user_imp_aviso_log,
           _date_imp_aviso_log,
           a_sucursal,
           a_estatus
		   with resume;

end foreach
end procedure



   




























































































