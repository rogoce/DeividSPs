--***********************************************************************
-- Procedimiento que detalla por año para corredor ducruet y sus codigos nuevos.

--***********************************************************************
-- Creado    : 11/01/2024 - Autor: Armando Moreno M.

DROP PROCEDURE sp_roman02;
CREATE PROCEDURE sp_roman02()
RETURNING integer,char(5),char(100),char(20),char(100),DEC(16,2),DEC(16,2),DEC(5,2),DEC(16,2);

DEFINE _no_poliza       CHAR(10);
DEFINE _fecha_pago      integer;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic,_porc_comis_agt     DEC(5,2); 
DEFINE _no_documento    CHAR(20); 
DEFINE _monto_descontado,_monto    DEC(16,2);
define _cod_contratante char(10);
define _error           smallint;
define _cod_agente   	char(5);
define _n_cliente,_n_agente       varchar(100);

--SET DEBUG FILE TO "sp_pro868a.trc";
--TRACE ON;

let _error            = 0;
let _prima            = 0;
let _monto            = 0;
let _monto_descontado = 0;

SET ISOLATION TO DIRTY READ;

foreach
	select d.no_poliza,
		   year(d.fecha),
		   d.monto,
		   d.prima_neta,
		   d.monto_descontado,
		   c.porc_partic_agt,
		   c.porc_comis_agt,
		   d.doc_remesa,
		   c.cod_agente
	  into _no_poliza,
		   _fecha_pago,
		   _monto,
		   _prima,
		   _monto_descontado,
		   _porc_partic,
		   _porc_comis_agt,
		   _no_documento,
		   _cod_agente
	  from cobredet d, cobremae m, cobreagt c
	 where d.no_remesa    = m.no_remesa
	   and d.no_remesa    = c.no_remesa
	   and d.renglon      = c.renglon
	   and d.actualizado  = 1
	   and d.tipo_mov     in ('P','N')
	   and m.tipo_remesa  in ('A', 'M', 'C')
	   and c.cod_agente in('00035','02904')
	 order by d.fecha,d.no_recibo,d.no_poliza

	let _no_poliza = sp_sis21(_no_documento);
	
	select cod_contratante
	  into _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select nombre
	  into _n_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;
	 
	select nombre
	  into _n_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	Return _fecha_pago,_cod_agente,_n_agente,_no_documento,_n_cliente,_monto,_prima,_porc_comis_agt,_monto_descontado with resume;

end foreach
END PROCEDURE;