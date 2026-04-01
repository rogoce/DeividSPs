-- Bloqueo de los motores por pérdida total
-- 
-- Creado    : 04/08/2023 - Autor: Amado Perez Mendoza 
-- Modificado: 04/08/2023 - Autor: Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rec347;
create procedure sp_rec347(a_no_motor char(30), a_usuario CHAR(8), a_tercero SMALLINT DEFAULT 0, a_no_reclamo CHAR(10) default null, a_cod_tercero char(10) default null)
returning integer, char(50);

define _placa		      char(10);
define _vin		          char(30);
define _no_chasis         char(30);
define _no_motor          char(30);
define _cod_marca		  char(5);
define _cod_modelo        char(5);
define _ano_auto          smallint;
define _cnt               smallint;

define _error			  integer;
define _error_isam		  integer;
define _error_desc		  char(50);

--	set debug file to "sp_rec347.trc";
--	trace on;	


set isolation to dirty read;

if a_no_motor is null or trim(a_no_motor) = "" then
	return 1, "Motor en blanco o nulo";
end if

begin
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _placa = null;
let _vin = null;
let _no_chasis = null;
let _cod_marca = null;
let _cod_modelo = null;
let _ano_auto = null;

if a_tercero = 0 then
	select placa,
		   vin,
		   no_chasis
	  into _placa,
		   _vin,
		   _no_chasis
	  from emivehic
	 where no_motor = a_no_motor; 
else
	select count(*)
	  into _cnt
	  from emivehic
	 where no_motor = a_no_motor;
	 
	select cod_marca,
	       cod_modelo,
	       placa,
		   ano_auto,
		   no_chasis
	  into _cod_marca,
	       _cod_modelo,
		   _placa,
		   _ano_auto,
		   _no_chasis
	  from recterce
	 where no_reclamo = a_no_reclamo
	   and cod_tercero = a_cod_tercero; 
	   
	insert into emivehic (
	        no_motor,
		    cod_marca,
		    cod_modelo,
		    placa,
		    ano_auto,
		    no_chasis,
		    tercero,
			cod_color,
			user_added)
	values (a_no_motor,
            _cod_marca,
            _cod_modelo,
            _placa,
			_ano_auto,
			_no_chasis,
			1,
			'001',
			a_usuario);
	 
end if

update emivehic
   set bloqueado = 1,
       cod_mala_ref = '005'
 where no_motor = a_no_motor;

insert into emivebit (
    no_motor,
	bloqueado,
	user_bloqueo,
	cod_mala_ref,
	fecha_bloqueo)
values (
    a_no_motor,
    1,
    a_usuario,
    '005',
    current);

if _placa is not null and trim(_placa) <> "" then
	foreach
		select no_motor
		  into _no_motor
		  from emivehic 
		 where placa = _placa 
		   and no_motor <> a_no_motor
		   
		update emivehic
		   set bloqueado = 1,
			   cod_mala_ref = '005'
		 where no_motor = _no_motor;	

		insert into emivebit (
			no_motor,
			bloqueado,
			user_bloqueo,
			cod_mala_ref,
			fecha_bloqueo)
		values (
			_no_motor,
			1,
			a_usuario,
			'005',
			current);		 
	end foreach
end if

if _vin is not null and trim(_vin) <> "" then
	foreach
		select no_motor
		  into _no_motor
		  from emivehic 
		 where vin = _vin 
		   and no_motor <> a_no_motor
		   
		update emivehic
		   set bloqueado = 1,
			   cod_mala_ref = '005'
		 where no_motor = _no_motor;	

		insert into emivebit (
			no_motor,
			bloqueado,
			user_bloqueo,
			cod_mala_ref,
			fecha_bloqueo)
		values (
			_no_motor,
			1,
			a_usuario,
			'005',
			current);		 
	end foreach
end if

if _no_chasis is not null and trim(_no_chasis) <> "" then
	foreach
		select no_motor
		  into _no_motor
		  from emivehic 
		 where no_chasis = _no_chasis 
		   and no_motor <> a_no_motor
		   
		update emivehic
		   set bloqueado = 1,
			   cod_mala_ref = '005'
		 where no_motor = _no_motor;	

		insert into emivebit (
			no_motor,
			bloqueado,
			user_bloqueo,
			cod_mala_ref,
			fecha_bloqueo)
		values (
			_no_motor,
			1,
			a_usuario,
			'005',
			current);		 
	end foreach
end if
end
return 0, "Bloqueo Exitoso";		
end procedure