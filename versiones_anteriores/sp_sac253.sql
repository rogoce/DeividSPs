-- Consulta de Movimientos de Cuentas Sac x Auxiliar
-- Creado    : 12/12/2019 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac253('23102020804','REA03102','09/03/2010','72879','RE050')

DROP PROCEDURE sp_sac253;
CREATE PROCEDURE sp_sac253(a_cuenta char(12),a_comp CHAR(15),a_fecha DATE)
returning	integer,
			varchar(100);	


DEFINE i_no_registro    char(10);
DEFINE i_notrx			INTEGER;
DEFINE i_auxiliar		CHAR(5);
DEFINE i_origen			CHAR(15);
DEFINE i_no_poliza		CHAR(10);
DEFINE i_no_endoso		CHAR(5);
DEFINE i_no_remesa		CHAR(10);
DEFINE i_renglon		smallint;
DEFINE i_no_tranrec		CHAR(10);
DEFINE _mostrar         CHAR(10);
DEFINE _tipo            CHAR(15);

DEFINE i_cuenta			char(12);
DEFINE i_comprobante	CHAR(15);
DEFINE i_fechatrx		DATE;
DEFINE i_no_documento	CHAR(20);
DEFINE i_debito			DEC(15,2);
DEFINE i_credito		DEC(15,2);
DEFINE _transaccion        CHAR(10);
DEFINE _numrecla           CHAR(18);
DEFINE _monto_reclamo      DEC(15,2);
DEFINE _fecha_reclamo	   DATE;			
DEFINE _debito             DEC(15,2);
DEFINE _credito            DEC(15,2);
DEFINE i_total             DEC(15,2);
DEFINE _monto_pagado       DEC(15,2);
DEFINE _cod_contrato       CHAR(5);
DEFINE _desc_contrato      CHAR(50);
DEFINE _porc_partic_suma   DEC(15,2);
DEFINE _cod_ramo           CHAR(3);
DEFINE _desc_ramo          CHAR(50);
define _periodo_trx        char(7);


SET ISOLATION TO DIRTY READ;
Drop Table If Exists tmp_reasiento;
CREATE TEMP TABLE tmp_reasiento(
		cuenta			char(12),
		comprobante		char(15),
		fechatrx		date,
		no_registro		CHAR(10),
		debito			DEC(15,2)   default 0,
		credito			DEC(15,2)   default 0,
		origen          char(15),
		no_documento	char(20),
		no_poliza       char(10),
		no_endoso       char(5),
		no_remesa		char(10),
		renglon			smallint,
		no_tranrec		char(10),
		notrx           integer,
		mostrar			char(10),
		tipo            char(15)				
		) WITH NO LOG; 	

--  set debug file to "sp_sac179.trc";	
--  trace on;

let i_comprobante = a_comp;
let i_auxiliar = "";
let _numrecla = '';
let i_total = 0;

FOREACH	
	select b.cuenta,
	       b.fecha,
	       b.no_registro,
		   b.debito,
		   b.credito,
		   decode(c.tipo_registro,"1","PRODUCCION","2","COBROS","3","RECLAMOS", "4", "CHEQUES", "5", "ANULADOS"),
		   c.no_documento,
		   c.no_poliza,
		   c.no_endoso,
		   c.no_remesa,
		   c.renglon,
		   c.no_tranrec,
		   b.sac_notrx
	  into i_cuenta,
		   i_fechatrx,
		   i_no_registro,
		   i_debito,
		   i_credito,
		   i_origen,
		   i_no_documento,
		   i_no_poliza,
		   i_no_endoso,
		   i_no_remesa,
		   i_renglon,
		   i_no_tranrec,
		   i_notrx
	  from sac999:reacompasie b, sac999:reacomp c
	 where b.no_registro = c.no_registro
	   and b.cuenta = a_cuenta           -- '23102020804'
	   and b.fecha  = a_fecha            --'09/03/2010'

		LET _mostrar = "";

		if trim(i_origen) = "PRODUCCION" then

			LET _tipo = 'No. Factura';

			 SELECT no_factura
			   INTO _mostrar
			   FROM endedmae
			  WHERE no_poliza = i_no_poliza
			    AND	no_endoso = i_no_endoso
			    AND actualizado = 1;	 

		elif trim(i_origen) = "COBROS" then

			LET _tipo    = 'No. Remesa';
			LET _mostrar = i_no_remesa;

	    elif trim(i_origen) = "RECLAMOS" then

			LET _tipo = 'No. transaccion';

			 SELECT transaccion,numrecla,monto, fecha
			   INTO _mostrar,_numrecla, _monto_reclamo, _fecha_reclamo
			   FROM rectrmae
			  WHERE no_tranrec  = i_no_tranrec
			    AND actualizado = 1;		
				
				let _transaccion = _mostrar;
  
			 SELECT cod_ramo
			   INTO _cod_ramo
			   FROM emipoliza 
			  WHERE no_documento = i_no_documento;						
			  
			select nombre
			  into _desc_ramo
			  from prdramo
			 where cod_ramo = _cod_ramo;							 			 		 
			 
			 let i_total = i_debito - i_credito;
			  call sp_sis39(a_fecha) returning _periodo_trx;
			 
			foreach 
			select a.cod_contrato, b.nombre, a.porc_partic_suma
			  into _cod_contrato, _desc_contrato, _porc_partic_suma
			  from rectrrea a, reacomae b
			 where a.no_tranrec = i_no_tranrec
			   and a.cod_contrato = b.cod_contrato
			   and a.tipo_contrato = b.tipo_contrato
			 order by a.orden			 
			 
					INSERT INTO tmp_zule (
							cuenta,
							comprobante,
							fechatrx,
							poliza,
							transaccion,
							numrecla,
							monto_reclamo,
							fecha_reclamo,
							debito,
							credito,
							monto_pagado,
							cod_contrato,
							desc_contrato,							
							porc_partic_suma,
							cod_ramo,
							desc_ramo,
                            periodo							
							 )
							VALUES (
							i_cuenta,
							i_comprobante,		
							i_fechatrx,
							i_no_documento,
							_transaccion,
							_numrecla,
							_monto_reclamo,
							_fecha_reclamo,							
							i_debito,
							i_credito,
							i_total,
							_cod_contrato,
							_desc_contrato,
							_porc_partic_suma,
							_cod_ramo,
							_desc_ramo,
							_periodo_trx
							);			 			 			 
			 end foreach
			 

	    elif trim(i_origen) = "CHEQUES" then

			LET _tipo = 'No. Requisicion';
			LET _mostrar = i_no_remesa;

	    elif trim(i_origen) = "ANULADOS" then

			LET _tipo = 'No. Requisicion';
			LET _mostrar = i_no_remesa;

		end if

		INSERT INTO tmp_reasiento (
		cuenta,
		comprobante,
		fechatrx,
		no_registro,
		debito,
		credito,
		origen,
		no_documento,
		no_poliza,
		no_endoso,
		no_remesa,
		renglon,
		no_tranrec,
		notrx,
		mostrar,
		tipo
		 )
		VALUES (
		i_cuenta,
		i_comprobante,		
		i_fechatrx,
		i_no_registro,
		i_debito,
		i_credito,
		i_origen,
		i_no_documento,
		i_no_poliza,
		i_no_endoso,
		i_no_remesa,
		i_renglon,
		i_no_tranrec,
		i_notrx,
		_mostrar,
		_tipo
		);
   
END FOREACH;

return 0, 'Carga Exitosa';

--DROP TABLE tmp_reasiento;
END PROCEDURE					 