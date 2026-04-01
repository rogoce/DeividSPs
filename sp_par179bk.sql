-- Procedure que verifica que todas las polizas esten en la tabla emipoliza
-- Modificado    : 06/10/2010- Autor: Roman Gordon

--drop procedure sp_par179bk;

create procedure sp_par179bk()
returning integer;

define _motivo_rechazo		varchar(50);
define _no_documento  		char(20);
define _no_tarjeta			char(19);
define v_cod_pagador		char(10);
define _no_poliza			char(10);
define _fecha_exp			char(7);
define v_cod_agente			char(5);
define v_cod_area			char(5);
define v_cod_grupo			char(5);
define v_cod_acreencia		char(3);
define v_cod_formapag		char(3);
define v_cod_pagos			char(3);
define v_cod_zona			char(3);
define v_cod_ramo			char(3);
define _cod_ramo			char(3);
define v_cod_suc			char(3);
define v_cod_status			char(1);
define v_prima_bruta		dec(16,2);
define v_carta_aviso_canc	smallint;
define _cont_agente			smallint;
define v_dia_cob1			smallint;
define v_dia_cob2			smallint;
define _cont_acre			smallint;
define _cantidad			integer;
define v_vigencia_ini		date;
define v_vigencia_fin		date;
define _cod_subramo         char(3);

set isolation to dirty read;

--set debug file to "sp_par179.trc";
--trace on;

foreach
 select no_documento
   into _no_documento
   from emipomae
  where actualizado  = 1
    and cod_ramo = '023'
  group by no_documento

  let _no_poliza = sp_sis21(_no_documento);

    select cod_ramo,cod_subramo
	  into _cod_ramo,_cod_subramo
	  from emipomae
	 where no_poliza = _no_poliza;

	update emipoliza 
	   set cod_ramo	    = _cod_ramo,
		   cod_subramo  = _cod_subramo
	 where no_documento = _no_documento;
	 
end foreach

return 0;
end procedure