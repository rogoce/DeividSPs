-- buscar a los pagadores que tienen mas de 15 dias de que se emitio aviso(call center) y los cobradores
-- aun no los han entregado.
-- 
-- Creado    : 05/04/2004 - Autor: Armando Moreno
-- Modificado: 05/04/2004 - Autor: Armando Moreno M.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cas074;

CREATE PROCEDURE "informix".sp_cas074()
       RETURNING   smallint,
       			   char(20),
       			   date,
       			   char(10),
       			   decimal(16,2),
				   char(100),
       			   date;

DEFINE _nombre_pagador   CHAR(100);
DEFINE _cod_sucursal     CHAR(3);
DEFINE v_exigible        DEC(16,2);
DEFINE _monto_exigible   DEC(16,2);
DEFINE _pagado			 DEC(16,2);
DEFINE _cod_pagador      CHAR(10);
define _user_added		 char(8);
define _fecha_hoy		 date;
define _fecha_entregado	 date;
define _fecha_aviso      date;
define _no_documento	 CHAR(20);
define _fecha_ult_pago   date;
define _cod_cobrador_ant_gestor char(3);
define _cantidad		 integer;
define _origen			 integer;
define _cod_cobrador	 CHAR(3);
define _no_poliza		 CHAR(10);
define _fecha_hora		 datetime year to fraction(5);

set isolation to dirty read;

let _fecha_hoy   	= today;
let v_exigible   	= 0;
let _cod_pagador 	= null;
let _nombre_pagador = "";
let _origen		    = null;
let _fecha_hora     = current;

FOREACH
-- Lectura de Cobavica
	select no_documento,
		   fecha_aviso,
		   cod_pagador,
		   exigible,
		   fecha_entregado,
		   cod_sucursal,
		   origen,
		   cod_cobrador,
		   no_poliza
	  into _no_documento,
		   _fecha_aviso,
		   _cod_pagador,
		   v_exigible,
		   _fecha_entregado,
		   _cod_sucursal,
		   _origen,
		   _cod_cobrador,
		   _no_poliza
	  from cobavica
	 where entregado = 1
	   and (_fecha_hoy - fecha_entregado) >= 15 -- 15 dias de que se entrego y 
     order by 3

	let _monto_exigible = v_exigible * 0.6;

	if _origen is null then
		let _origen = 0;
	end if

	SELECT max(fecha),
	       sum(monto)
	  INTO _fecha_ult_pago,
		   _pagado
	  FROM cobredet
	 WHERE doc_remesa  = _no_documento	    -- Recibos de la Poliza
	   AND actualizado = 1			        -- Recibo este actualizado
	   AND tipo_mov    IN ('P','N')
	   AND fecha       >= _fecha_entregado; -- Hechas durante y antes de la fecha seleccionada

		--insercion de historia antes de borrar el registro
		INSERT INTO bkcavica(
		no_documento,
		fecha_aviso,
		entregado,
		fecha_entregado,
		cod_cobrador,   	
		exigible,    
		cod_pagador,
		origen,
		no_poliza,
		cod_sucursal,
		fecha_borrado
		)
		VALUES(
		_no_documento,
		_fecha_aviso,
		1,
		_fecha_entregado,
		_cod_cobrador,
		v_exigible,
		_cod_pagador,
	    _origen,
		_no_poliza,
		_cod_sucursal,
		_fecha_hora
	    );

    delete from cobavica
     where no_documento = _no_documento;

	 if _pagado >= _monto_exigible then		--Cte. pago, proceso normal
		select nombre
		  into _nombre_pagador
		  from cliclien
		 where cod_cliente = _cod_pagador;

		select cod_cobrador_ant
		  into _cod_cobrador_ant_gestor
		  from cascliente
		 where cod_cliente = _cod_pagador;

	   	if _cod_cobrador_ant_gestor is null then
			let _cod_cobrador_ant_gestor = sp_cas006(_cod_sucursal, 1);
		end if
		update cascliente
		   set cod_cobrador     = _cod_cobrador_ant_gestor,
			   cod_cobrador_ant = null,
			   dia_cobros3      = 0
		 where cod_cliente      = _cod_pagador;

		RETURN 0,
			   null,
			   null,
			   null,
			   null,
			   null,
			   null
			   WITH RESUME;
	 else
		-- mandar mail
		-- poner polizas por cancelar
		let _no_poliza = sp_sis21(_no_documento);

		update emipomae
		   set cobra_poliza = "P",
		       cod_formapag = "080"
		 where no_poliza    = _no_poliza;

		-- borrar del call center
		select count(*)
		  into _cantidad
		  from caspoliza
		 where cod_cliente = _cod_pagador;

		if _cantidad = 1 then
			delete from caspoliza
			 where cod_cliente = _cod_pagador;

			delete from cascliente
			 where cod_cliente = _cod_pagador;

			delete from cobcapen
			 where cod_cliente = _cod_pagador;

		elif _cantidad > 1 then
			delete from caspoliza
			 where no_documento = _no_documento;
		end if

		select nombre
		  into _nombre_pagador
		  from cliclien
		 where cod_cliente = _cod_pagador;

			 RETURN 1,
		       _no_documento,
			   _fecha_aviso,
			   _cod_pagador,
			   v_exigible,
			   _nombre_pagador,
			   _fecha_entregado
			   WITH RESUME;
	 end if
END FOREACH;
END PROCEDURE