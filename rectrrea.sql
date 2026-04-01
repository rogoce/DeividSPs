-- Consulta de Cobertura de una Transaccion

-- Creado    : 25/06/2004 - Autor: Amado Perez M.
-- Modificado: 25/06/2004 - Autor: Amado Perez M.

-- SIS v.2.0 -  - DEIVID, S.A.

DROP PROCEDURE verif_rectrrea;

CREATE PROCEDURE verif_rectrrea()
RETURNING char(10);

define v_no_tranrec          char(10);

--set debug file to "sp_rwf02.trc";

create temp table tmp_reclamo(
	no_tranrec      char(10),
	suma            smallint default 1,
   	PRIMARY KEY (no_tranrec)
	) with no log;


SET ISOLATION TO DIRTY READ;

	FOREACH
	 select	porc_partic_suma
	   into _porc_reas
	   from rectrrea
	  where no_tranrec    = _no_tranrec
	    and tipo_contrato = 1
	END FOREACH
	
drop table tmp_reclamo;

END PROCEDURE;