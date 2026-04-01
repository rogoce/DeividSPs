-- Reporte de Evaluaciones por evaluador

-- Creado    : 31/01/2011 - Autor: Armando Moreno.

DROP PROCEDURE sp_pro206b;

CREATE PROCEDURE "informix".sp_pro206b(a_fecha1 date, a_fecha2 date)
returning char(10),datetime year to fraction(5),char(10),varchar(100),smallint,smallint,smallint,char(8),date,date,char(15),char(20),decimal(16,2);


define _n_contratante    varchar(100);
define _nom_tipo_ramo	 char(15);
define _no_evaluacion	 char(10);
define _fecha			 datetime year to fraction(5);
define _no_recibo		 char(10);
define _fecha_recibo	 date;
define _monto			 decimal(16,2);
define _cantidad	     integer;
define _cod_asegurado    char(10);
define _cod_producto     char(5);
define _es_medico        smallint;
define _fecha_eval       date;
define _fecha_hora       datetime hour to fraction(5);
define _decicion,_dec2   smallint;
define _suspenso         smallint;
define _completado       smallint;
define _tipo_ramo		 smallint;
define _usuario_eval     char(8);
define _fecha_compl		 date;
define _n_decicion       char(20);


SET ISOLATION TO DIRTY READ;


BEGIN

let _n_decicion = "";
let _monto      = 0;

foreach					  

	SELECT no_evaluacion,
		   fecha,
		   cod_asegurado,
		   decicion,
		   suspenso,
		   completado,
		   usuario_med,
		   tipo_ramo,
		   fecha_obs_med,
		   date(fecha_completado),
		   monto
	  INTO _no_evaluacion,
		   _fecha,
		   _cod_asegurado,
		   _decicion,
		   _suspenso,
		   _completado,
		   _usuario_eval,
		   _tipo_ramo,
		   _fecha_eval,
		   _fecha_compl,
		   _monto
	  FROM emievalu
	 WHERE escaneado = 1
	   AND usuario_med is not null
	   AND fecha_obs_med >= a_fecha1
	   AND fecha_obs_med <= a_fecha2
	 ORDER BY fecha_obs_med

	if _cod_asegurado is null or _cod_asegurado = "" then
		continue foreach;
	end if

	if _tipo_ramo = 1 then
		let _nom_tipo_ramo = 'Salud';
	elif _tipo_ramo = 2 then
		let _nom_tipo_ramo = 'Vida';
	elif _tipo_ramo = 3 then
		let _nom_tipo_ramo = 'Accidentes';
	end if

	select nombre
	  into _n_contratante
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	if _decicion in(3,8) then	--declina ancon,desiste cliente
		let _decicion = 2;		--aplazar
	elif _decicion in(4,5,9,7,2,10,11) then
		let _decicion = 3;
	elif _decicion = 6 then
		let _decicion = 4;
--	elif _decicion = 0 then
--		continue foreach;
	end if

	Return _no_evaluacion,
		   _fecha,
		   _cod_asegurado,
		   _n_contratante,
		   _decicion,
		   _suspenso,
		   _completado,
		   _usuario_eval,
		   _fecha_eval,
		   _fecha_compl,
		   _nom_tipo_ramo,
		   "",
		   _monto
		    with resume;
		   

end foreach


END
END PROCEDURE
