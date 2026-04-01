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
	return _error, "Error de Base de Datos " || trim(_cuenta_con) || " " || trim(_cuenta_sin);
end exception

{
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
}
{
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
}
{
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
}
{
foreach
 select cuenta
   into _cuenta_con
   from cobasien
  group by cuenta
  order by cuenta

	let _cuenta_sin = sp_sac03(_cuenta_con);
	
	update cobasien
	   set cuenta = _cuenta_sin
	 where cuenta = _cuenta_con;

end foreach
}
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

end

--commit work;

rollback work;

return 0, "Actualizacion Exitosa";

end procedure
