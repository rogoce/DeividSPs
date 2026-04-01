-- Detalle de pólizas Anuladas Nva. Ley.
-- Creado:       22/04/2015  - Autor:  Armando Moreno M.
-- Modificado: 22/04/2015  - Autor:  Armando Moreno M.

drop procedure sp_cob360;
create procedure sp_cob360(
a_cia			char(3),
a_agencia		char(3),
a_codramo		char(255)	default "*",
a_periodo		char(7),
a_periodo2		char(7),
a_no_documento	char(255)	default "*",
a_agente		char(255)	default "*")
returning	char(50),
			char(20),
			char(50),
			char(3),
			char(50),
			char(3),
			char(50),
			char(3),
			char(50),
			char(3),
			char(50),
			char(5),
			char(50),
			char(3),
			char(50),
			smallint,
			smallint,
			date,
			date,
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			dec(16,2),
			char(5),
			char(50),
			char(100),
			CHAR(50),
			char(50);

BEGIN

define v_filtros			varchar(100);
define v_desc_grupo			varchar(50);
define _nom_div_cob			varchar(50);
define v_n_acreedor			varchar(50);
define _n_formapag			varchar(50);
define v_descr_cia			varchar(50);
define v_desc_ramo			varchar(50);
define _n_sucursal			varchar(50);
define _n_subramo			varchar(50);
define _n_motivo			varchar(50);
define v_agente				varchar(50);
define v_zona				varchar(50);
define v_desc_cliente		varchar(45);
define v_documento			char(20);
define v_contratante		char(10);
define _periodo				char(7);
define _cod_acreedor		char(5);
define _cod_agente			char(5);
define v_codgrupo			char(5);
define v_codigo				char(5);
define v_codsucursal		char(3);
define v_codformapag		char(3);
define v_codramo			char(3);
define _cod_endomov			char(3);
define v_saber				char(2);
define _tipo				char(1);
define _porc_partic_agt		dec(5,2);
define v_prima_bruta		dec(16,2);
define _por_vencer,_exigible,_corriente,_monto_30,_monto_60         dec(16,2);
define _monto_90,_monto_120,_monto_150,_monto_180,_saldo_total      dec(16,2);
define _cod_subramo,v_cod_zona										char(3);
define _estatus_poliza,_no_pagos,v_leasing							smallint;
define _cod_div_cob													char(1);
define _cod_cliente													char(10);
define _cod_gestion													char(3);
define _vig_fin				date;
define _vig_ini				date;
define _fecha				date;
define _cod_cobrador_c      char(3);
define _usuario             char(8);
define _nom_cobrador        char(50);
define _no_poliza			char(10);
	
	--SET DEBUG FILE TO "sp_cob360.trc";
	--TRACE ON;
CREATE TEMP TABLE tmp_cancela
                (no_documento     CHAR(20),
                 cod_ramo         CHAR(3),
				 cod_subramo      CHAR(3),
                 cod_sucursal     CHAR(3),
                 cod_contratante  CHAR(10),
                 prima_bruta	  DEC(16,2),
				 no_poliza        CHAR(10),
				 vig_ini		  DATE,
				 vig_fin		  DATE,
				 cod_agente       CHAR(5),
                 seleccionado     SMALLINT DEFAULT 1,
				 cod_formapag     char(3),
				 cod_zona         char(3),
				 nombre_zona      char(50),
				 estatus_poliza   smallint,
				 no_pagos         smallint,
				 cod_motiv        char(3),
				 cod_acreedor     char(5),
				 n_agente         char(50),
				 cod_cobrador     char(3)
				 );

   CREATE INDEX i_cancela1 ON tmp_cancela(cod_ramo);
   CREATE INDEX i_cancela2 ON tmp_cancela(cod_sucursal);
   CREATE INDEX i_cancela3 ON tmp_cancela(cod_subramo);

--   CREATE INDEX i_cancela5 ON tmp_cancela(cod_contratante);

    LET v_prima_bruta = 0;
    LET _por_vencer   = 0;
	LET _exigible     = 0;
	LET _corriente    = 0;
	LET _monto_30     = 0;
	LET _monto_60     = 0;
    LET v_desc_cliente   = NULL;
    LET v_desc_ramo      = NULL;
    LET v_n_acreedor     = NULL;
	let v_agente         = NULL;
    LET v_descr_cia      = NULL;
    LET v_filtros        = NULL;

    LET v_descr_cia = sp_sis01(a_cia);
	let _fecha 		= sp_sis36(a_periodo2);


    SET ISOLATION TO DIRTY READ;

    SELECT cod_endomov
      INTO _cod_endomov
      FROM endtimov
     WHERE tipo_mov = 2;

FOREACH
       SELECT e.no_documento,
       		  e.cod_sucursal,
       		  e.cod_formapag,
              e.cod_ramo,
              e.cod_contratante,
			  e.cod_subramo,
			  e.estatus_poliza,
			  e.no_pagos,
              x.prima_bruta,
			  x.vigencia_inic,
			  x.vigencia_final,
			  x.no_poliza
         INTO v_documento,
	      	  v_codsucursal,
	      	  v_codformapag,
	      	  v_codramo,
	      	  v_contratante,
	          _cod_subramo,
			  _estatus_poliza,
			  _no_pagos,
	          v_prima_bruta,
	          _vig_ini,
	          _vig_fin,
			  _no_poliza
	     FROM emipomae e, endedmae x
	    WHERE e.cod_compania = a_cia
	      AND e.no_poliza    = x.no_poliza
	      AND x.periodo     >= a_periodo
		  AND x.periodo     <= a_periodo2
	      AND x.actualizado  = 1
	      AND x.cod_endomov  = _cod_endomov
		  AND x.cod_tipocan  = "037"
	    ORDER BY e.cod_grupo,e.cod_ramo,x.no_factura

		call sp_cob116(_no_poliza) returning _cod_agente,v_agente,v_cod_zona,v_zona,v_leasing,_cod_div_cob,_nom_div_cob;

		let _cod_acreedor = '';

		foreach
			select x.cod_acreedor
			  into _cod_acreedor
			  from emipoacr x, emipouni e
             where x.no_poliza = e.no_poliza
               and x.no_unidad = e.no_unidad
               and e.no_poliza = _no_poliza
			 exit foreach;
		end foreach

		let _cod_cliente = '';
		foreach
			select cod_cliente
			  into _cod_cliente
			  from caspoliza
			 where no_documento = v_documento
		 
			exit foreach;		 
		end foreach
	   
		if _cod_cliente is null or _cod_cliente = '' then
			continue foreach;
		end if
		
	   
	   let _cod_gestion = null;
	   foreach
			select c.cod_gestion,
			       c.cod_cobrador
			  into _cod_gestion,
			       _cod_cobrador_c
			  from cascampana e, cascliente c
			 where e.cod_campana = c.cod_campana
			   and e.tipo_campana = 3
			   and c.cod_cliente  = _cod_cliente
			
			if _cod_gestion is not null then
				exit foreach;
			end if	
	   end foreach
	   
       INSERT INTO tmp_cancela
       VALUES(
       v_documento,        
       v_codramo,
	   _cod_subramo,
       v_codsucursal,
       v_contratante,
	   v_prima_bruta,
      _no_poliza,
	  _vig_ini,
	  _vig_fin,
	  _cod_agente,
      1,
	  v_codformapag,
	  v_cod_zona,
	  v_zona,
	  _estatus_poliza,
	  _no_pagos,
	  _cod_gestion,
	  _cod_acreedor,
	  v_agente,
	  _cod_cobrador_c
      );
END FOREACH

      -- Filtro de Ramo
      IF a_codramo <> "*" THEN
         LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_codramo);
         LET _tipo = sp_sis04(a_codramo); -- Separa los valores del String

         IF _tipo <> "E" THEN -- Incluir los Registros

            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo NOT IN(SELECT codigo FROM tmp_codigos);
         ELSE
            UPDATE tmp_cancela
                   SET seleccionado = 0
                 WHERE seleccionado = 1
                   AND cod_ramo IN(SELECT codigo FROM tmp_codigos);
         END IF
         DROP TABLE tmp_codigos;
      END IF

	--Filtro de poliza
   	IF a_no_documento <> "*" and a_no_documento <> "" THEN
         LET v_filtros = TRIM(v_filtros) ||"Documento: "||TRIM(a_no_documento);

            UPDATE tmp_cancela
               SET seleccionado = 0
             WHERE seleccionado = 1
               AND no_documento <> a_no_documento;
    END IF

	--Filtro de corredor
	IF a_agente <> "*" THEN

		LET _tipo = sp_sis04(a_agente);  -- Separa los Valores del String en una tabla de codigos

	   	LET v_filtros = TRIM(v_filtros) || " Corredor: "; --||  TRIM(a_agente);


		IF _tipo <> "E" THEN -- Incluir los Registros

			UPDATE tmp_cancela
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_agente NOT IN (SELECT codigo FROM tmp_codigos);
	       	   LET v_saber = "";

		ELSE		        -- Excluir estos Registros

			UPDATE tmp_cancela
			   SET seleccionado = 0
			 WHERE seleccionado = 1
			   AND cod_agente IN (SELECT codigo FROM tmp_codigos);
	           LET v_saber = " Ex";
		END IF

	    FOREACH
			SELECT agtagent.nombre,tmp_codigos.codigo
		      INTO v_agente,v_codigo
		      FROM agtagent,tmp_codigos
		     WHERE agtagent.cod_agente = codigo
		     LET v_filtros = TRIM(v_filtros) || " " || TRIM(v_codigo) || " " || TRIM(v_agente) || (v_saber);
	    END FOREACH

		DROP TABLE tmp_codigos;

	END IF

FOREACH
       SELECT no_documento,
       		  cod_acreedor,
       		  cod_ramo,
			  cod_subramo,
              cod_contratante,
              prima_bruta,
			  no_poliza,
              vig_ini,
              vig_fin,
			  cod_agente,
			  n_agente,
			  cod_formapag,
			  cod_zona,
		      nombre_zona,
			  estatus_poliza,
			  cod_sucursal,
			  no_pagos,
			  cod_motiv,
			  cod_cobrador
         INTO v_documento,
              _cod_acreedor,
              v_codramo,
			  _cod_subramo,
              v_contratante,
              v_prima_bruta,
			  _no_poliza,
              _vig_ini,
              _vig_fin,
			  _cod_agente,
			  v_agente,
			  v_codformapag,
			  v_cod_zona,
			  v_zona,
			  _estatus_poliza,
			  v_codsucursal,
			  _no_pagos,
			  _cod_gestion,
			  _cod_cobrador_c
         FROM tmp_cancela
        WHERE seleccionado = 1
        ORDER BY cod_ramo,no_documento

	   --Asegurado
       SELECT nombre
         INTO v_desc_cliente
         FROM cliclien
        WHERE cod_cliente = v_contratante;

	   --Ramo
       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = v_codramo;

	   SELECT nombre
         INTO _n_subramo
         FROM prdsubra
        WHERE cod_ramo    = v_codramo
		  AND cod_subramo = _cod_subramo;		

		let v_n_acreedor = null;	
		SELECT nombre
         INTO v_n_acreedor
         FROM emiacre
        WHERE cod_acreedor = _cod_acreedor;
		
		select nombre
		  into _n_formapag
		  from cobforpa
		 where cod_formapag = v_codformapag;

 		select descripcion
		  into _n_sucursal
		  from insagen
		 where codigo_agencia = v_codsucursal;
		 
		if _cod_gestion is not null then
			select nombre
			  into _n_motivo
			  from cobcages
			 where cod_gestion = _cod_gestion;
        else
			let _n_motivo = '';
		end if
		
		select usuario
		  into _usuario
		  from cobcobra
		 where cod_cobrador = _cod_cobrador_c;

		select upper(descripcion)
		  into _nom_cobrador
		  from insuser
		 where usuario = _usuario;
		 
       CALL sp_cob245a(
			 "001",
			 "001",	
			 v_documento,
			 a_periodo2,
			 _fecha
			 ) RETURNING _por_vencer,      
						 _exigible,         
						 _corriente,        
						 _monto_30,         
						 _monto_60,         
						 _monto_90,
						 _monto_120,
 						 _monto_150,
						 _monto_180,
						 _saldo_total;

       RETURN v_descr_cia,
	          v_documento,
			  v_desc_cliente,
       		  v_codramo,
       		  v_desc_ramo,
              _cod_subramo,
              _n_subramo,
              v_codformapag,
			  _n_formapag,
			  v_cod_zona,
			  v_zona,
			  _cod_agente,
			  v_agente,
			  v_codsucursal,
			  _n_sucursal,
			  _estatus_poliza,
			  _no_pagos,
              _vig_ini,
              _vig_fin,			  
              v_prima_bruta,
			  _por_vencer,      
			  _exigible,         
			  _corriente,        
			  _monto_30,         
			  _monto_60,         
			  _monto_90,
			  _saldo_total,
			  _cod_acreedor,
			  v_n_acreedor,
			  v_filtros,
			  _n_motivo,
			  _nom_cobrador
			  WITH RESUME;

END FOREACH
DROP TABLE tmp_cancela;
END
END PROCEDURE;
