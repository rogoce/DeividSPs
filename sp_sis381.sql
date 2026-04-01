--***************************************************************--
-- Procedimiento que Carga tabla año 2008 Incentivos de Fidelidad--
--***************************************************************--

-- Creado    : 05/01/2009 - Autor: Armando Moreno M.
-- Modificado: 05/01/2009 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_sis381;

CREATE PROCEDURE sp_sis381(a_compania CHAR(3),a_no_documento CHAR(20),a_periodo CHAR(7), a_tipo smallint, a_no_poliza char(10))
RETURNING CHAR(7);

define _ano        smallint;
define _no_recibo  CHAR(10);
define _fecha      DATE;
define _no_poliza  char(10);
define _periodo    char(7);

let _ano     = a_periodo[1,4];
let _periodo = "";

--SET DEBUG FILE TO "sp_sis381.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

if a_tipo = 0 then

	foreach

		SELECT d.no_poliza,
		       d.no_recibo,
		       d.fecha,
		       d.periodo
		  INTO _no_poliza,
		       _no_recibo,
			   _fecha,
			   _periodo
		  FROM cobredet d, cobremae m
		 WHERE d.cod_compania = a_compania
		   AND d.actualizado  = 1
		   AND d.tipo_mov     IN ('P','N')
		   AND d.doc_remesa   = a_no_documento
		   AND d.saldo        <= 0
		   AND d.periodo[1,4] = _ano
		   AND d.periodo      <= a_periodo
		   AND d.no_remesa    = m.no_remesa
		   AND m.tipo_remesa  IN ('A', 'M', 'C')
		 ORDER BY d.fecha,d.no_recibo,d.no_poliza

		exit foreach;

	end foreach

	if _periodo is null then
		let _periodo = "";
	end if

	return _periodo;

else

		foreach

		SELECT d.no_poliza,
		       d.no_recibo,
		       d.fecha,
		       d.periodo
		  INTO _no_poliza,
		       _no_recibo,
			   _fecha,
			   _periodo
		  FROM cobredet d, cobremae m
		 WHERE d.cod_compania = a_compania
		   AND d.actualizado  = 1
		   AND d.tipo_mov     IN ('P','N')
		   AND d.no_poliza    = a_no_poliza
		   AND d.saldo        <= 0
		   AND d.periodo[1,4] = _ano
		   AND d.periodo      <= a_periodo
		   AND d.no_remesa    = m.no_remesa
		   AND m.tipo_remesa  IN ('A', 'M', 'C')
		 ORDER BY d.fecha,d.no_recibo,d.no_poliza

		exit foreach;

	end foreach

	if _periodo is null then
		let _periodo = "";
	end if

	return _periodo;

end if

END PROCEDURE;