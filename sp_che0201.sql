-- Procedimiento que Crea el Maestro Conciliador

-- Creado    : 02/11/2009 - Autor: Juan Plata
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che0201;

CREATE PROCEDURE sp_che0201(a_compania char(3),a_cod_banco char(3),a_cod_ctabanco char(4),a_ano_transac char(4),a_mes_transac char(2),a_saldo_libro decimal(15,2),a_saldo_banco decimal(15,2),a_fecha_ini date,a_fecha_final date) returning integer,char(50);

Define _registro    Integer;
define _fechamax	char(3);
define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);
define _deposito     decimal(15,2);
define _ncredito     decimal(15,2);
define _ndebito      decimal(15,2);
define _cheques      decimal(15,2);
define _chq_circula  decimal(15,2);
define _dep_transito decimal(15,2);
define _ncr_noaplica decimal(15,2);
define _ndb_noaplica decimal(15,2);
define _chq_anulado  decimal(15,2);
define _estado       CHAR(1);


set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

IF a_saldo_libro IS NULL THEN
	LET a_saldo_libro = 0;
END IF

IF a_saldo_banco IS NULL THEN
	LET a_saldo_banco = 0;
END IF

--SELECT count(*) Into _registro
--  FROM bcoconc 
-- WHERE compania     = a_compania
--   AND cod_banco    = a_cod_banco
--   AND cod_ctabanco = a_cod_ctabanco
--   AND ano_transac  = a_ano_transac
--   AND mes_transac  = a_mes_transac;
  
  --IF _registro > 0 THEN 
  --  INSERT INTO bcoconc VALUES (a_compania,a_cod_banco,a_cod_ctabanco,a_ano_transac,a_mes_transac,a_saldo_libro,a_saldo_banco,0,0,0,0,0,0,0,0,0,0,"0",0);
  --END IF
  
  SELECT status Into _estado
  FROM bcoconc 
 WHERE compania     = a_compania
   AND cod_banco    = a_cod_banco
   AND cod_ctabanco = a_cod_ctabanco
   AND ano_transac  = a_ano_transac
   AND mes_transac  = a_mes_transac;

  IF _estado = "0" THEN 
  
	  SELECT SUM(monto) INTO _deposito
		FROM bcocirc 
	   WHERE compania     = a_compania
		 AND cod_banco    = a_cod_banco
		 AND cod_ctabanco = a_cod_ctabanco
		 AND fecha  BETWEEN a_fecha_ini AND a_fecha_final
		 AND estado <> "1"
		 AND tipo_docu = "DP";

	  SELECT SUM(monto) INTO _ncredito
		FROM bcocirc 
	   WHERE compania     = a_compania
		 AND cod_banco    = a_cod_banco
		 AND cod_ctabanco = a_cod_ctabanco
		 AND fecha  BETWEEN a_fecha_ini AND a_fecha_final
		 AND estado <> "1"
		 AND tipo_docu = "NC";

	  SELECT SUM(monto) INTO _ndebito
		FROM bcocirc 
	   WHERE compania     = a_compania
		 AND cod_banco    = a_cod_banco
		 AND cod_ctabanco = a_cod_ctabanco
		 AND fecha  BETWEEN a_fecha_ini AND a_fecha_final
		 AND estado <> "1"
		 AND tipo_docu = "ND" ; 

	   SELECT SUM(monto) INTO _cheques
		FROM bcocirc 
	   WHERE compania     = a_compania
		 AND cod_banco    = a_cod_banco
		 AND cod_ctabanco = a_cod_ctabanco
		 AND fecha  BETWEEN a_fecha_ini AND a_fecha_final
		 AND estado <> "1"
		 AND tipo_docu = "CK" ; 
		 
		 
	  SELECT SUM(monto) INTO _chq_anulado
		FROM bcocirc 
	   WHERE compania     = a_compania
		 AND cod_banco    = a_cod_banco
		 AND cod_ctabanco = a_cod_ctabanco
		 AND fecha  BETWEEN a_fecha_ini AND a_fecha_final
		 AND estado = "1"
		 AND tipo_docu = "CK" ;  
		 
		  
	---DOCUMENTOS EN CIRCULACIÒN

	SELECT SUM(monto) INTO _dep_transito
		FROM bcocirc 
	   WHERE compania     = a_compania
		 AND cod_banco    = a_cod_banco
		 AND cod_ctabanco = a_cod_ctabanco
		 AND fecha  <= a_fecha_final
		 AND estado = "0"
		 AND tipo_docu = "DP";

	  SELECT SUM(monto) INTO _ncr_noaplica
		FROM bcocirc 
	   WHERE compania     = a_compania
		 AND cod_banco    = a_cod_banco
		 AND cod_ctabanco = a_cod_ctabanco
		 AND fecha  <= a_fecha_final
		 AND estado = "0"
		 AND tipo_docu = "NC";

	  SELECT SUM(monto) INTO _ndb_noaplica
		FROM bcocirc 
	   WHERE compania     = a_compania
		 AND cod_banco    = a_cod_banco
		 AND cod_ctabanco = a_cod_ctabanco
		 AND fecha  <= a_fecha_final
		 AND estado = "0"
		 AND tipo_docu = "ND" ; 

	   SELECT SUM(monto) INTO _chq_circula
		FROM bcocirc 
	   WHERE compania     = a_compania
		 AND cod_banco    = a_cod_banco
		 AND cod_ctabanco = a_cod_ctabanco
		 AND fecha  <= a_fecha_final
		 AND estado = "0"
		 AND tipo_docu = "CK" ; 

		IF _deposito IS NULL THEN
			LET _deposito = 0;
		END IF
		IF _ncredito IS NULL THEN
			LET _ncredito = 0;
		END IF
		IF _ndebito IS NULL THEN
			LET _ndebito = 0;
		END IF
		IF _cheques IS NULL THEN
			LET _cheques = 0;
		END IF
		IF _chq_circula IS NULL THEN
			LET _chq_circula = 0;
		END IF
		IF _dep_transito IS NULL THEN
			LET _dep_transito = 0;
		END IF
		IF _ncr_noaplica IS NULL THEN
			LET _ncr_noaplica = 0;
		END IF
		IF _ndb_noaplica IS NULL THEN
			LET _ndb_noaplica = 0;
		END IF
		IF _chq_anulado IS NULL THEN
			LET _chq_anulado = 0;
		END IF	
	  
	   UPDATE  bcoconc 
		 SET deposito      = _deposito,
			 ncredito      = _ncredito,
			 ndebito       = _ndebito,
			 cheques       = _cheques,
			 chq_circula   = _chq_circula,
			 dep_transito  = _dep_transito,
			 ncr_noaplica  = _ncr_noaplica,
			 ndb_noaplica  = _ndb_noaplica,
			 chq_anulado   = _chq_anulado,
			 Saldoinicial  = a_saldo_libro,
			 Saldobanco    = a_saldo_banco
		WHERE compania     = a_compania
		  AND cod_banco    = a_cod_banco
		  AND cod_ctabanco = a_cod_ctabanco
		  AND ano_transac  = a_ano_transac
		  AND mes_transac  = a_mes_transac
		  AND status       = "0";
		  
		UPDATE bcoconc 
		   SET Saldofinal   = Saldoinicial + deposito + ncredito + chq_anulado - cheques - ndebito,
               Saldobcofin =  Saldobanco + dep_transito - chq_circula - ndb_noaplica
		WHERE  compania     = a_compania
		  AND  cod_banco    = a_cod_banco
		  AND  cod_ctabanco = a_cod_ctabanco
		  AND  ano_transac  = a_ano_transac
		  AND  mes_transac  = a_mes_transac
		  AND  status       = "0";  
	  
 END IF	  
	  
 end


return 0, "Actualizacion Exitosa";

end procedure 
  