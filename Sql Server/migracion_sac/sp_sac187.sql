-- Consulta de Movimientos de Auxiliar Sac x CHEQUES
-- Creado    : 06/08/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	

DROP PROCEDURE sp_sac187;
CREATE PROCEDURE sp_sac187(a_cuenta char(12), a_comp CHAR(15), a_fecha DATE, a_aux char(5)) 
RETURNING	char(12),		--cuenta 
			char(15), 		--comprobante 
			DATE,			--fecha
			CHAR(10),		-- 	requisicion
			DEC(15,2),		-- 	debito
			DEC(15,2),		-- 	credito
			DEC(15,2);		-- 	neto

DEFINE i_cuenta			char(12);
DEFINE i_origen			char(12);
DEFINE i_comprobante	CHAR(15);
DEFINE i_fechatrx		DATE;
DEFINE i_notrx			INTEGER;
DEFINE i_debito			DEC(15,2);
DEFINE i_credito		DEC(15,2);
DEFINE i_neto           DEC(15,2);

DEFINE d_remesa, d_requis			CHAR(10);
DEFINE d_debito			DEC(15,2);
DEFINE d_credito		DEC(15,2);

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_asiento(
		cuenta			char(12),
		comprobante		CHAR(15),
		fechatrx		DATE,
		debito			DEC(15,2)   default 0,
		credito			DEC(15,2)   default 0,
		neto            DEC(15,2)   default 0,
		requis          CHAR(10)
		) WITH NO LOG; 	

--  set debug file to "sp_sac187.trc";	
--  trace on;


	if a_comp[1,3] = 'CHE' then

		FOREACH
		  select res_notrx
			into i_notrx
			from cglresumen
			where res_cuenta = a_cuenta
			  and res_comprobante = a_comp
			  and res_fechatrx = a_fecha
			order by res_notrx


			FOREACH
				select a.no_requis,
				       sum(a.debito),
				       sum(a.credito)
				  into d_requis,
				       d_debito,
				       d_credito
				  from deivid:chqctaux  a, deivid:chqchcta b
				 where a.cuenta       = b.cuenta
	               and a.no_requis    = b.no_requis
	               and a.renglon      = b.renglon
	               and a.cuenta       = a_cuenta
				   and a.cod_auxiliar = a_aux
	               and b.sac_notrx    = i_notrx
				 group by a.no_requis
				 order by a.no_requis

				if d_debito is null then
					let d_debito = 0; 
				end if
				if d_credito is null then
					let d_credito = 0; 
				end if

				let i_neto = d_debito - d_credito ;

				INSERT INTO tmp_asiento (
				cuenta,
				comprobante,
				fechatrx,
				debito,
				credito,
				neto,
				requis )
				VALUES (
				a_cuenta,
				a_comp,
				a_fecha,
				d_debito,
				d_credito,
				i_neto,
				d_requis
				);

			END FOREACH;
		END FOREACH;

	end if

FOREACH	
  SELECT requis,
		 sum(debito),
		 sum(credito),
		 sum(neto)
	INTO d_requis,
		 d_debito,
	     d_credito,
		 i_neto
    FROM tmp_asiento
	where cuenta      = a_cuenta
	and   comprobante = a_comp
	and   fechatrx    = a_fecha
	group by requis
	order by requis

  RETURN a_cuenta,
		 a_comp,
		 a_fecha,
		 d_requis,
		 d_debito,
		 d_credito,
		 i_neto		   
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_asiento;
END PROCEDURE					 