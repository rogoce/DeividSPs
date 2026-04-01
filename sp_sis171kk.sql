-- Procedimiento que Cambia el Reaseguro para una Dev de Prima en chqreaco, a partir de las polizas que fueron cambiadas
-- en cambio de reaseguro masivo que se hizo a las polizas de automovil con vig ini >= 01/07/2013 y que se almacenaron en la tabla
-- camrea
-- 
-- Creado    : 01/10/2013 - Autor: Armando Moreno M.
-- Modificado: 01/10/2013 - Autor: Armando Moreno M.


drop procedure sp_sis171kk;
CREATE PROCEDURE "informix".sp_sis171kk()
RETURNING INTEGER, CHAR(250);

DEFINE _mensaje			CHAR(250);
DEFINE _error		    INTEGER;

DEFINE _no_poliza       CHAR(10);
DEFINE _renglon         SMALLINT;
DEFINE _no_unidad       CHAR(5);
define _no_requis       char(10);
define _error_isam		integer;
define _periodo         char(7);
define _cnt             smallint;


SET ISOLATION TO DIRTY READ;


--SET DEBUG FILE TO "sp_sis171g.trc";
--TRACE ON;

begin

on exception set _error,_error_isam,_mensaje
	let _mensaje = trim(_mensaje) || ' Verificar la Requisicion: ' || trim(_no_requis);
	rollback work;
 	return _error,_mensaje;
end exception

FOREACH WITH HOLD

	SELECT	no_poliza
	  INTO	_no_poliza
	  FROM	camrea
	 group by no_poliza
	 order by no_poliza

begin work;

    foreach

       select distinct no_requis
         into _no_requis
         from chqreaco
        where no_poliza = _no_poliza

		insert into camchqreaco(no_poliza,no_requis) values(_no_poliza,_no_requis);
		
		update chqreaco
		   set cod_contrato = '00659'
		 where no_requis = _no_requis
           and no_poliza = _no_poliza
           and cod_contrato = '00656';
		   
		update chqreaco
		   set cod_contrato = '00660'
		 where no_requis = _no_requis
           and no_poliza = _no_poliza
           and cod_contrato = '00657';
	
		select periodo
		  into _periodo
		  from chqchmae
		 where no_requis = _no_requis;
	 
		if _periodo >= '2016-09' then	
			update chqchmae
			   set sac_asientos = 0
			 where no_requis    = _no_requis;
			 
			update sac999:reacomp
			   set sac_asientos  = 0
			 where tipo_registro = 4
			   and no_poliza     = _no_poliza;
			   
			update sac999:reacomp
			   set sac_asientos  = 0
			 where tipo_registro = 5
			   and no_poliza     = _no_poliza;		   
		end if
	 
   end foreach

COMMIT WORK;

END FOREACH

LET _mensaje = 'Actualizacion Exitosa ...';
RETURN 0, _mensaje;
end

END PROCEDURE;