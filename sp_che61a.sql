-- Hoja de Auditoria para Reclamos de Salud (Para Pago de Reclamos)

-- Creado    : 20/04/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - d_recl_sp_rec83_dw1 - DEIVID, S.A.

drop procedure sp_che61a;

create procedure sp_che61a(a_compania char(3),a_requis char(10))
RETURNING   SMALLINT;

define _numrecla		char(20);
define _no_documento	char(20);
define _fecha_siniestro	date;
define _cod_icd			char(10);
define _cod_cpt			char(10);
define _no_reclamo		char(10);
define _cod_reclamante	char(10);
define _cod_asegurado	char(10);
define _nombre_recla	char(100);
define _nombre_aseg		char(100);

define _gasto_fact		dec(16,2);
define _gasto_eleg		dec(16,2);
define _a_deducible		dec(16,2);
define _co_pago			dec(16,2);
define _coaseguro		dec(16,2);
define _pago_prov		dec(16,2);
define _nombre_prov		char(100);
define _gastos_no_cub	dec(16,2);

define _cod_proveedor	char(10);
define _nombre_cia 		char(50);
define _no_unidad		char(10);
define _cod_contratante	char(10);
define _nombre_cont		char(100);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_gasto		date;
define _periodo			char(7);
define _dependencia		char(50);
define _cod_parentesco  char(3);
define _transaccion		char(10);
define _no_tranrec		char(10);
define _nombre_icd		char(100);
define _nombre_cpt		char(100);
define _cod_no_cubierto	char(3);
define _fecha_factura	date;
define _fecha_desde		date;
define _fecha_hasta		date;
define v_fecha_desde	date;
define v_fecha_hasta	date;
define _cod_banco		char(3);
define _cod_chequera	char(3);
define _fecha_impresion date;
define _no_requis		char(10);
define _no_cheque       integer;
define _deducible   	dec(16,2);
--DEFINE _error_code      INTEGER;

--set debug file to "sp_rec83.trc";
--trace on;

set isolation to dirty read;

{BEGIN

ON EXCEPTION SET _error_code
 	RETURN _error_code, '', '';         
END EXCEPTION           }

let _nombre_cia = sp_sis01(a_compania); 
		
select cod_banco,
       cod_chequera
  into _cod_banco,
	   _cod_chequera
  from chqbanch
 where cod_ramo = '018';

foreach
 select	no_requis,
		fecha_impresion,
		no_cheque
   into	_no_requis,
		_fecha_impresion,
		_no_cheque
   from chqchmae
  where pagado          = 1
    and anulado         = 0
	and origen_cheque   = "3"
	and cod_banco	    = _cod_banco
	and cod_chequera    = _cod_chequera
	and en_firma        = 2
	and autorizado      = 1
	and no_requis       = a_requis

--	and fecha_impresion = today

	let _no_requis = trim(_no_requis);

--  insertar registros en chqchrec, de N/T de deducibles para que se vean en hoja de audito.

  {	foreach
		select numrecla
		  into _numrecla
		  from chqchrec
		 where no_requis = _no_requis
		 group by numrecla
		 order by numrecla
		 
	  foreach
		select c.a_deducible,
			   t.transaccion
		  into _deducible,
			   _transaccion
		  from recrcmae r, rectrmae t, rectrcob c
		 where r.numrecla      = _numrecla
		   and r.no_reclamo    = t.no_reclamo
		   and t.no_tranrec    = c.no_tranrec
		   and t.actualizado   = 1
		   and t.cod_tipotran  in ("004","013")
		   and t.no_requis is null
		   and t.monto         = 0
		   and t.anular_nt is null
		 order by t.fecha, t.transaccion

		 BEGIN
			ON EXCEPTION IN(-268)
				continue foreach;
			END EXCEPTION

			INSERT INTO chqchrec(
			no_requis,
			transaccion,
			monto,      
			numrecla
			)
			VALUES(
			a_requis,
			_transaccion,    
			0.00,
			_numrecla     
		    );
		 END
	  end foreach

	end foreach	}

end foreach

RETURN 0;

end procedure;
