-- - Procedimiento que Genera el Archivo para las comisiones automaticas de SEMUSA

-- Creado    : 25/09/2008	- Autor: Henry Giron
-- Modificado: 13/03/2013	- Autor: Roman Gordon -- Se modifica el proceso para que tome en cuenta el proceso de adelanto de comision.
-- Modificado: 08/04/2013	- Autor: Roman Gordon -- Se modifica para que tome en cuenta la comision de SEMUSA Chitré (01853).
-- - SIS v.2.0 - sp_che05 - DEIVID, S.A.

drop procedure sp_che236a;

create procedure "informix".sp_che236a(
a_fecha_desde    date,
a_fecha_hasta    date
)

define _nombre_cliente		char(100);
define _no_documento		char(20);
define _no_remesa_ancon		char(10);
define _vigen_inic_char		char(10);
define _vigen_fin_char		char(10);
define _no_recibo_a			char(10);
define _no_registro			char(10);
define _no_licencia			char(10);
define _fecha_desde			char(10);
define _fecha_hasta			char(10);
define _cod_cliente			char(10);
define _no_recibo			char(10);
define _no_poliza			char(10);
define _cod_agente2			char(5);
define _cod_agente			char(5);
define _cod_compania		char(4);
define _ano					char(4);
define _dia					char(2);
define _mes					char(2);
define _lugar_cobro			char(1);
define _porc_comision		dec(8,5);
define _comision_adelanto	dec(16,2);
define _total_comision		dec(16,2);
define _total_descont		dec(16,2);
define _comis_descont		dec(16,2);
define _prima_pagada		dec(16,2);
define _total_prima			dec(16,2);
define _neto_pagado			dec(16,2);
define _comis_monto			dec(16,2);
define _comis_neta			dec(16,2);
define _cnt_remesa			smallint;
define _cnt_existe			smallint;
define _valor				smallint;
define _error				smallint;
define _secuencia			integer;
define _vigen_inic_date		date;
define _vigen_fin_date		date;
define _fecha               date;

--set debug file to "sp_che91.txt";
--trace on;


set isolation to dirty read;

let _comis_descont	= 0.00;
let _cod_compania	= "0270";
let _lugar_cobro	= "A";
--let _cod_agente2	= '01853';
let _cod_agente		= "00270";

let _no_registro	= sp_sis13("001", 'CHE', '02', 'com_rem_ducruet');

update parparam
   set che_reg_semusa  = _no_registro
 where cod_compania    = "001";
    
-- Fecha Desde
let _fecha_desde = 	sp_sis85(a_fecha_desde);


-- Fecha Hasta
let _fecha_hasta = 	sp_sis85(a_fecha_hasta);

-- Detalle del corredor
select no_licencia
  into _no_licencia
  from agtagent
 where cod_agente = _cod_agente;
 
insert into checomen(
no_registro,
cod_compania,
periodo_desde,
periodo_hasta,
total_prima,
total_comision,
total_descontada,
no_cheque,
cant_detalle,
no_licencia
)
values(
_no_registro,
_cod_compania,
_fecha_desde,
_fecha_hasta,
0.00,
0.00,
0.00,
0,
0,
_no_licencia
);


end procedure;