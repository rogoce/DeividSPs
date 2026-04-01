-- Procedimiento Para Actualizar los Datos de la tabla de cliclien desde cotizacion
-- Creado    : 25/03/2003 - Autor: Amado Perez
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_atc18a;
create procedure "informix".sp_atc18a(a_cliente 			char(10), 
                                     a_nombre 			varchar(100), 
                                     a_telefono1 		char(10),
                                     a_telefono2 		char(10), 
                                     a_celular 			char(10), 
                                     a_e_mail 			varchar(50), 
									 a_e_mail2 			varchar(50), 
                                     a_direccion_1 		varchar(50), 
                                     a_direccion_2 		varchar(50),
                                     a_user_added       char(8))
returning integer,
          char(10);

define _error		    integer;
define _error_isam		integer;
define _error_desc		char(50);

define _renglon         integer;

SET LOCK MODE TO WAIT;
--SET DEBUG FILE TO "sp_atc18a.trc";
--TRACE ON;
BEGIN

ON EXCEPTION SET _error, _error_isam, _error_desc
  RETURN _error, _error_desc;
END EXCEPTION


insert into cliultact (
        cod_cliente, 
	    nombre,
	    direccion_1,
	    direccion_2,
	    telefono1,
	    telefono2,
	    date_added,
	    user_added,
	    email,
	    celular,
		email2)
values( a_cliente,
        trim(a_nombre),
		a_direccion_1,
		a_direccion_2,
		a_telefono1,
		a_telefono2,
		date(current),
		a_user_added,
		a_e_mail,
		a_celular,
		a_e_mail2
		);
		
		if a_e_mail2 is not null then
        Select count(renglon)
		  into _renglon
		  from climail
		 where cod_cliente = a_cliente 
		   and lower(email)  = lower(a_e_mail2) ;
		   
		   if _renglon = 0 then		 
				Select max(renglon)
				  into _renglon
				  from climail
				 where cod_cliente = a_cliente;
				 
				IF _renglon IS NULL THEN
					let _renglon = 1;			
				else
					let _renglon = _renglon + 1;						
				END IF	
				
				Insert Into climail(
				cod_cliente,
				renglon,
				email)
				values(
				a_cliente,
				_renglon,
				a_e_mail2);
		 end if
		end if		 
--TRACE OFF;
END
return 0,
       "Actualizacion Exitosa";

end procedure;
