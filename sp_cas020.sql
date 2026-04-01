-- Arreglar Numeros de Telefono de los Clientes
--
-- Creado    : 24/05/2003 - Autor: Demetrio Hurtado Almanza
-- Modificado: 24/05/2003 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cas020;

create procedure "informix".sp_cas020()
returning char(10),
          char(10),
          char(10),
          char(10),
          char(10),
          char(10);

define _cod_cliente	char(10);
define _telefono1	char(10);
define _telefono2	char(10);
define _telefono3	char(10);
define _celular 	char(10);
define _fax			char(10);

define _retornar	smallint;

define _telefono1_t	char(10);
define _telefono2_t	char(10);
define _telefono3_t	char(10);
define _celular_t 	char(10);
define _fax_t		char(10);

--set debug file to "sp_cas020.trc";
--trace on;

foreach
 select cod_cliente,
 		telefono1,
        telefono2,
		telefono3,
		celular,
		fax
   into _cod_cliente,
 		_telefono1,
        _telefono2,
		_telefono3,
		_celular,
		_fax
   from cliclien
--  where cod_cliente = "05112"
  order by 1

	let _retornar = 0;
		
   	let _telefono1_t = _telefono1;
   	let _telefono2_t = _telefono2;
   	let _telefono3_t = _telefono3;
   	let _celular_t   = _celular;
   	let _fax_t       = _fax;

-- Arreglar los Numeros que comenzaban con 507

{	

	if _telefono1[1,3] = "507"  and
	   _telefono1 is not null then
	   	let _telefono1_t = _telefono1[4,10];
		let _retornar    = 1;
	end if

	if _telefono2[1,3] = "507"  and
	   _telefono2 is not null then
	   	let _telefono2_t = _telefono2[4,10];
		let _retornar    = 1;
	end if

	if _telefono3[1,3] = "507"  and
	   _telefono3 is not null then
	   	let _telefono3_t = _telefono3[4,10];
		let _retornar    = 1;
	end if

	if _celular[1,3] = "507"  and
	   _celular is not null then
	   	let _celular_t = _celular[4,10];
		let _retornar    = 1;
	end if

	if _fax[1,3] = "507"  and
	   _fax is not null then
	   	let _fax_t = _fax[4,10];
		let _retornar    = 1;
	end if

	if _retornar = 1 then

		update cliclien
		   set telefono1   = _telefono1_t,
               telefono2   = _telefono2_t,
		       telefono3   = _telefono3_t,
		       celular     = _celular_t,
		       fax		   = _fax_t
		 where cod_cliente = _cod_cliente;

	end if
--}

-- Arreglar Numeros que tenian 7 posiciones pero sin el guion separando los telefonos

{
	if _telefono1 is not null  then

		if _telefono1[1] between "0" and "9" and 
		   _telefono1[2] between "0" and "9" and
		   _telefono1[3] between "0" and "9" and
		   _telefono1[4] between "0" and "9" and
		   _telefono1[5] between "0" and "9" and
		   _telefono1[6] between "0" and "9" and
		   _telefono1[7] between "0" and "9" and
		   _telefono1[8]  = " " and
		   _telefono1[9]  = " " and
		   _telefono1[10] = " " then
		                 
			let _telefono1_t = _telefono1[1,3] || "-" || _telefono1[4,7];
			let _retornar = 1;

		end if

	end if

	if length(_telefono2) = 7 and
	   _telefono2 is not null  then

		if _telefono2[1] between "0" and "9" and 
		   _telefono2[2] between "0" and "9" and
		   _telefono2[3] between "0" and "9" and
		   _telefono2[4] between "0" and "9" and
		   _telefono2[5] between "0" and "9" and
		   _telefono2[6] between "0" and "9" and
		   _telefono2[7] between "0" and "9" and
		   _telefono2[8]  = " " and
		   _telefono2[9]  = " " and
		   _telefono2[10] = " " then

			let _telefono2_t = _telefono2[1,3] || "-" || _telefono2[4,7];
			let _retornar = 1;

		end if

	end if

	if length(_telefono3) = 7 and
	   _telefono3 is not null  then

		if _telefono3[1] between "0" and "9" and 
		   _telefono3[2] between "0" and "9" and
		   _telefono3[3] between "0" and "9" and
		   _telefono3[4] between "0" and "9" and
		   _telefono3[5] between "0" and "9" and
		   _telefono3[6] between "0" and "9" and
		   _telefono3[7] between "0" and "9" and
		   _telefono3[8]  = " " and
		   _telefono3[9]  = " " and
		   _telefono3[10] = " " then

			let _telefono3_t = _telefono3[1,3] || "-" || _telefono3[4,7];
			let _retornar = 1;

		end if

	end if

	if length(_celular) = 7 and
	   _celular is not null  then

		if _celular[1] between "0" and "9" and 
		   _celular[2] between "0" and "9" and
		   _celular[3] between "0" and "9" and
		   _celular[4] between "0" and "9" and
		   _celular[5] between "0" and "9" and
		   _celular[6] between "0" and "9" and
		   _celular[7] between "0" and "9" and
		   _celular[8]  = " " and
		   _celular[9]  = " " and
		   _celular[10] = " " then

			let _celular_t = _celular[1,3] || "-" || _celular[4,7];
			let _retornar = 1;

		end if

	end if

	if length(_fax) = 7 and
	   _fax is not null  then

		if _fax[1] between "0" and "9" and 
		   _fax[2] between "0" and "9" and
		   _fax[3] between "0" and "9" and
		   _fax[4] between "0" and "9" and
		   _fax[5] between "0" and "9" and
		   _fax[6] between "0" and "9" and
		   _fax[7] between "0" and "9" and
		   _fax[8]  = " " and
		   _fax[9]  = " " and
		   _fax[10] = " " then

			let _fax_t = _fax[1,3] || "-" || _fax[4,7];
			let _retornar = 1;

		end if

	end if

{
	if _retornar = 1 then

		update cliclien
		   set telefono1   = _telefono1_t,
               telefono2   = _telefono2_t,
		       telefono3   = _telefono3_t,
		       celular     = _celular_t,
		       fax		   = _fax_t
		 where cod_cliente = _cod_cliente;

	end if
--}

--}

-- Arreglar Numeros que comienzan con espacios
{
	if _telefono1 is not null  and
	   _telefono1[1] = " "     then
	   	let _telefono1_t = _telefono1[2,10];
		let _retornar = 1;
	end if

	if _telefono2 is not null  and
	   _telefono2[1] = " "     then
	   	let _telefono2_t = _telefono2[2,10];
		let _retornar = 1;
	end if

	if _telefono3 is not null  and
	   _telefono3[1] = " "     then
	   	let _telefono3_t = _telefono3[2,10];
		let _retornar = 1;
	end if

	if _celular is not null  and
	   _celular[1] = " "     then
	   	let _celular_t = _celular[2,10];
		let _retornar = 1;
	end if

	if _fax is not null  and
	   _fax[1] = " "     then
	   	let _fax_t = _fax[2,10];
		let _retornar = 1;
	end if

{
	if _retornar = 1 then

		update cliclien
		   set telefono1   = _telefono1_t,
               telefono2   = _telefono2_t,
		       telefono3   = _telefono3_t,
		       celular     = _celular_t,
		       fax		   = _fax_t
		 where cod_cliente = _cod_cliente;

	end if
--}

-- Arreglar (Poner Null) a Telefonos con espacios
{

if _telefono1 is not null    and
   _telefono1 = "          " then
	let _telefono1_t = null;
	let _retornar = 1;
end if

if _telefono2 is not null    and
   _telefono2 = "          " then
	let _telefono2_t = null;
	let _retornar = 1;
end if
if _telefono3 is not null    and
   _telefono3 = "          " then
	let _telefono3_t = null;
	let _retornar = 1;
end if
if _celular is not null    and
   _celular = "          " then
	let _celular_t   = null;
	let _retornar = 1;
end if
if _fax is not null    and
   _fax = "          " then
	let _fax_t       = null;
	let _retornar = 1;
end if

	if _retornar = 1 then

		update cliclien
		   set telefono1   = _telefono1_t,
               telefono2   = _telefono2_t,
		       telefono3   = _telefono3_t,
		       celular     = _celular_t,
		       fax		   = _fax_t
		 where cod_cliente = _cod_cliente;

	end if
--}

-- Arreglar (Poner Null) a Telefonos con una rayita
{

if _telefono1 is not null    and
   _telefono1 = "-         " then
	let _telefono1_t = null;
	let _retornar = 1;
end if

if _telefono2 is not null    and
   _telefono2 = "-         " then
	let _telefono2_t = null;
	let _retornar = 1;
end if
if _telefono3 is not null    and
   _telefono3 = "-         " then
	let _telefono3_t = null;
	let _retornar = 1;
end if
if _celular is not null    and
   _celular = "-         " then
	let _celular_t   = null;
	let _retornar = 1;
end if
if _fax is not null    and
   _fax = "-         " then
	let _fax_t       = null;
	let _retornar = 1;
end if

{
	if _retornar = 1 then

		update cliclien
		   set telefono1   = _telefono1_t,
               telefono2   = _telefono2_t,
		       telefono3   = _telefono3_t,
		       celular     = _celular_t,
		       fax		   = _fax_t
		 where cod_cliente = _cod_cliente;

	end if
--}

--}

-- Arreglar Numeros con dos rayitas de separador

{
	if _telefono1 is not null  then

		if _telefono1[1] between "0" and "9" and 
		   _telefono1[2] between "0" and "9" and
		   _telefono1[3] between "0" and "9" and
		   _telefono1[4] = "-" and
		   _telefono1[5] between "0" and "9" and
		   _telefono1[6] between "0" and "9" and
		   _telefono1[7] = "-" and
		   _telefono1[8] between "0" and "9" and
		   _telefono1[9] between "0" and "9" and
		   _telefono1[10] = " " then
		                 
			let _telefono1_t = _telefono1[1,6] || _telefono1[8,9];
			let _retornar = 1;

		end if

	end if

	if _telefono2 is not null  then

		if _telefono2[1] between "0" and "9" and 
		   _telefono2[2] between "0" and "9" and
		   _telefono2[3] between "0" and "9" and
		   _telefono2[4] = "-" and
		   _telefono2[5] between "0" and "9" and
		   _telefono2[6] between "0" and "9" and
		   _telefono2[7] = "-" and
		   _telefono2[8] between "0" and "9" and
		   _telefono2[9] between "0" and "9" and
		   _telefono2[10] = " " then

			let _telefono2_t = _telefono2[1,6] || _telefono2[8,9];
			let _retornar = 1;

		end if

	end if

	if _telefono3 is not null  then

		if _telefono3[1] between "0" and "9" and 
		   _telefono3[2] between "0" and "9" and
		   _telefono3[3] between "0" and "9" and
		   _telefono3[4] = "-" and
		   _telefono3[5] between "0" and "9" and
		   _telefono3[6] between "0" and "9" and
		   _telefono3[7] = "-" and
		   _telefono3[8] between "0" and "9" and
		   _telefono3[9] between "0" and "9" and
		   _telefono3[10] = " " then

			let _telefono3_t = _telefono3[1,6] || _telefono3[8,9];
			let _retornar = 1;

		end if

	end if

	if _celular is not null  then

		if _celular[1] between "0" and "9" and 
		   _celular[2] between "0" and "9" and
		   _celular[3] between "0" and "9" and
		   _celular[4] = "-" and
		   _celular[5] between "0" and "9" and
		   _celular[6] between "0" and "9" and
		   _celular[7] = "-" and
		   _celular[8] between "0" and "9" and
		   _celular[9] between "0" and "9" and
		   _celular[10] = " " then

			let _celular_t = _celular[1,6] || _celular[8,9];
			let _retornar = 1;

		end if

	end if

	if _fax is not null  then

		if _fax[1] between "0" and "9" and 
		   _fax[2] between "0" and "9" and
		   _fax[3] between "0" and "9" and
		   _fax[4] = "-" and
		   _fax[5] between "0" and "9" and
		   _fax[6] between "0" and "9" and
		   _fax[7] = "-" and
		   _fax[8] between "0" and "9" and
		   _fax[9] between "0" and "9" and
		   _fax[10] = " " then

			let _fax_t = _fax[1,6] || _fax[8,9];
			let _retornar = 1;

		end if

	end if

{
	if _retornar = 1 then

		update cliclien
		   set telefono1   = _telefono1_t,
               telefono2   = _telefono2_t,
		       telefono3   = _telefono3_t,
		       celular     = _celular_t,
		       fax		   = _fax_t
		 where cod_cliente = _cod_cliente;

	end if
--}

--}

-- Arreglar Numeros con espacio de separador

{
	if _telefono1 is not null  then

		if _telefono1[1] between "0" and "9" and 
		   _telefono1[2] between "0" and "9" and
		   _telefono1[3] between "0" and "9" and
		   _telefono1[4] = " " and
		   _telefono1[5] between "0" and "9" and
		   _telefono1[6] between "0" and "9" and
		   _telefono1[7] between "0" and "9" and
		   _telefono1[8] between "0" and "9" and
		   _telefono1[9]  = " " and
		   _telefono1[10] = " " then
		                 
			let _telefono1_t = _telefono1[1,3] || "-" || _telefono1[5,10];
			let _retornar = 1;

		end if

	end if

	if _telefono2 is not null  then

		if _telefono2[1] between "0" and "9" and 
		   _telefono2[2] between "0" and "9" and
		   _telefono2[3] between "0" and "9" and
		   _telefono2[4] = " " and
		   _telefono2[5] between "0" and "9" and
		   _telefono2[6] between "0" and "9" and
		   _telefono2[7] between "0" and "9" and
		   _telefono2[8] between "0" and "9" and
		   _telefono2[9]  = " " and
		   _telefono2[10] = " " then

			let _telefono2_t = _telefono2[1,3] || "-" || _telefono2[5,10];
			let _retornar = 1;

		end if

	end if

	if _telefono3 is not null  then

		if _telefono3[1] between "0" and "9" and 
		   _telefono3[2] between "0" and "9" and
		   _telefono3[3] between "0" and "9" and
		   _telefono3[4] = " " and
		   _telefono3[5] between "0" and "9" and
		   _telefono3[6] between "0" and "9" and
		   _telefono3[7] between "0" and "9" and
		   _telefono3[8] between "0" and "9" and
		   _telefono3[9]  = " " and
		   _telefono3[10] = " " then

			let _telefono3_t = _telefono3[1,3] || "-" || _telefono3[5,10];
			let _retornar = 1;

		end if

	end if

	if _celular is not null  then

		if _celular[1] between "0" and "9" and 
		   _celular[2] between "0" and "9" and
		   _celular[3] between "0" and "9" and
		   _celular[4] = " " and
		   _celular[5] between "0" and "9" and
		   _celular[6] between "0" and "9" and
		   _celular[7] between "0" and "9" and
		   _celular[8] between "0" and "9" and
		   _celular[9]  = " " and
		   _celular[10] = " " then

			let _celular_t = _celular[1,3] || "-" || _celular[5,10];
			let _retornar = 1;

		end if

	end if

	if _fax is not null  then

		if _fax[1] between "0" and "9" and 
		   _fax[2] between "0" and "9" and
		   _fax[3] between "0" and "9" and
		   _fax[4] = " " and
		   _fax[5] between "0" and "9" and
		   _fax[6] between "0" and "9" and
		   _fax[7] between "0" and "9" and
		   _fax[8] between "0" and "9" and
		   _fax[9]  = " " and
		   _fax[10] = " " then

			let _fax_t = _fax[1,3] || "-" || _fax[5,10];
			let _retornar = 1;

		end if

	end if

{
	if _retornar = 1 then

		update cliclien
		   set telefono1   = _telefono1_t,
               telefono2   = _telefono2_t,
		       telefono3   = _telefono3_t,
		       celular     = _celular_t,
		       fax		   = _fax_t
		 where cod_cliente = _cod_cliente;

	end if
--}

--}


-- Verificacion Total del Numero de Telefono
--{
if _telefono1 is not null then
	if _telefono1[1] not between "0" and "9" or 
	   _telefono1[2] not between "0" and "9" or
	   _telefono1[3] not between "0" and "9" or
	   _telefono1[4] <> "-" or
	   _telefono1[5] not between "0" and "9" or
	   _telefono1[6] not between "0" and "9" or
	   _telefono1[7] not between "0" and "9" or
	   _telefono1[8] not between "0" and "9" or
	   _telefono1[9] <> " " or
	   _telefono1[10] <> " " then
		let _retornar = 1;
	end if
end if
if _telefono2 is not null then
	if _telefono2[1] not between "0" and "9" or 
	   _telefono2[2] not between "0" and "9" or
	   _telefono2[3] not between "0" and "9" or
	   _telefono2[4] <> "-" or
	   _telefono2[5] not between "0" and "9" or
	   _telefono2[6] not between "0" and "9" or
	   _telefono2[7] not between "0" and "9" or
	   _telefono2[8] not between "0" and "9" or
	   _telefono2[9] <> " " or
	   _telefono2[10] <> " " then
		let _retornar = 1;
	end if
end if
if _telefono3 is not null then
	if _telefono3[1] not between "0" and "9" or 
	   _telefono3[2] not between "0" and "9" or
	   _telefono3[3] not between "0" and "9" or
	   _telefono3[4] <> "-" or
	   _telefono3[5] not between "0" and "9" or
	   _telefono3[6] not between "0" and "9" or
	   _telefono3[7] not between "0" and "9" or
	   _telefono3[8] not between "0" and "9" or
	   _telefono3[9] <> " " or
	   _telefono3[10] <> " " then
		let _retornar = 1;
	end if
end if
if _celular is not null then
	if _celular[1] not between "0" and "9" or 
	   _celular[2] not between "0" and "9" or
	   _celular[3] not between "0" and "9" or
	   _celular[4] <> "-" or
	   _celular[5] not between "0" and "9" or
	   _celular[6] not between "0" and "9" or
	   _celular[7] not between "0" and "9" or
	   _celular[8] not between "0" and "9" or
	   _celular[9] <> " " or
	   _celular[10] <> " " then
		let _retornar = 1;
	end if
end if
if _fax is not null then
	if _fax[1] not between "0" and "9" or 
	   _fax[2] not between "0" and "9" or
	   _fax[3] not between "0" and "9" or
	   _fax[4] <> "-" or
	   _fax[5] not between "0" and "9" or
	   _fax[6] not between "0" and "9" or
	   _fax[7] not between "0" and "9" or
	   _fax[8] not between "0" and "9" or
	   _fax[9] <> " " or
	   _fax[10] <> " " then
		let _retornar = 1;
	end if
end if
--}

	if _retornar = 1 then

		return _cod_cliente,
		       _telefono1,
	           _telefono2,
			   _telefono3,
			   _celular,
			   _fax
			   with resume;

{
	 	return "",
		       _telefono1_t,
	           _telefono2_t,
			   _telefono3_t,
			   _celular_t,
			   _fax_t
			   with resume;
--}
	end if

end foreach


end procedure
