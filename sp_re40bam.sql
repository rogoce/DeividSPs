-- Detalle de Coberturas y Detalle de Pago para el Informe de Estatus del Reclamo
-- Creado    : 17/01/2001 - Autor: Marquelda Valdelamar
-- Modificado: 13/14/2001 - Autor: Marquelda Valdelamar
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_re40bam;
CREATE PROCEDURE sp_re40bam(
a_compania     CHAR(3),
a_sucursal     CHAR(3),   
a_numrecla     CHAR(18)
)
RETURNING CHAR(50),      -- nombre_cober
		  DEC(16,2),     -- monto_cobertura
		  DEC(16,2)      -- variacion_cober
		  	  		         
DEFINE _cod_cobertura  		CHAR(5);
DEFINE _nombre_cober		CHAR(50);
DEFINE _monto_cobertura,_monto_cob		DECIMAL(16,2);
DEFINE _variacion_cober     DECIMAL(16,2);
DEFINE _no_reclamo,_no_tranrec          CHAR(10);
define _cod_tipotran        char(3);
define _tipo_transaccion,_cnt    smallint;

create temp table tmp_est_cob(
cod_cobertura     char(5),
monto_cobertura	  dec(16,2),
variacion		  dec(16,2)
) with no log;

-- Detalle de Coberturas

select no_reclamo
  into _no_reclamo
  from recrcmae
 where numrecla    = a_numrecla
   and actualizado = 1;

let _monto_cob = 0.00;
FOREACH
	select cod_tipotran,
	       no_tranrec
      into _cod_tipotran,
           _no_tranrec
      from rectrmae
     where no_reclamo = _no_reclamo
	   and actualizado = 1

	select tipo_transaccion
	  into _tipo_transaccion
	  from rectitra
	 where cod_tipotran = _cod_tipotran;
	 
	let _monto_cob = 0.00;
	
	FOREACH
		SELECT c.cod_cobertura,
		       SUM(c.monto),
		       SUM(c.variacion)
		  INTO _cod_cobertura,
		       _monto_cobertura,
		       _variacion_cober
		  FROM rectrcob c
		 WHERE c.no_tranrec = _no_tranrec
		 GROUP BY cod_cobertura
		
		if _tipo_transaccion in(4,6) then
		else
			let _monto_cobertura = _monto_cob;
		end if
		select count(*)
		  into _cnt
		  from tmp_est_cob
		 where cod_cobertura = _cod_cobertura;
		if _cnt = 0 then
			insert into tmp_est_cob
			values(_cod_cobertura,_monto_cobertura,_variacion_cober);
		else
			update tmp_est_cob
			   set monto_cobertura = monto_cobertura + _monto_cobertura,
			       variacion       = variacion + _variacion_cober
			 where cod_cobertura = _cod_cobertura;
		end if
	END FOREACH
end FOREACH

FOREACH
  SELECT cod_cobertura,
  		 SUM(monto_cobertura),
         SUM(variacion)
  	INTO _cod_cobertura,
  	     _monto_cobertura,
    	 _variacion_cober
	FROM tmp_est_cob
   GROUP BY cod_cobertura

  SELECT nombre
    INTO _nombre_cober
    FROM prdcober
   WHERE cod_cobertura = _cod_cobertura;

	RETURN _nombre_cober, _monto_cobertura, _variacion_cober WITH RESUME;
END FOREACH;
drop table tmp_est_cob;
END PROCEDURE;