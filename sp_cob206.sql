-- Informe Anual para INUSE
-- Creado    : 18/04/2007 - Autor: Rub‚n Arn ez
-- SIS v.2.0 - DEIVID, S.A.
--
-- DROP PROCEDURE sp_cob206;

create procedure "informix".sp_cob206(a_fecha date, a_fechaf date) 
       returning   		 char(50),						-- 1. -nombre del cobrador de calle
						 char(3),						-- 2. -codigo del cobrador 
       					 char(30),  					-- 3. -p¢liza
						 dec(12,2),						-- 4. -monto cobtotal
						 datetime year to fraction(5),	-- 5. -fecha de programaci¢n
						 char(50),						-- 6. -nombre del cliente
			     		 char(10),						-- 7. -codigo del cliente
						 smallint,						-- 8. -anulado
						 integer,						-- 9. -fecha de programaci¢n 
						 varchar(20);					--10  -tipo de pago

define _tipo_pago        varchar(20);
define v_nombre_cobrador char(50);
define v_nombre_cliente  char(50);
define v_id_cliente      char(30);
define v_no_poliza       char(30);
define v_poliza  	     char(20);
define v_cod_cobrador    char(3);
define v_total_det	 	 dec(12,2);
define v_total  	 	 dec(12,2);
define _anulado          smallint;
define v_id_usuario 	 integer;
define v_id_transaccion  integer;
define v_usuario         integer;
define _id_motivo    	 integer;
define v_turno           integer;
define v_trans           integer;
define _secuencia        integer;
define _id_tipo_cobro    integer;
define v_fecha           date;
define v_fecha_inicio    datetime year to fraction(5);

	   
set isolation to dirty read;
foreach
    select nombre,
	       cod_cobrador
	  into v_nombre_cobrador,
		   v_cod_cobrador 
	  from cobcobra
   	 where tipo_cobrador = "3"	--rutero
       and activo        =  1
 
foreach
     	select id_turno,
		       id_cliente,
			   id_transaccion,
			   nombre_cliente,
			   total,
			   fecha_inicio,
			   id_motivo_abandono,
			   secuencia
		  into v_turno,
			   v_id_cliente,
			   v_id_transaccion,
			   v_nombre_cliente,
			   v_total,
			   v_fecha_inicio,
			   _id_motivo,
			   _secuencia
		  from cdmtransaccionesbk
		 where id_usuario         = v_cod_cobrador 
		   and (date(fecha_inicio)) between  a_fecha and a_fechaf 
   	     order by fecha_inicio

		let _anulado = 0;

		if v_total = 0 and _id_motivo is null then     -- cobro anulado
			let _anulado = 1;
		end if

		if v_total = 0 and _id_motivo is not null then -- no cobrado por motivo
			let _anulado = 2;
		end if
		   if _secuencia is null then
			let _secuencia = 0;
		   end if

		   let _tipo_pago = '';

		   foreach
			    select cuenta,
					   monto	
			      into v_poliza,
				       v_total_det
				  from cdmtrandetallebk
			 	 where id_transaccion      = v_id_transaccion and
				       id_usuario          = v_cod_cobrador   and
				       id_turno            = v_turno

				foreach

				    select id_tipo_cobro
				      into _id_tipo_cobro
					  from cdmtrancobrobk
				 	 where id_usuario     = v_cod_cobrador
				 	   and id_turno       = v_turno
				 	   and id_transaccion = v_id_transaccion
					                 
					if _id_tipo_cobro = 1 then
						let _tipo_pago = _tipo_pago || '-E-';
					elif _id_tipo_cobro = 2 then
						let _tipo_pago = _tipo_pago || '-CH-';
					elif _id_tipo_cobro = 3 then
						let _tipo_pago = _tipo_pago || '-CLV-';
				   	elif _id_tipo_cobro in(4,5,6,7) then
						let _tipo_pago = _tipo_pago || '-TC-';
					end if

				end foreach

		 	    return v_nombre_cobrador, -- 1. nombre del cobrador de la calle
					   v_cod_cobrador,	  -- 2. numero de usuario del cobrador de calle
					   v_poliza,		  -- 3. p¢liza
					   v_total_det,       -- 4. monto a pagar en detalle
					   v_fecha_inicio,    -- 5. fecha de inicio
					   v_nombre_cliente,  -- 6. nombre del cliente
					   v_id_cliente,  	  -- 7. codigo del cliente 
					   _anulado,          -- 8. anulado 
					   _secuencia,		  -- 9.
					   _tipo_pago         -- 10.
				  with resume;

		   end foreach;

       end foreach;

    end foreach;

end procedure;



						
