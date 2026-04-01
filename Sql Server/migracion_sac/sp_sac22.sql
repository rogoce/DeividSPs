-- Procedure que Verifica los registros contables de Deivid Vs el Catalogo de SAC

-- Creado    : 25/10/2004 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac22;

create procedure sp_sac22(a_cuenta char(25)) 
returning char(4),
          char(25),
          char(50);

define _cuenta_con	char(25);
define _cuenta_sac	char(25);
define _recibe_mov	char(1);
define _origen		char(4);

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

let _origen = "che1";

{
foreach
 select cuenta
   into _cuenta_con
   from chqchmae
  where cuenta = a_cuenta
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Existe en SAC"
			   with resume;

		continue foreach;

	end if

	if _recibe_mov = "N" then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Recibe Movimiento"
			   with resume;

	end if

end foreach
}

let _origen = "che2";

foreach
 select cuenta
   into _cuenta_con
   from chqchcta
  where cuenta = a_cuenta
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Existe en SAC"
			   with resume;

		continue foreach;

	end if

	if _recibe_mov = "N" then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Recibe Movimiento"
			   with resume;

	end if

end foreach

{
let _origen = "flu";

foreach
 select cuenta
   into _cuenta_con
   from chqflucu
  where cuenta = a_cuenta
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Existe en SAC"
			   with resume;

		continue foreach;

	end if

	if _recibe_mov = "N" then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Recibe Movimiento"
			   with resume;

	end if

end foreach
}

{
let _origen = "end";

foreach
 select cuenta
   into _cuenta_con
   from endasien
  where cuenta = a_cuenta
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Existe en SAC"
			   with resume;

		continue foreach;

	end if

	if _recibe_mov = "N" then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Recibe Movimiento"
			   with resume;

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
  where cuenta = a_cuenta
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Existe en SAC"
			   with resume;

		continue foreach;

	end if

	if _recibe_mov = "N" then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Recibe Movimiento"
			   with resume;

	end if

end foreach
}
{
let _origen = "rec";

foreach
 select cuenta
   into _cuenta_con
   from recasien
  where cuenta = a_cuenta
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Existe en SAC"
			   with resume;

		continue foreach;

	end if

	if _recibe_mov = "N" then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Recibe Movimiento"
			   with resume;

	end if

end foreach
}
{
let _origen = "cob1";

foreach
 select doc_remesa
   into _cuenta_con
   from cobredet
  where actualizado = 1
    and tipo_mov    = "M"
    and doc_remesa  <> "NO DEFINIDO"
    and doc_remesa = a_cuenta
  group by doc_remesa
  order by doc_remesa

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Existe en SAC"
			   with resume;

		continue foreach;

	end if

	if _recibe_mov = "N" then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Recibe Movimiento"
			   with resume;

	end if

end foreach
}
let _origen = "cob2";

foreach
 select cuenta
   into _cuenta_con
   from cobasien
  where cuenta = a_cuenta
  group by cuenta
  order by cuenta

	select cta_cuenta,
	       cta_recibe
	  into _cuenta_sac,
	       _recibe_mov
	  from cglcuentas 
	 where cta_cuenta = _cuenta_con;

	if _cuenta_sac is null then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Existe en SAC"
			   with resume;

		continue foreach;

	end if

	if _recibe_mov = "N" then

		return _origen,
		       _cuenta_con,
			   "Cuenta No Recibe Movimiento"
			   with resume;

	end if

end foreach

end procedure

