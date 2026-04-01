-- Consulta de Movimientos de Auxiliar Sac x PRODUCCION
-- Creado    : 06/08/2010 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac158('121020402','COB12091','18/12/2009')

DROP PROCEDURE sp_sac189;
CREATE PROCEDURE sp_sac189(a_cuenta char(12), a_comp CHAR(15), a_fecha DATE, a_aux char(5)) 
RETURNING	char(12),		--  cuenta 
			char(15), 		--  comprobante 
			DATE,			--  fecha
			CHAR(10),		-- 	factura
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
DEFINE d_factura		CHAR(10);
DEFINE d_poliza			CHAR(10);
DEFINE d_endoso			CHAR(5);
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
		factura         CHAR(10)
		) WITH NO LOG; 	

--  set debug file to "sp_sac158.trc";	
--  trace on;

if 	a_comp[1,3] = 'PRO' then

	FOREACH
	  select res_notrx
		into i_notrx
		from cglresumen
		where res_cuenta = a_cuenta
		  and res_comprobante = a_comp
		  and res_fechatrx = a_fecha
		order by res_notrx

				FOREACH
					select a.no_poliza,  
					       a.no_endoso, 
						   sum(a.debito),
						   sum(a.credito)
					  into d_poliza,
					       d_endoso,
					       d_debito,
					       d_credito
					  from deivid:endasiau a, deivid:endasien b
					 where a.cuenta       = b.cuenta
			           and a.no_poliza    = b.no_poliza
			           and a.no_endoso    = b.no_endoso
			--         and a.tipo_comp    = b.tipo_comp
			           and a.cuenta       = a_cuenta   --'231010304'
					   and a.cod_auxiliar = a_aux      --'RE007'
					   and b.sac_notrx    = i_notrx    --'7373'
					 group by a.no_poliza,a.no_endoso
					 order by a.no_poliza,a.no_endoso

						if d_debito is null then
							let d_debito = 0; 
						end if
						if d_credito is null then
							let d_credito = 0; 
						end if

						let i_neto = d_debito - d_credito ;

						select no_factura 
						into d_factura
						from deivid:endedmae  
						where no_poliza = d_poliza
						and no_endoso = d_endoso ;

						INSERT INTO tmp_asiento (
						cuenta,
						comprobante,
						fechatrx,
						debito,
						credito,
						neto,
						factura )
						VALUES (
						a_cuenta,
						a_comp,
						a_fecha,
						d_debito,
						d_credito,
						i_neto,
						d_factura
						);
				END FOREACH;
			   
	END FOREACH;

end if

FOREACH	
  SELECT factura,
		 sum(debito),
		 sum(credito),
		 sum(neto)
	INTO d_factura,
		 d_debito,
	     d_credito,
		 i_neto
    FROM tmp_asiento
	where cuenta      = a_cuenta
	  and comprobante = a_comp
	  and fechatrx    = a_fecha
	group by factura
	order by factura

  RETURN a_cuenta,
		   a_comp,
		   a_fecha,
		   d_factura,
		   d_debito,
		   d_credito,
		   i_neto		   
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_asiento;
END PROCEDURE					 