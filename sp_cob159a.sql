-- Actualizacion de Registros Segun el Tipo de Gestion

-- Creado    : 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/05/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.

drop procedure sp_cob159a;	  

create procedure sp_cob159a(a_cod_cobrador char(3))
returning char(10),dec(16,2),datetime year to fraction(5);

define _dia_cobros1			integer;
define _dia_cobros2			integer;
define _dia1				integer;
define _dia2				integer;
define _cod_sucursal		char(3);
define _cod_cobrador		char(3);
define _fec		    		datetime year to fraction(5);
define _cod_pagador		    char(10);
define _code_pais		    char(3);
define _code_provincia	    char(2);
define _code_ciudad  	    char(2);
define _code_distrito	    char(2);
define _code_correg  	    char(5);
define _cod_motiv   		char(3);
define _no_documento		char(20);
define _por_vencer          dec(16,2);
define _code_agente  	    char(5);
define _user_added		    CHAR(10);
define _apagar              dec(16,2);
define _saldo				dec(16,2);
define _exigible			dec(16,2);
define _corriente			dec(16,2);
define _monto_30			dec(16,2);
define _monto_60			dec(16,2);
define _monto_90            dec(16,2);
define _descripcion			CHAR(50);
define _cantidad			integer;
define _procedencia			integer;
define _error				integer;
define _error_isam			integer;
define _error_desc			char(50);
define _cnt					smallint;

--set debug file to "sp_cob159.trc";
--trace on;

set isolation to dirty read;

let _por_vencer = 0;

begin

foreach
select a_pagar,
	   fecha,
	   cod_pagador
  into _apagar,
	   _fec,
	   _cod_pagador
  from cobruter1
 where cod_cobrador = a_cod_cobrador
   and cod_pagador is not null

 select count(*)
   into _cnt
   from cobruter2
  where cod_pagador = _cod_pagador;

if _cnt = 0 and _apagar = 0 then

   delete from cobruter1
    where cod_pagador  = _cod_pagador
      and cod_cobrador = a_cod_cobrador;

	return _cod_pagador,_apagar,_fec with resume;
end if

			
end foreach

end

--return 0, "Actualizacion Exitosa";

end procedure;

