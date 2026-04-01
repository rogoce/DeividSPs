-- Procedimiento que procesa los "no cobros" de los Cobros Mobiles

-- Creado    : 17/10/2005 - Autor: Armando Moreno M.
-- Modificado: 07/11/2005 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob185;

CREATE PROCEDURE "informix".sp_cob185(
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
define _error_desc		char(50);
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
define _user_cob		char(8);
define _dia_cobros1     smallint;
define li_dia_sig       smallint;
define _tipo_accion     smallint;
define _nombre_motivo   varchar(255);
define _fecha_ult_pro   date;
define _tipo_cobrador   smallint;
define _can             smallint;
define _dia_ult_pro     smallint;
define _cod_motivo_char char(3);
define _apag			DEC(16,2);
define _pago_fijo 		smallint;
define _cnt             smallint;
define _modo_callcenter smallint;
define _cod_user_added	char(3);
define _fecha_turno		date;
define _dia_semana		smallint; 
define _dia_sig			smallint; 


--SET DEBUG FILE TO "sp_cob185.trc"; 
--TRACE ON;                                                                

SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET _error_code 
 	RETURN _error_code, 'Error al Procesar los No Cobros de los Cobros Moviles', '';
END EXCEPTION           

let _existe = 0;
let _fecha_turno = current;

call sp_sis40() returning ld_fecha_hora;

delete from cdmcorre;
delete from cdmcorrd;

select modo_callcenter
  into _modo_callcenter
  from parparam
 where cod_compania = '001';

FOREACH
	select id_usuario,
		   id_turno,
		   fecha_inicio
	  into _id_usuario,
		   _id_turno,
		   _fecha_turno
	  from cdmturno
	 where id_usuario = a_id_usuario
       and id_turno   = a_turno
	 order by 1,2

	if _fecha_turno <> a_fecha_hoy then
		let a_fecha_hoy = _fecha_turno; 
		
		let _dia_semana = weekday(a_fecha_hoy);
		if _dia_semana = 5 then
			let _dia_sig = 3;
		elif _dia_semana = 6 then
			let _dia_sig = 2;
		else
			let _dia_sig = 1;
		end if
		
		let a_fecha_sig = _fecha_turno + _dia_sig units day;
	end if  

	select count(*)
	  into _existe
	  from cdmtransacciones
	 where id_usuario = _id_usuario
       and id_turno   = _id_turno;

    if _existe = 0 then
		continue foreach;
	end if

	--Buscar las transacciones por cobrador por turno que tienen motivo de no cobro.
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

		if _cod_motivo < 10 THEN
			LET _cod_motivo_char = '00' || _cod_motivo;
		elif _cod_motivo < 100 THEN
			LET _cod_motivo_char = '0'  || _cod_motivo;
		end if

		select tipocliente
		  into _tipo_cliente
		  from cdmclientes
		 where id_usuario = _id_usuario
		   and id_cliente = _id_cliente;


		let _pago_fijo = 0;
		let _cod_gestor = "";
	   foreach
		select cod_cobrador,
			   pago_fijo
		  into _cod_gestor,
			   _pago_fijo
		  from cascliente
		 where cod_cliente = _id_cliente

	   	exit foreach;
	   end foreach

	   		select cod_cobrador,
				   fecha,
				   dia_cobros1,
				   user_added
			  into _cod_cobrador,
			  	   _fecha_registro,
				   _dia_cobros1,
				   _user_added
			  from cobruter1
			 where cod_pagador = _id_cliente
			   and tipo_labor  = 0;

		let li_dia_sig      = day(a_fecha_sig);
		let	_cod_cobrador   = _cod_cobrador;  
		let _fecha_registro	= _fecha_registro;
		let	_dia_cobros1	= _dia_cobros1;	
		let	_user_added		= _user_added;		

		if _tipo_cliente = 1 then				  --Es Corredor

			if _cod_motivo = 14 then    --cliente ya pago

				delete from cobruter1	--Borrar de Cobruter1 y Cobruter2
				 where cod_agente = _id_cliente;
			else

				 update cobruter1
				 	set dia_cobros1 = li_dia_sig,
				 	    dia_cobros2 = li_dia_sig
				  where cod_agente  = _id_cliente;
			end if
		else									  --Es Pagador
			 
			select tipo_accion,
			       nombre
			  into _tipo_accion,  --es el tipo de motivo
			       _nombre_motivo
			  from cobmotiv
			 where cod_motiv = _cod_motivo;

			let _nombre_motivo = trim(_nombre_motivo);
			let ld_fecha_hora  = ld_fecha_hora + 10 UNITS SECOND;

			if _tipo_accion = 1 then			  --Se pasa para el dia siguiente	cobruter1

				--Inserta registro de historia y le cambia el dia a los registros del rutero

				call sp_cob185a(_cod_cobrador, _dia_cobros1, _fecha_registro, ld_fecha_hora, li_dia_sig, a_user) returning _error_code;

			elif _tipo_accion = 2 then			  --Se pasa para el Callcenter o ejecutivas

				if _pago_fijo = 1  and _cod_motivo = 14 then --cte ya pago.
				
					if _dia_cobros1 is not null then

						call sp_cob159(_id_cliente, _cod_cobrador, _dia_cobros1, _fecha_registro, ld_fecha_hora) returning _error_code, _error_desc;

						if _error_code <> 0 then
							return _error_code, _error_desc, '';

						end if
						
					end if
				end if
				if _pago_fijo = 0  and _cod_motivo = 14 then
					delete from cobruter2
					 where cod_pagador = _id_cliente 
					   and tipo_labor  = 0;
				 
					delete from cobruter1
					 where cod_pagador = _id_cliente
					   and tipo_labor  = 0;
				end if

			   if _cod_gestor is not null or _cod_gestor <> "" then	--Es de callcenter

					INSERT INTO cdmcorre(			 --tmp_ejec(
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
					   {
						INSERT INTO cdmcorrebk(			 --tmp_ejec(
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
						);	}

					select fecha_ult_pro,
					       tipo_cobrador
					  into _fecha_ult_pro,
					       _tipo_cobrador
					  from cobcobra
					 where cod_cobrador = _cod_gestor;

				   if _modo_callcenter = 1 then
					let _fecha_ult_pro = a_fecha_hoy;
				   end if

				   if _tipo_cobrador = 12 then --rol 90 dias
						select count(*)
						  into _can
						  from cobcapen
						 where cod_cliente = _id_cliente;

						if _can = 0 then
							insert into cobcapen(cod_cliente, hora, cod_cobrador, nuevo, dia)
							values (_id_cliente, null, _cod_gestor, 1, _dia_cobros1);
						end if
				   end if

					if _fecha_ult_pro is null then
						let _fecha_ult_pro = a_fecha_hoy;
					end if

					let _fecha_ult_pro = _fecha_ult_pro + 2;
					let _dia_ult_pro   = Day(_fecha_ult_pro);

					update cascliente
					   set dia_cobros3 = _dia_ult_pro
					 where cod_cliente = _id_cliente;

					let _nombre_motivo = _nombre_motivo || " ,DEBE SALIR: " || _fecha_ult_pro;
					
					--Insertar la gestion "Cobgesti"
					
					if _id_usuario < 100 then
						let _cod_user_added = '0' || _id_usuario;
					else
						let _cod_user_added = _id_usuario;
					end if

					select usuario
					  into _user_added
					  from cobcobra
					 where cod_cobrador = _cod_user_added;
					
					if _user_added is null then
						let _cod_user_added = a_user;
					end if
					foreach
						 select	no_documento
						   into	_no_documento
						   from	caspoliza
						  where	cod_cliente = _id_cliente

						 LET _no_poliza = sp_sis21(_no_documento);

						 select	count(*)
						   into	_cnt
						   from	cobgesti
						  where	no_poliza     = _no_poliza
						    and fecha_gestion = ld_fecha_hora;

						 if _cnt > 0 then
							continue foreach;
						 end if
						Insert Into cobgesti(no_poliza, fecha_gestion, desc_gestion, user_added,cod_pagador,no_documento)
						Values              (_no_poliza, ld_fecha_hora, _nombre_motivo, _user_added, _id_cliente,_no_documento);

						if _no_documento is null or _no_documento = "" then
						else
							INSERT INTO cdmcorrd(		--tmp_eje1(
							cod_pagador,
							no_documento,
							a_pagar
							)
							VALUES(
							_id_cliente,        
							_no_documento,
							0
							);

						   {	INSERT INTO cdmcorrdbk(		--tmp_eje1(
							cod_pagador,
							no_documento,
							a_pagar
							)
							VALUES(
							_id_cliente,        
							_no_documento,
							0
							); }

						end if
                    end foreach

			   else
					--insertar en la tabla temporal los registros que son de las ejecutivas, etc.
					--para ser enviados por correo electronico desde power builder.
					if _cod_cobrador is null or _cod_cobrador = "" then
					else
						INSERT INTO cdmcorre(			 --tmp_ejec(
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
						{
						INSERT INTO cdmcorrebk(			 --tmp_ejec(
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
						);	}
						
					end if

					--Insertar la gestion "Cobgesti"
					foreach
						 select	no_documento,
								a_pagar
						   into	_no_documento,
								_apag
						   from	cobruter2
						  where	cod_pagador = _id_cliente
						    and tipo_labor  = 0

						 LET _no_poliza = sp_sis21(_no_documento);

  						 select	count(*)
						   into	_cnt
						   from	cobgesti
						  where	no_poliza     = _no_poliza
						    and fecha_gestion = ld_fecha_hora;

						 if _cnt > 0 then
							continue foreach;
						 end if

						if _id_usuario < 100 then
							let _cod_user_added = '0' || _id_usuario;
						else
							let _cod_user_added = _id_usuario;
						end if

						select usuario
						  into _user_added
						  from cobcobra
						 where cod_cobrador = _cod_user_added;
						 						
						Insert Into cobgesti(no_poliza, fecha_gestion, desc_gestion, user_added,cod_pagador,no_documento)
						Values              (_no_poliza, ld_fecha_hora, _nombre_motivo, _user_added, _id_cliente,_no_documento);


						if _no_documento is null or _no_documento = "" then
						else
							INSERT INTO cdmcorrd(		--tmp_eje1(
							cod_pagador,
							no_documento,
							a_pagar
							)
							VALUES(
							_id_cliente,        
							_no_documento,
							_apag
							);

							{INSERT INTO cdmcorrdbk(		--tmp_eje1(
							cod_pagador,
							no_documento,
							a_pagar
							)
							VALUES(
							_id_cliente,        
							_no_documento,
							_apag
							); }

						end if
                    end foreach

			   end if

			   --Borrar de Cobruter1 y Cobruter2
		   		delete from cobruter2
				 where cod_pagador = _id_cliente 
				   and tipo_labor  = 0;

				delete from cobruter1
				 where cod_pagador = _id_cliente
				   and tipo_labor  = 0;	 

			end if

			update cobruhis
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
