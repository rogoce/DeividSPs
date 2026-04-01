-- Creacion de procedimiento de cuentas ACH
-- Creado: 28/11/2008 - Autor: Ricardo Jim‚nez Banda
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob744;

CREATE PROCEDURE "informix".sp_cob744(a_compania CHAR(3), a_sucursal CHAR(3), a_banco CHAR(255) default "*" )
RETURNING CHAR(17),  CHAR(100), CHAR(20), CHAR(100), DEC(16,2), CHAR(03), CHAR(50);

BEGIN

DEFINE _no_cuenta		 CHAR(17);
DEFINE _estatus          SMALLINT;
DEFINE _no_documento	 CHAR(20);
DEFINE _cod_cliente		 CHAR(10);
DEFINE _contratante      CHAR(10);
DEFINE _asegurado       CHAR(100);
DEFINE _pagador         CHAR(100);
DEFINE _cod_agente       CHAR(05);
DEFINE _agente          CHAR(100);
DEFINE _saldo           DEC(16,2);
DEFINE _no_poliza        CHAR(10);
DEFINE _remesa           CHAR(10);
DEFINE _existe           SMALLINT;
DEFINE _compania          CHAR(3);
DEFINE _sucursal          CHAR(3);
DEFINE _tipo              CHAR(1);
DEFINE _selecionado      SMALLINT;
DEFINE _cod_banco        CHAR(03);
DEFINE _banco       	CHAR(50);

SET ISOLATION TO DIRTY READ;

LET _remesa 				= '';
LET _no_poliza 				= '';
LET _no_documento			= '';
LET	_cod_cliente			= '';
LET	_contratante			= '';
LET	_asegurado				= '';
LET	_pagador				= '';
LET	_agente					= '';
LET	_saldo					= '';
LET	_compania       	 = '001';
LET	_sucursal	    	 = '001';

IF  a_banco <> "*" THEN
    --LET v_filtros = TRIM(v_filtros) ||"Ramo"||TRIM(a_codramo);
    LET _tipo = sp_sis04(a_banco); -- Separa los valores del String

    IF _tipo <> "E" THEN -- Incluir los Registros
	   FOREACH
			SELECT h.no_cuenta,
	   	   		   c.no_documento,
		   		   h.nombre,
				   h.cod_banco
	  		  INTO _no_cuenta,
		   		   _no_documento,
		   		   _pagador,
				   _cod_banco
	  		  FROM cobcutas c,
	  		       cobcuhab h
	 		 WHERE c.no_cuenta = h.no_cuenta
	   		   AND h.cod_banco IN (SELECT codigo FROM tmp_codigos)  ORDER BY h.no_cuenta
	  
	   		CALL sp_sis21(_no_documento) RETURNING _no_poliza;

	     	SELECT cod_contratante
	   	   	  INTO _cod_cliente
	       	  FROM emipomae
	      	 WHERE no_poliza      = _no_poliza
	           AND no_documento   = _no_documento
		       AND estatus_poliza = 1;

	    	SELECT nombre
		   	  INTO _asegurado
		   	  FROM cliclien
		   	 WHERE cod_cliente = _cod_cliente;

			SELECT nombre
			  INTO _banco
			  FROM chqbanco
			 WHERE cod_banco = _cod_banco;

			FOREACH
				SELECT cod_agente
				  INTO _cod_agente
				  FROM emipoagt
				 WHERE no_poliza  = _no_poliza
				 EXIT FOREACH;
			END FOREACH
		
		    SELECT nombre
		      INTO _agente
		      FROM agtagent
		     WHERE cod_agente = _cod_agente;

		    CALL sp_cob115b(a_compania, a_sucursal, _no_documento, _remesa) RETURNING _saldo;
		    IF _saldo = 0 THEN
			   LET _saldo = 0;
		    END IF;

		    RETURN _no_cuenta, _pagador, _no_documento, _agente, _saldo, _cod_banco, _banco WITH RESUME;
			
	   END FOREACH
	   
    ELIF _tipo = "E" THEN  -- Excluir los Registros

       FOREACH
			SELECT h.no_cuenta,
	   	   		   c.no_documento,
		   		   h.nombre,
	  		       h.cod_banco
	  		  INTO _no_cuenta,
		   		   _no_documento,
		   		   _pagador,
				   _cod_banco
			  FROM cobcutas c,
			       cobcuhab h
	       	 WHERE c.no_cuenta = h.no_cuenta
	   		   AND h.cod_banco NOT IN (SELECT codigo FROM tmp_codigos)  ORDER BY h.no_cuenta
	  
	   		CALL sp_sis21(_no_documento) RETURNING _no_poliza;

	     	SELECT cod_contratante
	   	   	  INTO _cod_cliente
	       	  FROM emipomae
	      	 WHERE no_poliza      = _no_poliza
	           AND no_documento   = _no_documento
		       AND estatus_poliza = 1;

	    	SELECT nombre
		   	  INTO _asegurado
		   	  FROM cliclien
		   	 WHERE cod_cliente = _cod_cliente;

			SELECT nombre
			  INTO _banco
			  FROM chqbanco
			 WHERE cod_banco = _cod_banco;

			FOREACH
				SELECT cod_agente
				  INTO _cod_agente
				  FROM emipoagt
				 WHERE no_poliza  = _no_poliza
				  EXIT FOREACH;
			END FOREACH
		
		    SELECT nombre
		      INTO _agente
		      FROM agtagent
		     WHERE cod_agente = _cod_agente;

		    CALL sp_cob115b(a_compania, a_sucursal, _no_documento, _remesa) RETURNING _saldo;
		    IF _saldo = 0 THEN
			   LET _saldo = 0;
		    END IF;

		   RETURN _no_cuenta, _pagador, _no_documento, _agente, _saldo, _cod_banco, _banco WITH RESUME;

	   END FOREACH
    END IF
  drop table tmp_codigos;

ELIF a_banco = '*' THEN

  FOREACH
   	SELECT h.no_cuenta,
	   	   c.no_documento,
		   h.nombre,
		   h.cod_banco
	  INTO _no_cuenta,
		   _no_documento,
		   _pagador,
		   _cod_banco
	  FROM cobcutas c,
	       cobcuhab h
	 WHERE c.no_cuenta = h.no_cuenta
	   AND c.procesar  = 1
	   AND c.excepcion = 0
	   AND h.cod_banco matches a_banco  ORDER BY h.no_cuenta
	CALL sp_sis21(_no_documento) RETURNING _no_poliza;

	SELECT cod_contratante
	  INTO _cod_cliente
	  FROM emipomae
	 WHERE no_poliza      = _no_poliza
	   AND no_documento   = _no_documento
	   AND estatus_poliza = 1;

	SELECT nombre
	  INTO _asegurado
	  FROM cliclien
	 WHERE cod_cliente = _cod_cliente;

	FOREACH
	   SELECT cod_agente
	     INTO _cod_agente
	     FROM emipoagt
	    WHERE no_poliza  = _no_poliza
	    EXIT FOREACH;
	END FOREACH
		
	SELECT nombre
	  INTO _agente
	  FROM agtagent
	 WHERE cod_agente = _cod_agente;

	SELECT nombre
	  INTO _banco
	  FROM chqbanco
	 WHERE cod_banco = _cod_banco;


   CALL sp_cob115b(_compania, _sucursal, _no_documento, _remesa) RETURNING _saldo;
   IF _saldo = 0 THEN
	  LET _saldo = 0;
   END IF;

   RETURN _no_cuenta, _pagador, _no_documento, _agente, _saldo, _cod_banco, _banco WITH RESUME;

   END FOREACH
   
END IF
  
END

END PROCEDURE;



