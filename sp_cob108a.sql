-- Procedimiento que pasa de un cobrador de calle a otro
-- 
-- Creado    : 20/09/2000 - Autor: Amado Perez Mendoza
-- Modificado: 20/11/2001 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob108a;
--DROP TABLE tmp_arreglo;
CREATE PROCEDURE "informix".sp_cob108a(a_cobrador_vjo CHAR(3), a_cobrador_nvo CHAR(3),a_parametro integer,a_arg integer default 1)
       RETURNING	    int;

DEFINE v_orden2,v_orden1,_pago_fijo  SMALLINT;
DEFINE v_dia1			 INT;
DEFINE v_dia2            INT;
DEFINE _tipo_cobrador    INT;
DEFINE v_motiv  		 CHAR(3);
DEFINE _cia		         CHAR(3);
DEFINE _suc		         CHAR(3);
DEFINE v_asegurado       CHAR(100);
DEFINE v_prima_orig      DEC(16,2);
DEFINE v_saldo           integer;
DEFINE v_por_vencer      DEC(16,2);	 
DEFINE v_exigible        DEC(16,2);
DEFINE v_corriente		 DEC(16,2);
DEFINE v_monto_30		 DEC(16,2);
DEFINE v_monto_60		 DEC(16,2);
DEFINE v_monto_90		 DEC(16,2);
DEFINE v_apagar          DEC(16,2);
DEFINE _code_agente      CHAR(5);				  
DEFINE _cod_pagador      CHAR(10);
DEFINE _cod_cobrador     CHAR(3);
DEFINE _fecha_dt         DATETIME YEAR TO FRACTION(5);
DEFINE _periodo          CHAR(7);
DEFINE _mes_char         CHAR(2);
DEFINE _ano_char		 CHAR(4);
define _user_added		 char(8);
define _cod_cliente		 char(10);

--Armar varibale que contiene el periodo(aaaa-mm)
IF  MONTH(TODAY) < 10 THEN
	LET _mes_char = '0'||MONTH(TODAY);
ELSE
	LET _mes_char = MONTH(TODAY);
END IF

LET _ano_char = YEAR(TODAY);
LET _periodo  = _ano_char || "-" || _mes_char;

LET v_por_vencer = 0;
LET v_exigible   = 0;
LET v_corriente  = 0; 
LET v_monto_30   = 0;  
LET v_monto_60   = 0;  
LET v_monto_90   = 0;
LET v_saldo	     = 0;
LET _cod_pagador = null;
LET _code_agente = null;
LET v_dia1       = null;
LET _fecha_dt    = null;
LET v_apagar     = null;
LET v_motiv		 = null;
LET v_dia2		 = null;

SELECT tipo_cobrador
  INTO _tipo_cobrador
  FROM cobcobra
 WHERE cod_cobrador  = a_cobrador_vjo;

if a_parametro = 1 then	--rutero
	FOREACH
	 -- Lectura de Cobruter1
		SELECT dia_cobros1,
			   fecha,
			   cod_pagador
		  INTO v_dia1,
			   _fecha_dt,
			   _cod_pagador
		  FROM cobruter1
		 WHERE cod_cobrador  = a_cobrador_vjo
		  order by 1,2

		 update cobruhis
			set cod_cobrador = a_cobrador_nvo
		  WHERE cod_cobrador = a_cobrador_vjo
		    AND dia_cobros1  = v_dia1
		    AND fecha        = _fecha_dt;

	END FOREACH;

	 update cobruter1
		set cod_cobrador = a_cobrador_nvo
	  WHERE cod_cobrador = a_cobrador_vjo;

	 update cobruter2
		set cod_cobrador = a_cobrador_nvo
	  WHERE cod_cobrador = a_cobrador_vjo;

	 update gencorr
		set cod_cobrador = a_cobrador_nvo
	  WHERE cod_cobrador = a_cobrador_vjo;

	 {update cobavica
		set cod_cobrador = a_cobrador_nvo
	  WHERE cod_cobrador = a_cobrador_vjo;}

elif a_parametro = 2 then	--gestores
	foreach
	 select cod_cliente
	   into _cod_cliente
	   from cascliente
	  where cod_cobrador = a_cobrador_vjo

		update cascliente
		   set cod_cobrador = a_cobrador_nvo
	     where cod_cliente  = _cod_cliente;

		update cobcapen
		   set cod_cobrador = a_cobrador_nvo
	     where cod_cliente  = _cod_cliente;

	end foreach
	update cascliente
	   set cod_cobrador_ant = a_cobrador_nvo
	 where cod_cobrador_ant = a_cobrador_vjo;
end if

 update cobcobra
	set activo = 1
  WHERE cod_cobrador = a_cobrador_nvo;

 update cobcobra
	set activo = a_arg
  WHERE cod_cobrador = a_cobrador_vjo;

{ update cobcobra
	set activo 		  = 1,
	    tipo_cobrador = _tipo_cobrador
  WHERE cod_cobrador  = a_cobrador_nvo;

 if _tipo_cobrador = 12 then	--rol 90 dias y mas.
	update cobca90p
	   set cod_cobrador = a_cobrador_nvo
	 where cod_cobrador = a_cobrador_vjo;
 end if}	

return 0;

END PROCEDURE