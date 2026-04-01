-- Procedimiento que busca si hay registro en recrcmae antes de crear el reclamo

-- Creado    : 07/10/2011 - Autor: Amado Perez  

drop procedure sp_rwf97;

create procedure sp_rwf97(a_no_reclamo char(10)) 
returning varchar(30);

define _e_mail               varchar(30);
define _ajust_interno        char(3);
define _usuario              char(8);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;
set isolation to dirty read;

select ajust_interno
  into _ajust_interno
  from recrcmae
 where no_reclamo = a_no_reclamo;

select usuario
  into _usuario
  from recajust
 where cod_ajustador = _ajust_interno;

foreach
	select e_mail
	  into _e_mail
	  from insuser
	 where usuario = _usuario
	 exit foreach;
end foreach

return _e_mail;

end procedure