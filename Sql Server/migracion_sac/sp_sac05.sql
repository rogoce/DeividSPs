-- Procedure que Reemplaza las cuentas con guiones con cuentas sin guiones de todas las
-- tablas de registros contables

-- Creado    : 21/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac05;

create procedure sp_sac05() 
returning smallint,
          char(100);

define _cuenta_con	char(25);
define _cuenta_sin	char(25);
define _nombre		char(100);

define _error		smallint;
define _cantidad	smallint;
define _descripcion	char(100);

-- Tablas a las que hay que verificar la estructura de cuentas

-- chqchcta
-- chqchmae
-- chqflucu
-- cobasien
-- endasien
-- parintcu
-- reacocob
-- recasien
-- cobredet 

set isolation to dirty read;

begin work;

begin 
on exception set _error
	rollback work;
	return _error, trim(_descripcion) || " " || trim(_cuenta_con) || " " || trim(_cuenta_sin);
end exception

let _descripcion = "Procesando chqchcta ";

foreach
 select cuenta
   into _cuenta_con
   from chqchcta
  group by cuenta
  order by cuenta

	let _cuenta_sin = sp_sac03(_cuenta_con);
	
	update chqchcta
	   set cuenta = _cuenta_sin
	 where cuenta = _cuenta_con;

end foreach

{
let _descripcion = "Procesando chqchmae ";

foreach
 select cuenta
   into _cuenta_con
   from chqchmae
  group by cuenta
  order by cuenta

	let _cuenta_sin = sp_sac03(_cuenta_con);
	
	update chqchmae
	   set cuenta = _cuenta_sin
	 where cuenta = _cuenta_con;

end foreach
let _descripcion = "Procesando chqflucu ";

foreach
 select cuenta
   into _cuenta_con
   from chqflucu
  group by cuenta
  order by cuenta

	let _cuenta_sin = sp_sac03(_cuenta_con);
	
	update chqflucu
	   set cuenta = _cuenta_sin
	 where cuenta = _cuenta_con;

end foreach

let _descripcion = "Procesando endasien ";

foreach
 select cuenta
   into _cuenta_con
   from endasien
  group by cuenta
  order by cuenta

	let _cuenta_sin = sp_sac03(_cuenta_con);
	
	update endasien
	   set cuenta = _cuenta_sin
	 where cuenta = _cuenta_con;

end foreach

let _descripcion = "Procesando parintcu ";

foreach
 select cuenta
   into _cuenta_con
   from parintcu
  group by cuenta
  order by cuenta

	let _cuenta_sin = sp_sac03(_cuenta_con);
	
	update parintcu
	   set cuenta = _cuenta_sin
	 where cuenta = _cuenta_con;

end foreach

let _descripcion = "Procesando reacocob ";

foreach
 select cuenta
   into _cuenta_con
   from reacocob
  group by cuenta
  order by cuenta

	let _cuenta_sin = sp_sac03(_cuenta_con);
	
	update reacocob
	   set cuenta = _cuenta_sin
	 where cuenta = _cuenta_con;

end foreach

let _descripcion = "Procesando recasien ";

foreach
 select cuenta
   into _cuenta_con
   from recasien
  group by cuenta
  order by cuenta

	let _cuenta_sin = sp_sac03(_cuenta_con);
	
	update recasien
	   set cuenta = _cuenta_sin
	 where cuenta = _cuenta_con;

end foreach

let _descripcion = "Procesando cobredet ";

foreach
 select doc_remesa
   into _cuenta_con
   from cobredet
  where actualizado = 1
    and tipo_mov    = "M"
    and doc_remesa  <> "NO DEFINIDO"
  group by doc_remesa
  order by doc_remesa

	let _cuenta_sin = sp_sac03(_cuenta_con);
	
	update cobredet
	   set doc_remesa = _cuenta_sin
	 where doc_remesa = _cuenta_con;

end foreach
}

end

commit work;

--rollback work;

return 0, "Actualizacion Exitosa";

end procedure