
drop procedure sp_sis112a;

create procedure "informix".sp_sis112a(a_notrx integer, a_tipo char(1), a_renglon integer)
returning integer,integer;
--) returning char(10),char(20);

define _error			integer;
define _existe			integer;
define _fecha_hoy 		date;
define _no_poliza 		char(10);
define _poliza 			char(20);
define ll_i             integer;
define ll_j             integer;
define ll_k             integer;
define ll_todos         integer;

set debug file to "sp_sis112a.trc";
trace on;


BEGIN
ON EXCEPTION SET _error
	return _error,a_notrx;
end exception

let ll_i     = 0;
let ll_j     = 0;
let ll_k     = 0;
let ll_todos = 0;

if a_tipo = "E" then
	DELETE FROM cgltrx3 WHERE trx3_notrx = a_notrx;
	DELETE FROM cgltrx2 WHERE trx2_notrx = a_notrx;
	DELETE FROM cgltrx1 WHERE trx1_notrx = a_notrx;
else	
	DELETE FROM cgltrx3 WHERE trx3_notrx = a_notrx and trx3_lineatrx2 = a_renglon;
	DELETE FROM cgltrx2 WHERE trx2_notrx = a_notrx and trx2_linea = a_renglon;

	select *
	  from cgltrx2
	 WHERE trx2_notrx = a_notrx
	  into temp tmp_cgltrx2;

	select *
	  from cgltrx3
	 WHERE trx3_notrx = a_notrx
	  into temp tmp_cgltrx3;

    DELETE FROM cgltrx3 WHERE trx3_notrx = a_notrx; 

   select count(*)
	 into ll_todos
	 from cgltrx2
	where trx2_notrx = a_notrx;

    let ll_i = 0;

   foreach
   select trx2_linea
	 into ll_j
	 from tmp_cgltrx2
	where trx2_notrx = a_notrx 
	order by 1

	      let ll_i = ll_i + 1;

		   select count(*)
	         into ll_k
	         from tmp_cgltrx3
	        where trx3_notrx = a_notrx and trx3_lineatrx2 = ll_j;

			     update cgltrx2
				    set trx2_linea = ll_i
				  where trx2_notrx = a_notrx and trx2_linea = ll_j;

			  if ll_k > 0 then

				  insert into cgltrx3 (
					trx3_notrx,
					trx3_tipo,
					trx3_lineatrx2,
					trx3_linea,
					trx3_cuenta,
					trx3_auxiliar,
					trx3_debito,
					trx3_credito,
					trx3_actlzdo,
					trx3_referencia
				  ) 
				  select trx3_notrx,
					trx3_tipo,
					ll_i,
					trx3_linea,
					trx3_cuenta,
					trx3_auxiliar,
					trx3_debito,
					trx3_credito,
					trx3_actlzdo,
					trx3_referencia
				   from tmp_cgltrx3
				  where trx3_notrx = a_notrx and trx3_lineatrx2 = ll_j;

			   end if
	  end foreach
--	DELETE FROM cgltrx1 WHERE trx1_notrx = a_notrx;	
	--drop table tmp_cgltrx1;
	drop table tmp_cgltrx3;
	drop table tmp_cgltrx2;

end if

end


return 0,a_notrx;

end procedure

	