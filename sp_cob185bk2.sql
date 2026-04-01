-- Procedimiento que procesa los "no cobros" de los Cobros Mobiles

-- Creado    : 17/10/2005 - Autor: Armando Moreno M.
-- Modificado: 07/11/2005 - Autor: Armando Moreno M.
-- Modificado: 28/10/2010 - Autor: Roman Gordon

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob185bk2;

CREATE PROCEDURE "informix".sp_cob185bk2(
a_compania		CHAR(3),
a_sucursal		CHAR(3),
a_user			CHAR(8),
a_fecha_sig     DATE,
a_fecha_hoy     DATE
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

--SET DEBUG FILE TO "sp_cob185.trc"; 
--TRACE ON;                                                                

--tabla temporal para la parte de envio de correo a los cobradores que no son callcenter
CREATE TEMP TABLE tmp_ejec(
        user_added         char(10),
	    cod_pagador        char(10) NOT NULL,
	    descripcion	       varchar(50),
		cod_cobrador       char(3)
	    ) WITH NO LOG;

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Procesar los No Cobros de los Cobros Moviles', '';
END EXCEPTION           

let _existe = 0;

call sp_sis40() returning ld_fecha_hora;

FOREACH
	select id_usuario,
		   id_turno
	  into _id_usuario,
		   _id_turno
	  from cdmturno
	 order by 1,2

	select count(*)
	  into _existe
	  from cdmtransacciones
	 where id_usuario = _id_usuario
       and id_turno   = _id_turno;

    if _existe = 0 then
		continue foreach;
	end if

	--Buscar la transacciones por cobrador por turno que tienen motivo de no cobro.
	FOREACH
		select id_transaccion,
			   nombre_cliente,
			   total,
			   secuencia,
			   id_cliente,
			   id_motivo_abandono
		  into _id_transaccion,
			   _nombre_cliente,
			   _monto_total,
			   _secuencia,
			   _id_cliente,
			   _cod_motivo
		  from cdmtransacciones
		 where id_usuario = _id_usuario
	       and id_turno   = _id_turno
		   and id_motivo_abandono is not null
		 order by id_transaccion

		let _id_cliente = trim(_id_cliente);

		IF _cod_motivo < 10 THEN
			LET _cod_motivo_char = '00' || _cod_motivo;
		elif _cod_motivo < 100 THEN
			LET _cod_motivo_char = '0'  || _cod_motivo;
		END IF

		select tipocliente
		  into _tipo_cliente
		  from cdmclientes
		 where id_cliente = _id_cliente;

		select cod_cobrador,
			   fecha,
			   dia_cobros1,
			   user_added
		  into _cod_cobrador,
		  	   _fecha_registro,
			   _dia_cobros1,
			   _user_added
		  from cobruter3
		 where cod_pagador = _id_cliente
		   and tipo_labor  = 0;

		let li_dia_sig  = day(a_fecha_sig);

		if _tipo_cliente = 1 then				  --Es Corredor

			 update cobruter3
			 	set dia_cobros1 = li_dia_sig,
			 	    dia_cobros2 = li_dia_sig
			  where cod_agente  = _id_cliente;
		else									  --Es Pagador
			 
			select tipo_accion,
			       nombre
			  into _tipo_accion,
			       _nombre_motivo
			  from cobmotiv
			 where cod_motiv = _cod_motivo;

			let _nombre_motivo = trim(_nombre_motivo);
			LET ld_fecha_hora  = ld_fecha_hora + 10 UNITS SECOND;

			if _tipo_accion = 1 then			  --Se pasa para el dia siguiente	cobruter1

				--Inserta registro de historia y le cambia el dia a los registros del rutero
				call sp_cob185abk(_cod_cobrador, _dia_cobros1, _fecha_registro, ld_fecha_hora, li_dia_sig, a_user) returning _error_code;

			elif _tipo_accion = 2 then			  --Se pasa para el Callcenter

			   if _cod_gestor is not null or _cod_gestor <> "" then	--Es de callcenter
					select fecha_ult_pro,
					       tipo_cobrador
					  into _fecha_ult_pro,
					       _tipo_cobrador
					  from cobcobra
					 where cod_cobrador = _cod_gestor;

				   {if _tipo_cobrador = 12 then --rol 90 dias
						select count(*)
						  into _can
						  from cobcapen
						 where cod_cliente = _id_cliente;

						if _can = 0 then
							insert into cobcapen(cod_cliente, hora, cod_cobrador, nuevo, dia)
							values (_id_cliente, null, _cod_gestor, 1, _dia_cobros1);
						end if
					end if}

					if _fecha_ult_pro is null then
						let _fecha_ult_pro = a_fecha_hoy;
					end if

					let _fecha_ult_pro = _fecha_ult_pro + 2;
					let _dia_ult_pro   = Day(_fecha_ult_pro);

					{update cascliente
						set dia_cobros3 = _dia_ult_pro
					 where cod_cliente  = _id_cliente;}

					let _nombre_motivo = _nombre_motivo || " ,DEBE SALIR: " || _fecha_ult_pro;
					
					--Insertar la gestion "Cobgesti"
					foreach
						 select	no_documento
						   into	_no_documento
						   from	caspoliza
						  where	cod_cliente = _id_cliente

						 LET _no_poliza = sp_sis21(_no_	documento);

						Insert Into cobgesti(no_poliza, fecha_gestion, desc_gestion, user_added,cod_pagador,no_documento)
						Values              (_no_poliza, ld_fecha_hora, _nombre_motivo, a_user, _id_cliente,_no_documento);
                    end foreach

			   else
					--insertar en la tabla temporal los registros que son de las ejecutivas, etc.
					--para ser enviador por correo electronico desde power builder.
					INSERT INTO tmp_ejec(
					user_added,      
					cod_pagador,
					descripcion,
					cod_cobrador
					)
					VALUES(
					_user_added,      
					_id_cliente,        
					_nombre_motivo,       
					_cod_cobrador
					);

					--Insertar la gestion "Cobgesti"
					foreach
						 select	no_documento
						   into	_no_documento
						   from	cobruter4
						  where	cod_pagador = _id_cliente
						    and tipo_labor  = 0

						 LET _no_poliza = sp_sis21(_no_documento);

						Insert Into cobgesti(no_poliza, fecha_gestion, desc_gestion, user_added,cod_pagador,no_documento)
						Values              (_no_poliza, ld_fecha_hora, _nombre_motivo, a_user, _id_cliente,_no_documento);
                    end foreach

			   end if

			   --Borrar de Cobruter1 y Cobruter2
		   		delete from cobruter4
				 where cod_pagador = _id_cliente 
				   and tipo_labor  = 0;

				delete from cobruter3
				 where cod_pagador = _id_cliente
				   and tipo_labor  = 0;	 

			end if

			update cobruhisbk
			   set fecha_posteo = ld_fecha_hora,
			       user_posteo  = a_user,
				   cod_motiv    = _cod_motivo_char
			 where cod_cobrador = _cod_cobrador
			   and dia_cobros1  = _dia_cobros1
			   and fecha        = _fecha_registro;
		end if

	end foreach

END FOREACH

RETURN 0, 'No Cobros ' || '', ''; 

END 

END PROCEDURE;
