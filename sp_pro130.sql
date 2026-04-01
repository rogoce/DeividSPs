-- Endosos de Cancelacion por Periodo
--
-- Creado    : 14/10/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 14/10/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_pro130;

create procedure "informix".sp_pro130(a_compania char(3), a_ano char(4), a_agente CHAR(255) DEFAULT "*")
returning char(20),
          char(10),
		  date,
		  date,
		  char(100),
		  dec(16,2),
		  char(10),
		  char(50),
		  smallint,
		  char(50),
		  char(255),
		  char(7);

define v_filtros        char(255);
define _tipo            char(1);
define v_saber          char(2);

define _no_documento	char(20);
define _no_factura		char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _prima_suscrita	dec(16,2);
define _periodo			char(7);

define _no_poliza		char(10);
define _nombre_aseg		char(100);
define _cod_aseg		char(10);

define _ano				smallint;
define _nombre_cia		char(50);

define _cod_agente		char(10);
define _nombre_agente	char(50);

create temp table tmp_canc(
no_documento	char(20),
no_factura		char(10),
vigencia_inic	date,
vigencia_final	date,
cod_aseg		char(10),
prima_suscrita	dec(16,2),
ano				smallint,
cod_agente		char(10),
seleccionado    SMALLINT,
periodo			char(7)
) with no log;

let _nombre_cia = sp_sis01(a_compania);

foreach
 select no_documento,
        no_factura,
		vigencia_inic,
		vigencia_final,
		no_poliza,
		prima_suscrita,
		periodo
   into _no_documento,
        _no_factura,
		_vigencia_inic,
		_vigencia_final,
		_no_poliza,
		_prima_suscrita,
		_periodo
   from endedmae
  where cod_endomov  = "002" 
    and actualizado  = 1
	and periodo[1,4] = a_ano

	let _ano = year(_vigencia_inic);

	select cod_contratante
	  into _cod_aseg
	  from emipomae
	 where no_poliza = _no_poliza;

	foreach
	 select cod_agente
	   into _cod_agente
	   from emipoagt
	  where no_poliza = _no_poliza

		insert into tmp_canc
		values(
		_no_documento,
		_no_factura,
		_vigencia_inic,
		_vigencia_final,
		_cod_aseg,
		_prima_suscrita,
		_ano,
		_cod_agente,
		1,
		_periodo
		);

	end foreach

end foreach

LET v_filtros = "";

IF a_agente <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Corredor: " || TRIM(a_agente);

	LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_canc
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = "";

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_canc
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	       LET v_saber = " Ex";

	END IF

	DROP TABLE tmp_codigos;

END IF

foreach
 select no_documento,
        no_factura,
		vigencia_inic,
		vigencia_final,
		cod_aseg,
		prima_suscrita,
		ano,
		cod_agente,
		periodo
   into _no_documento,
        _no_factura,
		_vigencia_inic,
		_vigencia_final,
		_cod_aseg,
		_prima_suscrita,
		_ano,
		_cod_agente,
		_periodo
   from tmp_canc
  where seleccionado = 1

	select nombre
	  into _nombre_aseg
	  from cliclien
	 where cod_cliente = _cod_aseg;

	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;

	return _no_documento,
	       _no_factura,
		   _vigencia_inic,
		   _vigencia_final,
		   _nombre_aseg,
		   _prima_suscrita,
		   _cod_agente,
		   _nombre_agente,
		   _ano,
		   _nombre_cia,
		   v_filtros,
		   _periodo
		   with resume;


end foreach

drop table tmp_canc;

end procedure;
