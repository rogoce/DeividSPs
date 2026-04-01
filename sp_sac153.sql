-- Consulta de Movimientos de Cuentas Sac x Remesa
-- Creado    : 29/12/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac153( '121020402','COB12091','18/12/2009','348552')
DROP PROCEDURE sp_sac153;
CREATE PROCEDURE sp_sac153(a_cuenta char(12), a_comp CHAR(15), a_fecha DATE, a_remesa CHAR(10)) 
RETURNING	char(12),		--cuenta 
			char(15), 		--comprobante 
			DATE,			--fecha
			CHAR(10),		-- remesa
			smallint,		-- renglon
			DEC(15,2),		-- debito
			DEC(15,2),		-- credito
			DEC(15,2),		-- neto
			CHAR(10),		-- Recibo
			CHAR(1),		-- Tipo Movimiento
			CHAR(30),		-- Documento
			DEC(16,2), 	 	-- Monto Banco
			DEC(16,2),  	-- Prima
			DEC(16,2),  	-- Impuesto
			CHAR(100);		-- desc_remesa

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
DEFINE d_renglon		smallint;
DEFINE v_no_recibo      CHAR(10);
DEFINE v_tipo_mov		CHAR(1);
DEFINE v_doc_remesa		CHAR(30);
DEFINE v_monto_banco	DEC(16,2);
DEFINE v_prima			DEC(16,2);
DEFINE v_impuesto		DEC(16,2);
DEFINE v_desc_remesa	CHAR(100);


SET ISOLATION TO DIRTY READ;

{1:
select res_comprobante,res_fechatrx,res_tipcomp,res_descripcion,sum(res_debito),sum(res_credito)
from cglresumen
where res_cuenta = '121020402'
--and res_comprobante = 'COB01101'
and res_fechatrx >= '01/12/2009' and res_fechatrx <= '30/12/2009'
group by res_comprobante,res_fechatrx,res_tipcomp,res_descripcion
order by res_comprobante,res_fechatrx,res_tipcomp,res_descripcion
}
{2:
select res_comprobante,res_fechatrx,res_notrx,res_noregistro,res_origen,res_debito,res_credito
from cglresumen
where res_cuenta = '121020402'
and res_comprobante = 'COB01101'
and res_fechatrx = '18/12/2009'
order by res_comprobante,res_fechatrx,res_notrx,res_noregistro,res_origen
}
{3:
select no_remesa,sum(debito),sum(credito)  ,sum(debito) - sum(credito)
from deivid:cobasien
where sac_notrx = '52882'
and cuenta = '121020402'
group by no_remesa
}
{4:
select no_remesa,renglon,debito,credito,debito - credito
from deivid:cobasien
where sac_notrx = '52882'
and cuenta = '121020402'
}

CREATE TEMP TABLE tmp_remesa(
		cuenta			char(12),
		comprobante		CHAR(15),
		fechatrx		DATE,
		notrx			INTEGER,
		debito			DEC(15,2)   default 0,
		credito			DEC(15,2)   default 0,
		neto            DEC(15,2)   default 0,
		origen			CHAR(3),
		remesa          CHAR(10),
		renglon			smallint
		) WITH NO LOG; 	

--  set debug file to "sp_sac152.trc";	
--  trace on;

FOREACH
	select res_notrx,res_origen,res_debito,res_credito
	into i_notrx,i_origen,i_debito,i_credito
	from cglresumen
	where res_cuenta = a_cuenta
	and res_comprobante = a_comp
	and res_fechatrx = a_fecha
	order by res_comprobante,res_fechatrx,res_notrx,res_noregistro,res_origen

	if 	i_origen = 'COB' then

		FOREACH
			select no_remesa,renglon,debito,credito 
			into  d_remesa,d_renglon,d_debito,d_credito
			from deivid:cobasien
			where sac_notrx = i_notrx
			and cuenta = a_cuenta
			and no_remesa = a_remesa
			order by no_remesa,renglon

				if d_debito is null then
					let d_debito = 0; 
				end if
				if d_credito is null then
					let d_credito = 0; 
				end if

				let i_neto = d_debito - d_credito ;

				INSERT INTO tmp_remesa (
				cuenta,
				comprobante,
				fechatrx,
				notrx,
				debito,
				credito,
				neto,
				origen,
				remesa,
				renglon )
				VALUES (
				a_cuenta,
				a_comp,
				a_fecha,
				i_notrx,
				d_debito,
				d_credito,
				i_neto,
				i_origen,
				d_remesa,
				d_renglon
				);
		END FOREACH;

	end if

   
END FOREACH;


FOREACH	
  SELECT remesa,
		 renglon,
		sum(debito),
		sum(credito),
		sum(neto)
	INTO   d_remesa,
		   d_renglon,
		   d_debito,
	       d_credito,
		   i_neto
    FROM tmp_remesa
	where cuenta = 	a_cuenta
	and   comprobante = a_comp
	and   fechatrx  = a_fecha
	and   remesa = a_remesa
	group by remesa,renglon
	order by remesa,renglon

	 SELECT no_recibo,
			tipo_mov,
			doc_remesa,
			monto,
			prima_neta,
			impuesto,
			desc_remesa
	   INTO	v_no_recibo,
			v_tipo_mov,
			v_doc_remesa,
			v_monto_banco,
			v_prima,
			v_impuesto,
			v_desc_remesa 		
	   FROM deivid:cobredet
	  WHERE no_remesa = d_remesa
		AND renglon   = d_renglon ;

  RETURN a_cuenta,
		   a_comp,
		   a_fecha,
		   d_remesa,
		   d_renglon,
		   d_debito,
		   d_credito,
		   i_neto,
			v_no_recibo,
			v_tipo_mov,
			v_doc_remesa,
			v_monto_banco,
			v_prima,
			v_impuesto,
			v_desc_remesa		   		   
    	 WITH RESUME;

END FOREACH;

DROP TABLE tmp_remesa;
END PROCEDURE	