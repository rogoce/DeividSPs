-- Procedimiento para corregir los caracteres especiales a motor, chasis y vin
-- 
-- Creado    : 09/05/2011 - Autor: Armando Moreno M.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure amado_motor;

create procedure "informix".amado_motor()
returning integer, 
          char(100),
          char(30);
		  	
define _no_poliza    char(10); 
define _no_endoso	 char(5);
define _no_factura   char(30);
define _resultado    char(30);
define _no_documento char(20);
define _no_unidad    char(5);

define _error_cod	integer;
define _error_isam	integer;
define _error_desc	char(100);
define _no_motor    varchar(30);
define _cnt         integer;
define _no_motor2    varchar(30);


set isolation to dirty read;

BEGIN WORK;

begin 
on exception set _error_cod, _error_isam, _error_desc
    rollback work;
	return _error_cod, _error_desc,_no_motor;
end exception

--SET DEBUG FILE TO "sp_caracter.trc"; 
--trace on;

let _resultado = "";



 let _no_motor = " BHE15EFZS2G00007506";
 --let _no_motor2 = REPLACE(_no_motor," ","");
 --let _no_motor2 = trim(_no_motor2);
 let _no_motor2 = "BHE15EFZS2G00007506";
   	  	
 select count(*)
   into _cnt
   from emivehic
  where no_motor = _no_motor;
 
 if _cnt > 0 then

select * 
  from emivehic
 where no_motor = _no_motor
  into temp prueba;

update prueba 
   set no_motor = _no_motor2;

insert into emivehic
select * from prueba;

drop table prueba;


 {insert into emivehic 
 select trim(no_motor),
		cod_color,
		cod_marca,
		cod_modelo,
		valor_auto,
		valor_original,
		ano_auto,
		no_chasis,
		vin,
		placa,
		placa_taxi,
		nuevo,
		user_added,
		date_added,
		user_changed,
 		date_changed,
		capacidad,
		bloqueado,
		user_bloqueo,
		cod_mala_ref,
		desc_mala_ref,
		cod_version,
		transmision,
		motor,
		tamano,
		tipo,
		rines,
		km,
		frenos,
		air_bag
  from emivehic 
  where no_motor = _no_motor;
}

 update emiauto
    set no_motor = trim(_no_motor2)
  where no_motor = _no_motor;
 
 update endmoaut
    set no_motor = trim(_no_motor2)
  where no_motor = _no_motor;

 update recrcmae
    set no_motor = trim(_no_motor2)
  where no_motor = _no_motor;

 update emiauto
    set no_motor = trim(_no_motor2)
  where no_motor = _no_motor;
 
 update endmoaut
    set no_motor = trim(_no_motor2)
  where no_motor = _no_motor;

 update recrcmae
    set no_motor = trim(_no_motor2)
  where no_motor = _no_motor;
 end if

 delete from emivehic
  where no_motor = _no_motor;

end

COMMIT WORK;

let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";

return _error_cod, _error_desc,"";

end procedure;
