--*****************************************************************************
-- Procedimiento que genera detalle de polizas para un corredor, bono especial
--***********************************************************************
-- Creado    : 10/09/2024 - Autor: Armando Moreno M.

DROP PROCEDURE sp_roman16;
CREATE PROCEDURE sp_roman16(a_cod_agente char(5))
RETURNING 
char(5)    as cod_agente,
char(5)    as cod_grupo,
char(50)   as n_grupo,
char(20)   as poliza,
char(10)   as cod_cliente,
char(50)   as n_cliente,
date       as vigencia_inicial,
date       as vigencia_final,
char(15)   as estatus_poliza,
char(10)   as no_remesa,
integer    as renglon,
date       as fecha_cobro,
char(35)   as tipo_mov,
DEC(16,2)  as monto_cobrado,
DEC(16,2)  as impuesto,
DEC(16,2)  as prima_neta;

DEFINE _no_poliza,_cod_contratante  CHAR(10);
DEFINE _fecha           DATE;     
DEFINE _prima_neta,_monto,_impuesto DEC(16,2);
DEFINE _n_cliente,_n_grupo          CHAR(50); 
DEFINE _no_documento    CHAR(20); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _tipo_mov        char(1);
define _n_mov           char(35);
define _cod_grupo       char(5);
define _estatus_licencia char(1);
define _renglon,_estatus_poliza         integer;
define _vigencia_inic,_vigencia_final	date;
define _estatus                         char(15);

--SET DEBUG FILE TO "sp_roman16.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _prima_neta = 0;
let _monto      = 0;
let _impuesto   = 0;

foreach
	select no_documento,
	       cod_grupo,
		   no_poliza,
		   vigencia_inic,
		   vigencia_fin
	  into _no_documento,
	       _cod_grupo,
		   _no_poliza,
		   _vigencia_inic,
		   _vigencia_final
	  from emipoliza
	 where cod_agente = a_cod_agente
	 
	select nombre
      into _n_grupo
      from cligrupo
     where cod_grupo = _cod_grupo;

	select estatus_poliza,
		   cod_contratante
	  into _estatus_poliza,
		   _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	if _estatus_poliza = 1 then
		let _estatus = 'VIGENTE';
	elif _estatus_poliza = 2 then
		let _estatus = 'CANCELADA';
	elif _estatus_poliza = 3 then
		let _estatus = 'VENCIDA';
	else
		let _estatus = 'ANULADA';
	end if
	 
	select nombre
      into _n_cliente
      from cliclien
     where cod_cliente = _cod_contratante;	  
	 
	foreach
		SELECT no_remesa,
			   tipo_mov,
			   renglon,
			   fecha,
			   monto,
			   impuesto,
			   prima_neta
		  INTO _no_remesa,
			   _tipo_mov,
			   _renglon,
			   _fecha,
			   _monto,
			   _impuesto,
			   _prima_neta
		  FROM cobredet
		 WHERE no_poliza = _no_poliza
		 order by no_remesa, renglon
		 
		if _tipo_mov = 'P' then
			let _n_mov = 'PAGO DE PRIMA';
		elif _tipo_mov = 'N' then
			let _n_mov = 'NOTA DE CREDITO';
		elif _tipo_mov = 'C' then
			let _n_mov = 'COMISION DESCONTADA';
		elif _tipo_mov = 'D' then
			let _n_mov = 'PAGO DE DEDUCIBLE';
		elif _tipo_mov = 'S' then
			let _n_mov = 'PAGO DE SALVAMENTO';
		elif _tipo_mov = 'R' then
			let _n_mov = 'PAGO DE RECUPERO';
		elif _tipo_mov = 'E' then
			let _n_mov = 'CREAR PAGO EN SUSPENSO';
		elif _tipo_mov = 'A' then
			let _n_mov = 'APLICAR PAGO EN SUSPENSO';
		elif _tipo_mov = 'B' then
			let _n_mov = 'RECIBO ANULADO';
		elif _tipo_mov = 'T' then
			let _n_mov = 'APLICAR RECLAMO';
		elif _tipo_mov = 'O' then
			let _n_mov = 'DEUDA AGENTE';
		elif _tipo_mov = 'M' then
			let _n_mov = 'AFECTACION CATALOGO';
		elif _tipo_mov = 'X' then
			let _n_mov = 'ELIM. DE CENTAVO';
		elif _tipo_mov = 'L' then
			let _n_mov = 'PAGO COBR. EXTERNA';
		else
			let _n_mov = 'DEVOL. POR CANCELACION DE POLIZA';
		end if

		return a_cod_agente,_cod_grupo,_n_grupo,_no_documento,_cod_contratante,_n_cliente,_vigencia_inic,_vigencia_final,_estatus,_no_remesa,_renglon,_fecha,
		       _n_mov,_monto,_impuesto,_prima_neta with resume;

	end foreach
end foreach	
END PROCEDURE;