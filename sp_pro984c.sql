-- Procedure que guarda la poliza que se envio a imprimir
-- desde el pool de impresion.


-- Creado    : 30/11/2009 - Autor: Armando Moreno
-- Modificado: 15/01/2013 - Autor: Roman Gordon -- se modifica para que actualice la fecha y el usuario que se imprimio la póliza.

-- SIS v.2.0 - DEIVID, S.A.

--drop procedure sp_pro984c;

create procedure sp_pro984c(a_no_poliza char(10),a_usuario char(8),a_documento char(20))
RETURNING smallint;

define _no_poliza2   char(10);	
define _cantidad	 smallint;
define _email        varchar(50);
define _cod_acreedor char(5);
define _status_flag  smallint;
define _cod_leasing  char(10);
define _no_unidad    char(5);
define _leasing      smallint;
define _error_isam	 smallint;
define _error_desc	 char(100);
define _error		 smallint;

begin
on exception set _error,_error_isam,_error_desc
 	return _error; --,_error_desc;
end exception

set isolation to dirty read;


let _no_poliza2 = sp_sis21(a_documento);
delete from emirepobk where estatus in (5,9) and no_documento = a_documento ; 
{
select count(*)
  into _cantidad
  from emireimp
 where no_poliza = _no_poliza2; --a_no_poliza;

if _cantidad <> 0 then
	update emireimp
	   set fecha_impresion	= current,
		   user_imprimio	= a_usuario,
		   user_poliza     = a_usuario,
		   fecha_poliza    = current
	 where no_poliza = _no_poliza2; --a_no_poliza;
else
}
		begin
		on exception in (-239,-268)
		end exception
			insert into emireimp(
			no_poliza,		  
			no_documento,
			fecha_impresion,
			user_imprimio,
			user_poliza,
			fecha_poliza
			)
			VALUES (
			_no_poliza2, ---a_no_poliza,
			a_documento,
			current,
			a_usuario,
			a_usuario,
			current
			);
	    end
--end if
--sd5034 JEPEREZ
let _leasing = 0;
let _cod_acreedor = '';
let _email = ''; 
let _status_flag = 0;

--let _no_poliza2 = sp_sis21(a_documento);

	select leasing
  	  into _leasing
  	  from emipomae
     where no_poliza = _no_poliza2;
	 
	foreach
		select cod_acreedor
		  into _cod_acreedor
		  from emipoacr
		 where no_poliza = _no_poliza2

		select email
		  into _email
		  from emiacre
		 where cod_acreedor = _cod_acreedor;
		 
		 if _email is null or trim(_email) = '' then
		    let _status_flag = 1;
		 end if

		exit foreach;
	end foreach
	
	if _cod_acreedor is null or _cod_acreedor = '' then
	    if _leasing = 1 then
		
			foreach
				select no_unidad
				  into _no_unidad
				  from emipouni
				 where no_poliza = _no_poliza2
			 exit foreach;
			end foreach
			
			select cod_asegurado
			  into _cod_leasing
			  from emipouni
			 where no_poliza = _no_poliza2
               and no_unidad = _no_unidad;
			   
		   select e_mail
			 into _email
			 from cliclien
			where cod_cliente = _cod_leasing;
			
		 if _email is null or trim(_email) = '' then
		    let _status_flag = 1;
		 end if
		 
		else	   
			let _cod_acreedor = '';
			let _status_flag = 0;
		end if
	end if	

		begin
		on exception in (-239,-268)
		end exception
			INSERT INTO emirepobk(
			no_poliza,
			user_added,
			cod_no_renov,
			no_documento,
			renovar,
			no_renovar,
			fecha_selec,
			vigencia_inic,
			vigencia_final,
			saldo,
			cant_reclamos,
			no_factura,
			incurrido,
			pagos,
			porc_depreciacion,
			cod_agente,
			estatus,
			observacion,
			cod_sucursal,
			user_cobros ,
			no_poliza2,
			status_imp,
			no_recibo
			)
			SELECT
			no_poliza,
			user_added,
			cod_no_renov,
			no_documento,
			renovar,
			no_renovar,
			fecha_selec,
			vigencia_inic,
			vigencia_final,
			saldo,
			cant_reclamos,
			no_factura,
			incurrido,
			pagos,
			porc_depreciacion,
			cod_agente,
			estatus,
			observacion,
			cod_sucursal,
			user_cobros ,
			no_poliza2,
			status_imp,
			no_recibo
			FROM emirepo
           where estatus   in (5,9)
	         and no_documento = a_documento ;  ---fecha_selec = a_fecha;
		end


delete from emirepo where estatus   in (5,9) and no_documento = a_documento;
if _status_flag = 0 then
	Update emirepo
	   Set estatus   = 10									
	 where estatus   in (5,9)
	   and no_documento = a_documento  ; --no_poliza in (a_no_poliza,_no_poliza2) ;
end if

end
return 0;
end procedure