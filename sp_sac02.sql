-- Procedure que Crea las Cuentas del Catalogo de Cuentas sin el guion

-- Creado    : 10/09/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac02;

create procedure sp_sac02() 
returning smallint,
          char(50);

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

begin work;

begin 
on exception set _error
	rollback work;
	return _error, "Error de Base de Datos " || _cuenta_sin;
end exception

foreach
 select cuenta,
		nombre
   into _cuenta_con,
        _nombre
   from cglctas
  where length(cuenta) > 3
    and cuenta[4,4] = "-"
--	and cuenta      = "111-01"

	let _cuenta_sin = sp_sac03(_cuenta_con);
	
	select count(*)
	  into _cantidad
	  from cglctas
	 where cuenta = _cuenta_sin;

	if _cantidad = 0 then

		insert into cglctas
		values(
		_cuenta_sin,
		"T",
		_nombre
		);

	end if

{
	return _cuenta_con,
	       _cuenta_sin,
		   _nombre
		   with resume;
}

end foreach

end

commit work;

--rollback work;

return 0, "Actualizacion Exitosa";

end procedure