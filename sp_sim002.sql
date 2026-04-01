-- Insertar Registros de reacomp hacia sreacomp

-- Creado    : 10/09/2012 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.	

--DROP PROCEDURE sp_sim002;
CREATE PROCEDURE sp_sim002(a_cod_contrato char(5), a_tipo smallint)
RETURNING integer,char(100);

DEFINE _no_factura char(10);
DEFINE _no_poliza  CHAR(10);
DEFINE _no_endoso  CHAR(5);
DEFINE _no_remesa  char(10);
DEFINE _no_tranrec char(10);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

--if a_tipo = 1 then --Produccion
delete from sac999:sreacomp;

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
            and e.cod_contrato = a_cod_contrato
          group by e.no_poliza,t.no_factura,t.no_endoso
          order by e.no_poliza,t.no_factura,t.no_endoso

		select *
		  from sac999:reacomp c
		 where c.tipo_registro = "1"
		   and c.no_poliza = _no_poliza
		   and c.no_endoso = _no_endoso
		  into temp prueba;

		update prueba
		   set sac_asientos = 0;

		insert into sac999:sreacomp
		select * from prueba;

	    drop table prueba;

		return 1,'' with resume;
END FOREACH;

--elif a_tipo = 2 then --Cobros

FOREACH
	select no_remesa
	  into _no_remesa
	  from scobreaco
	 where cod_contrato = a_cod_contrato
	 group by no_remesa

	select *
	  from sac999:reacomp
	 where tipo_registro = "2"
	   and no_remesa = _no_remesa
	  into temp prueba;

	update prueba
	   set sac_asientos = 0;

	insert into sac999:sreacomp
	select * from prueba;

    drop table prueba;

	return 1,'' with resume;
END FOREACH


--elif a_tipo = 3 then --Reclamos

FOREACH
	select no_tranrec
	  into _no_tranrec
	  from srectrrea
	 where cod_contrato = a_cod_contrato
	 group by no_tranrec

	select *
	  from sac999:reacomp
	 where tipo_registro = "3"
	   and no_tranrec = _no_tranrec
	  into temp prueba;

	update prueba
	   set sac_asientos = 0;

	insert into sac999:sreacomp
	select * from prueba;

    drop table prueba;

	return 1,'' with resume;
END FOREACH

--end if
end
  
let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;

END PROCEDURE					 