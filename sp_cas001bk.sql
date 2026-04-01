-- Creacion Inicial de Datos para los Cobros Automaticos
-- 
-- Creado    : 07/04/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 07/04/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas001;

create procedure sp_cas001(a_cod_cliente char(10))

define _cod_cliente		char(10);
define _no_documento	char(20);
define _no_poliza		char(10);
define _vigencia_final	date;
define _cantidad        smallint;
define _fecha			datetime year to fraction(5);
define _cant_cliente	smallint;

define _code_pais		char(3);
define _code_provincia	char(2);
define _code_ciudad		char(2);
define _code_distrito	char(2);
define _code_correg		char(5);

define _direccion1		char(50);
define _direccion2		char(50);
define _direccion_cob	char(100);
define _telefono1		char(10);
define _telefono2		char(10);
define _telefono3		char(10);
define _fax				char(10);
define _apartado		char(20);
define _e_mail			char(50);

define _procesado		smallint;

set isolation to dirty read;

let _fecha = current year to fraction(5);

select code_correg
  into _code_correg
  from cliclien
 where cod_cliente = a_cod_cliente;

if _code_correg = "01" then

	foreach
	 select	cod_cliente
	   into	_cod_cliente
	   from	cascliente
	  where cod_cliente = a_cod_cliente

		let _cant_cliente = 0;
		let _procesado    = 0;

		foreach
		 select no_documento
		   into _no_documento
		   from caspoliza
		  where cod_cliente = _cod_cliente

			if _procesado = 1 then
				exit foreach;
			end if

			 select	count(*)
			   into	_cantidad
			   from	emipomae p, emidirco d
			  where	p.no_poliza    = d.no_poliza
			    and p.no_documento = _no_documento;

			if _cantidad is null then
				let _cantidad = 0;
			end if

			if _cantidad <> 0 then
						
				foreach
				 select no_poliza,
				        vigencia_final
				   into _no_poliza,
				        _vigencia_final
				   from emipomae
				  where no_documento = _no_documento
				    and actualizado  = 1
				  order by vigencia_final desc, no_poliza desc

					select code_pais,
						   code_provincia,
						   code_ciudad,
						   code_distrito,
						   code_correg,
						   direccion_1,
						   direccion_2,
						   telefono1,
						   telefono2,
						   telefono3,
						   fax,
						   apartado,
						   e_mail
					  into _code_pais,
						   _code_provincia,
						   _code_ciudad,
						   _code_distrito,
						   _code_correg,
						   _direccion1,
						   _direccion2,
						   _telefono1,
						   _telefono2,
						   _telefono3,
						   _fax,
						   _apartado,
						   _e_mail
					  from emidirco
					 where no_poliza = _no_poliza;

					if _direccion2 is null then
						let _direccion2 = "";
					end if

					if _code_correg is not null then

						if _procesado = 0 then

							update cliclien
							   set code_pais      = _code_pais,
							       code_provincia = _code_provincia,
								   code_ciudad    = _code_ciudad,
								   code_distrito  = _code_distrito,
								   code_correg    = _code_correg,
								   direccion_cob  = trim(_direccion1) || " " || trim(_direccion2)
						     where cod_cliente    = _cod_cliente;

						end if

						let _procesado = 1;

					end if

	--{
					if _code_pais      is null and
					   _code_provincia is null and
					   _code_ciudad    is null and
					   _code_distrito  is null and
					   _code_correg    is null and
					   _direccion1     is null and
					   _direccion2     is null and
					   _telefono1      is null and
					   _telefono2      is null and
					   _telefono3      is null and
					   _fax            is null and
					   _apartado       is null and
					   _e_mail         is null then

					   	continue foreach;

					end if

					LET _fecha = _fecha + 1 UNITS SECOND;

					insert into cobcacam(
					cod_cliente,
					fecha,
					code_pais,
					code_provincia,
					code_ciudad,
					code_distrito,
					code_correg,
					apartado,
					telefono1,
					telefono2,
					e_mail,
					fax,
					celular,
					contacto,
					telefono3,
					direccion_cob
					)
					values(
					_cod_cliente,
					_fecha,
					_code_pais,
					_code_provincia,
					_code_ciudad,
					_code_distrito,
					_code_correg,
					_apartado,
					_telefono1,
					_telefono2,
					_e_mail,
					_fax,
					null,
					null,
					_telefono3,
					trim(_direccion1) || " " || trim(_direccion2)
					);
	--}

					if _procesado = 1 then
						exit foreach;
					end if

				end foreach

			end if
			
		end foreach

		if _procesado = 0 then

			let	_code_pais		= "001";
	        let _code_provincia	= "01";
	        let _code_ciudad	= "01";
	        let _code_distrito	= "01";
	        let _code_correg	= "01";
			
			update cliclien
			   set code_pais      = _code_pais,
			       code_provincia = _code_provincia,
				   code_ciudad    = _code_ciudad,
				   code_distrito  = _code_distrito,
				   code_correg    = _code_correg
		     where cod_cliente    = _cod_cliente;

		end if

	end foreach

end if

select direccion_1,
       direccion_2,
	   direccion_cob
  into _direccion1,
       _direccion2,
	   _direccion_cob
  from cliclien
 where cod_cliente = a_cod_cliente;

if _direccion_cob is null or
   _direccion_cob = ""    then

	if _direccion2 is null then
		let _direccion2 = "";
	end if

	update cliclien
	   set direccion_cob  = trim(_direccion1) || " " || trim(_direccion2)
	 where cod_cliente    = a_cod_cliente;

end if

end procedure
