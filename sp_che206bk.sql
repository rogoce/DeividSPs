--***************************************************************--
-- Procedimiento que categoriza al corredor para la mini convencion tropical 2011
-- Ramos a participar: AUTO,SODA,INCENDIO, SALUD, TRANSPORTE Y CAR.
--***************************************************************--

-- Creado    : 24/03/2011 - Autor: Armando Moreno M.
-- Modificado: 24/03/2011 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che206bk;

CREATE PROCEDURE sp_che206bk()
RETURNING SMALLINT;

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
define _cod_origen      char(3); 
DEFINE _monto           DEC(16,2);
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _nombre          CHAR(50); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50); 
define _forma_pag		smallint;
define _fecha_desde     date;
define _fecha_hasta     date;
define v_corr			DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);
define _cedula_paga		char(30);
define _cedula_cont		char(30);
define _cod_pagador     char(10);
define _cod_contratante char(10);
define _estatus_licencia char(1);
DEFINE _periodo_ant     CHAR(7);
define _mes_ant			smallint;
define _ano_ant			smallint;
define _error           smallint;
define _prima_neta		DEC(16,2);
define _vigencia_inic   date;
define _vigencia_final  date;
define _fecha_cancelacion date;
define _renglon         smallint;
define _nueva_renov     char(1);
define _flag            smallint;
define _saldo           dec(16,2);
define _per_cero        char(7);
define _no_remesa       char(10);
define _no_recibo       char(10);
define _cnt             smallint;
define _prima_r         DEC(16,2);
define _monto_b         DEC(16,2);
define _prima_n         DEC(16,2);
define _cod_subramo     char(3);
define _concurso        smallint;
define _n_agente        char(50);


--SET DEBUG FILE TO "sp_che206.trc";
--TRACE ON;

let _error           = 0;
let _porc_coas_ancon = 0;
let _prima_neta      = 0;
let _cnt             = 0;
let _prima_r         = 0;
let _monto_b         = 0;
let _prima_n         = 0;

SET ISOLATION TO DIRTY READ;

FOREACH

	SELECT d.no_poliza,
		   d.no_remesa,
		   d.renglon,
		   d.no_recibo,
		   d.fecha,
		   d.monto,
		   d.prima_neta,
		   d.tipo_mov
	  INTO _no_poliza,
		   _no_remesa,
		   _renglon,
		   _no_recibo,
		   _fecha,
		   _monto,
		   _prima,
		   _tipo_mov
	  FROM cobredet d, cobremae m
	 WHERE d.cod_compania = "001"
	   AND d.actualizado  = 1
	   AND d.tipo_mov     IN ('P','N')
	   AND (month(d.fecha) >= 1
	   AND  month(d.fecha) <= 12)
	   AND year(d.fecha)  = 2010
	   AND d.no_remesa    = m.no_remesa
	   AND m.tipo_remesa  IN ('A', 'M', 'C')
	 ORDER BY d.fecha,d.no_recibo,d.no_poliza

	select cod_grupo,
	       cod_ramo,
	       cod_pagador,
	       cod_contratante,
	       cod_subramo,
		   cod_tipoprod
	  into _cod_grupo,
	       _cod_ramo,
	       _cod_pagador,
	       _cod_contratante,
	       _cod_subramo,
		   _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;

	if _cod_ramo in("002","001","018","009","014","020") then	--SOLO AUTO, INC, SALUD, TRANSPORTE SODA Y CAR
	else
		continue foreach;
	end if

	if _cod_grupo = "00000" then --excluir estado
		continue foreach;
	end if  	

   	select count(*)
	  into _cnt
	  from emipouni
	 where no_poliza = _no_poliza;

	if _cnt > 1 then --no se consideran flotas
		continue foreach;
	end if

	select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;

	if _cnt > 0 then		--excluir los facultativos
		continue foreach;
	end if

	if _cod_ramo = '009' and _cod_subramo in('001','002','006') then --Excluir Transporte terrestre	anual, terrestre por carga,terrestre maritimo y aereo
		continue foreach;
	end if

	select cedula
	  into _cedula_paga
	  from cliclien
	 where cod_cliente = _cod_pagador;

	select cedula
	  into _cedula_cont
	  from cliclien
	 where cod_cliente = _cod_contratante;

	SELECT tipo_produccion
	  INTO _tipo_prod
	  FROM emitipro
	 WHERE cod_tipoprod = _cod_tipoprod;

	IF _tipo_prod = 4 THEN	-- excluir Reaseguro Asumido
	   CONTINUE FOREACH;
	END IF

	IF _tipo_prod = 3 THEN	--excluir coas minoritario
	   CONTINUE FOREACH;
	END IF

   if _tipo_prod = 2 then  --coas mayoritario
		select porc_partic_coas
		  into _porc_coas_ancon
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = "036";    --ancon
   else
		let _porc_coas_ancon = 100;
   end if

   let _prima = (_porc_coas_ancon * _prima) / 100;

	FOREACH
	 SELECT	cod_agente,
			porc_partic_agt,
			porc_comis_agt
	   INTO	_cod_agente,
			_porc_partic,
			_porc_comis
	   FROM	cobreagt
	  WHERE	no_remesa = _no_remesa
	    AND renglon   = _renglon


		SELECT nombre,
		       no_licencia,
		       tipo_pago,
		       tipo_agente,
			   estatus_licencia,
			   cedula
		  INTO _nombre,
		       _no_licencia,
		       _tipo_pago,
		       _tipo_agente,
			   _estatus_licencia,
			   _cedula_agt
		  FROM agtagent
		 WHERE cod_agente = _cod_agente;

		if trim(_cedula_agt) = trim(_cedula_paga) then
			continue foreach;
		end if
		
		if trim(_cedula_agt) = trim(_cedula_cont) then
			continue foreach;
		end if

	   	IF _tipo_agente <> "A" then	--solo agentes
			continue foreach;
		END IF

		IF _estatus_licencia <> "A" then  --El corredor debe estar activo
			continue foreach;
		END IF

	  LET _prima_neta = 0;
	  LET _prima_neta = _prima * (_porc_partic / 100);

	  BEGIN

		ON EXCEPTION IN(-239,-268)

			UPDATE tropical3
			   SET prima_cobrada2010 = prima_cobrada2010 + _prima_neta
			 WHERE cod_agente        = _cod_agente;

		END EXCEPTION

		INSERT INTO tropical3(
		cod_agente,
		prima_cobrada2010
		)
		VALUES(
		_cod_agente,
		_prima_neta
		);

	  END
	END FOREACH
END FOREACH

foreach

	select sum(prima_cobrada2010),
		   cod_agente
	  into _prima_neta,
	       _cod_agente
	  from tropical3
	 group by cod_agente


	 select nombre
	   into _n_agente
	   from agtagent
	  where cod_agente = _cod_agente;


	if _prima_neta >= 100000 then
		UPDATE tropical3
		   SET categoria  = 1,
		       n_agente   = _n_agente
		 WHERE cod_agente = _cod_agente;
	else
		UPDATE tropical3
		   SET categoria  = 2,
   		       n_agente   = _n_agente
		 WHERE cod_agente = _cod_agente;
		
	end	if
	 
end foreach

return 0;

END PROCEDURE;