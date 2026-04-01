-- Consulta de Movimientos de Auxiliar Sac x Remesa
-- Creado    : 11/08/2010 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac152('121020402','COB12091','18/12/2009')

DROP PROCEDURE sp_sac191;
CREATE PROCEDURE sp_sac191(a_cuenta char(12), a_comp CHAR(15), a_fecha DATE, a_auxiliar CHAR(5))
RETURNING	char(12),		-- cuenta 
			char(15), 		-- comprobante 
			DATE,			-- fecha
			CHAR(10),		-- remesa
			DEC(15,2),		-- debito
			DEC(15,2),		-- credito
			DEC(15,2);		-- neto

DEFINE i_cuenta			char(12);
DEFINE i_origen			char(12);
DEFINE i_comprobante	CHAR(15);
DEFINE i_fechatrx		DATE;
DEFINE i_notrx			INTEGER;
DEFINE i_debito			DEC(15,2);
DEFINE i_credito		DEC(15,2);
DEFINE i_neto           DEC(15,2);

DEFINE d_remesa			CHAR(10);
DEFINE d_debito			DEC(15,2);
DEFINE d_credito		DEC(15,2);

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmp_asiento(
		cuenta			char(12),
		comprobante		CHAR(15),
		fechatrx		DATE,
		notrx			INTEGER,
		debito			DEC(15,2)   default 0,
		credito			DEC(15,2)   default 0,
		neto            DEC(15,2)   default 0,
		origen			CHAR(3),
		remesa          CHAR(10)
		) WITH NO LOG; 	

--  set debug file to "sp_sac191.trc";
--  trace on;

FOREACH
  	select Distinct e.res_notrx,
	       e.res_origen,
	       e.res_debito,
	       e.res_credito
	  into i_notrx,
	       i_origen,
	       i_debito,
	       i_credito
	  from cglresumen e, cglresumen1 d
	 where e.res_cuenta      = d.res1_cuenta
       and e.res_noregistro  = d.res1_noregistro
       and e.res_cuenta      = a_cuenta
	   and e.res_origen      = 'COB'
	   and e.res_fechatrx    = a_fecha
	   and d.res1_auxiliar   = a_auxiliar
	   and e.res_comprobante = a_comp
	 order by e.res_notrx,e.res_origen

	if 	i_origen = 'COB' then

		FOREACH
			select x.no_remesa,
			       sum(x.debito),
			       sum(x.credito)
			  into d_remesa,
			       d_debito,
			       d_credito
			 from deivid:cobasien m, deivid:cobasiau x
			 where m.no_remesa = x.no_remesa
			  and m.renglon = x.renglon
			  and m.cuenta = x.cuenta
			   and x.cod_auxiliar = a_auxiliar
			   and m.sac_notrx = i_notrx
			   and m.cuenta    = a_cuenta
			 group by x.no_remesa
			 order by x.no_remesa


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
				notrx,
				debito,
				credito,
				neto,
				origen,
				remesa )
				VALUES (
				a_cuenta,
				"", --a_comp,
				a_fecha,
				i_notrx,
				d_debito,
				d_credito,
				i_neto,
				i_origen,
				d_remesa
				);
		END FOREACH;

	end if

   
END FOREACH;


FOREACH	
  SELECT remesa,
		 sum(debito),
		 sum(credito),
		 sum(neto)
	INTO d_remesa,
		 d_debito,
	     d_credito,
		 i_neto
    FROM tmp_asiento
   where cuenta      = a_cuenta
	 --and comprobante = a_comp
	 and fechatrx    = a_fecha
   group by remesa
   order by remesa

  RETURN   a_cuenta,
		   a_comp,
		   a_fecha,
		   d_remesa,
		   d_debito,
		   d_credito,
		   i_neto		   
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_asiento;
END PROCEDURE					 