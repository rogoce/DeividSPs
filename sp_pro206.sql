-- Reporte de Evaluaciones por evaluador

-- Creado    : 31/01/2011 - Autor: Armando Moreno.
--Modificado : 21/05/2022  AMM.

DROP PROCEDURE sp_pro206;
CREATE PROCEDURE sp_pro206(a_fecha1 date, a_fecha2 date)
returning char(10),datetime year to fraction(5),char(10),varchar(100),smallint,smallint,smallint,char(8),date,date,char(15),char(20),decimal(16,2),varchar(50),varchar(50);


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
define _n_corredor       varchar(50);
define _n_ejecutivo      varchar(50);
define _cod_agente       char(5);
define _cod_v            char(3);


SET ISOLATION TO DIRTY READ;

{create temp table tmp_eval(
no_eval			char(10),
renglon			smallint,
no_recibo		char(10),
tipo_mov		char(1),
doc_remesa		char(30),
recibi_de		char(50),
tipo_pago		smallint,
tipo_tarjeta	smallint,
importe			dec(16,2)
) with no log; }


--SET DEBUG FILE TO "sp_pro206.trc";
--trace on;

--SET LOCK MODE TO WAIT;

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
		   usuario_eval,
		   tipo_ramo,
		   date(fecha_obs_eval),
		   date(fecha_completado),
		   monto,
		   nombre_corredor,
		   cod_agente
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
		   _monto,
		   _n_corredor,
		   _cod_agente
	  FROM emievalu
	 WHERE escaneado = 1
	   AND date(fecha_completado) >= a_fecha1
	   AND date(fecha_completado) <= a_fecha2
	 ORDER BY fecha

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

    if _decicion <> 1 then
		continue foreach;
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
	elif _decicion = 0 then
		continue foreach;
	end if
	select cod_vendedor
	  into _cod_v
	  from agtagent
	 where cod_agente = _cod_agente;
	 
    select nombre
	  into _n_ejecutivo
	  from agtvende
	 where cod_vendedor = _cod_v; 
	  
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
		   _monto,
		   _n_corredor,
		   _n_ejecutivo with resume;

end foreach
foreach					  
	SELECT no_evaluacion,
		   fecha,
		   cod_asegurado,
		   decicion,
		   suspenso,
		   completado,
		   usuario_eval,
		   tipo_ramo,
		   date(fecha_obs_eval),
		   date(fecha_completado),
		   monto,
		   nombre_corredor,
		   cod_agente
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
		   _monto,
		   _n_corredor,
		   _cod_agente
	  FROM emievalu
	 WHERE escaneado = 1
	   AND (fecha_suspenso >= a_fecha1
	   AND fecha_suspenso <= a_fecha2)
	    OR (fecha_escan >= a_fecha1
	   AND fecha_escan <= a_fecha2)
	   AND decicion <> 1
	 ORDER BY fecha_suspenso

	if _cod_asegurado is null or _cod_asegurado = "" then
		continue foreach;
	end if

    if _decicion = 1 then
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

	let _dec2 = _decicion;

	if _decicion in(3,8) then	--declina ancon,desiste cliente
		let _decicion = 2;		--aplazar
	elif _decicion in(4,5,9,7,2,10,11) then
		let _decicion = 3;
	elif _decicion = 6 then
		let _decicion = 4;
	elif _decicion = 0 then
		continue foreach;
	end if

	  let _n_decicion = "";

    if _dec2 = 4 then
	  let _n_decicion = "CON RECARGO";
	elif _dec2 = 5 then
	  let _n_decicion = "CON EXCL.";
	elif _dec2 = 9 then
	  let _n_decicion = "CON RECARGO Y EXCL.";
    elif _dec2 = 7 then
	  let _n_decicion = "REQUISITOS ADIC.";
	elif _dec2 = 2 then
	  let _n_decicion = "APLAZAR";
	elif _dec2 = 11 then
	  let _n_decicion = "DEVOLVER";
	elif _dec2 = 10 then
	  let _n_decicion = "DECLINA ?";
	elif _dec2 = 3 then
	  let _n_decicion = "DECLINACION";
	elif _dec2 = 8 then
	  let _n_decicion = "DESISTE CTE.";
	elif _dec2 = 6 then
	  let _n_decicion = "";
	end if
	select cod_vendedor
	  into _cod_v
	  from agtagent
	 where cod_agente = _cod_agente;
	 
    select nombre
	  into _n_ejecutivo
	  from agtvende
	 where cod_vendedor = _cod_v; 

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
		   _n_decicion,
		   _monto,
		   _n_corredor,
		   _n_ejecutivo with resume;
		   

end foreach
END
END PROCEDURE