-- Procedimiento para pasar los reg. que quedaron del dia anterior al dia actual(registros del tipo otro dia)
-- de las gestoras
-- Creado    : 23/01/2004 - Autor: Armando Moreno M.

-- SIS v.2.0 - d_cobr_cobros_x_dia_cte - DEIVID, S.A.

drop procedure sp_cas065a;

create procedure sp_cas065a()
returning char(10),smallint,smallint;

define _error			integer;
define _cod_cliente		char(10);
define _nombre	        char(50);
define v_documento      char(20);
define _contacto	    char(50);
define _direccion	    char(100);
define _ultima_gestion	char(100);
define a_cobrador		char(3);
define _cod_cobrador 	char(3);
define _nombre_pagador	char(100);
define _telefono1		char(10);
define _telefono2		char(10);
define _celular			char(10);
define _telefono3		char(10);
define _fax				char(10);
define _e_mail			char(50);
define _apartado		char(20);
define _cedula			char(30);

define _cod_gestion     char(3);
define _no_poliza	    char(10);
define _cod_cobrador_otro  char(3);
define _no_documento	char(20);
define _code_pais       char(3);
define _code_provincia	char(2);
define _code_ciudad		char(2);
define _code_distrito	char(2);
define _code_correg		char(5);
DEFINE _mes_char        CHAR(2);
DEFINE _ano_char		CHAR(4);
DEFINE _periodo         CHAR(7);
DEFINE v_por_vencer     DEC(16,2);	 
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente		DEC(16,2);
DEFINE v_monto_30		DEC(16,2);
DEFINE v_monto_60		DEC(16,2);
DEFINE v_monto_90		DEC(16,2);
DEFINE v_apagar			DEC(16,2);
DEFINE v_saldo			DEC(16,2);

define _prioridad		smallint;
define _procesado		smallint;
define _cantidad		smallint;
define _existe			smallint;
define _cnt				smallint;
define _pago_fijo		smallint;
define _hora_hoy		datetime hour to minute;
define _hora_tra		datetime hour to minute;
define i				integer;
define _li_return		integer;
define _cnt_apagar_no    		 smallint;   
define _cnt_total        		 smallint;
define _cant	 		 		 smallint;
define _cnt_atrasado_sin_gestion smallint;
define _fecha_menos1 	 		 date;
define _dia_menos1,_dia_hoy		 smallint;

--set debug file to "sp_cob101.trc";

set isolation to dirty read;
begin


foreach
	select cod_campana,
		   fecha_hasta
		   filt_status,
		   filt_zonacob,
		   filt_sucursal,
		   filt_pago,
		   filt_moros,
		   filt_formapag,
		   filt_agente,
		   filt_grupo,
		   filt_diacob}
	  into _cod_campana,
		   _fecha_hasta
		   _filt_status,
		   _filt_zonacob,
		   _filt_sucursal,
		   _filt_pago,
		   _filt_moros,
		   _filt_formapag,
		   _filt_agente,
		   _filt_grupo,
		   _filt_diacob
	  from cascampana
	 where cod_campana in ()
	 order by cod_campana
end foreach

end

end procedure