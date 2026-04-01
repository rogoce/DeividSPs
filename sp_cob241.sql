-- Procedimiento para insertar registros en COBENVAU para proceso diario de envio de correos desde programa de remesas
-- Creado: 10/03/2010 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob241;
CREATE PROCEDURE sp_cob241(a_poliza CHAR(20), a_asegurado char(100), a_vig_fin date, a_no_remesa char(10), a_no_recibo char(10), a_monto dec(16,2), a_tipo smallint default 0, a_cod_ramo char(3))
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
define _cnt 			smallint;

BEGIN

select count(*)
  into _cnt
  from cobenvau
 where no_documento = a_poliza
   and enviado      = 0;

if _cnt > 0 then
	RETURN 0, "";
end if

if a_tipo = 1 then --No se debe enviar tipo 1, correo Enilda 18/06/2025
	RETURN 0, "";
end if
select date_added
  into v_fecha
  from cobremae
 where no_remesa = a_no_remesa;

INSERT INTO cobenvau(
no_documento,
asegurado,
vigencia_final,
no_remesa,
no_recibo,
monto,
tipo,
enviado,
cod_ramo,
fecha
)
VALUES (
a_poliza,
a_asegurado,
a_vig_fin,
a_no_remesa,
a_no_recibo,
a_monto,
a_tipo,
0,
a_cod_ramo,
v_fecha
);

RETURN 0, "";

END

END PROCEDURE
