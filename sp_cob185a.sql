-- Actualizacion de Registros Segun el Tipo de Gestion

-- Creado    : 08/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 08/05/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - w_m_detalle_detalle - DEIVID, S.A.

drop procedure sp_cob185a;	  

create procedure sp_cob185a(
a_cod_cobrador 		char(3),
a_dia				smallint,
a_fecha				datetime year to fraction(5),
a_fecha_hora		datetime year to fraction(5),
a_dia_sig			smallint,
a_usuario           char(8)
)
returning integer;

define _error				integer;
define _dia_cobros1			integer;
define _dia_cobros2			integer;
define _dia1				integer;
define _dia2				integer;
define _cod_sucursal		char(3);
define _cod_cobrador		char(3);
define _fec		    		datetime year to fraction(5);
define _no_poliza		    char(10);
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
define _cantidad,_can		integer;
define _procedencia			integer;
define _cod_pagador         char(10);

--set debug file to "sp_cob185a.trc";
--trace on;

set isolation to dirty read;

let _por_vencer = 0;

begin

on exception set _error
 	return _error;         
end exception

select a_pagar,
	   code_pais,
	   code_provincia,
	   code_ciudad,
	   code_distrito,
	   code_correg,
	   procedencia,
	   dia_cobros1,
	   saldo,
	   por_vencer,
	   exigible,
	   corriente,
	   monto_30,
	   monto_60,
 	   monto_90,
	   descripcion,
	   user_added,
	   dia_cobros2,
	   cod_pagador
  into _apagar,
  	   _code_pais,
	   _code_provincia,
	   _code_ciudad,
	   _code_distrito,
	   _code_correg,
	   _procedencia,
	   _dia_cobros1,
	   _saldo,
	   _por_vencer,
	   _exigible,
	   _corriente,
	   _monto_30,
	   _monto_60,
 	   _monto_90,
	   _descripcion,
	   _user_added,
	   _dia_cobros2,
	   _cod_pagador		 
  from cobruter1
 where cod_cobrador = a_cod_cobrador
   and dia_cobros1  = a_dia
   and fecha        = a_fecha;

	--historia de rutero(cobruhis)
	INSERT INTO cobruhis(
	cod_cobrador,   	
	cod_motiv,
	a_pagar,      
	dia_cobros1,	
	fecha,
	cod_pagador,
	code_pais,     
	code_provincia,
	code_ciudad,	 
	code_distrito,
	code_correg,
	user_added,
	procedencia
	)
	VALUES(
	a_cod_cobrador,
	null,    
	_apagar,
	a_dia_sig,
	a_fecha_hora,
	_cod_pagador,
	_code_pais,
	_code_provincia,
	_code_ciudad,
	_code_distrito,
	_code_correg,
	a_usuario,
	_procedencia
    );

select * 
  from cobruter2
 where cod_cobrador = a_cod_cobrador
   and dia_cobros1  = a_dia
   and fecha        = a_fecha
  into temp prueba;

delete from cobruter2
 where cod_cobrador = a_cod_cobrador
   and dia_cobros1  = a_dia
   and fecha        = a_fecha;

insert into cobruter2
select * from prueba
 where cod_cobrador = a_cod_cobrador
   and dia_cobros1  = a_dia
   and fecha        = a_fecha;

drop table prueba;

select * 
  from cobruter1
 where cod_cobrador = a_cod_cobrador
   and dia_cobros1  = a_dia
   and fecha        = a_fecha
  into temp prueba;

delete from cobruter1
 where cod_cobrador = a_cod_cobrador
   and dia_cobros1  = a_dia
   and fecha        = a_fecha;

insert into cobruter1
select * from prueba
 where cod_cobrador = a_cod_cobrador
   and dia_cobros1  = a_dia
   and fecha        = a_fecha;

drop table prueba;

update cobruter1
   set dia_cobros1  = a_dia_sig,
	   dia_cobros2  = a_dia_sig,
	   cod_motiv    = null,
	   fecha        = a_fecha_hora
 where cod_cobrador = a_cod_cobrador
   and dia_cobros1  = a_dia
   and fecha        = a_fecha;

update cobruter2
   set dia_cobros1  = a_dia_sig,
	   dia_cobros2  = a_dia_sig,
	   cod_motiv    = null,
	   fecha        = a_fecha_hora
 where cod_cobrador = a_cod_cobrador
   and dia_cobros1  = a_dia
   and fecha        = a_fecha;

end

return 0;

end procedure;

