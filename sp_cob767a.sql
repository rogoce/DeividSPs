-- Procedimiento que Genera las Cancelaciones Automaticas Proceso de Avisos de Cancelacion.
-- Creado     : 27/09/2010  -- Autor: Henry Giron.	-- execute procedure sp_cob767a('501536','00014','HGIRON')
-- SIS v.2.0 -- DEIVID, S.A.
Drop procedure sp_cob767a;
create procedure "informix".sp_cob767a(a_no_poliza char(10),a_referencia CHAR(15),a_user_proceso CHAR(15))
returning smallint,Char(255);
{returning char(20),
          char(10),
          date,
          char(50),
          char(8),
          date,
          char(5),
          char(10); }
define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _no_endoso		char(5);
define _no_factura		char(10);
define _user_added		char(8);
define _estatus_poliza	smallint;
define _fecha_end_canc	date;
define _cancelada		smallint;
define _fecha_canc		date;
define _fecha_perdida	date;
define _fecha_vence 	date;

-- Vigencia Actual
define _no_poliza2		char(10);
define _estatus_poliza2 smallint;
define _desc_estatus	char(10);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(255);

define _descripcion		char(255);
define _cantidad		integer;
define _cod_cliente		char(10);
define _saldo_canc		dec(16,2);

 CREATE TEMP TABLE temp_msg
           (no_aviso		 CHAR(15),
            no_poliza		 CHAR(10),
			no_documento 	 CHAR(20),
			mensaje          CHAR(200),
        PRIMARY KEY(no_aviso,no_poliza,no_documento)) 
        WITH NO LOG;

CREATE INDEX idx1_temp_msg ON temp_msg(no_aviso);
CREATE INDEX idx2_temp_msg ON temp_msg(no_poliza);
CREATE INDEX idx3_temp_msg ON temp_msg(no_documento);

set debug file to "sp_cob252.trc";
trace on;

set isolation to dirty read;
--return 0,"Realizado Exitosamente. En Base de prueba de Sistema.";

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _cantidad   = 0;
let _saldo_canc = 0;
 
foreach	
 select no_poliza,
		user_proceso,
		no_documento,
		fecha_vence,
		cod_contratante,
		fecha_cancela
   into _no_poliza, 
		_user_added, 
		_no_documento, 
		_fecha_vence,   -- _fecha_perdida ,
		_cod_cliente, 
		_fecha_canc 
   from avisocanc 
  where estatus = "Z"  
    and no_poliza = a_no_poliza 
    and no_aviso  = a_referencia 

{ select fecha_cancela
  into _fecha_canc
 where no_poliza       = _no_poliza
   and no_aviso        = _no_aviso
   and renglon         = _renglon
   and estatus         = "X"; }

	-- Verifica que exista emireama y emireaco
	let _no_unidad = "0001";

	if _fecha_vence is null then
		let _fecha_vence = sp_sis26();
	end if

	delete from emireaco
	 where no_poliza         = _no_poliza
	   and porc_partic_suma  = 0
	   and porc_partic_prima = 0;
   --	trace off;
	call sp_pro159(_no_poliza) returning _error, _descripcion;
	--trace on;
	-- Cantidad de Unidades
	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = _no_poliza;

	   let _cantidad = 1;

	if _cantidad = 1 then -- Cancelacion de Poliza

		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;
--		   and no_unidad = _no_unidad;

		if _cantidad = 0 then		
			let _cancelada   = 0;
			let _fecha_canc  = sp_sis26();
			let _descripcion = "Unidad ya fue Eliminada";
		else

			select estatus_poliza,
			       fecha_cancelacion
			  into _estatus_poliza,
			       _fecha_end_canc
			  from emipomae
			 where no_poliza = _no_poliza;

			if _fecha_end_canc is null then
				let _fecha_end_canc = sp_sis26();
			end if

			if _estatus_poliza   = 2 then
				let _cancelada   = 0;
				let _fecha_canc  = _fecha_end_canc;
				let _descripcion = "Poliza ya fue Cancelada";
			else		
--			    trace on;	
				call sp_par304(_no_poliza, _user_added, 0.00,_fecha_canc) returning _error, _descripcion, _no_endoso;
--			   	trace off;
				if _error <> 0 then
					let _cancelada   = 0;
					let _fecha_canc  = null;

					INSERT INTO temp_msg(
							    no_aviso,		
								no_poliza,		
							    no_documento, 	
							    mensaje	)
						VALUES	(a_referencia,
						        _no_poliza,
						        _no_documento,
								_descripcion
						        );

					exit foreach;

				else
					let _cancelada   = 1;
					if _fecha_canc  is null then
						let _fecha_canc  = sp_sis26();
					end if
					let _descripcion = "Poliza Cancelada";

					foreach
					select trim(no_unidad)
					  into _no_unidad
					  from emipouni
					 where no_poliza = _no_poliza

						-- Cancelacion de Unidades
						INSERT INTO endedde2(
					    no_poliza,
						no_endoso,
					    no_unidad,
					    descripcion
						)
						SELECT _no_poliza,
							   _no_endoso,
							   _no_unidad,
							   descripcion
						  FROM endedde2
	                     WHERE no_poliza = '557015'	   -- Mientras investigo como colocar un blob desde un insert en informix. Henry     00001  '01-1186686'
			               AND no_endoso = '00001'	   -- OBSERVACION: MEDIANTE EL PRESENTE ENDOSO SE CANCELA LA PÓLIZA ARRIBA DESCRITA POR FALTA DE PAGO 
	                       AND no_unidad = '00001';	

                       end foreach	
				end if
			end if
		end if
	else -- Eliminacion de Unidades

		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = _no_poliza;
--		   and no_unidad = _no_unidad;

		if _cantidad = 0 then		
			let _cancelada   = 0;
			let _fecha_canc  = sp_sis26();
			let _descripcion = "Unidad ya fue Eliminada";
		else
			foreach
			 select no_unidad
			   into _no_unidad
			   from emipouni
			  where no_poliza = _no_poliza
--				  	trace on;
					call sp_par305(_no_poliza, _no_unidad, _user_added, 0.00,_fecha_canc) returning _error, _descripcion, _no_endoso;
--				  	trace off;
					if _error <> 0 then
						let _descripcion = _error || " " || trim(_descripcion);
						let _cancelada   = 0;
						let _fecha_canc  = null;						

						INSERT INTO temp_msg(
							    no_aviso,		
								no_poliza,		
							    no_documento, 	
							    mensaje	)
						VALUES	(a_referencia,
						        _no_poliza,
						        _no_documento,
								_descripcion
						        );

						exit foreach;

					else
						let _cancelada   = 1;
							if _fecha_canc  is null then
								let _fecha_canc  = sp_sis26();
							end if
						let _descripcion = "Unidad Eliminada";

						-- Cancelacion de Unidades
						INSERT INTO endedde2(
					    no_poliza,
						no_endoso,
					    no_unidad,
					    descripcion
						)
						SELECT _no_poliza,
							   _no_endoso,
							   _no_unidad,
							   descripcion
						  FROM endedde2
	                     WHERE no_poliza = '557015'	   -- Mientras investigo como colocar un blob desde un insert en informix. Henry     00001  '01-1186686'
			               AND no_endoso = '00001'	   -- OBSERVACION: MEDIANTE EL PRESENTE ENDOSO SE CANCELA LA PÓLIZA ARRIBA DESCRITA POR FALTA DE PAGO 
	                       AND no_unidad = '00001';		
					end if

			end foreach
		end if
	end if

	if _cancelada = 1 then
		let _prima_bruta = 0;
		select no_factura, prima_bruta
		  into _no_factura, _prima_bruta
		  from endedmae
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso;

			if _no_factura is null then 
				let _no_factura = ""; 
			end if

			let _saldo_canc = abs(_prima_bruta); 
{
			update cliclien 
			   set mala_referencia = '1', cod_mala_refe = '001', desc_mala_ref = "CANCELACION POR FALTA DE PAGO." 	 -- para que tome INCUMPLIMIENTO DE PAGO
			 where cod_cliente = _cod_cliente; 
}  -- CASO:31266:ASTANZIO HGIRON 30/04/2019
			update avisocanc
			   set estatus         = "Z",
			       cancela         = _cancelada,
				   fecha_cancela   = _fecha_canc,
				   motivo          = _descripcion,
				   user_cancela    = a_user_proceso,
				   no_endoso       = _no_endoso,
				   no_factura      = _no_factura,
				   saldo_cancelado = _saldo_canc
			 where no_poliza       = _no_poliza
			   and no_aviso        = a_referencia;
	else  
		let _no_factura = null;
	end if

	if _no_factura is null then
		let _no_factura = "";
	end if

	let _no_poliza2 = sp_sis21(_no_documento);

	select estatus_poliza
	  into _estatus_poliza2
	  from emipomae
	 where no_poliza = _no_poliza2;

	if _estatus_poliza2 = 1 then
		let _desc_estatus = "Vigente";
	elif _estatus_poliza2 = 2 then
		let _desc_estatus = "Cancelada";
		update emipomae  
	   	   set carta_aviso_canc = 1,fecha_cancelacion = _fecha_vence -- today
 		 where no_poliza = _no_poliza;
	elif _estatus_poliza2 = 3 then
		let _desc_estatus = "Vencida";
		update emipomae  
	   	   set carta_prima_gan = 1,fecha_vencida_sal = _fecha_vence  -- today
 		 where no_poliza = _no_poliza;
	elif _estatus_poliza2 = 4 then
		let _desc_estatus = "Anulada";
	end if

end foreach
--trace off;
if _error <> 0 then
   foreach
		select trim(no_documento),trim(mensaje)
		  into _no_documento,_descripcion
		  from temp_msg		 
		 exit foreach;
   end foreach

	return 1,"Error "||_descripcion||". Poliza: "||_no_documento ;
else
	return 0,"Realizado Exitosamente.";
end if

end 

DROP TABLE temp_msg;

end procedure
 
 		