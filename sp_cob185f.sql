-- Procedimiento que procesa los "no cobros" de los Cobros Mobiles

-- Creado    : 17/10/2005 - Autor: Armando Moreno M.
-- Modificado: 07/11/2005 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

--DROP PROCEDURE sp_cob185f;

CREATE PROCEDURE "informix".sp_cob185f(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8),
a_fecha_sig     DATE,
a_fecha_hoy     DATE,
a_turno			integer,
a_id_usuario    integer
) RETURNING SMALLINT,
            CHAR(100),
            CHAR(10);

DEFINE _error_code      INTEGER;
DEFINE _no_poliza    	CHAR(10); 
DEFINE _no_documento 	CHAR(18);
DEFINE _nombre_cliente 	CHAR(50);
DEFINE _cod_cobrador    CHAR(3);
define _id_transaccion  integer;
define _id_usuario      integer;
define _id_turno        integer;
define _existe          integer;
define _monto_total		DEC(16,2);
define _secuencia       integer;
define ld_fecha_hora	datetime year to fraction(5);
define _fecha_registro  datetime year to fraction(5);
define _id_cliente		char(30);
define _cod_motivo      integer;
define _tipo_cliente    smallint;
define _cod_gestor      char(3);
define _user_added      char(8);
define _dia_cobros1     smallint;
define li_dia_sig       smallint;
define _tipo_accion     smallint;
define _nombre_motivo   varchar(255);
define _fecha_ult_pro   date;
define _tipo_cobrador   smallint;
define _can             smallint;
define _dia_ult_pro     smallint;
define _cod_motivo_char char(3);
define _fecha			date;
define _dia				smallint;
define _cod_agente		char(5);
define _bandera			smallint;
define _pago_fijo		smallint;
define _saber			smallint;
define _error_isam		integer;
define _error_desc		char(100);

--SET DEBUG FILE TO "sp_cob185.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code,_error_isam,_error_desc 
 	RETURN _error_code, 'Error al Procesar los No Cobros de los Cobros Moviles', _error_desc;
END EXCEPTION           

let _existe = 0;

call sp_sis40() returning ld_fecha_hora;

FOREACH
	select id_usuario,
		   id_turno
	  into _id_usuario,
		   _id_turno
	  from cdmturno
	 where id_usuario = a_id_usuario
       and id_turno   = a_turno
	 order by 1,2

    select fecha_fin
	  into _fecha
   	  from cdmturno
	 where id_usuario = _id_usuario
       and id_turno   = _id_turno;

	let _dia = day(_fecha);

	let _cod_cobrador = '0' || a_id_usuario;

   	foreach
		select cod_cobrador,
			   fecha,
			   dia_cobros1,
			   user_added,
			   cod_pagador,
			   cod_agente
		  into _cod_cobrador,
		  	   _fecha_registro,
			   _dia_cobros1,
			   _user_added,
			   _id_cliente,
			   _cod_agente
		  from cobruter1
		 where dia_cobros1  = _dia
		    or dia_cobros2  = _dia
		   and cod_cobrador = _cod_cobrador
		   and tipo_labor   = 0

		let _bandera = 0;
		let li_dia_sig  = day(a_fecha_sig);

		if _id_cliente is null then				  --Es Corredor

			 update cobruter1
			 	set dia_cobros1 = li_dia_sig,
			 	    dia_cobros2 = li_dia_sig
			  where cod_agente  = _cod_agente;
		else
			let _pago_fijo = 0;
			foreach
				select pago_fijo
				  into _pago_fijo
				  from cascliente
				 where cod_cliente = _id_cliente
				exit foreach;
			end foreach
			
			if _pago_fijo is null then
				let _pago_fijo = 0;
			end if
			
			if _pago_fijo = 1 then

				select count(*)
				  into _saber
				  from cdmtransacciones
				 where id_cliente = _id_cliente
				   and id_motivo_abandono is null;

				if _saber > 0 then --a este cliente de pago fijo se le cobro, no hay que pasarlo al dia siguiente.
					let _bandera = 1;
				end if
			end if

			LET ld_fecha_hora  = ld_fecha_hora + 10 UNITS SECOND;

			--Inserta registro de historia y le cambia el dia a los registros del rutero

			if _bandera = 0 then
				call sp_cob185a(_cod_cobrador, _dia_cobros1, _fecha_registro, ld_fecha_hora, li_dia_sig, a_user) returning _error_code;
			end if

		end if

	end foreach

END FOREACH

RETURN 0, 'No Cobros ' || '', ''; 

END 

END PROCEDURE;
