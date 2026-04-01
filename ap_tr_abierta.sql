-- Procedimiento que actualiza los descuentos y recargos de las polizas de salud en emipomae, emipouni y emipocob

-- Creado    : 24/07/2012 - Autor: Armando Moreno
-- Modificado: 24/07/2012 - Autor: Armando Moreno
-- Modificado: 06/03/2013 - Autor: Amado Perez --  se corrige asi: Si algun concepto tiene agregar acreedor en 1 entonces retornamos 1 y no al reves
											   --    Antes estaba: Si algun concepto tiene agregar acreedor en 0 entonces retornamos 0

DROP PROCEDURE ap_tr_abierta;

CREATE PROCEDURE "informix".ap_tr_abierta()
returning char(20) as Reclamo,
          date as Fecha_Transaccion,
		  char(10) as Transaccion,
		  dec(16,2) as Monto,
		  char(10) as Anular_N_T,
		  char(10) as Cod_Cliente,
		  varchar(100) as Cliente,
		  char(10) as Cod_Cpt,
		  varchar(255) as Cpt,
		  char(8) as Usuario,
		  char(10) as Requisicion,
		  date as Fecha_Pagado;


define _no_reclamo       char(10);
define v_numrecla        char(20);
define _fecha            date;
define _transaccion      char(10);
define _anular_nt        char(10);
define _cod_cliente      char(10);
define _cliente          varchar(100);
define _cod_cpt          char(10);
define _cpt              varchar(255);
define _user_added       char(8);
define _no_requis        char(10);
define _fecha_pagado     date;
define _monto            dec(16,2);

SET ISOLATION TO DIRTY READ;

FOREACH
 SELECT	no_reclamo,
 		numrecla,
        fecha,
		transaccion,
		monto,
		anular_nt,
		cod_cliente,
		cod_cpt,
		user_added,
		no_requis,
		fecha_pagado
   INTO	_no_reclamo,
   		v_numrecla,
        _fecha,
		_transaccion,
		_monto,
		_anular_nt,
		_cod_cliente,
		_cod_cpt,
		_user_added,
		_no_requis,
		_fecha_pagado
   FROM rectrmae
  WHERE numrecla[1,2] in ('02','20','23') -- = '18'
    AND cod_tipotran = '004'
	AND (no_requis is null OR trim(no_requis) = "")
    AND actualizado = 1	
	order by 3

  SELECT nombre
   INTO _cliente
   FROM cliclien
  WHERE cod_cliente = _cod_cliente;
  
  select nombre
	into _cpt
	from reccpt
   where cod_cpt = _cod_cpt;
 
   return v_numrecla,
          _fecha,
		  _transaccion,
		  _monto,
		  _anular_nt,
		  _cod_cliente,
		  _cliente,
		  _cod_cpt,
		  _cpt,
		  _user_added,
		  _no_requis,
		  _fecha_pagado WITH RESUME;
   
end foreach

END PROCEDURE
