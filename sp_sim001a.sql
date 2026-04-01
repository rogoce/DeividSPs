-- Simulacion de cambio de contrato de reaseguro
-- Crear registros Nuevos a partir de los anteriores

-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 07/08/2012 - Autor: Armando Moreno

--execute procedure sp_sim001('00616','00613',2)


--DROP procedure sp_sim001a;

CREATE procedure "informix".sp_sim001a(
a_cod_cont_nvo CHAR(05),
a_cod_cont_ant CHAR(05)
) RETURNING    integer;


define _no_poliza char(10);
define _no_endoso char(5);
define _no_remesa char(10);
define _renglon   integer;
define _cnt       integer;
define _no_tranrec char(10);
define _no_factura char(10);


set isolation to dirty read;


let _cnt = 0;

foreach

		select no_poliza,
		       no_endoso
		  into _no_poliza,
		       _no_endoso
		  from emifacon
		 where cod_contrato = a_cod_cont_ant
	  group by 1,2
	  order by 1,2


	  let _cnt = _cnt + 1;

end foreach


FOREACH 
     SELECT cobredet.no_remesa,cobredet.renglon
       INTO _no_remesa,_renglon
       FROM cobredet, cobreaco c
	  WHERE cobredet.no_remesa = c.no_remesa
        and cobredet.renglon   = c.renglon
        and cobredet.actualizado = 1
		and cobredet.tipo_mov    in ("P", "N")
	    and c.cod_contrato       = a_cod_cont_ant
	  order by cobredet.no_remesa

      let _cnt = _cnt + 1;

END FOREACH

let _cnt = _cnt + 1;

FOREACH 
         SELECT e.no_poliza,
                t.no_factura,
				t.no_endoso
		   INTO _no_poliza,
		        _no_factura,
				_no_endoso
           FROM semifacon e, endedmae t
          WHERE e.no_poliza = t.no_poliza
            and e.no_endoso = t.no_endoso
            and t.actualizado = 1
            and e.cod_contrato = a_cod_cont_nvo
          group by e.no_poliza,t.no_factura,t.no_endoso
          order by e.no_poliza,t.no_factura,t.no_endoso


	let _cnt = _cnt + 1;

END FOREACH;


FOREACH
	select no_remesa
	  into _no_remesa
	  from scobreaco
	 where cod_contrato = a_cod_cont_nvo
	 group by no_remesa

	let _cnt = _cnt + 1;

END FOREACH

FOREACH
	select no_tranrec
	  into _no_tranrec
	  from srectrrea
	 where cod_contrato = a_cod_cont_nvo
	 group by no_tranrec

	let _cnt = _cnt + 1;

END FOREACH


return _cnt;
   
END PROCEDURE;
