-- Reporte Detallado de Pólizas en Adelanto de Comisión
-- Creado    : 18/09/2014 - Autor: Román Gordón
-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_cob341;
create procedure sp_che145(a_cod_agente char(5))
returning	varchar(50) 	as Corredor,
			smallint		as numero_maximo_pagos,
			char(20)		as Poliza,
			date			as Fecha_Pago,
			dec(16,2)		as monto_cobrado,
			dec(16,2)		as prima_neta_cob,
			dec(5,2)		as porc_partic_agt,
			dec(5,2)		as porc_comis_agt,
			dec(16,2)		as comision_pagada,
			dec(16,2)		as comis_devengada,
			dec(16,2)		as comis_saldo;

define _nom_agente			varchar(50);
define _no_documento		char(20);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _cod_tipoprod		char(3);
define _porc_partic_agt		dec(5,2);
define _porc_comis_agt		dec(5,2);
define _comision_adelanto	dec(16,2);
define _comision_ganada		dec(16,2);
define _comision_pagada		dec(16,2);
define _comis_devengada		dec(16,2);
define _prima_neta_cob		dec(16,2);
define _prima_suscrita		dec(16,2);
define _comision_saldo		dec(16,2);
define _monto_cobrado		dec(16,2);
define _comis_saldo			dec(16,2);
define _prima_neta			dec(16,2);
define _adelanto_comis		smallint;
define _cnt_cobadeco		smallint;
define _max_no_pagos		smallint;
define _cant_pagos			smallint;
define _fecha_adelanto		date;
define _fecha_inicio		date;
define _fecha_cobro			date;

set isolation to dirty read;

--set debug file to "sp_che145.trc";	 																						 
--trace on;