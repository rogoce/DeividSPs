-- Procedimiento que carga las coberturas de los prodcutos en el Proceso de Emisiones Electronicas para Ducruet Banisi
--
-- Copia del sp_pro371a
-- Creado: 27/02/2021 - Autor: Amado Perez--
-- Cooreccion renovacion 2021-10
-- sis v.2.0 - deivid, s.a.

drop procedure sp_pro371g_txt;
create procedure "informix".sp_pro371g_txt(a_periodo char(7))
returning   integer,
			char(100);   


define _no_documento	char(20);
define _no_poliza_ant, _no_poliza	char(10);
define _error_desc		varchar(100);
define _error_isam		integer;
define _error			integer;
define _fecha_hoy		date;
define _periodo_ren		char(7);

begin

on exception set _error,_error_isam,_error_desc
 	return _error,_error_desc;
end exception

--set debug file to "sp_pro371_txt.trc";
--trace on;

set isolation to dirty read;



foreach
	select a.no_poliza_ant, a.no_documento 
	  into _no_poliza_ant, _no_documento
	  from emirenduc a
	 where a.periodo = '2021-10'
	   and a.vigencia_inic[7,10] = '2020'
	   and year(a.fecha_envio) = 2020 and a.enviado = 1 --   presentan enviado del año 2020 y estan renovadas
	 --and no_documento = '0219-00293-90'
	   and a.cod_grupo = '1122'
	   
			call sp_sis21(_no_documento) returning _no_poliza;

			select periodo
			  into _periodo_ren
			  from emipomae
			 where no_poliza = _no_poliza
			   and actualizado = 1;


			    if _periodo_ren = a_periodo then		   
				   call sp_pro371(_no_poliza) returning _error, _error_desc;
			   end if

			    if _error = 0 then
					update emirenduc
					   set periodo = '2020-10'
					 where no_documento = _no_documento
					   and periodo = a_periodo
					   and no_poliza_ant = _no_poliza_ant;
					   
					   return 0,'Exito '||_periodo_ren||' - '||_no_documento  WITH RESUME;
			     else
				       return 1,'Error '||_periodo_ren||' - '||_no_documento  WITH RESUME;
			      end if
	
end foreach
end


end procedure 