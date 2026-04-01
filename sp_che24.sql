-- Porcedure que Elimina las Requisiciones de Cheques no Usadas

drop procedure sp_che24;

create procedure "informix".sp_che24(a_no_requis char(10))
returning integer,
          char(50);

define _autorizado	smallint;
define _error		integer;
define _descripcion char(50);

set isolation to dirty read;

begin work;

begin
on exception set _error
	rollback work;
	return _error,
           _descripcion;
end exception

select autorizado
  into _autorizado
  from chqchmae
 where no_requis = a_no_requis;

if _autorizado = 1 then
	rollback work;
	return 1,
	       "Esta requisicion Esta Autorizada y no Puede ser Eliminada";
end if

let _descripcion = "Actualizando rectrmae ...";
update rectrmae
   set no_requis = null,
       pagado    = 0
 where no_requis = a_no_requis;

let _descripcion = "Borrando chqchagt ...";
delete from chqchagt where no_requis = a_no_requis;

let _descripcion = "Borrando chqchcta ...";
delete from chqchcta where no_requis = a_no_requis;

let _descripcion = "Borrando chqchdes ...";
delete from chqchdes where no_requis = a_no_requis;

let _descripcion = "Borrando chqchpoa ...";
delete from chqchpoa where no_requis = a_no_requis;

let _descripcion = "Borrando chqchpol ...";
delete from chqchpol where no_requis = a_no_requis;

let _descripcion = "Borrando chqchrec ...";
delete from chqchrec where no_requis = a_no_requis;

let _descripcion = "Borrando chqchmae ...";
delete from chqchmae where no_requis = a_no_requis;

commit work;

return 0,
       "Actualizacion Exitosa";
end


end procedure