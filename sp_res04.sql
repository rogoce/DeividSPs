-- Reporte de Resumen de Siniestros Pagados Sin Reserva
-- Creado    : 11/04/2016 - Autor: Armando Moreno M.

DROP PROCEDURE sp_res04;
CREATE PROCEDURE "informix".sp_res04(
a_compania	CHAR(3),
a_agencia	CHAR(3),
a_periodo1	CHAR(7),
a_periodo2	CHAR(7),
a_sucursal	CHAR(255) DEFAULT "*",
a_ramo		CHAR(255) DEFAULT "*"
)
RETURNING	char(50),char(3),char(50),decimal(16,2),decimal(16,2),decimal(16,2),varchar(255),char(7);

DEFINE v_filtros          CHAR(255);

DEFINE v_doc_reclamo      CHAR(18);     
DEFINE v_doc_poliza       CHAR(20);     
DEFINE v_fecha_siniestro  DATE;         
DEFINE v_ramo_nombre      CHAR(50);     
DEFINE v_compania_nombre  CHAR(50);     

DEFINE _no_reclamo        CHAR(10);     
DEFINE _no_poliza         CHAR(10);     
DEFINE _cod_sucursal      CHAR(3);      
DEFINE _cod_subramo       CHAR(3);
DEFINE _cod_ramo          CHAR(3);      
DEFINE _cod_contrato      CHAR(5);     
DEFINE _cod_cliente,_no_tranrec       CHAR(10);     
DEFINE _periodo           CHAR(7);      
DEFINE _porc_reas,_porc_coas         dec;

DEFINE _pagado_bruto      dec(16,2);
DEFINE _pagado_neto       dec(16,2);


DEFINE _monto_bruto             dec(16,2);
define _cod_cobertura     char(5);

define _monto_total     dec(16,2);
define _no_unidad         char(5);
define _fecha			  date;
define _fecha_reclamo	  date;
define _periodo_eval	  char(7);
define _variacion	     dec(16,2);
define _pagado_total     dec(16,2);
define _monto_var        dec(16,2);
define _no_documento     char(20);
define _fecha_siniestro  date;
define _cod_evento       char(3);
define _n_subramo		 char(50);
define _n_evento		 char(50);
define _n_sucursal		 char(50);

-- Nombre de la Compania
LET  v_compania_nombre = sp_sis01(a_compania);

LET v_filtros = sp_rec704(a_compania,a_agencia, a_periodo1,a_periodo2,a_sucursal,'*', a_ramo,'*','*','*','*','*'); --CREA TMPSINIS

--SET DEBUG FILE TO 'sp_rec705.trc';
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _fecha = sp_sis36bk5(a_periodo1);--Busca el ultimo dia del primer periodo a evaluar
let _periodo_eval = sp_sis39(_fecha);

create temp table tmp_sinis_sal(
no_reclamo			char(10)  not null)
 with no log;

FOREACH 
	 SELECT no_reclamo,		
			no_poliza,	
			cod_ramo,		
			periodo,
			numrecla,
			cod_sucursal,
			cod_subramo,
			pagado_bruto,
			pagado_neto
	   INTO	_no_reclamo, 		
			_no_poliza,	   	
			_cod_ramo, 
			_periodo,
			v_doc_reclamo,
			_cod_sucursal,
			_cod_subramo,
			_pagado_bruto, 		
			_pagado_neto 		
	   FROM tmp_sinis 
	  WHERE seleccionado = 1
	  ORDER BY no_reclamo
	
	select fecha_reclamo
	  into _fecha_reclamo
	  from recrcmae
	 where no_reclamo = _no_reclamo;

    if _fecha_reclamo >= _fecha then
		continue foreach;
	end if
	
	SELECT porc_partic_coas
	  INTO _porc_coas
      FROM reccoas
     WHERE no_reclamo   = _no_reclamo
       AND cod_coasegur = '036';

	IF _porc_coas IS NULL THEN
		LET _porc_coas = 0;
	END IF
	
	FOREACH
		SELECT c.cod_cobertura,
		       sum(c.monto)
		  into _cod_cobertura,
               _monto_total		  
		  FROM rectrmae a, rectitra b, rectrcob c
		 WHERE a.no_tranrec = c.no_tranrec
		   AND a.cod_tipotran = b.cod_tipotran
		   AND a.no_reclamo   = _no_reclamo
		   AND a.actualizado  = 1
	       AND b.tipo_transaccion IN (4,5,6,7)
		   AND a.periodo  >= a_periodo1
		   AND a.periodo  <= a_periodo2
		   AND c.monto    <> 0
		   group by 1
		   
		let _monto_bruto = 0;
		let _monto_bruto = _monto_total  / 100 * _porc_coas;
		let _monto_var   = 0;

		select sum(t.variacion)
	      into _variacion
		  from rectrmae r, rectrcob t
		 where r.no_tranrec    = t.no_tranrec
		   and r.no_reclamo    = _no_reclamo
		   and r.periodo       <= _periodo_eval 
		   and r.actualizado   = 1
		   and t.cod_cobertura = _cod_cobertura;
		   
		let _monto_var = _variacion  / 100 * _porc_coas;		   
		if _monto_var < _monto_total then
			insert into tmp_sinis_sal(no_reclamo) values(_no_reclamo);
			exit foreach;
		end if
		   
	END FOREACH	   
END FOREACH

FOREACH 
	SELECT cod_ramo,
		   sum(pagado_bruto),
		   sum(pagado_neto),
		   sum(pagado_total)
	  INTO _cod_ramo, 
		   _pagado_bruto, 		
		   _pagado_neto,
		   _pagado_total
	  FROM tmp_sinis 
	 WHERE seleccionado = 1
	   AND no_reclamo in(select no_reclamo from tmp_sinis_sal)
	 GROUP BY cod_ramo  
	 ORDER BY cod_ramo

	select nombre
	  into v_ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;
	 
	return v_compania_nombre,_cod_ramo,v_ramo_nombre,_pagado_bruto,_pagado_total,_pagado_neto,v_filtros,_periodo_eval with resume;
		
END FOREACH	  

DROP TABLE tmp_sinis;
DROP TABLE tmp_sinis_sal;

END PROCEDURE;