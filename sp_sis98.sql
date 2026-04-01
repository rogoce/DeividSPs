-- Creacion de las cuentas para reaseguro por pagar y reaseguro por cobrar

-- Creado    : 24/07/2007 - Autor: Demetrio Hurtado Almanza 
--
-- SIS v.2.0 - DEIVID, S.A.
  
drop procedure sp_sis98;

create procedure sp_sis98()
returning char(25),
          char(50);

{
returning char(3),
          char(3),
          char(3),
          char(25),
          char(50);
}

define _cod_ramo	char(3);
define _cod_subramo	char(3);
define _cod_tipo	char(3);
define _enlace_cat	char(4);
define _enlace_cat2 char(2);
define _cantidad	smallint;

define _cuenta		char(25);
define _nombre_cta	char(50);
define _cod_origen	char(3);
define _nombre_orig	char(50);
define _nombre_ramo	char(50);
 
let _cod_origen = "002";

select nombre
  into _nombre_orig
  from parorig
 where cod_origen = _cod_origen;

create temp table tmp_cuenta (
cuenta	char(25),
nombre	char(50),
primary key (cuenta)
) with no log;

foreach
 select cod_ramo,
        cod_tiporamo,
		enlace_cat
   into _cod_ramo,
        _cod_tipo,
		_enlace_cat
   from prdramo
  order by cod_tiporamo, cod_ramo

	let _nombre_ramo = "";

	foreach
	 select cod_subramo,
	        enlace_cat
	   into _cod_subramo,
	        _enlace_cat2
	   from prdsubra
	  where cod_ramo = _cod_ramo
	  order by cod_subramo

		let _nombre_cta  = "REAS. X PAGAR " || " - " || trim(_nombre_orig);
		let _nombre_ramo = "";

		if _cod_tipo = "003" then
			let _enlace_cat = _enlace_cat2;
		end if

		if _cod_tipo = "001" then

			if _enlace_cat = "01" then
				let _nombre_ramo = "VIDA - IND. TRAD.";
			elif _enlace_cat = "02" then
				let _nombre_ramo = "VIDA - COLEC. VIDA";
			elif _enlace_cat = "03" then
				let _nombre_ramo = "VIDA - ACC. PERS. IND.";
			elif _enlace_cat = "04" then
				let _nombre_ramo = "VIDA - HOSP. IND.";
			end if

		elif _cod_tipo = "002" then

			if _enlace_cat = "01" then
				let _nombre_ramo = "INCENDIO";
			elif _enlace_cat = "02" then
				let _nombre_ramo = "TRANSPORTE";
			elif _enlace_cat = "03" then
				let _nombre_ramo = "AUTO";
			elif _enlace_cat = "04" then
				let _nombre_ramo = "CASCO MARITIMO";
			elif _enlace_cat = "05" then
				let _nombre_ramo = "CASCO AEREO";
			elif _enlace_cat = "06" then
				let _nombre_ramo = "RESP. CIVIL";
			elif _enlace_cat = "07" then
				let _nombre_ramo = "ROBO";
			elif _enlace_cat = "0802" then
				let _nombre_ramo = "RIES. VAR. - RIES. DIV.";
			elif _enlace_cat = "0804" then
				let _nombre_ramo = "RIES. VAR. - RAM. TEC.";
			end if

		elif _cod_tipo = "003" then

			if _enlace_cat = "01" then
				let _nombre_ramo = "FIDELIDAD";
			elif _enlace_cat = "02" then
				let _nombre_ramo = "CONSTRUCCION";
			elif _enlace_cat = "03" then
				let _nombre_ramo = "BANCARIAS";
			elif _enlace_cat = "04" then
				let _nombre_ramo = "OTRAS FIANZAS";
			end if

		end if
		
		let _nombre_cta = trim(_nombre_cta) || " - " || trim(_nombre_ramo);
		let _cuenta     = sp_sis15("PPRXP", "05", _cod_origen, _cod_ramo, _cod_subramo);   

		select count(*)
		  into _cantidad
		  from tmp_cuenta
		 where cuenta = _cuenta;

		if _cantidad = 0 then
			insert into tmp_cuenta
			values (_cuenta, _nombre_cta);
		end if

{
		return _cod_tipo,
			   _cod_ramo,
		       _cod_subramo,
			   _cuenta,
			   _nombre_cta
			   with resume;
}

	end foreach

end foreach

foreach
 select cuenta,
        nombre
   into _cuenta,
        _nombre_cta
   from tmp_cuenta
  order by cuenta

	delete from	cglcuentas
	 where cta_cuenta = _cuenta[1,11];

	delete from	cglcuentas
	 where cta_cuenta = _cuenta[1,9];

	select count(*)
	  into _cantidad
	  from cglcuentas
	 where cta_cuenta = _cuenta[1,7];

	if _cantidad = 0 then

		insert into cglcuentas
		values (_cuenta[1,7], _nombre_cta, _nombre_cta, "2", "00", 3, "C", "N", "S", "S", "N", "N", "00");

	end if

	select count(*)
	  into _cantidad
	  from cglcuentas
	 where cta_cuenta = _cuenta[1,9];

	if _cantidad = 0 then

		insert into cglcuentas
		values (_cuenta[1,9], _nombre_cta, _nombre_cta, "2", "00", 4, "C", "S", "S", "S", "S", "N", "00");

	end if

	select count(*)
	  into _cantidad
	  from cglcuentas
	 where cta_cuenta = _cuenta[1,11];

	if _cantidad = 0 then

		insert into cglcuentas
		values (_cuenta[1,11], _nombre_cta, _nombre_cta, "2", "00", 5, "C", "S", "S", "S", "S", "N", "00");

	end if

	select count(*)
	  into _cantidad
	  from cglcuentas
	 where cta_cuenta = _cuenta[1,11];

	if _cantidad <> 0 then

		if _cuenta[1,9] <> _cuenta[1,11] then

			update cglcuentas
			   set cta_recibe   = "N",
			       cta_auxiliar = "N"
			 where cta_cuenta = _cuenta[1,9];

		end if

	end if

	return _cuenta,
		   _nombre_cta
		   with resume;

end foreach

drop table tmp_cuenta;
        
end procedure
