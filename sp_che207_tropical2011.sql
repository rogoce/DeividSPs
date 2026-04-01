--*******************************************************************************************
-- Procedimiento que Actualiza las primas cobradas nuevas para mini convencion tropical 2011
--*******************************************************************************************

-- Creado    : 27/02/2008 - Autor: Armando Moreno M.
-- Modificado: 27/02/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_che207;

CREATE PROCEDURE sp_che207(a_compania CHAR(3))
RETURNING SMALLINT;

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
define _cod_subramo     char(3); 
define _cod_origen      char(3); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50);
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
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
define _fecha_hoy       date;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_prima_n        DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define _prima_45        DEC(16,2);
define _prima_90		DEC(16,2);
define _prima_r  		DEC(16,2);
define _prima_rr  		DEC(16,2);
define _formula_a  		DEC(16,2);
define _cnt             integer;
define v_monto_30bk		DEC(16,2);
define v_corr			DEC(16,2);
DEFINE _formula_b       DEC(16,2);
define _comision1       DEC(16,2);
define _comision2       DEC(16,2);
define _prima_bruta     DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);				   
define _cedula_paga		char(30);				   
define _cedula_cont		char(30);				   
define _cod_pagador     char(10);				   
define _cod_contratante char(10);				   
define _estatus_licencia char(1);				   
define v_nombre_clte     char(100);				   
define _cod_contr        char(10);
define _error           smallint;				   
define _monto_m			DEC(16,2);				   
define _monto_p			DEC(16,2);				   
define _suc_origen      char(3);				   
define _beneficios      smallint;				   
define _contado         smallint;				   
define _dias            integer;
define _fecha_decla     date;
define _mess            integer;
define _anno            integer;
define _f_ult           date;
define _f_decla_ult     date;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _concurso        smallint;
define _agente_agrupado char(5);
define _prima_cobrada   dec(16,2);
define _prima_cobrada2   dec(16,2);
define _retro            smallint;
define a_periodo_ini    char(7);
define _cod_agente1     char(5);
define _declarativa     smallint;
define _valor           smallint;
define _nueva_renov     char(1);
define _cantidad_pol    integer;
define _n_agente        char(50);
define _n_ramo          char(50);
define _categoria       smallint;
define _cod_agente2     char(5);
define _sw              smallint;

--SET DEBUG FILE TO "sp_che207a.trc";
--TRACE ON;

let _error   = 0;
let _porc_coas_ancon = 0;
let _forma_pag      = 0;
let _porc_comis     = 0;
let _porc_comis2    = 0;
let _prima_45       = 0;
let _prima_90       = 0;
let _cnt            = 0;
let _monto_m        = 0;
let _monto_p        = 0;
let _prima_bruta    = 0;
let _prima_cobrada  = 0;
let _prima_cobrada2 = 0;
let _retro          = 0;
let _declarativa    = 0;
let _valor          = 0;
let v_prima_n       = 0;
let _sw             = 0;


CREATE TEMP TABLE tmp_tropi(
	cod_agente		CHAR(15),
	no_documento    CHAR(20),
	prima           DEC(16,2),
	cantidad_pol    integer default 0,
	cod_ramo        char(3),
	categoria       smallint,
	PRIMARY KEY		(cod_agente, no_documento)
	) WITH NO LOG;

CREATE INDEX i_boni1 ON tmp_tropi(cod_agente);
CREATE INDEX i_boni2 ON tmp_tropi(no_documento);

SET ISOLATION TO DIRTY READ;

delete from tropical2;

select * 
  from tropical
  into temp prueba;

insert into tropical2
select * 
  from prueba;

drop table prueba;


FOREACH

	select cod_agente,
	       categoria
	  into _cod_agente,
	       _categoria
	  from tropical
	 order by categoria

	 foreach

		 select e.no_documento
		   into _no_documento
		   from emipomae e, emipoagt t
		  where e.no_poliza         = t.no_poliza
            and e.cod_compania      = a_compania
		    and e.actualizado       = 1
			and e.nueva_renov       = "N"
		    and e.fecha_suscripcion >= "15/03/2011"
			and e.fecha_suscripcion <= "15/07/2011"
			and e.cod_ramo          in("002","020","001","018","009","014")
            and t.cod_agente        = _cod_agente
		   group by e.no_documento
		   order by e.no_documento

		 let _cod_agente2 = _cod_agente;	
		 let _no_poliza = sp_sis21(_no_documento);

			select cod_grupo,
			       cod_ramo,
			       cod_pagador,
			       cod_contratante,
			       cod_subramo,
				   cod_tipoprod,
				   nueva_renov,
				   prima_neta
			  into _cod_grupo,
			       _cod_ramo,
			       _cod_pagador,
			       _cod_contratante,
			       _cod_subramo,
				   _cod_tipoprod,
				   _nueva_renov,
				   v_prima_n
			  from emipomae
			 where no_poliza = _no_poliza;

			if _nueva_renov = "N" then
			else
				continue foreach;
			end if

			if _cod_grupo = "00000" then --excluir estado
				continue foreach;
			end if  	

			if v_prima_n < 50 then --excluir primas menores de 50$
				continue foreach;
			end if

		   	select count(*)
			  into _cnt
			  from emipouni
			 where no_poliza = _no_poliza;

			-- Solicitud de Betzy Almanza, No evaluar esta poliza como flota
			-- Cambio realizado por Demetrio Hurtado el 30/jun/2011

			if _no_documento <> "0211-00299-06" then

				if _cnt > 1 then --no se consideran flotas
					continue foreach;
				end if

			end if

			select count(*)
			  into _cnt
			  from emifafac
			 where no_poliza = _no_poliza;

			if _cnt > 0 then		--excluir los facultativos
				continue foreach;
			end if

			if _cod_ramo = '009' and _cod_subramo in('001','002','006') then --Excluir Transporte terrestre
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

		   select count(*)
		     into _cnt
		     from endedmae
		    where no_poliza   = _no_poliza
			  and actualizado = 1
		      and cod_endomov in ('003','012','002')  --rehabilitacion o cambio de corredor en el periodo no va
		      and fecha_emision >= '15/03/2011'
		      and fecha_emision <= '15/07/2011';

			let _sw = 0;
			if _cnt > 0 then

				if _cod_agente = "00791" then
				   select count(*)
				     into _cnt
				     from endmoage
				    where no_poliza   = _no_poliza
					  and cod_agente  = "01648";

				   if _cnt > 0 then
						let _sw = 1;
				   end if

				end if
				if _sw = 0 then
					continue foreach;
				end if
			end if

			if _cod_agente = "00791" then	--unificar este agente con cobreagt Omayra 15/07/2011
				let _cod_agente2 = "01648";
			end if

			foreach

				 SELECT	d.no_remesa,
				        d.renglon,
				        d.no_recibo,
				        d.fecha,
				        d.monto,
				        d.prima_neta,
				        d.tipo_mov,
						m.cod_banco,
						m.cod_chequera,
						c.porc_partic_agt
				   INTO	_no_remesa,
					    _renglon,
					    _no_recibo,
					    _fecha,
					    _monto,
					    _prima,
					    _tipo_mov,
						_cod_banco,
						_cod_chequera,
						_porc_partic
				   FROM	cobredet d, cobremae m, cobreagt c
				  WHERE	d.no_remesa    = m.no_remesa
				    AND d.no_remesa    = c.no_remesa
				    AND d.renglon      = c.renglon
				    AND d.cod_compania = a_compania
					AND d.doc_remesa   = _no_documento
				    AND d.actualizado  = 1
					AND d.tipo_mov     IN ('P','N')
					AND d.fecha        >= "15/03/2011"
					AND d.fecha        <= "15/07/2011"
					AND m.tipo_remesa  IN ('A', 'M', 'C')
					AND c.cod_agente   IN (_cod_agente,_cod_agente2)
			      ORDER BY d.fecha,d.no_recibo,d.no_poliza

				 if _prima < 50 then --excluir recibos menores de 50$
					continue foreach;
				 end if
				 
			     let _monto_p = 0;
		         let _prima   = (_porc_coas_ancon * _prima) / 100;
			     let _monto_p = _prima * (_porc_partic / 100);

				BEGIN

					ON EXCEPTION IN(-239)

					   	UPDATE tmp_tropi
						   SET prima        = prima + _monto_p
						 WHERE cod_agente   = _cod_agente
						   AND no_documento = _no_documento;

					END EXCEPTION

					INSERT INTO tmp_tropi(cod_agente,no_documento,prima,cantidad_pol,cod_ramo,categoria)
				    VALUES(_cod_agente,_no_documento,_monto_p,1,_cod_ramo,_categoria);

				END

			end foreach

		END FOREACH

end foreach


foreach

	 select cod_agente,
	        no_documento,
			prima,
			cantidad_pol,
			cod_ramo,
			categoria
	   into _cod_agente,
	        _no_documento,
			_monto_p,
			_cantidad_pol,
			_cod_ramo,
			_categoria
	   from tmp_tropi
	  order by cod_agente

	 select nombre
	   into _n_agente
	   from agtagent
	  where cod_agente = _cod_agente;

	 select nombre
	   into _n_ramo
	   from prdramo
	  where cod_ramo = _cod_ramo;

		INSERT INTO tropical2(
		cod_agente,
		prima_cobrada2010,
		prima_cobrada_nva,
		cantidad_polizas,
		no_documento,
		n_agente,
		n_ramo,
		categoria 
		)
		VALUES(
		_cod_agente,
		0,
		_monto_p,
		_cantidad_pol,
		_no_documento,
		_n_agente,
		_n_ramo,
		_categoria
		);

end foreach


DROP TABLE tmp_tropi;

return 0;

END PROCEDURE;