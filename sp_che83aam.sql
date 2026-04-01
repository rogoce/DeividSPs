-- Reporte de las bonificaciones de cobranza por Corredor - Detallado

-- Creado    : 11/03/2008 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 11/03/2008 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

DROP PROCEDURE sp_che83aam;
CREATE PROCEDURE sp_che83aam(a_compania CHAR(3), a_cod_agente CHAR(255) default '*', a_periodo char(7),a_tipo_pago smallint, a_periodo2 char(7)) 
  RETURNING CHAR(3),
            CHAR(50),
			CHAR(10),
			CHAR(50),
			CHAR(10),
			CHAR(50),
			CHAR(3),
            CHAR(50),
			CHAR(3),
            CHAR(50),			
			CHAR(20),
			date,
			date,
			DEC(16,2),
			DEC(16,2),
			DEC(5,2),  			   
			DEC(16,2);

DEFINE v_cod_agente,_cod_agente2   CHAR(5);  
DEFINE v_no_poliza    CHAR(10); 
DEFINE v_monto,_prima_suscrita,_prima_cobrada        DEC(16,2);
DEFINE v_prima        DEC(16,2);
DEFINE v_porc_comis   DEC(5,2); 
DEFINE v_comision     DEC(16,2);
DEFINE v_nombre_clte  CHAR(100);
DEFINE v_no_documento CHAR(20);
DEFINE v_nombre_agt,_n_ramo,_n_subramo,_n_vendedor   CHAR(50);
define _porc_comis	  DEC(5,2);
define _cod_ramo,_cod_subramo,_cod_vendedor,_tipo,_tipo2 char(3);
define _vigencia_inic, _vigencia_final date;



--SET DEBUG FILE TO "\\sp_che83.trc";
--TRACE ON;

-- Nombre de la Compania
SET ISOLATION TO DIRTY READ;

--cobranza = chqboni
--1% web = chqweb
--rentabilidad = rentabilidad1
--ramos generales = 

let	_porc_comis  = 0;

if a_tipo_pago = 0 then	--1% Web
	FOREACH
		SELECT cod_agente,
		       no_poliza,
		       monto,
		       prima,
		       comision,
		       nombre,
		       no_documento,
		       cod_ramo,
		       cod_subramo,
		       porc_4690
		  INTO v_cod_agente,
		       v_no_poliza,
			   v_monto,
			   v_prima,
			   v_comision,
			   v_nombre_agt,
			   v_no_documento,
			   _cod_ramo,
			   _cod_subramo,
			   _porc_comis
		  FROM	chqweb
		 WHERE cod_agente matches a_cod_agente
		   and periodo  >= a_periodo
		   and periodo  <= a_periodo2

		SELECT vigencia_inic,
			   vigencia_final
		  INTO _vigencia_inic,
			   _vigencia_final
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

		SELECT cod_vendedor
		  INTO _cod_vendedor
		  FROM agtagent
		 WHERE cod_agente = v_cod_agente;
		 
		SELECT nombre
		  INTO _n_vendedor
		  FROM agtvende
		 WHERE cod_vendedor = _cod_vendedor;
		 
		SELECT nombre
		  INTO _n_ramo
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		SELECT nombre
		  INTO _n_subramo
		  FROM prdsubra
		 WHERE cod_ramo = _cod_ramo
		   AND cod_subramo = _cod_subramo;
		 
		RETURN _cod_vendedor,_n_vendedor,v_cod_agente,v_nombre_agt,v_cod_agente,v_nombre_agt,_cod_ramo,_n_ramo,_cod_subramo,_n_subramo,v_no_documento,_vigencia_inic,_vigencia_final,v_monto,v_prima,_porc_comis,v_comision
			   WITH RESUME;
		
	END FOREACH
elif a_tipo_pago = 1 then	--Rentabilidad
	let _cod_agente2 = "";
	let _tipo2 = "";
	FOREACH
		 SELECT	tipo,
		        cod_agente,
				bono,
				n_agente,
				no_documento,
				cod_ramo,
				nombre_ramo,
				beneficio,
				cod_vendedor,
				nombre_vendedor
		   INTO	_tipo,
		        v_cod_agente,
				v_comision,
				v_nombre_agt,
				v_no_documento,
				_cod_ramo,
				_n_ramo,
				_porc_comis,
				_cod_vendedor,
				_n_vendedor
		   FROM	rentabilidad1
		  WHERE cod_agente matches a_cod_agente
			and periodo  = '2023-12'
			and bono <> 0
			order by cod_agente,tipo
			
		if (v_cod_agente = _cod_agente2) and (_tipo = _tipo2) then
			let v_comision = 0;
		end if
			
		SELECT vigencia_inic,
			   vigencia_fin,
			   cod_subramo
		  INTO _vigencia_inic,
			   _vigencia_final,
			   _cod_subramo
		  FROM emipoliza
		 WHERE no_documento = v_no_documento;
		 
		SELECT nombre
		  INTO _n_subramo
		  FROM prdsubra
		 WHERE cod_ramo = _cod_ramo
		   AND cod_subramo = _cod_subramo;
               		
		RETURN _cod_vendedor,_n_vendedor,v_cod_agente,v_nombre_agt,v_cod_agente,v_nombre_agt,_cod_ramo,_n_ramo,_cod_subramo,_n_subramo,v_no_documento,_vigencia_inic,_vigencia_final,0,0,_porc_comis,v_comision
			   WITH RESUME;
		let _cod_agente2 = v_cod_agente;
		let _tipo2 = _tipo;
	END FOREACH
	
elif a_tipo_pago = 2 then 	--Ramos generales
	FOREACH
			SELECT cod_agente,
				   no_poliza,
				   prima_suscrita,
				   prima_cobrada,
				   comision,
				   nombre,
				   no_documento,
				   porcentaje
			  INTO v_cod_agente,
				   v_no_poliza,
				   v_monto,
				   v_prima,
				   v_comision,
				   v_nombre_agt,
				   v_no_documento,
				   _porc_comis
			  FROM	chqborege
			 WHERE cod_agente matches a_cod_agente
			   and periodo  = '2022-12'

			SELECT vigencia_inic,
				   vigencia_final,
				   cod_ramo,
				   cod_subramo
			  INTO _vigencia_inic,
				   _vigencia_final,
				   _cod_ramo,
				   _cod_subramo
			  FROM emipomae
			 WHERE no_poliza = v_no_poliza;

			SELECT cod_vendedor
			  INTO _cod_vendedor
			  FROM agtagent
			 WHERE cod_agente = v_cod_agente;
			 
			SELECT nombre
			  INTO _n_vendedor
			  FROM agtvende
			 WHERE cod_vendedor = _cod_vendedor;
			 
			SELECT nombre
			  INTO _n_ramo
			  FROM prdramo
			 WHERE cod_ramo = _cod_ramo;

			SELECT nombre
			  INTO _n_subramo
			  FROM prdsubra
			 WHERE cod_ramo = _cod_ramo
			   AND cod_subramo = _cod_subramo;
			 
			RETURN _cod_vendedor,_n_vendedor,v_cod_agente,v_nombre_agt,v_cod_agente,v_nombre_agt,_cod_ramo,_n_ramo,_cod_subramo,_n_subramo,v_no_documento,_vigencia_inic,_vigencia_final,v_monto,v_prima,_porc_comis,v_comision
				   WITH RESUME;
			
	END FOREACH
	{	foreach
			select sum(prima_cobrada),
				   sum(prima_suscrita),
				   no_documento,
				   cod_agente_uni
			  into _prima_cobrada,
				   _prima_suscrita,
				   v_no_documento,
				   v_cod_agente
			  from bono_prod_d
			 where cod_agente_uni matches a_cod_agente
			 group by cod_agente_uni, no_documento

			select nombre,
				   cod_vendedor
			  into v_nombre_agt,
				   _cod_vendedor
			  from agtagent
			 where cod_agente = v_cod_agente;
			 
			SELECT nombre
		      INTO _n_vendedor
		      FROM agtvende
		     WHERE cod_vendedor = _cod_vendedor;
			 
			SELECT vigencia_inic,
				   vigencia_fin,
				   cod_ramo,
				   cod_subramo
			  INTO _vigencia_inic,
				   _vigencia_final,
				   _cod_ramo,
				   _cod_subramo
			  FROM emipoliza
			 WHERE no_documento = v_no_documento;

			select nombre
			  into _n_ramo
			  from prdramo
			 where cod_ramo = _cod_ramo;

			SELECT nombre
			  INTO _n_subramo
			  FROM prdsubra
			 WHERE cod_ramo    = _cod_ramo
			   AND cod_subramo = _cod_subramo;		 

			RETURN _cod_vendedor,_n_vendedor,v_cod_agente,v_nombre_agt,v_cod_agente,v_nombre_agt,_cod_ramo,_n_ramo,_cod_subramo,_n_subramo,v_no_documento,_vigencia_inic,_vigencia_final,_prima_suscrita,_prima_cobrada,0,0
				   WITH RESUME;

		end foreach}

elif a_tipo_pago = 3 then	--Persistencia
	FOREACH
		select cod_agente,
		       n_corredor,
			   cod_vendedor,
			   n_vendedor,
			   monto_bono
          into v_cod_agente,
		       v_nombre_agt,
			   _cod_vendedor,
			   _n_vendedor,
			   v_comision
		  from chqbopersis
		 where cod_agente matches a_cod_agente 
		 
		RETURN _cod_vendedor,_n_vendedor,v_cod_agente,v_nombre_agt,v_cod_agente,v_nombre_agt,'','','','','','','','','',0,v_comision WITH RESUME;
	end FOREACH
elif a_tipo_pago = 4 then	--cobranza
	FOREACH
		SELECT cod_agente,
		       no_poliza,
		       monto,
		       prima,
		       comision,
		       nombre,
		       no_documento,
		       cod_ramo,
		       cod_subramo,
		       porc_4690
		  INTO v_cod_agente,
		       v_no_poliza,
			   v_monto,
			   v_prima,
			   v_comision,
			   v_nombre_agt,
			   v_no_documento,
			   _cod_ramo,
			   _cod_subramo,
			   _porc_comis
		  FROM	chqboni
		 WHERE cod_agente matches a_cod_agente
		   and periodo  >= a_periodo
		   and periodo  <= a_periodo2

		SELECT vigencia_inic,
			   vigencia_final
		  INTO _vigencia_inic,
			   _vigencia_final
		  FROM emipomae
		 WHERE no_poliza = v_no_poliza;

		SELECT cod_vendedor
		  INTO _cod_vendedor
		  FROM agtagent
		 WHERE cod_agente = v_cod_agente;
		 
		SELECT nombre
		  INTO _n_vendedor
		  FROM agtvende
		 WHERE cod_vendedor = _cod_vendedor;
		 
		SELECT nombre
		  INTO _n_ramo
		  FROM prdramo
		 WHERE cod_ramo = _cod_ramo;

		SELECT nombre
		  INTO _n_subramo
		  FROM prdsubra
		 WHERE cod_ramo = _cod_ramo
		   AND cod_subramo = _cod_subramo;
		 
		RETURN _cod_vendedor,_n_vendedor,v_cod_agente,v_nombre_agt,v_cod_agente,v_nombre_agt,_cod_ramo,_n_ramo,_cod_subramo,_n_subramo,v_no_documento,_vigencia_inic,_vigencia_final,v_monto,v_prima,_porc_comis,v_comision
			   WITH RESUME;
		
	END FOREACH
else
	FOREACH
		SELECT sum(comision),
		       cod_agente,
			   nombre,
			   nombre_tipo_g
		  into v_comision,
               v_cod_agente,
			   v_nombre_agt,
			   _n_ramo
		  FROM chqrenta3
		 where cod_agente matches a_cod_agente 
	       and periodo = '2022-12'
	  GROUP BY cod_agente,nombre,nombre_tipo_g
	  ORDER BY cod_agente	
	
		select cod_vendedor
		  into _cod_vendedor
		  from agtagent
		 where cod_agente = v_cod_agente;
		 
		SELECT nombre
		  INTO _n_vendedor
		  FROM agtvende
		 WHERE cod_vendedor = _cod_vendedor;
		 
		RETURN _cod_vendedor,_n_vendedor,v_cod_agente,v_nombre_agt,v_cod_agente,v_nombre_agt,'','','','','','','','','',0,v_comision WITH RESUME;
	end FOREACH
end if
END PROCEDURE;