-- Procedimiento que valida envio de parmailsend
-- Creado : 02/01/2019 - Autor: Henry Giron 

-- info: Tal y como conversamos vamos a ajustar la fecha de marcar con la fecha de envío del proceso, 
-- con respecto al caso de envió avisos de cancelación por correo electrónico y 
-- que los mismos no tienen fecha colocada, 
-- esto según conversación con Henry, se debió a que los mismos tienen direcciones de correo no válidas. 

Drop procedure sp_cob778_fb4; 
CREATE PROCEDURE "informix".sp_cob778_fb4( 
) RETURNING INTEGER; 

define _error			integer; 
define _no_aviso		char(5);
define _renglon			smallint;
define _fecha_quitar    date;
define _fecha_envio		date;

define _fecha_proceso   date;
define _fecha_marcar	date;
define _secuencia    	integer; 

define _cnt             integer;

on exception set _error  
	return _error; 
end exception

SET ISOLATION TO DIRTY READ;
--set debug file to "sp_cob778.trc"; 
--trace on;
   let _error = 0;			
   let _cnt = 0;
   
foreach
	select t.no_remesa, t.renglon, date(p.fecha_envio), p.secuencia,x.fecha_proceso,x.fecha_marcar
	 into _no_aviso, _renglon, _fecha_envio, _secuencia, _fecha_proceso, _fecha_marcar
	  from parmailcomp t, parmailsend p, avisocanc x
	 where t.mail_secuencia = p.secuencia
	   and t.no_documento[1,2] in ('02','20')
	   and p.cod_tipo = '00010'
	   and p.enviado = 2
         --  and year(p.fecha_envio) = 2019
          -- and month(p.fecha_envio) >= 9
           and t.no_remesa = x.no_aviso
           and t.renglon = x.renglon
           and x.estatus not in ( 'Y','Z')
           and x.reporte_certifica is null
          and x.user_marcar = 'VGARCIA'
           and date(x.fecha_marcar) >= (date(x.fecha_marcar) - 30 units day)
 
		update avisocanc
		   set user_marcar = null,
		       marcar_entrega = '0',
			   fecha_marcar = null,
			   --estatus = 'M',
			   user_imp_log = 'z'
		 where no_aviso = _no_aviso
		   and renglon = _renglon
		   and estatus = 'I';	   

	if _error <> 0 then
		return _error;
	end if
end foreach


RETURN 0;

--trace off;
END PROCEDURE

