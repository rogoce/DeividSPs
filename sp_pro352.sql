-- Evaluaciones aprobadas

-- Creado    : 04/05/2011 - Autor: Armando Moreno M.

--DROP PROCEDURE sp_pro352;

CREATE PROCEDURE "informix".sp_pro352()
returning varchar(100),char(10),date,char(10),char(10),char(10),char(20),char(8);


define _n_contratante    varchar(100);
define _no_evaluacion	 char(10);
define _fecha			 date;
define _no_recibo		 char(10);
define _cod_asegurado    char(10);
define _cod_contratante  char(10);
define _no_poliza        char(10);
define _no_documento     char(20);
define _user_added       char(8);

--SET ISOLATION TO DIRTY READ;

--SET DEBUG FILE TO "sp_pro194.trc";
--trace on;

SET LOCK MODE TO WAIT;

BEGIN

foreach					  

		SELECT nombre,
			   no_evaluacion,
			   date(fecha_completado),
			   no_recibo,
			   no_poliza,
			   cod_contratante,
			   cod_asegurado
		  INTO _n_contratante,
		       _no_evaluacion,
			   _fecha,
			   _no_recibo,
			   _no_poliza,
			   _cod_contratante,
			   _cod_asegurado
		  FROM emievalu
		 WHERE decicion   = 1
		   and completado = 1
		 ORDER BY no_evaluacion

		select no_documento,
		       user_added
		  into _no_documento,
		       _user_added
		  from emipomae
		 where no_poliza = _no_poliza;


	Return  _n_contratante,
			_no_evaluacion,
			_fecha,
			_no_recibo,
			_cod_asegurado,
			_cod_contratante,
			_no_documento,
			_user_added
			with resume;

end foreach

END
END PROCEDURE
























































