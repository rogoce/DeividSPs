-- Procedimiento para adicion de cancelaciones sin email
-- Creado    : 14/02/2012 - Autor: Henry Giron
-- execute procedure hg_data6("13/02/2012")

DROP PROCEDURE hg_data6;
CREATE PROCEDURE "informix".hg_data6(a_fecha  date)
RETURNING smallint, char(100);	

define _secuencia		integer;
define _secuencia_comp	integer;
Define _flag			smallint;
Define _comp_electr		smallint;
Define _cant_renglon	smallint;
define _cant_err		smallint;
define _fecha_hoy		date;
Define _cod_chequera	CHAR(3);
define _periodo			char(8);
define _cod_cliente		char(10);
define _nom_cliente		char(50);
define _email			char(50);
define _error			smallint;
define _mensaje			char(100);
define _no_aviso 		char(15);
define _renglon         integer;

SET ISOLATION TO DIRTY READ;
set debug file to "hg_data6.trc"; 
trace on; 
let _error = 0;
let _mensaje = 'Actualizacion Satisfactoria.';

begin
on exception set _error
	return _error, "Error de Base de Datos";
end exception


foreach
    select no_aviso,renglon
	  into _no_aviso,_renglon 
      from avisocanc 
     where estatus in ('Z')
       and email_cli is null
	   and fecha_cancela = a_fecha	  

	   let _flag = 0;

    select count(*) 
	  into _flag
      from parmailsend 
     where enviado = 0 
       and cod_tipo = '00013' 
       and secuencia in (select distinct mail_secuencia from parmailcomp 
       where no_remesa||"-"||renglon in (select no_aviso||"-"||renglon from avisocanc where estatus = 'Z' and no_aviso = _no_aviso and renglon = _renglon
   and email_cli is null)) ;

       if _flag = 0 then

	       let _email = "";
		  call sp_par316("00013",_email,_no_aviso,_renglon) returning _error,_mensaje ; 

			if _error <> 0 then
				return _error,_mensaje WITH RESUME;
			end if

	  end if

end foreach;


foreach
    select no_aviso,renglon
	  into _no_aviso,_renglon 
      from avisocanc 
     where estatus = 'Z' 
       and email_cli is null
	   and fecha_cancela = a_fecha	  

	   let _flag = 0;
    select count(*) 
	  into _flag
      from parmailsend 
     where enviado = 0 
       and cod_tipo = '00014' 
       and secuencia in (select distinct mail_secuencia from parmailcomp 
       where no_remesa||"-"||renglon in (select no_aviso||"-"||renglon from avisocanc where estatus = 'Z' and no_aviso = _no_aviso and renglon = _renglon
   and email_cli is null)) ;

       if _flag = 0 then

	       let _email = "";
		  call sp_par316("00014",_email,_no_aviso,_renglon) returning _error,_mensaje; 

			if _error <> 0 then
				return _error,_mensaje WITH RESUME;
			end if

	  end if

end foreach;
end
return _error,_mensaje WITH RESUME;

End Procedure	  