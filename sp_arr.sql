-- Procedimiento para insertar registros en COBENVAU para proceso diario de envio de correos desde programa de remesas
-- Creado: 10/03/2010 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_arr;

CREATE PROCEDURE "informix".sp_arr()
RETURNING SMALLINT, CHAR(30);

DEFINE	v_cod_ramo		CHAR(3);
DEFINE	v_prima_bruta	DEC(16,2);
DEFINE	v_cod_formapag	CHAR(3);
DEFINE	v_fecha_susc	DATE;
DEFINE	v_no_doc		CHAR(20);
DEFINE	v_nombre		CHAR(255);
DEFINE	v_fecha			date;
DEFINE	v_zona_libre	SMALLINT;
DEFINE	v_cant_pag		SMALLINT;
DEFINE  v_existe_end	SMALLINT;
DEFINE	v_saldo			DEC(16,2);
DEFINE 	v_soda			SMALLINT;
DEFINE	v_prima_modu	DEC(16,2);
DEFINE  v_saldo_end		DEC(16,2);
DEFINE	v_grupo			CHAR(5);
DEFINE	v_flag_flota	SMALLINT;
DEFINE	v_v_inicial		DATE;
DEFINE	v_v_final		DATE;
DEFINE	v_flag_modu		SMALLINT;
DEFINE	v_saldo_endp	DEC(16,2);
DEFINE  v_flag_existe	SMALLINT;
DEFINE	v_contratante	CHAR(10);
DEFINE 	v_pagador		CHAR(10);
DEFINE	v_prima_end		DEC(16,2);
define _no_remesa       char(10);

BEGIN

foreach

select no_remesa
  into _no_remesa
  from cobenvau


select date_posteo
  into v_fecha
  from cobremae
 where no_remesa = _no_remesa;

update cobenvau
   set fecha = v_fecha
 where no_remesa = _no_remesa;

end foreach

RETURN 0, "";

END

END PROCEDURE
