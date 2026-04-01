--Cerrar reclamos Automovil con estatus Abierto e incurrido bruto cero
--Armando Moreno M./Amado Perez 06/12/2024

drop procedure sp_sis515;
create procedure sp_sis515()
returning	integer,integer,char(50),char(10);
			
define _error_desc			varchar(50);
define s_tipopro			char(3);
define _no_reclamo          char(10);
define _incurrido_bruto   	dec(16,2);
define _error_isam			integer;
define _error,_estimado		integer;
define _no_tramite          char(10);
define _incidente           integer;
define _user_added			char(8);
define _reserva				dec(16,2);


SET ISOLATION TO DIRTY READ;
begin
on exception set _error, _error_isam, _error_desc
   return _error,_error_isam,_error_desc,_no_reclamo;
end exception

--set debug file to "tarifa_salud_tcn.trc";
--trace on;
foreach with hold
	select no_reclamo,
	       no_tramite,
		   incidente,
		   user_added
	  into _no_reclamo,
	       _no_tramite,
		   _incidente,
		   _user_added
	  from recrcmae
	 where actualizado = 1
	   and numrecla[1,2] in('02','20','23')
	   and estatus_reclamo = 'A'
	   
	call sp_rec33(_no_reclamo) returning _estimado,_estimado,_estimado,_estimado,_estimado,_estimado,_estimado,_estimado,_estimado,_estimado,_estimado,_estimado,_estimado,_incurrido_bruto,_estimado;
	
	let _error = 0;
	let _error_desc = null;
	 
	if _incurrido_bruto = 0 then
		-- Verificando la reserva
		select sum(variacion)
		  into _reserva
		  from rectrmae
		 where no_reclamo   = _no_reclamo
		   and actualizado  = 1;

		if _reserva is null then
			let _reserva = 0.00;
		end if
	
	    call sp_rec158c(_no_reclamo, _reserva) returning _error, _error_desc;
		
		-- Inserta info en wfcieres para abortar los incidentes del mapa de control reclamos poliza.	Armando 19/10/2010
		insert into wfcieres (no_reclamo,no_tramite,incidente,user_added)
		values(_no_reclamo,_no_tramite,_incidente,_user_added);
	
		return _error,0,_error_desc,_no_reclamo with resume;
	end if
end foreach
end
end procedure;