-- Procedure que busca los reclamos abiertos hace mas de 3 meses que no han tenido movimiento TERCEROS

drop procedure sp_rec294;

create procedure sp_rec294(a_ajustador CHAR(255) DEFAULT "*", a_periodo_ter CHAR(255) DEFAULT "*", a_periodo_rec CHAR(255) DEFAULT "*", a_agente CHAR(255) DEFAULT "*", a_estatus_rec CHAR(255) DEFAULT "*")
returning char(10) as tramite,
          char(20) as reclamo,
          varchar(100) as asegurado,
		  date as fecha_siniestro,
		  date as fecha_reclamo,
		  varchar(100) as tercero,
		  date as fecha_tercero,
		  varchar(50) as marca,
		  varchar(50) as modelo,
		  smallint as ano_auto,
		  char(10) as placa,
		  char(15) as estatus_audiencia,
		  char(10) as estatus_reclamo,
		  dec(16,2) as incurrido_bruto,
		  dec(16,2) as reserva_bruta,
		  varchar(50) as ajustador,
		  char(8) as user_added,
		  char(7) as periodo,
		  varchar(255) as agente,
		  varchar(255) as filtros;
		  
		  
define _fecha_inicio	date;
define _fecha_reclamo	date;
define _cantidad		smallint;
define _cantidad2       smallint;
define _no_reclamo		char(10);
define _numrecla		char(20);
define _reserva			dec(16,2);
define _no_poliza		char(10);
define _cod_ramo		char(3);
define _cod_subramo		char(3);
define _nombre_ramo		char(50);
define _perd_total		smallint;
define _dias            integer;         

define _no_tramite      char(10);
define _incidente		integer;
define _user_added      char(10);

define _error			integer;
define _error_desc		char(50);
define _ult_fecha       date;
define _cod_abogado     char(3);
define _cont_tercero    smallint;
define _cod_ajustador   char(3);
define _n_ajustador   char(50);
define _cod_tercero    char(10);
define _cont           integer;
define _asegurado      varchar(100);
define _tercero        varchar(100);
define _date_added     date;
define _cod_asegurado  char(10);
define _no_documento   char(20);
define _fecha_siniestro date;

define _estatus_reclamo   char(1);
define _estatus_audiencia smallint;
define _periodo, _periodo_ter char(7);
define _ano_auto		smallint;
define _placa    		char(10);
define _marca			varchar(50);
define _modelo		    varchar(50);
define _cod_marca       char(5);
define _cod_modelo      char(5);
define _agente          varchar(255);
define _cod_agente      char(5);
define _nom_agent       varchar(50);
DEFINE v_porc_coas	    DEC(7,4);
DEFINE _incurrido_reclamo DEC(16,2);
DEFINE _incurrido_bruto  DEC(16,2);
define _monto_tran       DEC(16,2);
define _reserva_bruta    DEC(16,2);
define _ajustador        varchar(50);
define _cont2            smallint;
define v_filtros         varchar(255);
DEFINE _tipo             CHAR(1);
DEFINE v_desc_ajustador,v_desc_agente   VARCHAR(50);
DEFINE v_codigo         CHAR(5);
DEFINE v_saber          CHAR(2);

   CREATE TEMP TABLE temp_tercero
		 (no_tramite char(10),
		  numrecla   char(20),
		  asegurado  varchar(100),
		  fecha_siniestro date,
		  fecha_reclamo date,
		  tercero varchar(100),
		  date_added date,
		  marca varchar(50),
		  modelo varchar(50),
		  ano_auto smallint,
		  placa char(10),
		  estatus_audiencia smallint,
		  estatus_reclamo char(1),
		  incurrido_bruto dec(16,2),
		  reserva_bruta dec(16,2),
		  ajustador varchar(50),
		  user_added char(8),
		  periodo_rec char(7),
		  cod_agente char(5),
		  cod_ajustador char(3),
		  periodo_ter char(7),
		  no_poliza char(10),
		  seleccionado SMALLINT DEFAULT 1)
		  WITH NO LOG;


let _fecha_inicio = MDY(1,1,2008);

set isolation to dirty read;

let _error = 0;
let _cod_abogado   = null;
let _cod_ajustador = null;
let _n_ajustador   = null;

foreach
 select	a.no_tramite,
        a.cod_asegurado,
 		a.no_documento,
        a.fecha_siniestro,
        a.no_reclamo,
		a.estatus_reclamo,
		a.numrecla,
		a.fecha_reclamo,
		a.estatus_audiencia,
		a.ajust_interno,
		a.periodo,
		a.no_poliza,
		b.cod_tercero,
		b.date_added,
        b.cod_marca,
		b.cod_modelo,
		b.placa,
		b.ano_auto,
		b.user_added
   into	_no_tramite,
        _cod_asegurado,
		_no_documento,
		_fecha_siniestro,
        _no_reclamo,
		_estatus_reclamo,
		_numrecla,
		_fecha_reclamo,
		_estatus_audiencia,
		_cod_ajustador,
		_periodo,
		_no_poliza,
		_cod_tercero,
		_date_added,
        _cod_marca,
		_cod_modelo,
		_placa,
		_ano_auto,
		_user_added
   from recrcmae a, recterce b
  where a.no_reclamo = b.no_reclamo
    and today - b.date_added  >= 90
	and a.actualizado    = 1
--	and a.estatus_reclamo = 'A'
--	and a.estatus_audiencia in (0,8)
--	and a.cod_abogado = '001'
order by  a.incidente
	
	let _cont = 0;
	
	select count(*)
	  into _cont
	  from rectrmae
	 where no_reclamo = _no_reclamo
	   and cod_cliente  = _cod_tercero
	   and cod_tipotran = '004'
	   and actualizado = 1;
	   
	if month(_date_added) < 10 then
		let _periodo_ter = year(_date_added) || "-0" || month(_date_added);
	else
		let _periodo_ter = year(_date_added) || "-" || month(_date_added);
	end if
	   
    if _cont = 0 then
		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 		
			LET	v_porc_coas = NULL;

			FOREACH
			 SELECT porc_partic_coas
			   INTO v_porc_coas
			   FROM reccoas r, parparam p
			  WHERE r.cod_coasegur = p.par_ase_lider
				AND r.no_reclamo = _no_reclamo
			END FOREACH

			IF v_porc_coas IS NULL THEN
			   LET v_porc_coas = 0;
			END IF

			--INCURRIDOS

			LET _incurrido_reclamo = 0.00;
			LET _incurrido_bruto   = 0.00;
			let _reserva_bruta = 0.00;
			foreach
			 select monto
			   into _monto_tran
			   from rectrmae
			  where no_reclamo   = _no_reclamo
				and actualizado  = 1
				and cod_tipotran in ("004", "005", "006", "007")

				let _incurrido_reclamo = _incurrido_reclamo + _monto_tran;
				let _monto_tran        = _monto_tran * v_porc_coas / 100;
				let _incurrido_bruto   = _incurrido_bruto + _monto_tran;

			end foreach
			
			foreach
			 select variacion
			   into _monto_tran
			   from rectrmae
			  where no_reclamo   = _no_reclamo
				and actualizado  = 1
				and variacion    <> 0.00

				let _incurrido_reclamo = _incurrido_reclamo + _monto_tran;
				let _monto_tran        = _monto_tran * v_porc_coas / 100;
				let _incurrido_bruto   = _incurrido_bruto + _monto_tran;
				let _reserva_bruta     = _reserva_bruta + _monto_tran;
			end foreach
			
			select nombre
			  into _ajustador
			  from recajust
			 where cod_ajustador = _cod_ajustador;
						
			select nombre
			  into _asegurado
			  from cliclien
			 where cod_cliente = _cod_asegurado;
		
			select nombre
			  into _tercero
			  from cliclien
			 where cod_cliente = _cod_tercero;
			 
			let _marca = null;
			let _modelo = null;

			if _cod_marca is null then
				let _cod_marca = "";
			else
				select nombre
				  into _marca
				  from emimarca
				 where cod_marca = _cod_marca;
			end if

			if _cod_modelo is null then
				let _cod_modelo = "";
			else
				select nombre
				  into _modelo
				  from emimodel
				 where cod_marca  = _cod_marca
				   and cod_modelo = _cod_modelo;
			end if
			
			INSERT INTO temp_tercero
			 (no_tramite,
			  numrecla,
			  asegurado,
			  fecha_siniestro,
			  fecha_reclamo,
			  tercero,
			  date_added,
			  marca,
			  modelo,
			  ano_auto,
			  placa,
			  estatus_audiencia,
			  estatus_reclamo,
			  incurrido_bruto,
			  reserva_bruta,
			  ajustador,
			  user_added,
			  periodo_rec,
			  cod_agente,
		      cod_ajustador,
		      periodo_ter,
			  no_poliza
			  )
			 VALUES 
			 (_no_tramite,
			   _numrecla,
			   _asegurado,
			   _fecha_siniestro,
			   _fecha_reclamo,
			   _tercero,
			   _date_added,
			   _marca,
			   _modelo,
			   _ano_auto,
			   _placa,
			   _estatus_audiencia,
			   _estatus_reclamo,
			   _incurrido_bruto,
			   _reserva_bruta,
			   _ajustador,
			   _user_added,
			   _periodo,
			   _cod_agente,
			   _cod_ajustador,
			   _periodo_ter,
			   _no_poliza
			   );
			   
		end foreach
    end if
end foreach

LET v_filtros = "";
IF a_ajustador <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ajustador: "; --||  TRIM(a_ajustador);

	LET _tipo = sp_sis04(a_ajustador);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE temp_tercero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ajustador NOT IN (SELECT codigo FROM tmp_codigos);
          LET v_saber = "";

	ELSE		        -- Excluir estos Registros

		UPDATE temp_tercero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND ajust_interno IN (SELECT codigo FROM tmp_codigos);
          LET v_saber = " Ex";

	END IF

	 FOREACH
		SELECT recajust.nombre,tmp_codigos.codigo
          INTO v_desc_ajustador,v_codigo
          FROM recajust,tmp_codigos
         WHERE recajust.cod_ajustador = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_ajustador) || TRIM(v_saber);
	 END FOREACH
	
	DROP TABLE tmp_codigos;

END IF
IF a_periodo_ter <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Periodo Tercero: " ||  TRIM(a_periodo_ter);

	LET _tipo = sp_sis04(a_periodo_ter);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE temp_tercero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND periodo_ter NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE temp_tercero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND periodo_ter IN (SELECT codigo FROM tmp_codigos);

	END IF
	
	DROP TABLE tmp_codigos;

END IF
IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --||  TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE temp_tercero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
          LET v_saber = "";

	ELSE		        -- Excluir estos Registros

		UPDATE temp_tercero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
          LET v_saber = " Ex";

	END IF

	 FOREACH
		SELECT agtagent.nombre,tmp_codigos.codigo
          INTO v_desc_agente,v_codigo
          FROM agtagent,tmp_codigos
         WHERE agtagent.cod_agente = codigo
         LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_desc_agente) || TRIM(v_saber);
	 END FOREACH
	
	DROP TABLE tmp_codigos;

END IF
IF a_estatus_rec <> "*" THEN

	LET _tipo = sp_sis04(a_estatus_rec);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE temp_tercero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND estatus_reclamo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE temp_tercero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND estatus_reclamo IN (SELECT codigo FROM tmp_codigos);

	END IF
	
	DROP TABLE tmp_codigos;
	IF a_estatus_rec = "A;" THEN
		LET a_estatus_rec = "ABIERTO";
	ELIF a_estatus_rec = "C;" THEN
		LET a_estatus_rec = "CERRADO";
	ELIF a_estatus_rec = "D;" THEN
		LET a_estatus_rec = "DECLINADO";
	ELIF a_estatus_rec = "N;" THEN
		LET a_estatus_rec = "NO APLICA";
	END IF
	LET v_filtros = TRIM(v_filtros) || " Estatus Reclamo: " ||  TRIM(a_estatus_rec);

END IF
IF a_periodo_rec <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Periodo Reclamo: " ||  TRIM(a_periodo_rec);

	LET _tipo = sp_sis04(a_periodo_rec);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- Incluir los Registros

		UPDATE temp_tercero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND periodo_rec NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- Excluir estos Registros

		UPDATE temp_tercero
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND periodo_rec IN (SELECT codigo FROM tmp_codigos);

	END IF
	
	DROP TABLE tmp_codigos;

END IF

FOREACH
	SELECT no_tramite,
		   numrecla,
		   asegurado,
		   fecha_siniestro,
		   fecha_reclamo,
		   tercero,
		   date_added,
		   marca,
		   modelo,
		   ano_auto,
		   placa,
		   estatus_audiencia,
		   estatus_reclamo,
		   incurrido_bruto,
		   reserva_bruta,
		   ajustador,
		   user_added,
		   periodo_rec,
		   no_poliza
	  INTO _no_tramite,
		   _numrecla,
		   _asegurado,
		   _fecha_siniestro,
		   _fecha_reclamo,
		   _tercero,
		   _date_added,
		   _marca,
		   _modelo,
		   _ano_auto,
		   _placa,
		   _estatus_audiencia,
		   _estatus_reclamo,
		   _incurrido_bruto,
		   _reserva_bruta,
		   _ajustador,
		   _user_added,
		   _periodo,
		   _no_poliza
	  FROM temp_tercero
	 WHERE seleccionado = 1

	    let _agente = "";
		let _cont2 = 1;

		foreach
			select cod_agente
			  into _cod_agente
			  from emipoagt
			 where no_poliza = _no_poliza
			 
			select nombre 
			  into _nom_agent
			  from agtagent
			 where cod_agente = _cod_agente;
			 
			 if _cont2 = 1 then
				let _agente = _agente || trim(_nom_agent);
			 else
			    let _agente = _agente || ", " || trim(_nom_agent);
			 end if
			 let _cont2 = _cont2 + 1;
		end foreach

			return _no_tramite,
				   _numrecla,
				   _asegurado,
				   _fecha_siniestro,
				   _fecha_reclamo,
				   _tercero,
				   _date_added,
				   _marca,
				   _modelo,
				   _ano_auto,
				   _placa,
				   (case when _estatus_audiencia = 1 then "GANADO" else (case when _estatus_audiencia = 0 then "PERDIDO" else (case when _estatus_audiencia = 2 then "POR DEFINIR" else (case when _estatus_audiencia = 3 then "PROCESO PENAL" else (case when _estatus_audiencia = 4 then "PROCESO CIVIL" else (case when _estatus_audiencia = 5 then "APELACION" else (case when _estatus_audiencia = 6 then "RESUELTO" else (case when _estatus_audiencia = 7 then "FUT GANADO" else "FUT RESPONSABLE" end)end)end)end)end)end)end)end),
				   (case when _estatus_reclamo = "A" then "ABIERTO" else (case when _estatus_reclamo = "C" then "CERRADO" else (case when _estatus_reclamo = "D" then "DECLINADO" else "NO APLICA" end) end) end),
				   _incurrido_bruto,
				   _reserva_bruta,
				   _ajustador,
				   _user_added,
				   _periodo,
				   _agente,
				   v_filtros
				   with resume;
END FOREACH	
DROP TABLE temp_tercero;
end procedure