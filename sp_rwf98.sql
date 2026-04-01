-- Procedimiento que busca si hay registro en recrcmae antes de crear el reclamo

-- Creado    : 07/10/2011 - Autor: Amado Perez  

drop procedure sp_rwf98;

create procedure sp_rwf98(a_no_tranrec char(10)) 
returning varchar(20), char(10), varchar(30);

define _e_mail               varchar(30);
define _ajust_interno        char(3);
define _usuario              char(8);

define _no_reclamo           char(10);
define _numrecla			 varchar(20);
define _transaccion			 char(10);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;
set isolation to dirty read;

let _e_mail = "";
let _transaccion = "";
let _numrecla = "";

select no_reclamo, numrecla, transaccion
  into _no_reclamo, _numrecla, _transaccion
  from rectrmae
 where no_tranrec = a_no_tranrec;

select ajust_interno
  into _ajust_interno
  from recrcmae
 where no_reclamo = _no_reclamo;

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

if _e_mail is null then
	let _e_mail = "";
end if

return _numrecla, _transaccion, _e_mail;

end procedure