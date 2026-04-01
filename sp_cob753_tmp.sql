-- Cambio del proceso automatico que solo marque en estatus de cancelada 
-- y permita en Deivid seleccionar las polizas a cancelar 
-- Creado    : 27/10/2010 - Autor: Henry Giron 
-- SIS v.2.0 - DEIVID, S.A.	

drop procedure sp_cob753_tmp;
create procedure sp_cob753_tmp()
returning integer,
          char(100);

define a_user_proceso	   char(15);
define _no_documento	   char(20);
define _no_poliza,_no_poliza2     char(10);
define _cod_ramo           char(3);  
define _cobra_poliza	   char(1);
define _estatus_poliza	   char(1);
define _cod_tipoprod	   char(3);
define _cantidad		   SMALLINT;
define _fecha_emision	   date;
define _fecha_actual	   date;
define _fecha_marcar	   date;
define _cod_formapag	   char(3);
define _tipo_forma		   SMALLINT;
define _nombre_formapag	   char(50);
define _dias			   smallint;
define _return			   smallint;
define _error			   integer;
define _cancelada		   SMALLINT;
define _fecha_canc		   date;
define _fecha_proceso	   date;
define _saldo			   DEC(16,2);
define _saldo_act		   DEC(16,2);
define _saldo_canc		   DEC(16,2);
define _por_vencer		   DEC(16,2);
define _exigible		   DEC(16,2);
define _corriente		   DEC(16,2);
define _dias_30  		   DEC(16,2);
define _dias_60  		   DEC(16,2);
define _dias_90  		   DEC(16,2);
define _dias_120 		   DEC(16,2);
define _dias_150 		   DEC(16,2);
define _dias_180		   dec(16,2);
define _no_aviso 		   char(15);
define _user_added		   char(8);
define _renglon            integer;
define _descripcion        char(100);
define _pago_moro          SMALLINT;
define _tm_ultima_gestion  integer;
define _tm_fecha_efectiva  integer;
define _estatus_poliza2    SMALLINT;
define _saldo1             dec(16,2);
DEFINE _estatus			   CHAR(1);
define _mes_char		   char(2);
define _ano_char		   char(4);
DEFINE _periodo_c		   CHAR(7);
DEFINE _hay_pago		   SMALLINT;
DEFINE _saldo_pago 		   DECIMAL(16,2);
DEFINE _saldo_c   		   DECIMAL(16,2);
define _corriente_c 	   DECIMAL(16,2);
DEFINE _por_vencer_c	   DECIMAL(16,2);
DEFINE _exigible_c		   DECIMAL(16,2);
DEFINE _dias_30_c		   DECIMAL(16,2);
DEFINE _dias_60_c		   DECIMAL(16,2);
DEFINE _dias_90_c		   DECIMAL(16,2);
DEFINE _dias_120_c		   DECIMAL(16,2);
DEFINE _dias_150_c 		   DECIMAL(16,2);
DEFINE _dias_180_c		   DECIMAL(16,2);
DEFINE _saldo_sin_mora	   DECIMAL(16,2);
DEFINE _saldo_con_mora	   DECIMAL(16,2);
DEFINE _user_ciclo         CHAR(15);
DEFINE _fecha_ult_pago     DATE;
DEFINE _fecha_ult_vig      DATE;
define _cod_pagador		   char(10);
define _bitacora		   char(255);
define _no_recibo		   char(20);
DEFINE _monto_rec	       DECIMAL(16,2);
DEFINE _fecha_quitar       date;
DEFINE _fecha_ult_gestion  date;
DEFINE _no_factura		   char(10);
DEFINE _nombre			   char(50);
DEFINE _fecha_gestion   DATETIME YEAR TO SECOND;

--define _tm_ultima_gestion  SMALLINT;

set isolation to dirty read;
--set debug file to "sp_cob753_tmp.trc";
--trace on;

begin
on exception set _error
	return _error, "Error de Base de Datos";
end exception

let _fecha_actual = sp_sis26() ;
--let _fecha_actual = '21/01/2012';

select firma_end_canc
  into a_user_proceso
  from parparam
 where cod_compania = "001";

let _renglon = 0;
let _saldo_canc	= 0;
let _tm_ultima_gestion = 0;
let _tm_fecha_efectiva = 0;
let _saldo_sin_mora = 0;
let _saldo_con_mora = 0;
let _user_ciclo = "";
let _bitacora = "";

IF MONTH(_fecha_actual) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_actual);
ELSE
	LET _mes_char = MONTH(_fecha_actual);
END IF

LET _ano_char = YEAR(_fecha_actual);
LET _periodo_c  = _ano_char || "-" || _mes_char;

--- DESMARCAR CANCELACION MOTIVOS VARIOS  
foreach
 SELECT p.no_documento,f.no_factura,m.nombre,f.fecha_emision
   INTO	_no_documento,_no_factura,_descripcion,_fecha_proceso
   FROM emipomae p, endedmae f , endtican m
  WHERE p.fecha_cancelacion >= _fecha_actual  -- '10/11/2011' -- is not null --
    AND p.estatus_poliza = '2'
    AND p.no_poliza = f.no_poliza
    AND f.cod_endomov = '002'
	AND f.actualizado = 1
	AND f.activa = 1
	and f.cod_tipocan = m.cod_tipocan
	order by 1,2

	   let _cantidad = 0;
	 select count(*)
	   into _cantidad
	   from avisocanc 
	  where estatus not in ('Y','Z')
	    and trim(no_documento) = _no_documento;

		if _cantidad > 0 then

		   foreach
		    select distinct trim(no_poliza) 
		      into _no_poliza
		      from avisocanc 
		     where estatus not in ('Y','Z')
		       and trim(no_documento) = _no_documento
		      exit foreach;
		   	   end foreach

		   foreach
			select no_aviso,renglon,estatus_poliza
			  into _no_aviso,_renglon,_estatus_poliza
			  from avisocanc
			 where no_documento = _no_documento
			   and no_poliza    = _no_poliza
			 order by fecha_proceso desc
		      exit foreach;
		   	   end foreach


			select cod_pagador
			  into _cod_pagador
			  from emipomae 
			 where trim(no_poliza) = _no_poliza and trim(no_documento) = _no_documento;

			update avisocanc
			   set estatus         = "Y",  -- Se desmarca y se coloca motivo
			       cancela         = 1,
				   fecha_cancela   = _fecha_actual,
				   motivo          = _descripcion,
				   user_cancela    = a_user_proceso,
				   fecha_vence     = _fecha_actual,
				   no_factura      = _no_factura
			 where no_poliza       = _no_poliza
			   and no_aviso        = _no_aviso
			   and renglon         = _renglon;

			   LET _fecha_gestion  = CURRENT YEAR TO SECOND;
		       let _bitacora = "CANCELACION MOTIVOS VARIOS, FACTURA: "||trim(_no_factura)||" MOTIVO: "||trim(_descripcion)||" El DIA: "||_fecha_proceso||" REF.: "||trim(_no_aviso);

			 select count(*)
			 into _hay_pago
			 from cobgesti
			 where no_poliza = _no_poliza
			   and fecha_gestion = _fecha_gestion;

			   if _hay_pago = 0 then

					insert into cobgesti(no_poliza,fecha_gestion,desc_gestion,user_added,no_documento,fecha_aviso,tipo_aviso,cod_gestion,cod_pagador)
					values(_no_poliza,_fecha_proceso,_bitacora,a_user_proceso,_no_documento,_fecha_actual,0,null,_cod_pagador);	

					if _estatus_poliza = 1 then
						update emipomae  
					   	   set carta_aviso_canc = 0, fecha_aviso_canc = null, fecha_vencida_sal = null, carta_prima_gan = 0,carta_recorderis= 0, carta_vencida_sal = 0
				 		 where no_poliza = _no_poliza;
					elif _estatus_poliza = 2 then
						update emipomae  
					   	   set carta_aviso_canc = 0, fecha_aviso_canc = null, fecha_vencida_sal = null, carta_prima_gan = 0,carta_recorderis= 0, carta_vencida_sal = 0
				 		 where no_poliza = _no_poliza;
					elif _estatus_poliza = 3 then	 --Vencida
						update emipomae  
					   	   set carta_aviso_canc = 0, fecha_aviso_canc = null, fecha_vencida_sal = null, carta_prima_gan = 0,carta_recorderis= 0, carta_vencida_sal = 0
				 		 where no_poliza = _no_poliza;
					elif _estatus_poliza = 4 then	-- Anulada
						update emipomae  
					   	   set carta_aviso_canc = 0, fecha_aviso_canc = null, fecha_vencida_sal = null, carta_prima_gan = 0,carta_recorderis= 0, carta_vencida_sal = 0
				 		 where no_poliza = _no_poliza;
					end if

				end if
		end if

end foreach
end

return 0, "Actualizacion Exitosa ...";
end procedure	

	 
	