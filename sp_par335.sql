-- Procedimiento que cancela las pólizas por perdida total
-- Creado    : 17/05/2013 - Autor: Federico Coronado.
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_par335; 
CREATE PROCEDURE "informix".sp_par335(a_no_poliza char(10),
								   a_user_added char(20), 
								   a_no_motor char(30), 
								   a_no_unidad char(5))
RETURNING   int,
			char(50);
		

DEFINE _prima_bruta         dec(10,2);
define _descripcion			char(50);
define _error				integer;
define _cod_compania        char(3);
define _cod_sucursal        char(3);
define _cod_formapago       char(3);
define _no_endoso           char(5);
define _user_added          char(20);
define _no_documento        char(20);
define _no_requis           char(10);
define _fecha               date;
define _periodo             char(7);
define _no_motor            varchar(30);
DEFINE _null  			    CHAR(1);

define _error_isam		    integer;
define _cantidad            integer;

DEFINE v_saldo              DEC(16,2);
DEFINE v_por_vencer         DEC(16,2);
DEFINE v_exigible           DEC(16,2);
DEFINE v_corriente          DEC(16,2);
DEFINE v_monto_30           DEC(16,2);
DEFINE v_monto_60           DEC(16,2);
DEFINE v_monto_90           DEC(16,2);


SET ISOLATION TO DIRTY READ;
	--SET DEBUG FILE TO "sp_par335.trc";      
	--TRACE ON;                                                                     
begin
on exception set _error, _error_isam, _descripcion
	return _error, _descripcion;
end exception
	let _user_added = a_user_added;
	LET _null = NULL;
	select prima_bruta,
		   cod_compania,
		   cod_sucursal,
		   no_documento,
		   cod_formapag
	  into _prima_bruta,
		   _cod_compania,
		   _cod_sucursal,
		   _no_documento,
		   _cod_formapago
	  from emipomae
	 where no_poliza = a_no_poliza;
	 	-- Verifica que exista emireama y emireaco

	delete from emireaco
	 where no_poliza         = a_no_poliza
	   and porc_partic_suma  = 0
	   and porc_partic_prima = 0;

	call sp_pro159(a_no_poliza) returning _error, _descripcion; --Crea Dist. de Reasguro.

	-- Cantidad de Unidades
	select count(*)
	  into _cantidad
	  from emipouni
	 where no_poliza = a_no_poliza;

	if _cantidad = 1 then
		-- cancelacion de la poliza
		call sp_par278(a_no_poliza, _user_added, _prima_bruta,'006') returning _error, _descripcion, _no_endoso;
			if _error <> 0 then
				return _error, _descripcion;
			end if	
			if _cod_formapago = '003' or _cod_formapago = '005' then
				UPDATE emipomae
				   SET no_tarjeta    = _null,
					   fecha_exp     = _null,
					   cod_banco     = _null,
					   monto_visa    = 0,
					   tipo_tarjeta  = _null,
					   cod_formapag  = '006'
				 WHERE no_poliza     = a_no_poliza;

				UPDATE emipouni
				   SET no_tarjeta    = _null,
					   fecha_exp     = _null,
					   cod_banco     = _null,
					   monto_visa    = 0,
					   tipo_tarjeta  = _null
				 WHERE no_poliza     = a_no_poliza
				   and no_unidad     = a_no_unidad;
			end if
		-- buscando el saldo de la poliza  
		call sp_cob174(_no_documento)RETURNING v_saldo;
		if v_saldo < 0 then
			-- Devolucion de Prima Poliza Cancelada - Perdida Total
			call sp_che141(a_no_poliza,_user_added)RETURNING _error, _descripcion, _no_requis;
				if _error <> 0 then
					return _error, _descripcion;
				end if
		end if
		let _descripcion = 'Actualizacion exitosa';
	else
		-- Eliminacion de Unidades
		select count(*)
		  into _cantidad
		  from emipouni
		 where no_poliza = a_no_poliza
		   and no_unidad = a_no_unidad;

		if _cantidad > 0 then
			select no_motor
			  into _no_motor
			  from emiauto 
			 where no_poliza = a_no_poliza 
			   and no_unidad = a_no_unidad;
			
			if _no_motor = a_no_motor then 
				--Eliminar unidad
				call sp_par280(a_no_poliza, a_no_unidad, _user_added, 0.00) returning _error, _descripcion, _no_endoso;
				if _error <> 0 then
					return _error, _descripcion;
				else 
					let _descripcion = 'Actualizacion exitosa unidad eliminada';
				end if
			else    
				let _descripcion = "No Motor Diferentes";
			end if
		else 
			let _descripcion = "Unidad ya fue Eliminada";
		end if

	end if		
	RETURN 0, _descripcion;
end
end procedure