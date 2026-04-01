-- Procedure que Verifica los registros contables de Deivid Vs el Catalogo de SAC

-- Creado    : 25/10/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac21;

create procedure sp_sac21() 
returning char(3),
          char(25),
          char(50),
          char(50);

define _cuenta_con	char(25);
define _cuenta_sac	char(25);
define _recibe_mov	char(1);
define _origen		char(3);

define _nombre		char(100);

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

create temp table tmp_sac(
cuenta	char(25),
tipo	char(1)
) with no log;

--{
let _origen = "che";

foreach
 select c.cuenta
   into _cuenta_con
   from chqchcta c, chqchmae m
  where c.no_requis = m.no_requis
	and m.fecha_impresion >= "01/10/2004"
  group by c.cuenta
  order by c.cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		insert into tmp_sac
		values (_cuenta_con, 1);

		continue foreach;

	end if

	if _recibe_mov = "N" then

		insert into tmp_sac
		values (_cuenta_con, 2);

	end if

end foreach
--}
{
let _origen = "che";

foreach
 select cuenta
   into _cuenta_con
   from chqchmae
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		insert into tmp_sac
		values (_cuenta_con, 1);

		continue foreach;

	end if

	if _recibe_mov = "N" then

		insert into tmp_sac
		values (_cuenta_con, 2);

	end if

end foreach
}
{
let _origen = "flu";

foreach
 select cuenta
   into _cuenta_con
   from chqflucu
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		insert into tmp_sac
		values (_cuenta_con, 1);

		continue foreach;

	end if

	if _recibe_mov = "N" then

		insert into tmp_sac
		values (_cuenta_con, 2);

	end if

end foreach
}
{
let _origen = "end";

foreach
 select cuenta
   into _cuenta_con
   from endasien
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		insert into tmp_sac
		values (_cuenta_con, 1);

		continue foreach;

	end if

	if _recibe_mov = "N" then

		insert into tmp_sac
		values (_cuenta_con, 2);

	end if

end foreach
}
{
let _origen = "par";

foreach
 select cuenta
   into _cuenta_con
   from parintcu
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		insert into tmp_sac
		values (_cuenta_con, 1);

		continue foreach;

	end if

	if _recibe_mov = "N" then

		insert into tmp_sac
		values (_cuenta_con, 2);

	end if

end foreach
}
{
let _origen = "rea";

foreach
 select cuenta
   into _cuenta_con
   from reacocob
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		insert into tmp_sac
		values (_cuenta_con, 1);

		continue foreach;

	end if

	if _recibe_mov = "N" then

		insert into tmp_sac
		values (_cuenta_con, 2);

	end if

end foreach
}
{
let _origen = "rec";

foreach
 select cuenta
   into _cuenta_con
   from recasien
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		insert into tmp_sac
		values (_cuenta_con, 1);

		continue foreach;

	end if

	if _recibe_mov = "N" then

		insert into tmp_sac
		values (_cuenta_con, 2);

	end if

end foreach
}
{
let _origen = "cob";

foreach
 select doc_remesa
   into _cuenta_con
   from cobredet
  where actualizado = 1
    and tipo_mov    = "M"
    and doc_remesa  <> "NO DEFINIDO"
  group by doc_remesa
  order by doc_remesa

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		insert into tmp_sac
		values (_cuenta_con, 1);

		continue foreach;

	end if

	if _recibe_mov = "N" then

		insert into tmp_sac
		values (_cuenta_con, 2);

	end if

end foreach
}
{
foreach
 select cuenta
   into _cuenta_con
   from cobasien c, cobremae m
  where c.no_remesa = m.no_remesa
	and m.periodo   >= "2004-10"
  group by c.cuenta
  order by c.cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		insert into tmp_sac
		values (_cuenta_con, 1);

		continue foreach;

	end if

	if _recibe_mov = "N" then

		insert into tmp_sac
		values (_cuenta_con, 2);

	end if

end foreach
}

foreach
 select cuenta,
        tipo
   into _cuenta_con,
        _origen
   from tmp_sac
--  where cuenta[1,3] = "131"	
  group by 1, 2

	select cta_nombre
	  into _nombre
	  from cglcuentas
	 where cta_cuenta = _cuenta_con;

	if _origen = "1" then		

		return _origen,
		       _cuenta_con,
			   _nombre,
			   "Cuenta No Existe en SAC"
			   with resume;

	else

		return _origen,
		       _cuenta_con,
			   _nombre,
			   "Cuenta No Recibe Movimiento"
			   with resume;
	end if

end foreach

drop table tmp_sac;

end procedure

