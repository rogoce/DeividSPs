-- Consulta de Movimientos de Cuentas Sac x Transaccion de reclamos
-- Creado    : 26/01/2010 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac154('121020402','REC12091','18/12/2009')

DROP PROCEDURE sp_sac154;
CREATE PROCEDURE sp_sac154(a_cuenta char(12), a_comp CHAR(15), a_fecha DATE) 
RETURNING	char(12),		--cuenta 
			char(15), 		--comprobante 
			DATE,			--fecha
			CHAR(10),		-- 	remesa
			DEC(15,2),		-- 	debito
			DEC(15,2),		-- 	credito
			DEC(15,2),		-- 	neto
   			DECIMAL(16,2),	--  monto
		   	DECIMAL(16,2),	--  variacion
		   	CHAR(50),		--  nombre
		   	CHAR(10);		--  no_factura 

DEFINE i_cuenta				char(12);
DEFINE i_origen				char(12);
DEFINE i_comprobante		CHAR(15);
DEFINE i_fechatrx			DATE;
DEFINE i_notrx				INTEGER;
DEFINE i_debito				DEC(15,2);
DEFINE i_credito			DEC(15,2);
DEFINE i_neto           	DEC(15,2);
DEFINE d_remesa, d_tranrec	CHAR(10);
DEFINE d_debito				DEC(15,2);
DEFINE d_credito			DEC(15,2);
DEFINE c_monto_tran         DECIMAL(16,2);
DEFINE c_variacion          DECIMAL(16,2);
DEFINE c_cod_tipotran       CHAR(3);
DEFINE c_tipo_transaccion   INT;
DEFINE c_nombre        		CHAR(50);	
DEFINE c_transaccion		CHAR(10);

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
		tranrec         CHAR(10)
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

	if 	i_origen = 'REC' then

		FOREACH
			select no_tranrec,sum(debito),sum(credito) 
			into  d_tranrec,d_debito,d_credito
			from deivid:recasien
			where sac_notrx = i_notrx
			and cuenta = a_cuenta
			group by no_tranrec
			order by no_tranrec

				if d_debito is null then
					let d_debito = 0; 
				end if
				if d_credito is null then
					let d_credito = 0; 
				end if

				let i_neto = d_debito - ABS(d_credito) ;

				INSERT INTO tmp_asiento (
				cuenta,
				comprobante,
				fechatrx,
				notrx,
				debito,
				credito,
				neto,
				origen,
				tranrec )
				VALUES (
				a_cuenta,
				a_comp,
				a_fecha,
				i_notrx,
				d_debito,
				d_credito,
				i_neto,
				i_origen,
				d_tranrec
				);

		END FOREACH;

	end if
   
END FOREACH;


FOREACH	
  SELECT tranrec,
		sum(debito),
		sum(credito),
		sum(neto)
	INTO   d_tranrec,
		   d_debito,
	       d_credito,
		   i_neto
    FROM tmp_asiento
	where cuenta = 	a_cuenta
	and   comprobante = a_comp
	and   fechatrx  = a_fecha
	group by tranrec
	order by tranrec

 SELECT monto,
		variacion,
		cod_tipotran,
		transaccion
   INTO c_monto_tran,
		c_variacion,
		c_cod_tipotran,
		c_transaccion
   FROM deivid:rectrmae
  WHERE no_tranrec = d_tranrec	  
    AND actualizado = 1	  ;


   SELECT tipo_transaccion,nombre
	 INTO c_tipo_transaccion,c_nombre
	 FROM deivid:rectitra
	WHERE cod_tipotran = c_cod_tipotran;

  RETURN a_cuenta,
		   a_comp,
		   a_fecha,
		   d_tranrec,
		   d_debito,
		   d_credito,
		   i_neto,
		   c_monto_tran,
		   c_variacion,
		   c_nombre,
		   c_transaccion		   
    	 WITH RESUME;

END FOREACH;


DROP TABLE tmp_asiento;
END PROCEDURE					 